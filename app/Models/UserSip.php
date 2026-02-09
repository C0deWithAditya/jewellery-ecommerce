<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class UserSip extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'sip_plan_id',
        'monthly_amount',
        'start_date',
        'end_date',
        'maturity_date',
        'redemption_deadline',
        'next_payment_date',
        'total_invested',
        'total_gold_grams',
        'locked_gold_rate',
        'appreciation_bonus',
        'installments_paid',
        'installments_pending',
        'status',
        'mandate_id',
        'mandate_status',
        'eligible_for_reward',
        'reward_status',
        'redeemed_at',
    ];

    protected $casts = [
        'monthly_amount' => 'decimal:2',
        'total_invested' => 'decimal:2',
        'total_gold_grams' => 'decimal:4',
        'locked_gold_rate' => 'decimal:2',
        'appreciation_bonus' => 'decimal:4',
        'start_date' => 'date',
        'end_date' => 'date',
        'maturity_date' => 'date',
        'redemption_deadline' => 'date',
        'next_payment_date' => 'date',
        'redeemed_at' => 'datetime',
        'eligible_for_reward' => 'boolean',
    ];

    // Status constants
    const STATUS_ACTIVE = 'active';
    const STATUS_PAUSED = 'paused';
    const STATUS_COMPLETED = 'completed';
    const STATUS_CANCELLED = 'cancelled';
    const STATUS_MATURED = 'matured';

    // Mandate status constants
    const MANDATE_PENDING = 'pending';
    const MANDATE_ACTIVE = 'active';
    const MANDATE_CANCELLED = 'cancelled';

    // Reward status constants
    const REWARD_PENDING = 'pending';
    const REWARD_CLAIMED = 'claimed';
    const REWARD_EXPIRED = 'expired';

    /**
     * Get the user who owns this SIP.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the SIP plan.
     */
    public function sipPlan()
    {
        return $this->belongsTo(SipPlan::class);
    }

    /**
     * Get all transactions for this SIP.
     */
    public function transactions()
    {
        return $this->hasMany(SipTransaction::class);
    }

    /**
     * Get withdrawal requests for this SIP.
     */
    public function withdrawals()
    {
        return $this->hasMany(SipWithdrawal::class);
    }

    /**
     * Get reward claims for this SIP.
     */
    public function rewardClaims()
    {
        return $this->hasMany(SipRewardClaim::class);
    }

    /**
     * Scope for active SIPs.
     */
    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_ACTIVE);
    }

    /**
     * Scope for matured SIPs (ready for redemption).
     */
    public function scopeMatured($query)
    {
        return $query->where('status', self::STATUS_MATURED)
                     ->orWhere(function($q) {
                         $q->where('maturity_date', '<=', now())
                           ->where('status', self::STATUS_ACTIVE);
                     });
    }

    /**
     * Scope for SIPs due for payment today.
     */
    public function scopeDueToday($query)
    {
        return $query->where('next_payment_date', Carbon::today())
                     ->where('status', self::STATUS_ACTIVE);
    }

    /**
     * Check if SIP is active.
     */
    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }

    /**
     * Check if SIP is matured.
     */
    public function isMatured(): bool
    {
        if ($this->status === self::STATUS_MATURED) return true;
        if ($this->maturity_date && $this->maturity_date->isPast()) return true;
        return false;
    }

    /**
     * Check if still within redemption window.
     */
    public function canRedeem(): bool
    {
        if (!$this->isMatured()) return false;
        if (!$this->redemption_deadline) return true;
        return !$this->redemption_deadline->isPast();
    }

    /**
     * Get progress percentage.
     */
    public function getProgressPercentageAttribute(): float
    {
        $totalInstallments = $this->installments_paid + $this->installments_pending;
        if ($totalInstallments === 0) return 0;
        return round(($this->installments_paid / $totalInstallments) * 100, 1);
    }

    /**
     * Check if eligible for completion bonus.
     */
    public function isEligibleForBonus(): bool
    {
        return $this->installments_pending <= 0 && $this->installments_paid >= $this->sipPlan->duration_months;
    }

    /**
     * Get current gold value based on latest rate.
     */
    public function getCurrentValueAttribute(): float
    {
        $currentRate = MetalRate::getCurrentRate($this->sipPlan->metal_type, $this->sipPlan->gold_purity);
        $totalGrams = $this->total_gold_grams + $this->appreciation_bonus;
        return $totalGrams * ($currentRate ?? 0);
    }

    /**
     * Get total gold including bonus.
     */
    public function getTotalGoldWithBonusAttribute(): float
    {
        return $this->total_gold_grams + $this->appreciation_bonus;
    }

    /**
     * Get profit/loss based on locked rate vs current rate.
     */
    public function getProfitLossAttribute(): array
    {
        $currentRate = MetalRate::getCurrentRate($this->sipPlan->metal_type, $this->sipPlan->gold_purity);
        $currentValue = $this->total_gold_grams * ($currentRate ?? 0);
        $investedValue = $this->total_invested;
        
        $difference = $currentValue - $investedValue;
        $percentage = $investedValue > 0 ? ($difference / $investedValue) * 100 : 0;

        return [
            'invested' => $investedValue,
            'current_value' => $currentValue,
            'difference' => $difference,
            'percentage' => round($percentage, 2),
            'is_profit' => $difference >= 0,
        ];
    }

    /**
     * Get making charge discounts for this subscription.
     */
    public function getMakingDiscountsAttribute(): array
    {
        return $this->sipPlan->making_discounts;
    }

    /**
     * Days until maturity.
     */
    public function getDaysUntilMaturityAttribute(): int
    {
        if (!$this->maturity_date) return 0;
        if ($this->maturity_date->isPast()) return 0;
        return now()->diffInDays($this->maturity_date);
    }

    /**
     * Days until redemption deadline.
     */
    public function getDaysUntilDeadlineAttribute(): int
    {
        if (!$this->redemption_deadline) return 0;
        if ($this->redemption_deadline->isPast()) return 0;
        return now()->diffInDays($this->redemption_deadline);
    }

    /**
     * Process a successful payment.
     */
    public function processPayment(float $amount, float $goldRate, string $paymentMethod = 'online'): SipTransaction
    {
        $goldGrams = $amount / $goldRate;
        
        $transaction = $this->transactions()->create([
            'user_id' => $this->user_id,
            'amount' => $amount,
            'gold_rate' => $goldRate,
            'gold_grams' => $goldGrams,
            'status' => SipTransaction::STATUS_SUCCESS,
            'payment_method' => $paymentMethod,
            'installment_date' => Carbon::today(),
            'installment_number' => $this->installments_paid + 1,
        ]);

        $this->update([
            'total_invested' => $this->total_invested + $amount,
            'total_gold_grams' => $this->total_gold_grams + $goldGrams,
            'installments_paid' => $this->installments_paid + 1,
            'installments_pending' => max(0, $this->installments_pending - 1),
            'next_payment_date' => $this->calculateNextPaymentDate(),
        ]);

        // Check if SIP is completed
        if ($this->installments_pending <= 0) {
            $this->completeSubscription();
        }

        return $transaction;
    }

    /**
     * Complete the subscription and calculate bonuses.
     */
    public function completeSubscription(): void
    {
        $bonusGrams = 0;
        $plan = $this->sipPlan;

        // Calculate bonus months contribution (e.g., 11+1 scheme)
        if ($plan->bonus_months > 0) {
            $avgGoldRate = $this->transactions()->avg('gold_rate');
            if ($avgGoldRate > 0) {
                $bonusAmount = $this->monthly_amount * $plan->bonus_months;
                $bonusGrams += $bonusAmount / $avgGoldRate;
            }
        }

        // Calculate percentage bonus
        if ($plan->bonus_percentage > 0) {
            $bonusGrams += $this->total_gold_grams * ($plan->bonus_percentage / 100);
        }

        $this->update([
            'status' => self::STATUS_MATURED,
            'appreciation_bonus' => $bonusGrams,
            'maturity_date' => now(),
            'redemption_deadline' => now()->addDays($plan->redemption_window_days),
            'eligible_for_reward' => true,
            'reward_status' => self::REWARD_PENDING,
        ]);
    }

    /**
     * Calculate the next payment date based on frequency.
     */
    private function calculateNextPaymentDate(): ?Carbon
    {
        if ($this->installments_pending <= 1) {
            return null;
        }

        $frequency = $this->sipPlan->frequency;
        $nextDate = Carbon::parse($this->next_payment_date);

        switch ($frequency) {
            case SipPlan::FREQUENCY_DAILY:
                return $nextDate->addDay();
            case SipPlan::FREQUENCY_WEEKLY:
                return $nextDate->addWeek();
            case SipPlan::FREQUENCY_MONTHLY:
            default:
                return $nextDate->addMonth();
        }
    }

    /**
     * Create a new SIP subscription for a user.
     */
    public static function createSubscription(int $userId, int $planId, float $monthlyAmount): self
    {
        $plan = SipPlan::findOrFail($planId);
        
        // Get current gold rate for price locking
        $currentRate = MetalRate::getCurrentRate($plan->metal_type, $plan->gold_purity);

        $startDate = Carbon::today();
        $endDate = $startDate->copy()->addMonths($plan->duration_months);
        $maturityDate = $startDate->copy()->addDays($plan->maturity_days);
        $redemptionDeadline = $maturityDate->copy()->addDays($plan->redemption_window_days);

        return self::create([
            'user_id' => $userId,
            'sip_plan_id' => $planId,
            'monthly_amount' => $monthlyAmount,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'maturity_date' => $maturityDate,
            'redemption_deadline' => $redemptionDeadline,
            'next_payment_date' => $startDate,
            'total_invested' => 0,
            'total_gold_grams' => 0,
            'locked_gold_rate' => $currentRate ?? 0,
            'installments_paid' => 0,
            'installments_pending' => $plan->duration_months,
            'status' => self::STATUS_ACTIVE,
        ]);
    }
}
