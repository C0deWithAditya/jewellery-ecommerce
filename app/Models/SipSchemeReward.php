<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SipSchemeReward extends Model
{
    use HasFactory;

    protected $fillable = [
        'sip_plan_id',
        'reward_name',
        'reward_description',
        'reward_image',
        'reward_value',
        'reward_type',
        'min_installments_required',
        'quantity_available',
        'quantity_claimed',
        'is_active',
        'valid_from',
        'valid_until',
    ];

    protected $casts = [
        'reward_value' => 'decimal:2',
        'is_active' => 'boolean',
        'valid_from' => 'date',
        'valid_until' => 'date',
    ];

    // Reward type constants
    const TYPE_APPRECIATION_GIFT = 'appreciation_gift';
    const TYPE_PREMIUM_REWARD = 'premium_reward';
    const TYPE_LUCKY_DRAW = 'lucky_draw';
    const TYPE_MILESTONE = 'milestone';

    /**
     * Get the SIP plan this reward belongs to.
     */
    public function sipPlan()
    {
        return $this->belongsTo(SipPlan::class);
    }

    /**
     * Get all claims for this reward.
     */
    public function claims()
    {
        return $this->hasMany(SipRewardClaim::class, 'reward_id');
    }

    /**
     * Scope for active rewards.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)
                     ->where(function($q) {
                         $q->whereNull('valid_until')
                           ->orWhere('valid_until', '>=', now());
                     });
    }

    /**
     * Scope by reward type.
     */
    public function scopeOfType($query, $type)
    {
        return $query->where('reward_type', $type);
    }

    /**
     * Check if reward is available.
     */
    public function isAvailable(): bool
    {
        if (!$this->is_active) return false;
        if ($this->valid_until && $this->valid_until->isPast()) return false;
        if ($this->quantity_available <= $this->quantity_claimed) return false;
        return true;
    }

    /**
     * Get remaining quantity.
     */
    public function getRemainingQuantityAttribute(): int
    {
        return max(0, $this->quantity_available - $this->quantity_claimed);
    }

    /**
     * Get reward image URL.
     */
    public function getImageUrlAttribute(): string
    {
        if ($this->reward_image) {
            return asset('storage/sip-rewards/' . $this->reward_image);
        }
        return asset('public/assets/admin/img/gift-box.png');
    }

    /**
     * Claim this reward for a user.
     */
    public function claimFor(UserSip $userSip): ?SipRewardClaim
    {
        if (!$this->isAvailable()) {
            return null;
        }

        if ($userSip->installments_paid < $this->min_installments_required) {
            return null;
        }

        $claim = SipRewardClaim::create([
            'user_sip_id' => $userSip->id,
            'user_id' => $userSip->user_id,
            'reward_id' => $this->id,
            'status' => 'pending',
        ]);

        $this->increment('quantity_claimed');

        return $claim;
    }

    /**
     * Get reward type label.
     */
    public function getTypeLabelAttribute(): string
    {
        return match($this->reward_type) {
            self::TYPE_APPRECIATION_GIFT => 'Appreciation Gift',
            self::TYPE_PREMIUM_REWARD => 'Premium Reward',
            self::TYPE_LUCKY_DRAW => 'Lucky Draw',
            self::TYPE_MILESTONE => 'Milestone Reward',
            default => 'Gift',
        };
    }
}
