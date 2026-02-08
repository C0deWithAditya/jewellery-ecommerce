<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SipTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_sip_id',
        'user_id',
        'amount',
        'gold_rate',
        'gold_grams',
        'transaction_id',
        'payment_method',
        'status',
        'installment_date',
        'installment_number',
        'payment_response',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'gold_rate' => 'decimal:2',
        'gold_grams' => 'decimal:4',
        'installment_date' => 'date',
    ];

    // Status constants
    const STATUS_PENDING = 'pending';
    const STATUS_SUCCESS = 'success';
    const STATUS_FAILED = 'failed';
    const STATUS_REFUNDED = 'refunded';

    /**
     * Get the user SIP.
     */
    public function userSip()
    {
        return $this->belongsTo(UserSip::class);
    }

    /**
     * Get the user.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope for successful transactions.
     */
    public function scopeSuccessful($query)
    {
        return $query->where('status', self::STATUS_SUCCESS);
    }

    /**
     * Scope for pending transactions.
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Get formatted amount.
     */
    public function getFormattedAmountAttribute(): string
    {
        return '₹' . number_format($this->amount, 2);
    }

    /**
     * Get formatted gold grams.
     */
    public function getFormattedGoldGramsAttribute(): string
    {
        return number_format($this->gold_grams, 4) . ' g';
    }
}
