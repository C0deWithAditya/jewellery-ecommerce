<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use App\Models\SipPlan;
use App\Models\UserSip;
use App\Models\SipTransaction;
use App\Models\SipWithdrawal;
use App\Models\MetalRate;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class SipController extends Controller
{
    /**
     * Get current metal rates.
     */
    public function getMetalRates()
    {
        $rates = MetalRate::current()->get()->map(function($rate) {
            return [
                'metal_type' => $rate->metal_type,
                'purity' => $rate->purity,
                'rate_per_gram' => $rate->rate_per_gram,
                'rate_per_10gram' => $rate->rate_per_10gram,
                'currency' => $rate->currency,
                'updated_at' => $rate->updated_at,
            ];
        });

        return response()->json([
            'status' => true,
            'data' => $rates,
        ]);
    }

    /**
     * Get available SIP plans.
     */
    public function getPlans()
    {
        $plans = SipPlan::active()->get()->map(function($plan) {
            return [
                'id' => $plan->id,
                'name' => $plan->name,
                'description' => $plan->description,
                'frequency' => $plan->frequency,
                'frequency_label' => $plan->frequency_label,
                'min_amount' => $plan->min_amount,
                'max_amount' => $plan->max_amount,
                'duration_months' => $plan->duration_months,
                'bonus_months' => $plan->bonus_months,
                'total_duration' => $plan->total_duration,
                'bonus_percentage' => $plan->bonus_percentage,
                'metal_type' => $plan->metal_type,
                'gold_purity' => $plan->gold_purity,
                'amount_range' => $plan->amount_range,
            ];
        });

        return response()->json([
            'status' => true,
            'data' => $plans,
        ]);
    }

    /**
     * Get user's KYC status.
     */
    public function getKycStatus(Request $request)
    {
        $user = $request->user();
        $kyc = KycDocument::where('user_id', $user->id)->latest()->first();

        return response()->json([
            'status' => true,
            'data' => [
                'has_kyc' => $kyc !== null,
                'kyc_status' => $kyc ? $kyc->status : null,
                'is_approved' => $kyc ? $kyc->isApproved() : false,
                'rejection_reason' => $kyc ? $kyc->rejection_reason : null,
                'document_type' => $kyc ? $kyc->document_type : null,
            ],
        ]);
    }

    /**
     * Submit KYC documents.
     */
    public function submitKyc(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'document_type' => 'required|in:pan,aadhar,passport,voter_id',
            'document_number' => 'required|string|max:50',
            'document_front' => 'required|image|mimes:jpg,jpeg,png|max:2048',
            'document_back' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Check if user already has pending or approved KYC
        $existingKyc = KycDocument::where('user_id', $user->id)
            ->whereIn('status', ['pending', 'approved'])
            ->first();

        if ($existingKyc) {
            return response()->json([
                'status' => false,
                'message' => $existingKyc->status === 'approved' 
                    ? 'Your KYC is already approved' 
                    : 'You already have a pending KYC submission',
            ], 400);
        }

        // Upload documents
        $frontImage = $request->file('document_front');
        $frontName = 'kyc_' . $user->id . '_front_' . time() . '.' . $frontImage->extension();
        Storage::disk('public')->putFileAs('kyc', $frontImage, $frontName);

        $backName = null;
        if ($request->hasFile('document_back')) {
            $backImage = $request->file('document_back');
            $backName = 'kyc_' . $user->id . '_back_' . time() . '.' . $backImage->extension();
            Storage::disk('public')->putFileAs('kyc', $backImage, $backName);
        }

        $kyc = KycDocument::create([
            'user_id' => $user->id,
            'document_type' => $request->document_type,
            'document_number' => $request->document_number,
            'document_front_image' => $frontName,
            'document_back_image' => $backName,
            'status' => KycDocument::STATUS_PENDING,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'KYC submitted successfully. It will be reviewed within 24-48 hours.',
            'data' => [
                'kyc_id' => $kyc->id,
                'status' => $kyc->status,
            ],
        ]);
    }

    /**
     * Subscribe to a SIP plan.
     */
    public function subscribe(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'plan_id' => 'required|exists:sip_plans,id',
            'monthly_amount' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $plan = SipPlan::findOrFail($request->plan_id);

        // Check KYC status
        $kyc = KycDocument::where('user_id', $user->id)
            ->where('status', 'approved')
            ->first();

        if (!$kyc) {
            return response()->json([
                'status' => false,
                'message' => 'Please complete KYC verification before subscribing to a SIP',
            ], 400);
        }

        // Validate amount
        if ($request->monthly_amount < $plan->min_amount || $request->monthly_amount > $plan->max_amount) {
            return response()->json([
                'status' => false,
                'message' => 'Amount must be between ₹' . $plan->min_amount . ' and ₹' . $plan->max_amount,
            ], 400);
        }

        // Check for existing active SIP with same plan
        $existingSip = UserSip::where('user_id', $user->id)
            ->where('sip_plan_id', $plan->id)
            ->where('status', 'active')
            ->first();

        if ($existingSip) {
            return response()->json([
                'status' => false,
                'message' => 'You already have an active SIP with this plan',
            ], 400);
        }

        // Create SIP subscription
        $startDate = now();
        $totalInstallments = $plan->duration_months + $plan->bonus_months;

        $userSip = UserSip::create([
            'user_id' => $user->id,
            'sip_plan_id' => $plan->id,
            'monthly_amount' => $request->monthly_amount,
            'start_date' => $startDate,
            'end_date' => $startDate->copy()->addMonths($plan->duration_months),
            'next_payment_date' => $startDate,
            'installments_paid' => 0,
            'installments_pending' => $totalInstallments,
            'status' => UserSip::STATUS_ACTIVE,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'SIP subscription created successfully',
            'data' => [
                'sip_id' => $userSip->id,
                'plan_name' => $plan->name,
                'monthly_amount' => $userSip->monthly_amount,
                'start_date' => $userSip->start_date->format('Y-m-d'),
                'end_date' => $userSip->end_date->format('Y-m-d'),
                'total_installments' => $totalInstallments,
            ],
        ]);
    }

    /**
     * Get user's SIP subscriptions.
     */
    public function getMySips(Request $request)
    {
        $user = $request->user();
        
        $sips = UserSip::with('sipPlan')
            ->where('user_id', $user->id)
            ->latest()
            ->get()
            ->map(function($sip) {
                $currentRate = MetalRate::getCurrentRate(
                    $sip->sipPlan->metal_type, 
                    $sip->sipPlan->gold_purity
                );
                
                return [
                    'id' => $sip->id,
                    'plan_name' => $sip->sipPlan->name,
                    'monthly_amount' => $sip->monthly_amount,
                    'total_invested' => $sip->total_invested,
                    'total_gold_grams' => round($sip->total_gold_grams, 4),
                    'current_value' => $currentRate ? round($sip->total_gold_grams * $currentRate, 2) : null,
                    'progress_percentage' => $sip->progress_percentage,
                    'installments_paid' => $sip->installments_paid,
                    'installments_pending' => $sip->installments_pending,
                    'next_payment_date' => $sip->next_payment_date?->format('Y-m-d'),
                    'status' => $sip->status,
                    'metal_type' => $sip->sipPlan->metal_type,
                    'gold_purity' => $sip->sipPlan->gold_purity,
                ];
            });

        return response()->json([
            'status' => true,
            'data' => $sips,
        ]);
    }

    /**
     * Get SIP transaction history.
     */
    public function getTransactions(Request $request, $sipId = null)
    {
        $user = $request->user();
        
        $query = SipTransaction::with('userSip.sipPlan')
            ->where('user_id', $user->id);

        if ($sipId) {
            $query->where('user_sip_id', $sipId);
        }

        $transactions = $query->latest()
            ->paginate(20)
            ->through(function($txn) {
                return [
                    'id' => $txn->id,
                    'amount' => $txn->amount,
                    'gold_rate' => $txn->gold_rate,
                    'gold_grams' => round($txn->gold_grams, 4),
                    'status' => $txn->status,
                    'payment_method' => $txn->payment_method,
                    'installment_number' => $txn->installment_number,
                    'date' => $txn->created_at->format('Y-m-d H:i:s'),
                    'plan_name' => $txn->userSip->sipPlan->name ?? 'N/A',
                ];
            });

        return response()->json([
            'status' => true,
            'data' => $transactions,
        ]);
    }

    /**
     * Request withdrawal.
     */
    public function requestWithdrawal(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'sip_id' => 'required|exists:user_sips,id',
            'withdrawal_type' => 'required|in:gold_delivery,cash_redemption',
            'gold_grams' => 'required|numeric|min:0.1',
            'delivery_address' => 'required_if:withdrawal_type,gold_delivery|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $sip = UserSip::where('id', $request->sip_id)
            ->where('user_id', $user->id)
            ->whereIn('status', ['active', 'completed'])
            ->first();

        if (!$sip) {
            return response()->json([
                'status' => false,
                'message' => 'SIP not found or not eligible for withdrawal',
            ], 404);
        }

        // Check available gold
        if ($request->gold_grams > $sip->total_gold_grams) {
            return response()->json([
                'status' => false,
                'message' => 'Insufficient gold balance. Available: ' . $sip->total_gold_grams . 'g',
            ], 400);
        }

        // Calculate cash amount for cash redemption
        $cashAmount = null;
        $goldRate = null;
        if ($request->withdrawal_type === 'cash_redemption') {
            $goldRate = MetalRate::getCurrentRate($sip->sipPlan->metal_type, $sip->sipPlan->gold_purity);
            $cashAmount = $request->gold_grams * $goldRate;
        }

        $withdrawal = SipWithdrawal::create([
            'user_sip_id' => $sip->id,
            'user_id' => $user->id,
            'withdrawal_type' => $request->withdrawal_type,
            'gold_grams' => $request->gold_grams,
            'gold_rate' => $goldRate,
            'cash_amount' => $cashAmount,
            'delivery_address' => $request->delivery_address,
            'status' => SipWithdrawal::STATUS_PENDING,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Withdrawal request submitted successfully',
            'data' => [
                'withdrawal_id' => $withdrawal->id,
                'gold_grams' => $withdrawal->gold_grams,
                'estimated_cash' => $cashAmount,
                'status' => $withdrawal->status,
            ],
        ]);
    }
}
