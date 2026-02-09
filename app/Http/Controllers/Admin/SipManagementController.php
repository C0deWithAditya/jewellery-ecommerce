<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\UserSip;
use App\Models\SipTransaction;
use App\Models\SipWithdrawal;
use App\Models\MetalRate;
use Illuminate\Http\Request;
use Brian2694\Toastr\Facades\Toastr;
use Carbon\Carbon;

class SipManagementController extends Controller
{
    /**
     * Display SIP dashboard with statistics.
     */
    public function dashboard()
    {
        $stats = [
            'total_sips' => UserSip::count(),
            'active_sips' => UserSip::active()->count(),
            'completed_sips' => UserSip::where('status', 'completed')->count(),
            'total_invested' => UserSip::sum('total_invested'),
            'total_gold_grams' => UserSip::sum('total_gold_grams'),
            'pending_payments' => UserSip::dueToday()->count(),
            'pending_kyc' => \App\Models\KycDocument::pending()->count(),
            'pending_withdrawals' => SipWithdrawal::pending()->count(),
        ];

        // Recent transactions
        $recentTransactions = SipTransaction::with(['user', 'userSip'])
            ->latest()
            ->take(10)
            ->get();

        // Current metal rates
        $currentRates = MetalRate::current()->get();

        return view('admin-views.sip.dashboard', compact('stats', 'recentTransactions', 'currentRates'));
    }

    /**
     * Display a listing of user SIPs.
     */
    public function subscriptions(Request $request)
    {
        $query = UserSip::with(['user', 'sipPlan']);

        // Filter by status
        if ($request->has('status') && !empty($request->status)) {
            $query->where('status', $request->status);
        }

        // Search
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->whereHas('user', function($q) use ($search) {
                $q->where('f_name', 'like', '%' . $search . '%')
                  ->orWhere('l_name', 'like', '%' . $search . '%')
                  ->orWhere('email', 'like', '%' . $search . '%');
            });
        }

        $subscriptions = $query->latest()->paginate(config('default_pagination', 25));

        return view('admin-views.sip.subscriptions.index', compact('subscriptions'));
    }

    /**
     * Show subscription details.
     */
    public function showSubscription($id)
    {
        $subscription = UserSip::with(['user', 'sipPlan', 'transactions'])->findOrFail($id);
        return view('admin-views.sip.subscriptions.show', compact('subscription'));
    }

    /**
     * Display all SIP transactions.
     */
    public function transactions(Request $request)
    {
        $query = SipTransaction::with(['user', 'userSip.sipPlan']);

        // Filter by status
        if ($request->has('status') && !empty($request->status)) {
            $query->where('status', $request->status);
        }

        // Date filter
        if ($request->has('from_date') && !empty($request->from_date)) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }
        if ($request->has('to_date') && !empty($request->to_date)) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        // Search
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->whereHas('user', function($q) use ($search) {
                $q->where('f_name', 'like', '%' . $search . '%')
                  ->orWhere('l_name', 'like', '%' . $search . '%');
            });
        }

        $transactions = $query->latest()->paginate(config('default_pagination', 25));

        // Stats
        $stats = [
            'total' => SipTransaction::count(),
            'success' => SipTransaction::where('status', 'success')->count(),
            'pending' => SipTransaction::where('status', 'pending')->count(),
            'failed' => SipTransaction::where('status', 'failed')->count(),
            'total_amount' => SipTransaction::where('status', 'success')->sum('amount'),
            'total_gold' => SipTransaction::where('status', 'success')->sum('gold_grams'),
        ];

        return view('admin-views.sip.transactions.index', compact('transactions', 'stats'));
    }

    /**
     * Display withdrawal requests.
     */
    public function withdrawals(Request $request)
    {
        $query = SipWithdrawal::with(['user', 'userSip']);

        // Filter by status
        if ($request->has('status') && !empty($request->status)) {
            $query->where('status', $request->status);
        }

        // Filter by type
        if ($request->has('type') && !empty($request->type)) {
            $query->where('withdrawal_type', $request->type);
        }

        // Search
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->whereHas('user', function($q) use ($search) {
                $q->where('f_name', 'like', '%' . $search . '%')
                  ->orWhere('l_name', 'like', '%' . $search . '%')
                  ->orWhere('phone', 'like', '%' . $search . '%');
            });
        }

        $withdrawals = $query->latest()->paginate(config('default_pagination', 25));

        // Stats
        $stats = [
            'pending' => SipWithdrawal::where('status', 'pending')->count(),
            'processing' => SipWithdrawal::where('status', 'processing')->count(),
            'completed' => SipWithdrawal::where('status', 'completed')->count(),
            'rejected' => SipWithdrawal::where('status', 'rejected')->count(),
        ];

        return view('admin-views.sip.withdrawals.index', compact('withdrawals', 'stats'));
    }

    /**
     * Process a withdrawal request.
     */
    public function processWithdrawal(Request $request, $id)
    {
        $withdrawal = SipWithdrawal::findOrFail($id);

        $request->validate([
            'status' => 'required|in:processing,completed,rejected',
            'admin_notes' => 'nullable|string',
            'tracking_number' => 'nullable|string',
        ]);

        $withdrawal->update([
            'status' => $request->status,
            'admin_notes' => $request->admin_notes,
            'tracking_number' => $request->tracking_number,
        ]);

        Toastr::success(translate('Withdrawal status updated!'));
        return back();
    }

    /**
     * Metal rates management.
     */
    public function metalRates(Request $request)
    {
        $rates = MetalRate::orderBy('metal_type')
            ->orderBy('purity')
            ->orderByDesc('created_at')
            ->paginate(50);

        $currentRates = MetalRate::current()->get();

        // Get API settings from business_settings
        $apiSettings = $this->getMetalApiSettings();

        return view('admin-views.sip.metal-rates.index', compact('rates', 'currentRates', 'apiSettings'));
    }

    /**
     * Get Metal API settings from database.
     */
    private function getMetalApiSettings()
    {
        $settings = \App\Model\BusinessSetting::where('key', 'metal_price_api')->first();
        
        if ($settings && !empty($settings->value)) {
            $data = json_decode($settings->value, true);
            return [
                'api_key' => $data['api_key'] ?? '',
                'enabled' => $data['enabled'] ?? false,
                'sync_interval' => $data['sync_interval'] ?? 5,
                'last_synced' => $data['last_synced'] ?? null,
            ];
        }

        return [
            'api_key' => '',
            'enabled' => false,
            'sync_interval' => 5,
            'last_synced' => null,
        ];
    }

    /**
     * Save Metal API settings.
     */
    public function saveApiSettings(Request $request)
    {
        $request->validate([
            'api_key' => 'nullable|string|max:100',
            'sync_interval' => 'nullable|integer|in:5,15,30,60',
        ]);

        $settings = [
            'api_key' => $request->api_key,
            'enabled' => $request->has('api_enabled') ? true : false,
            'sync_interval' => $request->sync_interval ?? 5,
            'last_synced' => $this->getMetalApiSettings()['last_synced'],
        ];

        \App\Model\BusinessSetting::updateOrCreate(
            ['key' => 'metal_price_api'],
            ['value' => json_encode($settings)]
        );

        Toastr::success(translate('API settings saved successfully!'));
        return back();
    }

    /**
     * Test Metal API connection.
     */
    public function testApiConnection()
    {
        try {
            $settings = $this->getMetalApiSettings();
            
            if (empty($settings['api_key'])) {
                return response()->json([
                    'success' => false,
                    'message' => translate('API key is not configured'),
                ]);
            }

            // Test API call
            $response = \Illuminate\Support\Facades\Http::timeout(15)->get('https://api.metalpriceapi.com/v1/latest', [
                'api_key' => $settings['api_key'],
                'base' => 'INR',
                'currencies' => 'XAU,XAG,XPT',
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if (isset($data['success']) && $data['success']) {
                    $rates = $data['rates'] ?? [];
                    
                    // Convert rates to per gram (API returns per troy ounce)
                    $goldRate = isset($rates['INRXAU']) ? ($rates['INRXAU'] / 31.1035) : null;
                    $silverRate = isset($rates['INRXAG']) ? ($rates['INRXAG'] / 31.1035) : null;
                    $platinumRate = isset($rates['INRXPT']) ? ($rates['INRXPT'] / 31.1035) : null;

                    return response()->json([
                        'success' => true,
                        'message' => translate('API connection successful'),
                        'data' => [
                            'gold' => $goldRate ? number_format($goldRate, 2) : 'N/A',
                            'silver' => $silverRate ? number_format($silverRate, 2) : 'N/A',
                            'platinum' => $platinumRate ? number_format($platinumRate, 2) : 'N/A',
                        ],
                    ]);
                } else {
                    return response()->json([
                        'success' => false,
                        'message' => $data['error']['info'] ?? translate('Invalid API response'),
                    ]);
                }
            } else {
                return response()->json([
                    'success' => false,
                    'message' => translate('API request failed with status: ') . $response->status(),
                ]);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => translate('Error: ') . $e->getMessage(),
            ]);
        }
    }

    /**
     * Update metal rate.
     */
    public function updateMetalRate(Request $request)
    {
        $request->validate([
            'metal_type' => 'required|in:gold,silver,platinum',
            'purity' => 'required|string',
            'rate_per_gram' => 'required|numeric|min:0',
        ]);

        MetalRate::updateRate(
            $request->metal_type,
            $request->purity,
            $request->rate_per_gram,
            'manual'
        );

        // Update all product prices if checkbox is checked
        if ($request->has('update_products')) {
            $this->recalculateProductPrices($request->metal_type, $request->purity);
        }

        Toastr::success(translate('Metal rate updated successfully!'));
        return back();
    }

    /**
     * Recalculate all product prices for a given metal type and purity.
     */
    private function recalculateProductPrices($metalType, $purity)
    {
        try {
            $metalPriceService = app(\App\Services\MetalPriceService::class);
            
            // Get all products with dynamic pricing enabled for this metal type and purity
            $products = \App\Model\Product::where('is_price_dynamic', true)
                ->where('metal_type', $metalType)
                ->where('metal_purity', $purity)
                ->where('net_weight', '>', 0)
                ->get();

            $updatedCount = 0;
            foreach ($products as $product) {
                $priceResult = $metalPriceService->calculateProductPrice(
                    $product->metal_type,
                    $product->metal_purity,
                    $product->net_weight,
                    $product->making_charges,
                    $product->making_charge_type ?? 'fixed',
                    $product->stone_charges ?? 0,
                    3 // GST percentage
                );

                if ($priceResult['success']) {
                    $product->price = $priceResult['breakdown']['total_price'] + ($product->other_charges ?? 0);
                    $product->save();
                    $updatedCount++;
                }
            }

            if ($updatedCount > 0) {
                Toastr::info(translate('Updated prices for ') . $updatedCount . translate(' products.'));
            }
        } catch (\Exception $e) {
            Toastr::warning(translate('Could not update product prices: ') . $e->getMessage());
        }
    }

    /**
     * Sync metal rates from API.
     */
    public function syncMetalRates()
    {
        try {
            $settings = $this->getMetalApiSettings();
            
            if (!$settings['enabled']) {
                Toastr::warning(translate('API is disabled. Enable it first to sync rates.'));
                return back();
            }

            if (empty($settings['api_key'])) {
                Toastr::error(translate('API key is not configured.'));
                return back();
            }

            $metalPriceService = app(\App\Services\MetalPriceService::class);
            $result = $metalPriceService->syncRatesToDatabase();

            if ($result['success']) {
                // Update last synced time
                $settings['last_synced'] = Carbon::now()->format('d M Y, h:i A');
                \App\Model\BusinessSetting::updateOrCreate(
                    ['key' => 'metal_price_api'],
                    ['value' => json_encode($settings)]
                );

                // Recalculate all product prices with dynamic pricing enabled
                $this->recalculateAllDynamicProductPrices();

                Toastr::success($result['message'] . ' - ' . count($result['updated']) . ' rates updated.');
            } else {
                Toastr::error($result['message']);
            }
        } catch (\Exception $e) {
            Toastr::error(translate('Failed to sync rates: ') . $e->getMessage());
        }

        return back();
    }

    /**
     * Recalculate all products with dynamic pricing enabled.
     */
    private function recalculateAllDynamicProductPrices()
    {
        try {
            $metalPriceService = app(\App\Services\MetalPriceService::class);
            
            $products = \App\Model\Product::where('is_price_dynamic', true)
                ->where('metal_type', '!=', 'none')
                ->where('net_weight', '>', 0)
                ->get();

            $updatedCount = 0;
            foreach ($products as $product) {
                $priceResult = $metalPriceService->calculateProductPrice(
                    $product->metal_type,
                    $product->metal_purity,
                    $product->net_weight,
                    $product->making_charges,
                    $product->making_charge_type ?? 'fixed',
                    $product->stone_charges ?? 0,
                    3
                );

                if ($priceResult['success']) {
                    $product->price = $priceResult['breakdown']['total_price'] + ($product->other_charges ?? 0);
                    $product->save();
                    $updatedCount++;
                }
            }

            if ($updatedCount > 0) {
                Toastr::info(translate('Recalculated prices for ') . $updatedCount . translate(' products.'));
            }
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Product price recalculation failed: ' . $e->getMessage());
        }
    }

    /**
     * Export SIP data.
     */
    public function export(Request $request)
    {
        $type = $request->type ?? 'subscriptions';
        
        // Implementation for CSV export
        // ...

        Toastr::info(translate('Export functionality coming soon!'));
        return back();
    }
}

