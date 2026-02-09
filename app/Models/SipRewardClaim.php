<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SipRewardClaim extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_sip_id',
        'user_id',
        'reward_id',
        'status',
        'claim_notes',
        'admin_notes',
        'claimed_at',
    ];

    protected $casts = [
        'claimed_at' => 'datetime',
    ];

    // Status constants
    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_CLAIMED = 'claimed';
    const STATUS_REJECTED = 'rejected';

    /**
     * Get the user SIP subscription.
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
     * Get the reward.
     */
    public function reward()
    {
        return $this->belongsTo(SipSchemeReward::class, 'reward_id');
    }

    /**
     * Scope for pending claims.
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Approve this claim.
     */
    public function approve(string $adminNotes = null): bool
    {
        return $this->update([
            'status' => self::STATUS_APPROVED,
            'admin_notes' => $adminNotes,
        ]);
    }

    /**
     * Mark as claimed/delivered.
     */
    public function markAsClaimed(string $notes = null): bool
    {
        return $this->update([
            'status' => self::STATUS_CLAIMED,
            'claimed_at' => now(),
            'admin_notes' => $notes ?? $this->admin_notes,
        ]);
    }

    /**
     * Reject this claim.
     */
    public function reject(string $reason): bool
    {
        // Return the quantity back
        $this->reward->decrement('quantity_claimed');

        return $this->update([
            'status' => self::STATUS_REJECTED,
            'admin_notes' => $reason,
        ]);
    }

    /**
     * Get status badge color.
     */
    public function getStatusColorAttribute(): string
    {
        return match($this->status) {
            self::STATUS_PENDING => 'warning',
            self::STATUS_APPROVED => 'info',
            self::STATUS_CLAIMED => 'success',
            self::STATUS_REJECTED => 'danger',
            default => 'secondary',
        };
    }
}
