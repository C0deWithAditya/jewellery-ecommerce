<?php

namespace App\Http\Controllers;

use App\Models\PaymentRequest;
use App\Traits\Processor;
use App\Models\User;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class IciciPaymentController extends Controller
{
    use Processor;

    private PaymentRequest $payment;
    private $user;
    private $config;

    public function __construct(PaymentRequest $payment, User $user)
    {
        $config = $this->payment_config('icici_eazypay', 'payment_config');
        $icici = false;
        
        if (!is_null($config) && $config->mode == 'live') {
            $icici = json_decode($config->live_values);
        } elseif (!is_null($config) && $config->mode == 'test') {
            $icici = json_decode($config->test_values);
        }

        if ($icici) {
            $this->config = [
                'merchant_id' => $icici->merchant_id ?? '',
                'terminal_id' => $icici->terminal_id ?? '',
                'encryption_key' => $icici->encryption_key ?? '',
                'sub_merchant_id' => $icici->sub_merchant_id ?? '',
                'mode' => $config->mode ?? 'test',
            ];
            Config::set('icici_config', $this->config);
        }

        $this->payment = $payment;
        $this->user = $user;
    }

    /**
     * Display the ICICI payment page
     */
    public function index(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid'
        ]);

        if ($validator->fails()) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_400, null, $this->error_processor($validator)), 400);
        }

        $data = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        if (!isset($data)) {
            return response()->json($this->response_formatter(GATEWAYS_DEFAULT_204), 200);
        }
        
        $payer = json_decode($data['payer_information']);

        if ($data['additional_data'] != null) {
            $business = json_decode($data['additional_data']);
            $business_name = $business->business_name ?? "my_business";
            $business_logo = $business->business_logo ?? url('/');
        } else {
            $business_name = "my_business";
            $business_logo = url('/');
        }

        // Check if ICICI is configured
        if (empty($this->config) || empty($this->config['merchant_id'])) {
            return view('payment-gateway.icici-not-configured', compact('data', 'payer', 'business_logo', 'business_name'));
        }

        return view('payment-gateway.icici-pay', compact('data', 'payer', 'business_logo', 'business_name'));
    }

    /**
     * Initiate payment to ICICI Eazypay
     */
    public function initiatePayment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'payment_id' => 'required|uuid'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => 'Invalid payment ID'], 400);
        }

        $paymentData = $this->payment::where(['id' => $request['payment_id']])->where(['is_paid' => 0])->first();
        
        if (!$paymentData) {
            return response()->json(['error' => 'Payment not found or already processed'], 404);
        }

        $payer = json_decode($paymentData['payer_information']);
        
        // Generate unique reference number
        $referenceNo = 'ICICI' . time() . rand(1000, 9999);
        
        // Prepare payment parameters
        $amount = number_format($paymentData['payment_amount'], 2, '.', '');
        
        $params = [
            'merchantid' => $this->config['merchant_id'],
            'mandatory fields' => $referenceNo . '|' . $this->config['sub_merchant_id'] . '|' . $amount,
            'optional fields' => '',
            'returnurl' => route('icici.callback'),
            'Reference No' => $referenceNo,
            'submerchantid' => $this->config['sub_merchant_id'],
            'transaction amount' => $amount,
            'paymode' => 9, // All payment modes
        ];

        // Store reference for callback
        $paymentData->update([
            'transaction_id' => $referenceNo,
        ]);

        // Encrypt and redirect to ICICI
        $encryptedString = $this->encryptData($params);
        
        $baseUrl = $this->config['mode'] == 'live' 
            ? config('icici.live_url') 
            : config('icici.test_url');

        return redirect($baseUrl . '?encdata=' . urlencode($encryptedString));
    }

    /**
     * Handle ICICI payment callback
     */
    public function callback(Request $request)
    {
        Log::info('ICICI Payment Callback', $request->all());

        try {
            // Decrypt response
            $response = $this->decryptData($request->input('encdata'));
            
            $referenceNo = $response['Reference No'] ?? null;
            $status = $response['Response Code'] ?? null;
            $iciciRefNo = $response['Unique Ref Number'] ?? null;
            
            $paymentData = $this->payment::where('transaction_id', $referenceNo)->first();
            
            if (!$paymentData) {
                Log::error('ICICI Payment: Transaction not found', ['ref' => $referenceNo]);
                return redirect()->route('payment-fail');
            }

            if ($status == 'E000') { // Success code for ICICI
                $paymentData->update([
                    'payment_method' => 'icici_eazypay',
                    'is_paid' => 1,
                    'transaction_id' => $iciciRefNo ?? $referenceNo,
                ]);

                if (function_exists($paymentData->success_hook)) {
                    call_user_func($paymentData->success_hook, $paymentData);
                }

                return $this->payment_response($paymentData, 'success');
            } else {
                if (function_exists($paymentData->failure_hook)) {
                    call_user_func($paymentData->failure_hook, $paymentData);
                }

                Log::error('ICICI Payment Failed', ['response' => $response]);
                return $this->payment_response($paymentData, 'fail');
            }
        } catch (\Exception $e) {
            Log::error('ICICI Payment Callback Error', ['error' => $e->getMessage()]);
            return redirect()->route('payment-fail');
        }
    }

    /**
     * Encrypt data for ICICI Eazypay
     */
    private function encryptData($data): string
    {
        $key = $this->config['encryption_key'];
        $plainText = http_build_query($data);
        
        // ICICI uses AES-128-CBC encryption
        $ivSize = openssl_cipher_iv_length('AES-128-CBC');
        $iv = openssl_random_pseudo_bytes($ivSize);
        
        $encrypted = openssl_encrypt(
            $plainText,
            'AES-128-CBC',
            $key,
            OPENSSL_RAW_DATA,
            $iv
        );
        
        return base64_encode($iv . $encrypted);
    }

    /**
     * Decrypt data from ICICI Eazypay
     */
    private function decryptData($encryptedData): array
    {
        $key = $this->config['encryption_key'];
        $data = base64_decode($encryptedData);
        
        $ivSize = openssl_cipher_iv_length('AES-128-CBC');
        $iv = substr($data, 0, $ivSize);
        $encrypted = substr($data, $ivSize);
        
        $decrypted = openssl_decrypt(
            $encrypted,
            'AES-128-CBC',
            $key,
            OPENSSL_RAW_DATA,
            $iv
        );
        
        parse_str($decrypted, $result);
        return $result;
    }
}
