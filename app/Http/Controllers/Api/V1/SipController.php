<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use App\Models\SipPlan;
use App\Models\UserSip;
use App\Models\SipTransaction;
use App\Models\SipWithdrawal;
use App\Models\SipSchemeReward;
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
     * Get available SIP plans/schemes.
     */
    public function getPlans(Request $request)
    {
        $query = SipPlan::visibleOnApp();

        // Filter by scheme type
        if ($request->has('scheme_type')) {
            $query->bySchemeType($request->scheme_type);
        }

        // Filter by metal type
        if ($request->has('metal_type')) {
            $query->byMetal($request->metal_type);
        }

        // Filter featured only
        if ($request->boolean('featured')) {
            $query->featured();
        }

        $plans = $query->orderBy('sort_order')->get()->map(function($plan) {
            return $this->formatPlanResponse($plan);
        });

        return response()->json([
            'status' => true,
            'data' => $plans,
        ]);
    }

    /**
     * Get scheme details.
     */
    public function getPlanDetails($planId)
    {
        $plan = SipPlan::with(['rewards' => function($q) {
            $q->active();
        }])->where('is_active', true)->findOrFail($planId);

        $response = $this->formatPlanResponse($plan, true);

        // Add rewards
        $response['rewards'] = $plan->rewards->map(function($reward) {
            return [
                'id' => $reward->id,
                'name' => $reward->reward_name,
                'description' => $reward->reward_description,
                'image' => $reward->image_url,
                'type' => $reward->reward_type,
                'type_label' => $reward->type_label,
                'value' => $reward->reward_value,
                'min_installments' => $reward->min_installments_required,
                'is_available' => $reward->isAvailable(),
                'remaining_quantity' => $reward->remaining_quantity,
            ];
        });

        return response()->json([
            'status' => true,
            'data' => $response,
        ]);
    }

    /**
     * Format plan response for API.
     */
    private function formatPlanResponse(SipPlan $plan, bool $detailed = false): array
    {
        $response = [
            'id' => $plan->id,
            'name' => $plan->name,
            'scheme_code' => $plan->scheme_code,
            'display_name' => $plan->display_name ?? $plan->name,
            'tagline' => $plan->tagline,
            'description' => $plan->description,
            'banner_url' => $plan->banner_url,
            'color_code' => $plan->color_code,
            
            // Scheme type
            'scheme_type' => $plan->scheme_type,
            'scheme_type_label' => $plan->scheme_type_label,
            'is_featured' => $plan->featured,
            
            // Configuration
            'frequency' => $plan->frequency,
            'frequency_label' => $plan->frequency_label,
            'metal_type' => $plan->metal_type,
            'gold_purity' => $plan->gold_purity,
            
            // Amount
            'min_amount' => floatval($plan->min_amount),
            'max_amount' => floatval($plan->max_amount),
            'amount_increment' => floatval($plan->amount_increment),
            'amount_range' => $plan->amount_range,
            
            // Duration
            'duration_months' => $plan->duration_months,
            'maturity_days' => $plan->maturity_days,
            'redemption_window_days' => $plan->redemption_window_days,
            
            // Bonus
            'bonus_months' => $plan->bonus_months,
            'bonus_percentage' => floatval($plan->bonus_percentage),
            'total_duration' => $plan->total_duration,
            
            // Making charge discounts
            'discounts' => [
                'gold_making' => floatval($plan->gold_making_discount),
                'diamond_making' => floatval($plan->diamond_making_discount),
                'silver_making' => floatval($plan->silver_making_discount),
            ],
            
            // Rewards
            'has_lucky_draw' => $plan->has_lucky_draw,
            'premium_reward' => $plan->premium_reward,
            
            // Features
            'price_lock_enabled' => $plan->price_lock_enabled,
            'is_refundable' => $plan->is_refundable,
        ];

        // Add detailed info
        if ($detailed) {
            $response['benefits'] = $plan->benefits ?? [];
            $response['terms_conditions'] = $plan->terms_conditions;
            $response['appreciation_gifts'] = $plan->appreciation_gifts ?? [];
            
            // Calculate sample maturity for different amounts
            $sampleAmounts = [
                floatval($plan->min_amount),
                5000,
                10000,
            ];
            
            $response['maturity_examples'] = [];
            foreach ($sampleAmounts as $amount) {
                if ($amount >= $plan->min_amount && $amount <= $plan->max_amount) {
                    $response['maturity_examples'][] = $plan->calculateMaturityAmount($amount);
                }
            }
        }

        return $response;
    }

    /**
     * Calculate maturity for a given amount.
     */
    public function calculateMaturity(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'plan_id' => 'required|exists:sip_plans,id',
            'monthly_amount' => 'required|numeric|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $plan = SipPlan::findOrFail($request->plan_id);

        // Validate amount is within range
        if ($request->monthly_amount < $plan->min_amount || $request->monthly_amount > $plan->max_amount) {
            return response()->json([
                'status' => false,
                'message' => 'Amount must be between ₹' . number_format($plan->min_amount) . ' and ₹' . number_format($plan->max_amount),
            ], 400);
        }

        $result = $plan->calculateMaturityAmount($request->monthly_amount);

        // Get current gold rate
        $currentRate = MetalRate::getCurrentRate($plan->metal_type, $plan->gold_purity);
        if ($currentRate) {
            $result['estimated_gold_grams'] = round($result['maturity_amount'] / $currentRate, 4);
            $result['current_gold_rate'] = $currentRate;
        }

        return response()->json([
            'status' => true,
            'data' => $result,
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
     * Subscribe to a SIP plan/scheme.
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

        // Check if plan is active
        if (!$plan->is_active) {
            return response()->json([
                'status' => false,
                'message' => 'This scheme is currently not available',
            ], 400);
        }

        // Check KYC status
        $kyc = KycDocument::where('user_id', $user->id)
            ->where('status', 'approved')
            ->first();

        if (!$kyc) {
            return response()->json([
                'status' => false,
                'message' => 'Please complete KYC verification before subscribing to a scheme',
            ], 400);
        }

        // Validate amount
        if ($request->monthly_amount < $plan->min_amount || $request->monthly_amount > $plan->max_amount) {
            return response()->json([
                'status' => false,
                'message' => 'Amount must be between ₹' . number_format($plan->min_amount) . ' and ₹' . number_format($plan->max_amount),
            ], 400);
        }

        // Check amount increment
        if ($plan->amount_increment > 0 && $request->monthly_amount > $plan->min_amount) {
            $remainder = fmod($request->monthly_amount - $plan->min_amount, $plan->amount_increment);
            if ($remainder > 0.01) {
                return response()->json([
                    'status' => false,
                    'message' => 'Amount must be in increments of ₹' . number_format($plan->amount_increment),
                ], 400);
            }
        }

        // Check for existing active SIP with same plan
        $existingSip = UserSip::where('user_id', $user->id)
            ->where('sip_plan_id', $plan->id)
            ->where('status', 'active')
            ->first();

        if ($existingSip) {
            return response()->json([
                'status' => false,
                'message' => 'You already have an active subscription with this scheme',
            ], 400);
        }

        // Create SIP subscription using the model method
        $userSip = UserSip::createSubscription($user->id, $plan->id, $request->monthly_amount);

        return response()->json([
            'status' => true,
            'message' => 'Subscription created successfully! Complete your first payment to activate.',
            'data' => [
                'sip_id' => $userSip->id,
                'scheme_name' => $plan->display_name ?? $plan->name,
                'scheme_type' => $plan->scheme_type_label,
                'monthly_amount' => floatval($userSip->monthly_amount),
                'start_date' => $userSip->start_date->format('Y-m-d'),
                'maturity_date' => $userSip->maturity_date->format('Y-m-d'),
                'redemption_deadline' => $userSip->redemption_deadline->format('Y-m-d'),
                'total_installments' => $plan->duration_months,
                'locked_gold_rate' => $userSip->locked_gold_rate,
                'discounts' => $plan->making_discounts,
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
                
                $profitLoss = $sip->profit_loss;
                
                return [
                    'id' => $sip->id,
                    'scheme_name' => $sip->sipPlan->display_name ?? $sip->sipPlan->name,
                    'scheme_code' => $sip->sipPlan->scheme_code,
                    'scheme_type' => $sip->sipPlan->scheme_type,
                    'scheme_type_label' => $sip->sipPlan->scheme_type_label,
                    'color_code' => $sip->sipPlan->color_code,
                    
                    'monthly_amount' => floatval($sip->monthly_amount),
                    'total_invested' => floatval($sip->total_invested),
                    'total_gold_grams' => round($sip->total_gold_grams, 4),
                    'appreciation_bonus' => round($sip->appreciation_bonus, 4),
                    'total_gold_with_bonus' => round($sip->total_gold_with_bonus, 4),
                    
                    'current_value' => $currentRate ? round($sip->total_gold_with_bonus * $currentRate, 2) : null,
                    'profit_loss' => $profitLoss,
                    
                    'progress_percentage' => $sip->progress_percentage,
                    'installments_paid' => $sip->installments_paid,
                    'installments_pending' => $sip->installments_pending,
                    
                    'start_date' => $sip->start_date->format('Y-m-d'),
                    'maturity_date' => $sip->maturity_date?->format('Y-m-d'),
                    'redemption_deadline' => $sip->redemption_deadline?->format('Y-m-d'),
                    'days_until_maturity' => $sip->days_until_maturity,
                    'days_until_deadline' => $sip->days_until_deadline,
                    'next_payment_date' => $sip->next_payment_date?->format('Y-m-d'),
                    
                    'status' => $sip->status,
                    'is_matured' => $sip->isMatured(),
                    'can_redeem' => $sip->canRedeem(),
                    'eligible_for_reward' => $sip->eligible_for_reward,
                    'reward_status' => $sip->reward_status,
                    
                    'discounts' => $sip->making_discounts,
                    
                    'metal_type' => $sip->sipPlan->metal_type,
                    'gold_purity' => $sip->sipPlan->gold_purity,
                    'locked_gold_rate' => floatval($sip->locked_gold_rate),
                ];
            });

        return response()->json([
            'status' => true,
            'data' => $sips,
        ]);
    }

    /**
     * Get SIP subscription details.
     */
    public function getSipDetails(Request $request, $sipId)
    {
        $user = $request->user();
        
        $sip = UserSip::with(['sipPlan.rewards', 'transactions' => function($q) {
            $q->latest()->take(10);
        }, 'rewardClaims.reward'])
            ->where('user_id', $user->id)
            ->findOrFail($sipId);

        $currentRate = MetalRate::getCurrentRate(
            $sip->sipPlan->metal_type, 
            $sip->sipPlan->gold_purity
        );

        return response()->json([
            'status' => true,
            'data' => [
                'id' => $sip->id,
                'scheme' => $this->formatPlanResponse($sip->sipPlan, true),
                
                'monthly_amount' => floatval($sip->monthly_amount),
                'total_invested' => floatval($sip->total_invested),
                'total_gold_grams' => round($sip->total_gold_grams, 4),
                'appreciation_bonus' => round($sip->appreciation_bonus, 4),
                'total_gold_with_bonus' => round($sip->total_gold_with_bonus, 4),
                'current_gold_rate' => $currentRate,
                'current_value' => $currentRate ? round($sip->total_gold_with_bonus * $currentRate, 2) : null,
                'profit_loss' => $sip->profit_loss,
                
                'progress_percentage' => $sip->progress_percentage,
                'installments_paid' => $sip->installments_paid,
                'installments_pending' => $sip->installments_pending,
                
                'start_date' => $sip->start_date->format('Y-m-d'),
                'end_date' => $sip->end_date->format('Y-m-d'),
                'maturity_date' => $sip->maturity_date?->format('Y-m-d'),
                'redemption_deadline' => $sip->redemption_deadline?->format('Y-m-d'),
                'days_until_maturity' => $sip->days_until_maturity,
                'days_until_deadline' => $sip->days_until_deadline,
                'next_payment_date' => $sip->next_payment_date?->format('Y-m-d'),
                
                'status' => $sip->status,
                'is_matured' => $sip->isMatured(),
                'can_redeem' => $sip->canRedeem(),
                'eligible_for_reward' => $sip->eligible_for_reward,
                'reward_status' => $sip->reward_status,
                'locked_gold_rate' => floatval($sip->locked_gold_rate),
                
                'recent_transactions' => $sip->transactions->map(function($txn) {
                    return [
                        'id' => $txn->id,
                        'amount' => floatval($txn->amount),
                        'gold_rate' => floatval($txn->gold_rate),
                        'gold_grams' => round($txn->gold_grams, 4),
                        'status' => $txn->status,
                        'installment_number' => $txn->installment_number,
                        'date' => $txn->created_at->format('Y-m-d H:i:s'),
                    ];
                }),
                
                'reward_claims' => $sip->rewardClaims->map(function($claim) {
                    return [
                        'id' => $claim->id,
                        'reward_name' => $claim->reward->reward_name,
                        'reward_type' => $claim->reward->reward_type,
                        'status' => $claim->status,
                        'claimed_at' => $claim->claimed_at?->format('Y-m-d'),
                    ];
                }),
            ],
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
                    'amount' => floatval($txn->amount),
                    'gold_rate' => floatval($txn->gold_rate),
                    'gold_grams' => round($txn->gold_grams, 4),
                    'status' => $txn->status,
                    'payment_method' => $txn->payment_method,
                    'installment_number' => $txn->installment_number,
                    'date' => $txn->created_at->format('Y-m-d H:i:s'),
                    'scheme_name' => $txn->userSip->sipPlan->display_name ?? $txn->userSip->sipPlan->name,
                ];
            });

        return response()->json([
            'status' => true,
            'data' => $transactions,
        ]);
    }

    /**
     * Claim a reward.
     */
    public function claimReward(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'sip_id' => 'required|exists:user_sips,id',
            'reward_id' => 'required|exists:sip_scheme_rewards,id',
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
            ->firstOrFail();

        if (!$sip->eligible_for_reward) {
            return response()->json([
                'status' => false,
                'message' => 'You are not yet eligible for rewards. Complete more installments.',
            ], 400);
        }

        $reward = SipSchemeReward::where('id', $request->reward_id)
            ->where('sip_plan_id', $sip->sip_plan_id)
            ->active()
            ->firstOrFail();

        if (!$reward->isAvailable()) {
            return response()->json([
                'status' => false,
                'message' => 'This reward is no longer available.',
            ], 400);
        }

        if ($sip->installments_paid < $reward->min_installments_required) {
            return response()->json([
                'status' => false,
                'message' => 'You need to complete ' . $reward->min_installments_required . ' installments to claim this reward.',
            ], 400);
        }

        $claim = $reward->claimFor($sip);

        if (!$claim) {
            return response()->json([
                'status' => false,
                'message' => 'Unable to claim this reward. Please try again.',
            ], 400);
        }

        return response()->json([
            'status' => true,
            'message' => 'Reward claimed successfully! You will be contacted for delivery.',
            'data' => [
                'claim_id' => $claim->id,
                'reward_name' => $reward->reward_name,
                'status' => $claim->status,
            ],
        ]);
    }

    /**
     * Request withdrawal/redemption.
     */
    public function requestWithdrawal(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'sip_id' => 'required|exists:user_sips,id',
            'withdrawal_type' => 'required|in:gold_delivery,cash_redemption,jewelry_purchase',
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
        $sip = UserSip::with('sipPlan')
            ->where('id', $request->sip_id)
            ->where('user_id', $user->id)
            ->firstOrFail();

        // Check if SIP is matured and can redeem
        if (!$sip->canRedeem()) {
            return response()->json([
                'status' => false,
                'message' => 'This subscription is not yet eligible for redemption.',
            ], 400);
        }

        // Check refund policy for cash redemption
        if ($request->withdrawal_type === 'cash_redemption' && !$sip->sipPlan->is_refundable) {
            return response()->json([
                'status' => false,
                'message' => 'Cash redemption is not available for this scheme. Please choose jewelry purchase.',
            ], 400);
        }

        // Check available gold
        $availableGold = $sip->total_gold_with_bonus;
        if ($request->gold_grams > $availableGold) {
            return response()->json([
                'status' => false,
                'message' => 'Insufficient gold balance. Available: ' . number_format($availableGold, 4) . 'g',
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
            'message' => 'Redemption request submitted successfully',
            'data' => [
                'withdrawal_id' => $withdrawal->id,
                'gold_grams' => floatval($withdrawal->gold_grams),
                'estimated_value' => $cashAmount,
                'withdrawal_type' => $request->withdrawal_type,
                'status' => $withdrawal->status,
                'discounts' => $sip->making_discounts,
            ],
        ]);
    }

    /**
     * Get user's dashboard summary.
     */
    public function getDashboard(Request $request)
    {
        $user = $request->user();

        $activeSips = UserSip::with('sipPlan')
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->get();

        $totalInvested = $activeSips->sum('total_invested');
        $totalGold = $activeSips->sum('total_gold_grams');
        $totalBonus = $activeSips->sum('appreciation_bonus');

        // Calculate total current value
        $totalValue = 0;
        foreach ($activeSips as $sip) {
            $rate = MetalRate::getCurrentRate($sip->sipPlan->metal_type, $sip->sipPlan->gold_purity);
            if ($rate) {
                $totalValue += ($sip->total_gold_grams + $sip->appreciation_bonus) * $rate;
            }
        }

        // Get featured schemes
        $featuredSchemes = SipPlan::visibleOnApp()
            ->featured()
            ->take(3)
            ->get()
            ->map(function($plan) {
                return $this->formatPlanResponse($plan);
            });

        // Get current metal rates
        $rates = MetalRate::current()->get();

        // Get KYC status
        $kyc = KycDocument::where('user_id', $user->id)->latest()->first();

        return response()->json([
            'status' => true,
            'data' => [
                'portfolio' => [
                    'active_subscriptions' => $activeSips->count(),
                    'total_invested' => round($totalInvested, 2),
                    'total_gold_grams' => round($totalGold, 4),
                    'bonus_gold_grams' => round($totalBonus, 4),
                    'current_value' => round($totalValue, 2),
                    'profit_loss' => round($totalValue - $totalInvested, 2),
                    'profit_percentage' => $totalInvested > 0 ? round((($totalValue - $totalInvested) / $totalInvested) * 100, 2) : 0,
                ],
                'kyc' => [
                    'is_verified' => $kyc && $kyc->status === 'approved',
                    'status' => $kyc?->status,
                ],
                'featured_schemes' => $featuredSchemes,
                'metal_rates' => $rates->map(function($rate) {
                    return [
                        'metal_type' => $rate->metal_type,
                        'purity' => $rate->purity,
                        'rate_per_gram' => $rate->rate_per_gram,
                        'updated_at' => $rate->updated_at->diffForHumans(),
                    ];
                }),
            ],
        ]);
    }
}
