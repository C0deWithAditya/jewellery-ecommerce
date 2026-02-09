<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SipPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'scheme_code',
        'display_name',
        'tagline',
        'banner_image',
        'icon',
        'color_code',
        'description',
        'frequency',
        'min_amount',
        'max_amount',
        'amount_increment',
        'duration_months',
        'maturity_days',
        'redemption_window_days',
        'bonus_months',
        'bonus_percentage',
        'gold_making_discount',
        'diamond_making_discount',
        'silver_making_discount',
        'appreciation_gifts',
        'premium_reward',
        'has_lucky_draw',
        'is_refundable',
        'price_lock_enabled',
        'terms_conditions',
        'benefits',
        'metal_type',
        'gold_purity',
        'scheme_type',
        'is_active',
        'show_on_app',
        'show_on_web',
        'featured',
        'sort_order',
    ];

    protected $casts = [
        'min_amount' => 'decimal:2',
        'max_amount' => 'decimal:2',
        'amount_increment' => 'decimal:2',
        'bonus_percentage' => 'decimal:2',
        'gold_making_discount' => 'decimal:2',
        'diamond_making_discount' => 'decimal:2',
        'silver_making_discount' => 'decimal:2',
        'is_active' => 'boolean',
        'show_on_app' => 'boolean',
        'show_on_web' => 'boolean',
        'featured' => 'boolean',
        'has_lucky_draw' => 'boolean',
        'is_refundable' => 'boolean',
        'price_lock_enabled' => 'boolean',
        'appreciation_gifts' => 'array',
        'benefits' => 'array',
    ];

    // Frequency constants
    const FREQUENCY_DAILY = 'daily';
    const FREQUENCY_WEEKLY = 'weekly';
    const FREQUENCY_MONTHLY = 'monthly';

    // Metal type constants
    const METAL_GOLD = 'gold';
    const METAL_SILVER = 'silver';
    const METAL_PLATINUM = 'platinum';

    // Scheme type constants
    const SCHEME_SUPER_GOLD = 'super_gold';
    const SCHEME_SWARNA_SURAKSHA = 'swarna_suraksha';
    const SCHEME_FLEXI_SAVE = 'flexi_save';
    const SCHEME_REGULAR = 'regular';

    /**
     * Get all user SIPs for this plan.
     */
    public function userSips()
    {
        return $this->hasMany(UserSip::class);
    }

    /**
     * Get scheme rewards.
     */
    public function rewards()
    {
        return $this->hasMany(SipSchemeReward::class);
    }

    /**
     * Scope for active plans.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true)->orderBy('sort_order');
    }

    /**
     * Scope for featured plans.
     */
    public function scopeFeatured($query)
    {
        return $query->where('featured', true)->where('is_active', true);
    }

    /**
     * Scope for app visible plans.
     */
    public function scopeVisibleOnApp($query)
    {
        return $query->where('show_on_app', true)->where('is_active', true);
    }

    /**
     * Scope by metal type.
     */
    public function scopeByMetal($query, $metalType)
    {
        return $query->where('metal_type', $metalType);
    }

    /**
     * Scope by scheme type.
     */
    public function scopeBySchemeType($query, $schemeType)
    {
        return $query->where('scheme_type', $schemeType);
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

    /**
     * Get scheme type label.
     */
    public function getSchemeTypeLabelAttribute(): string
    {
        return match($this->scheme_type) {
            self::SCHEME_SUPER_GOLD => 'SuperGold Scheme',
            self::SCHEME_SWARNA_SURAKSHA => 'Swarna Suraksha Yojana',
            self::SCHEME_FLEXI_SAVE => 'Flexi Save Plan',
            default => 'Regular SIP',
        };
    }

    /**
     * Get banner image URL.
     */
    public function getBannerUrlAttribute(): string
    {
        if ($this->banner_image) {
            return asset('storage/sip-schemes/' . $this->banner_image);
        }
        return asset('public/assets/admin/img/sip-default-banner.jpg');
    }

    /**
     * Calculate maturity amount for given monthly amount.
     */
    public function calculateMaturityAmount(float $monthlyAmount): array
    {
        $totalInstallments = $this->duration_months;
        $totalInvestment = $monthlyAmount * $totalInstallments;
        
        // Bonus contribution (e.g., 11+1 scheme = 1 month bonus)
        $bonusContribution = $monthlyAmount * $this->bonus_months;
        
        // Bonus percentage on total investment
        $percentageBonus = $totalInvestment * ($this->bonus_percentage / 100);
        
        $maturityAmount = $totalInvestment + $bonusContribution + $percentageBonus;

        return [
            'monthly_amount' => $monthlyAmount,
            'total_installments' => $totalInstallments,
            'total_investment' => $totalInvestment,
            'bonus_contribution' => $bonusContribution,
            'percentage_bonus' => $percentageBonus,
            'maturity_amount' => $maturityAmount,
            'total_benefit' => $bonusContribution + $percentageBonus,
        ];
    }

    /**
     * Get making charge discounts summary.
     */
    public function getMakingDiscountsAttribute(): array
    {
        return [
            'gold' => [
                'discount' => $this->gold_making_discount,
                'label' => $this->gold_making_discount . '% off on Gold Making Charges',
            ],
            'diamond' => [
                'discount' => $this->diamond_making_discount,
                'label' => $this->diamond_making_discount . '% off on Diamond Jewellery',
            ],
            'silver' => [
                'discount' => $this->silver_making_discount,
                'label' => $this->silver_making_discount . '% off on Silver Making Charges',
            ],
        ];
    }

    /**
     * Get default scheme plans for seeding.
     */
    public static function getDefaultSchemes(): array
    {
        return [
            // SuperGold Scheme (11+1 months)
            [
                'name' => 'SuperGold Scheme',
                'scheme_code' => 'SUPERGOLD',
                'display_name' => 'SuperGold 11+1',
                'tagline' => 'Save for 11 months, Get 1 month FREE!',
                'description' => 'The SuperGold scheme is a carefully crafted gold savings plan designed to help customers accumulate gold smartly and enjoy substantial benefits on jewelry purchases.',
                'frequency' => 'monthly',
                'min_amount' => 1000,
                'max_amount' => 100000,
                'amount_increment' => 500,
                'duration_months' => 11,
                'maturity_days' => 330,
                'redemption_window_days' => 35,
                'bonus_months' => 1,
                'bonus_percentage' => 0,
                'gold_making_discount' => 75,
                'diamond_making_discount' => 60,
                'silver_making_discount' => 100,
                'metal_type' => 'gold',
                'gold_purity' => '22k',
                'scheme_type' => 'super_gold',
                'is_refundable' => false,
                'price_lock_enabled' => true,
                'has_lucky_draw' => false,
                'color_code' => '#f5af19',
                'terms_conditions' => 'Minimum 11 months payment required. Gold price is locked on each payment day.',
                'benefits' => [
                    '75% discount on Gold Making Charges',
                    '60% discount on Diamond Jewellery',
                    '100% discount on Silver Making Charges',
                    'Gold price locked on payment day',
                    '1 month bonus contribution (11+1)',
                    'Flexible jewelry selection at all branches',
                ],
                'is_active' => true,
                'show_on_app' => true,
                'show_on_web' => true,
                'featured' => true,
                'sort_order' => 1,
            ],
            // Swarna Suraksha Yojana 3000
            [
                'name' => 'Swarna Suraksha Yojana 3000',
                'scheme_code' => 'SSY3000',
                'display_name' => 'Swarna Suraksha ₹3000',
                'tagline' => 'Smart Gold Savings with Exciting Rewards!',
                'description' => 'Build your gold savings with confidence through our transparent monthly plan. Eligible customers receive special appreciation gifts for consistent participation.',
                'frequency' => 'monthly',
                'min_amount' => 3000,
                'max_amount' => 3000,
                'amount_increment' => 0,
                'duration_months' => 9,
                'maturity_days' => 270,
                'redemption_window_days' => 30,
                'bonus_months' => 0,
                'bonus_percentage' => 0,
                'gold_making_discount' => 50,
                'diamond_making_discount' => 40,
                'silver_making_discount' => 100,
                'metal_type' => 'gold',
                'gold_purity' => '22k',
                'scheme_type' => 'swarna_suraksha',
                'is_refundable' => false,
                'price_lock_enabled' => true,
                'has_lucky_draw' => true,
                'premium_reward' => 'Car',
                'color_code' => '#667eea',
                'appreciation_gifts' => [
                    'Silver Coin',
                    'Gold Pendant',
                    'Branded Watch',
                    'Home Appliances',
                ],
                'terms_conditions' => 'Minimum 9 months regular payment required. No cash refund - only jewellery redemption. Gold purity: 22K BIS Hallmarked only.',
                'benefits' => [
                    '22K BIS Hallmarked Gold conversion',
                    'Appreciation gifts for regular savers',
                    'Premium reward opportunity (Car)',
                    'No fluctuation risk - price locked',
                    'Digital receipts for all payments',
                ],
                'is_active' => true,
                'show_on_app' => true,
                'show_on_web' => true,
                'featured' => true,
                'sort_order' => 2,
            ],
            // Swarna Suraksha Yojana 5000
            [
                'name' => 'Swarna Suraksha Yojana 5000',
                'scheme_code' => 'SSY5000',
                'display_name' => 'Swarna Suraksha ₹5000',
                'tagline' => 'Higher Savings, Bigger Rewards!',
                'description' => 'Premium gold savings plan with enhanced benefits and bigger appreciation rewards for higher monthly contributions.',
                'frequency' => 'monthly',
                'min_amount' => 5000,
                'max_amount' => 5000,
                'amount_increment' => 0,
                'duration_months' => 6,
                'maturity_days' => 180,
                'redemption_window_days' => 30,
                'bonus_months' => 0,
                'bonus_percentage' => 0,
                'gold_making_discount' => 60,
                'diamond_making_discount' => 50,
                'silver_making_discount' => 100,
                'metal_type' => 'gold',
                'gold_purity' => '22k',
                'scheme_type' => 'swarna_suraksha',
                'is_refundable' => false,
                'price_lock_enabled' => true,
                'has_lucky_draw' => true,
                'premium_reward' => 'Bike/Scooty',
                'color_code' => '#764ba2',
                'appreciation_gifts' => [
                    'Silver Coin Set',
                    'Gold Chain',
                    'Smart Watch',
                    'Electronics',
                ],
                'terms_conditions' => 'Minimum 6 months regular payment required. No cash refund - only jewellery redemption.',
                'benefits' => [
                    '22K BIS Hallmarked Gold',
                    'Premium appreciation gifts',
                    'Lucky draw for Bike/Scooty',
                    '60% discount on Gold Making Charges',
                ],
                'is_active' => true,
                'show_on_app' => true,
                'show_on_web' => true,
                'featured' => false,
                'sort_order' => 3,
            ],
        ];
    }
}
