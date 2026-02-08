<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SipWithdrawal extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_sip_id',
        'user_id',
        'withdrawal_type',
        'gold_grams',
        'gold_rate',
        'cash_amount',
        'status',
        'delivery_address',
        'tracking_number',
        'admin_notes',
    ];

    protected $casts = [
        'gold_grams' => 'decimal:4',
        'gold_rate' => 'decimal:2',
        'cash_amount' => 'decimal:2',
    ];

    // Withdrawal types
    const TYPE_GOLD_DELIVERY = 'gold_delivery';
    const TYPE_CASH_REDEMPTION = 'cash_redemption';

    // Status constants
    const STATUS_PENDING = 'pending';
    const STATUS_PROCESSING = 'processing';
    const STATUS_COMPLETED = 'completed';
    const STATUS_REJECTED = 'rejected';

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
     * Scope for pending withdrawals.
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Check if withdrawal is for gold delivery.
     */
    public function isGoldDelivery(): bool
    {
        return $this->withdrawal_type === self::TYPE_GOLD_DELIVERY;
    }

    /**
     * Get withdrawal type options.
     */
    public static function getWithdrawalTypes(): array
    {
        return [
            self::TYPE_GOLD_DELIVERY => 'Physical Gold Delivery',
            self::TYPE_CASH_REDEMPTION => 'Cash Redemption',
        ];
    }
}
