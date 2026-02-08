<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SipPlan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Brian2694\Toastr\Facades\Toastr;

class SipPlanController extends Controller
{
    /**
     * Display a listing of SIP plans.
     */
    public function index(Request $request)
    {
        $query = SipPlan::query();

        // Search
        if ($request->has('search') && !empty($request->search)) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        // Filter by metal type
        if ($request->has('metal_type') && !empty($request->metal_type)) {
            $query->where('metal_type', $request->metal_type);
        }

        // Filter by status
        if ($request->has('status')) {
            $query->where('is_active', $request->status == 'active');
        }

        $plans = $query->orderBy('sort_order')->paginate(config('default_pagination', 25));

        return view('admin-views.sip.plan.index', compact('plans'));
    }

    /**
     * Show the form for creating a new SIP plan.
     */
    public function create()
    {
        return view('admin-views.sip.plan.create');
    }

    /**
     * Store a newly created SIP plan.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'frequency' => 'required|in:daily,weekly,monthly',
            'min_amount' => 'required|numeric|min:0',
            'max_amount' => 'required|numeric|gt:min_amount',
            'duration_months' => 'required|integer|min:1',
            'bonus_months' => 'nullable|integer|min:0',
            'bonus_percentage' => 'nullable|numeric|min:0|max:100',
            'metal_type' => 'required|in:gold,silver,platinum',
            'gold_purity' => 'required_if:metal_type,gold|in:24k,22k,18k',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        SipPlan::create([
            'name' => $request->name,
            'description' => $request->description,
            'frequency' => $request->frequency,
            'min_amount' => $request->min_amount,
            'max_amount' => $request->max_amount,
            'duration_months' => $request->duration_months,
            'bonus_months' => $request->bonus_months ?? 0,
            'bonus_percentage' => $request->bonus_percentage ?? 0,
            'metal_type' => $request->metal_type,
            'gold_purity' => $request->gold_purity ?? '22k',
            'is_active' => $request->has('is_active'),
            'sort_order' => $request->sort_order ?? 0,
        ]);

        Toastr::success(translate('SIP Plan created successfully!'));
        return redirect()->route('admin.sip.plan.index');
    }

    /**
     * Show the form for editing the specified SIP plan.
     */
    public function edit($id)
    {
        $plan = SipPlan::findOrFail($id);
        return view('admin-views.sip.plan.edit', compact('plan'));
    }

    /**
     * Update the specified SIP plan.
     */
    public function update(Request $request, $id)
    {
        $plan = SipPlan::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'frequency' => 'required|in:daily,weekly,monthly',
            'min_amount' => 'required|numeric|min:0',
            'max_amount' => 'required|numeric|gt:min_amount',
            'duration_months' => 'required|integer|min:1',
            'bonus_months' => 'nullable|integer|min:0',
            'bonus_percentage' => 'nullable|numeric|min:0|max:100',
            'metal_type' => 'required|in:gold,silver,platinum',
            'gold_purity' => 'required_if:metal_type,gold|in:24k,22k,18k',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $plan->update([
            'name' => $request->name,
            'description' => $request->description,
            'frequency' => $request->frequency,
            'min_amount' => $request->min_amount,
            'max_amount' => $request->max_amount,
            'duration_months' => $request->duration_months,
            'bonus_months' => $request->bonus_months ?? 0,
            'bonus_percentage' => $request->bonus_percentage ?? 0,
            'metal_type' => $request->metal_type,
            'gold_purity' => $request->gold_purity ?? '22k',
            'is_active' => $request->has('is_active'),
            'sort_order' => $request->sort_order ?? 0,
        ]);

        Toastr::success(translate('SIP Plan updated successfully!'));
        return redirect()->route('admin.sip.plan.index');
    }

    /**
     * Toggle the status of the specified SIP plan.
     */
    public function toggleStatus($id)
    {
        $plan = SipPlan::findOrFail($id);
        $plan->update(['is_active' => !$plan->is_active]);

        Toastr::success(translate('SIP Plan status updated!'));
        return back();
    }

    /**
     * Remove the specified SIP plan.
     */
    public function destroy($id)
    {
        $plan = SipPlan::findOrFail($id);
        
        // Check if plan has active subscriptions
        if ($plan->userSips()->where('status', 'active')->exists()) {
            Toastr::error(translate('Cannot delete plan with active subscriptions!'));
            return back();
        }

        $plan->delete();

        Toastr::success(translate('SIP Plan deleted successfully!'));
        return redirect()->route('admin.sip.plan.index');
    }
}
