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
        if ($request->has('from') && $request->has('to')) {
            $query->whereBetween('created_at', [$request->from, $request->to]);
        }

        $transactions = $query->latest()->paginate(config('default_pagination', 25));

        return view('admin-views.sip.transactions.index', compact('transactions'));
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

        $withdrawals = $query->latest()->paginate(config('default_pagination', 25));

        return view('admin-views.sip.withdrawals.index', compact('withdrawals'));
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

        return view('admin-views.sip.metal-rates.index', compact('rates', 'currentRates'));
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

        Toastr::success(translate('Metal rate updated successfully!'));
        return back();
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
