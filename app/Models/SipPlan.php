<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SipPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'frequency',
        'min_amount',
        'max_amount',
        'duration_months',
        'bonus_months',
        'bonus_percentage',
        'metal_type',
        'gold_purity',
        'is_active',
        'sort_order',
    ];

    protected $casts = [
        'min_amount' => 'decimal:2',
        'max_amount' => 'decimal:2',
        'bonus_percentage' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    // Frequency constants
    const FREQUENCY_DAILY = 'daily';
    const FREQUENCY_WEEKLY = 'weekly';
    const FREQUENCY_MONTHLY = 'monthly';

    // Metal type constants
    const METAL_GOLD = 'gold';
    const METAL_SILVER = 'silver';
    const METAL_PLATINUM = 'platinum';

    /**
     * Get all user SIPs for this plan.
     */
    public function userSips()
    {
        return $this->hasMany(UserSip::class);
    }

    /**
     * Scope for active plans.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)->orderBy('sort_order');
    }

    /**
     * Scope by metal type.
     */
    public function scopeByMetal($query, $metalType)
    {
        return $query->where('metal_type', $metalType);
    }

    /**
     * Get total duration including bonus months.
     */
    public function getTotalDurationAttribute(): int
    {
        return $this->duration_months + $this->bonus_months;
    }

    /**
     * Get human-readable frequency.
     */
    public function getFrequencyLabelAttribute(): string
    {
        return ucfirst($this->frequency);
    }

    /**
     * Get formatted amount range.
     */
    public function getAmountRangeAttribute(): string
    {
        return '₹' . number_format($this->min_amount) . ' - ₹' . number_format($this->max_amount);
    }
}
