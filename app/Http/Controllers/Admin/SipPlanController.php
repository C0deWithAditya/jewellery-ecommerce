<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SipPlan;
use App\Models\SipSchemeReward;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Brian2694\Toastr\Facades\Toastr;

class SipPlanController extends Controller
{
    /**
     * Display a listing of SIP plans.
     */
    public function index(Request $request)
    {
        $query = SipPlan::withCount(['userSips', 'rewards']);

        // Search
        if ($request->has('search') && !empty($request->search)) {
            $query->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('scheme_code', 'like', '%' . $request->search . '%');
        }

        // Filter by metal type
        if ($request->has('metal_type') && !empty($request->metal_type)) {
            $query->where('metal_type', $request->metal_type);
        }

        // Filter by scheme type
        if ($request->has('scheme_type') && !empty($request->scheme_type)) {
            $query->where('scheme_type', $request->scheme_type);
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
            'scheme_code' => 'nullable|string|max:50|unique:sip_plans',
            'display_name' => 'nullable|string|max:255',
            'tagline' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'frequency' => 'required|in:daily,weekly,monthly',
            'min_amount' => 'required|numeric|min:0',
            'max_amount' => 'required|numeric|gte:min_amount',
            'amount_increment' => 'nullable|numeric|min:0',
            'duration_months' => 'required|integer|min:1',
            'maturity_days' => 'nullable|integer|min:1',
            'redemption_window_days' => 'nullable|integer|min:1',
            'bonus_months' => 'nullable|integer|min:0',
            'bonus_percentage' => 'nullable|numeric|min:0|max:100',
            'gold_making_discount' => 'nullable|numeric|min:0|max:100',
            'diamond_making_discount' => 'nullable|numeric|min:0|max:100',
            'silver_making_discount' => 'nullable|numeric|min:0|max:100',
            'metal_type' => 'required|in:gold,silver,platinum',
            'gold_purity' => 'required_if:metal_type,gold|in:24k,22k,18k',
            'scheme_type' => 'required|in:super_gold,swarna_suraksha,flexi_save,regular',
            'color_code' => 'nullable|string|max:7',
            'banner_image' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        // Handle banner image upload
        $bannerImage = null;
        if ($request->hasFile('banner_image')) {
            $bannerImage = $request->file('banner_image')->store('sip-schemes', 'public');
        }

        // Parse benefits from textarea
        $benefits = array_filter(array_map('trim', explode("\n", $request->benefits ?? '')));

        SipPlan::create([
            'name' => $request->name,
            'scheme_code' => $request->scheme_code,
            'display_name' => $request->display_name,
            'tagline' => $request->tagline,
            'banner_image' => $bannerImage,
            'color_code' => $request->color_code ?? '#f5af19',
            'description' => $request->description,
            'frequency' => $request->frequency,
            'min_amount' => $request->min_amount,
            'max_amount' => $request->max_amount,
            'amount_increment' => $request->amount_increment ?? 500,
            'duration_months' => $request->duration_months,
            'maturity_days' => $request->maturity_days ?? ($request->duration_months * 30),
            'redemption_window_days' => $request->redemption_window_days ?? 35,
            'bonus_months' => $request->bonus_months ?? 0,
            'bonus_percentage' => $request->bonus_percentage ?? 0,
            'gold_making_discount' => $request->gold_making_discount ?? 0,
            'diamond_making_discount' => $request->diamond_making_discount ?? 0,
            'silver_making_discount' => $request->silver_making_discount ?? 0,
            'has_lucky_draw' => $request->has('has_lucky_draw'),
            'premium_reward' => $request->premium_reward,
            'is_refundable' => $request->has('is_refundable'),
            'price_lock_enabled' => $request->has('price_lock_enabled'),
            'terms_conditions' => $request->terms_conditions,
            'benefits' => $benefits,
            'metal_type' => $request->metal_type,
            'gold_purity' => $request->gold_purity ?? '22k',
            'scheme_type' => $request->scheme_type,
            'is_active' => $request->has('is_active'),
            'show_on_app' => $request->has('show_on_app'),
            'show_on_web' => $request->has('show_on_web'),
            'featured' => $request->has('featured'),
            'sort_order' => $request->sort_order ?? 0,
        ]);

        Toastr::success(translate('SIP Scheme created successfully!'));
        return redirect()->route('admin.sip.plan.index');
    }

    /**
     * Show the form for editing the specified SIP plan.
     */
    public function edit($id)
    {
        $plan = SipPlan::with('rewards')->findOrFail($id);
        return view('admin-views.sip.plan.edit', compact('plan'));
    }

    /**
     * Show plan details.
     */
    public function show($id)
    {
        $plan = SipPlan::with(['rewards', 'userSips' => function($q) {
            $q->latest()->take(10);
        }])->withCount(['userSips'])->findOrFail($id);

        return view('admin-views.sip.plan.show', compact('plan'));
    }

    /**
     * Update the specified SIP plan.
     */
    public function update(Request $request, $id)
    {
        $plan = SipPlan::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'scheme_code' => 'nullable|string|max:50|unique:sip_plans,scheme_code,' . $id,
            'display_name' => 'nullable|string|max:255',
            'tagline' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'frequency' => 'required|in:daily,weekly,monthly',
            'min_amount' => 'required|numeric|min:0',
            'max_amount' => 'required|numeric|gte:min_amount',
            'amount_increment' => 'nullable|numeric|min:0',
            'duration_months' => 'required|integer|min:1',
            'maturity_days' => 'nullable|integer|min:1',
            'redemption_window_days' => 'nullable|integer|min:1',
            'bonus_months' => 'nullable|integer|min:0',
            'bonus_percentage' => 'nullable|numeric|min:0|max:100',
            'gold_making_discount' => 'nullable|numeric|min:0|max:100',
            'diamond_making_discount' => 'nullable|numeric|min:0|max:100',
            'silver_making_discount' => 'nullable|numeric|min:0|max:100',
            'metal_type' => 'required|in:gold,silver,platinum',
            'gold_purity' => 'required_if:metal_type,gold|in:24k,22k,18k',
            'scheme_type' => 'required|in:super_gold,swarna_suraksha,flexi_save,regular',
            'color_code' => 'nullable|string|max:7',
            'banner_image' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        // Handle banner image upload
        $bannerImage = $plan->banner_image;
        if ($request->hasFile('banner_image')) {
            // Delete old image
            if ($bannerImage) {
                Storage::disk('public')->delete($bannerImage);
            }
            $bannerImage = $request->file('banner_image')->store('sip-schemes', 'public');
        }

        // Parse benefits from textarea
        $benefits = array_filter(array_map('trim', explode("\n", $request->benefits ?? '')));

        $plan->update([
            'name' => $request->name,
            'scheme_code' => $request->scheme_code,
            'display_name' => $request->display_name,
            'tagline' => $request->tagline,
            'banner_image' => $bannerImage,
            'color_code' => $request->color_code ?? '#f5af19',
            'description' => $request->description,
            'frequency' => $request->frequency,
            'min_amount' => $request->min_amount,
            'max_amount' => $request->max_amount,
            'amount_increment' => $request->amount_increment ?? 500,
            'duration_months' => $request->duration_months,
            'maturity_days' => $request->maturity_days ?? ($request->duration_months * 30),
            'redemption_window_days' => $request->redemption_window_days ?? 35,
            'bonus_months' => $request->bonus_months ?? 0,
            'bonus_percentage' => $request->bonus_percentage ?? 0,
            'gold_making_discount' => $request->gold_making_discount ?? 0,
            'diamond_making_discount' => $request->diamond_making_discount ?? 0,
            'silver_making_discount' => $request->silver_making_discount ?? 0,
            'has_lucky_draw' => $request->has('has_lucky_draw'),
            'premium_reward' => $request->premium_reward,
            'is_refundable' => $request->has('is_refundable'),
            'price_lock_enabled' => $request->has('price_lock_enabled'),
            'terms_conditions' => $request->terms_conditions,
            'benefits' => $benefits,
            'metal_type' => $request->metal_type,
            'gold_purity' => $request->gold_purity ?? '22k',
            'scheme_type' => $request->scheme_type,
            'is_active' => $request->has('is_active'),
            'show_on_app' => $request->has('show_on_app'),
            'show_on_web' => $request->has('show_on_web'),
            'featured' => $request->has('featured'),
            'sort_order' => $request->sort_order ?? 0,
        ]);

        Toastr::success(translate('SIP Scheme updated successfully!'));
        return redirect()->route('admin.sip.plan.index');
    }

    /**
     * Toggle the status of the specified SIP plan.
     */
    public function toggleStatus($id)
    {
        $plan = SipPlan::findOrFail($id);
        $plan->update(['is_active' => !$plan->is_active]);

        Toastr::success(translate('SIP Scheme status updated!'));
        return back();
    }

    /**
     * Toggle featured status.
     */
    public function toggleFeatured($id)
    {
        $plan = SipPlan::findOrFail($id);
        $plan->update(['featured' => !$plan->featured]);

        Toastr::success(translate('Featured status updated!'));
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
            Toastr::error(translate('Cannot delete scheme with active subscriptions!'));
            return back();
        }

        // Delete banner image
        if ($plan->banner_image) {
            Storage::disk('public')->delete($plan->banner_image);
        }

        $plan->delete();

        Toastr::success(translate('SIP Scheme deleted successfully!'));
        return redirect()->route('admin.sip.plan.index');
    }

    /**
     * Seed default schemes.
     */
    public function seedDefaults()
    {
        $defaults = SipPlan::getDefaultSchemes();
        $created = 0;

        foreach ($defaults as $scheme) {
            if (!SipPlan::where('scheme_code', $scheme['scheme_code'])->exists()) {
                SipPlan::create($scheme);
                $created++;
            }
        }

        if ($created > 0) {
            Toastr::success(translate('Created ') . $created . translate(' default schemes!'));
        } else {
            Toastr::info(translate('All default schemes already exist.'));
        }

        return back();
    }

    /**
     * Calculate maturity preview.
     */
    public function calculateMaturity(Request $request, $id)
    {
        $plan = SipPlan::findOrFail($id);
        $monthlyAmount = $request->amount ?? $plan->min_amount;

        $result = $plan->calculateMaturityAmount($monthlyAmount);

        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }

    /**
     * Add a reward to a plan.
     */
    public function addReward(Request $request, $id)
    {
        $plan = SipPlan::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'reward_name' => 'required|string|max:255',
            'reward_description' => 'nullable|string',
            'reward_value' => 'nullable|numeric|min:0',
            'reward_type' => 'required|in:appreciation_gift,premium_reward,lucky_draw,milestone',
            'min_installments_required' => 'required|integer|min:1',
            'quantity_available' => 'required|integer|min:1',
            'valid_until' => 'nullable|date',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        // Handle reward image
        $rewardImage = null;
        if ($request->hasFile('reward_image')) {
            $rewardImage = $request->file('reward_image')->store('sip-rewards', 'public');
        }

        $plan->rewards()->create([
            'reward_name' => $request->reward_name,
            'reward_description' => $request->reward_description,
            'reward_image' => $rewardImage,
            'reward_value' => $request->reward_value ?? 0,
            'reward_type' => $request->reward_type,
            'min_installments_required' => $request->min_installments_required,
            'quantity_available' => $request->quantity_available,
            'valid_from' => now(),
            'valid_until' => $request->valid_until,
            'is_active' => true,
        ]);

        Toastr::success(translate('Reward added successfully!'));
        return back();
    }

    /**
     * Remove a reward.
     */
    public function removeReward($planId, $rewardId)
    {
        $reward = SipSchemeReward::where('id', $rewardId)
                                  ->where('sip_plan_id', $planId)
                                  ->firstOrFail();

        if ($reward->reward_image) {
            Storage::disk('public')->delete($reward->reward_image);
        }

        $reward->delete();

        Toastr::success(translate('Reward removed successfully!'));
        return back();
    }
}
