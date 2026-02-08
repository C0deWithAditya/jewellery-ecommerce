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
        'next_payment_date',
        'total_invested',
        'total_gold_grams',
        'installments_paid',
        'installments_pending',
        'status',
        'mandate_id',
        'mandate_status',
    ];

    protected $casts = [
        'monthly_amount' => 'decimal:2',
        'total_invested' => 'decimal:2',
        'total_gold_grams' => 'decimal:4',
        'start_date' => 'date',
        'end_date' => 'date',
        'next_payment_date' => 'date',
    ];

    // Status constants
    const STATUS_ACTIVE = 'active';
    const STATUS_PAUSED = 'paused';
    const STATUS_COMPLETED = 'completed';
    const STATUS_CANCELLED = 'cancelled';

    // Mandate status constants
    const MANDATE_PENDING = 'pending';
    const MANDATE_ACTIVE = 'active';
    const MANDATE_CANCELLED = 'cancelled';

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
     * Scope for active SIPs.
     */
    public function scopeActive($query)
    {
        return $query->where('status', self::STATUS_ACTIVE);
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
     * Get progress percentage.
     */
    public function getProgressPercentageAttribute(): float
    {
        $totalInstallments = $this->installments_paid + $this->installments_pending;
        if ($totalInstallments === 0) return 0;
        return round(($this->installments_paid / $totalInstallments) * 100, 1);
    }

    /**
     * Get current gold value based on latest rate.
     */
    public function getCurrentValueAttribute(): float
    {
        $currentRate = MetalRate::getCurrentRate($this->sipPlan->metal_type, $this->sipPlan->gold_purity);
        return $this->total_gold_grams * ($currentRate ?? 0);
    }

    /**
     * Process a successful payment.
     */
    public function processPayment(float $amount, float $goldRate): SipTransaction
    {
        $goldGrams = $amount / $goldRate;
        
        $transaction = $this->transactions()->create([
            'user_id' => $this->user_id,
            'amount' => $amount,
            'gold_rate' => $goldRate,
            'gold_grams' => $goldGrams,
            'status' => SipTransaction::STATUS_SUCCESS,
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
            $this->update(['status' => self::STATUS_COMPLETED]);
        }

        return $transaction;
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
}
