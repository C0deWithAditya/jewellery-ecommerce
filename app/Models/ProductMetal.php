<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\MetalRate;

class ProductMetal extends Model
{
    protected $fillable = [
        'product_id',
        'metal_type',
        'purity',
        'weight',
        'weight_unit',
        'rate_per_unit',
        'calculated_value',
        'rate_updated_at',
        'rate_source',
        'quality_grade',
        'color',
        'certificate',
        'sort_order',
    ];

    protected $casts = [
        'weight' => 'decimal:4',
        'rate_per_unit' => 'decimal:2',
        'calculated_value' => 'decimal:2',
        'rate_updated_at' => 'datetime',
    ];

    // Metal type constants
    const TYPE_GOLD = 'gold';
    const TYPE_SILVER = 'silver';
    const TYPE_PLATINUM = 'platinum';
    const TYPE_DIAMOND = 'diamond';
    const TYPE_PEARL = 'pearl';
    const TYPE_RUBY = 'ruby';
    const TYPE_EMERALD = 'emerald';
    const TYPE_SAPPHIRE = 'sapphire';
    const TYPE_OTHER = 'other';

    // Rate source constants
    const SOURCE_LIVE_API = 'live_api';
    const SOURCE_MANUAL = 'manual';
    const SOURCE_FIXED = 'fixed';

    // Common purities by metal type
    const GOLD_PURITIES = ['24k', '22k', '18k', '14k'];
    const SILVER_PURITIES = ['999', '925', '800'];
    const PLATINUM_PURITIES = ['950', '900', '850'];
    const DIAMOND_QUALITIES = ['FL', 'IF', 'VVS1', 'VVS2', 'VS1', 'VS2', 'SI1', 'SI2', 'I1', 'I2', 'I3'];

    /**
     * Relationship to product.
     */
    public function product()
    {
        return $this->belongsTo(\App\Model\Product::class);
    }

    /**
     * Check if this is a precious metal (uses weight in grams).
     */
    public function isPreciousMetal(): bool
    {
        return in_array($this->metal_type, [self::TYPE_GOLD, self::TYPE_SILVER, self::TYPE_PLATINUM]);
    }

    /**
     * Check if this is a gemstone (uses weight in carats).
     */
    public function isGemstone(): bool
    {
        return in_array($this->metal_type, [self::TYPE_DIAMOND, self::TYPE_RUBY, self::TYPE_EMERALD, self::TYPE_SAPPHIRE, self::TYPE_PEARL]);
    }

    /**
     * Get purity percentage for calculation.
     */
    public function getPurityPercentage(): float
    {
        $purityMap = [
            // Gold
            '24k' => 99.9,
            '22k' => 91.67,
            '18k' => 75.0,
            '14k' => 58.3,
            // Silver
            '999' => 99.9,
            '925' => 92.5,
            '800' => 80.0,
            // Platinum
            '950' => 95.0,
            '900' => 90.0,
            '850' => 85.0,
        ];

        return $purityMap[$this->purity] ?? 100.0;
    }

    /**
     * Get the current market rate for this metal.
     */
    public function getCurrentRate(): ?float
    {
        if ($this->rate_source === self::SOURCE_FIXED) {
            return $this->rate_per_unit;
        }

        if ($this->isPreciousMetal()) {
            // Get rate from MetalRate model
            $rate = MetalRate::getCurrentRate($this->metal_type, $this->purity);
            return $rate;
        }

        // For gemstones, use the fixed rate_per_unit
        return $this->rate_per_unit;
    }

    /**
     * Calculate value based on weight and current rate.
     */
    public function calculateValue(): float
    {
        $rate = $this->getCurrentRate();
        
        if (!$rate || $this->weight <= 0) {
            return 0;
        }

        $value = $this->weight * $rate;

        // For precious metals with purity, adjust based on actual purity if needed
        // Most rates are already adjusted for purity (22k rate vs 24k rate)
        
        return round($value, 2);
    }

    /**
     * Update the calculated value and rate.
     */
    public function updateCalculatedValue(): self
    {
        $rate = $this->getCurrentRate();
        
        $this->rate_per_unit = $rate;
        $this->calculated_value = $this->calculateValue();
        $this->rate_updated_at = now();
        $this->save();
        
        return $this;
    }

    /**
     * Get label for display.
     */
    public function getDisplayLabel(): string
    {
        $label = ucfirst($this->metal_type);
        
        if ($this->purity) {
            $label .= ' ' . strtoupper($this->purity);
        }
        
        return $label;
    }

    /**
     * Get weight with unit for display.
     */
    public function getWeightDisplay(): string
    {
        $unit = $this->weight_unit === 'carat' ? 'ct' : ($this->weight_unit === 'milligram' ? 'mg' : 'g');
        return number_format($this->weight, 3) . ' ' . $unit;
    }

    /**
     * Scope for metals of a specific type.
     */
    public function scopeOfType($query, string $type)
    {
        return $query->where('metal_type', $type);
    }

    /**
     * Scope for precious metals only.
     */
    public function scopePreciousMetals($query)
    {
        return $query->whereIn('metal_type', [self::TYPE_GOLD, self::TYPE_SILVER, self::TYPE_PLATINUM]);
    }

    /**
     * Scope for gemstones only.
     */
    public function scopeGemstones($query)
    {
        return $query->whereIn('metal_type', [self::TYPE_DIAMOND, self::TYPE_RUBY, self::TYPE_EMERALD, self::TYPE_SAPPHIRE, self::TYPE_PEARL]);
    }

    /**
     * Get available metal types with labels.
     */
    public static function getMetalTypes(): array
    {
        return [
            self::TYPE_GOLD => 'Gold',
            self::TYPE_SILVER => 'Silver',
            self::TYPE_PLATINUM => 'Platinum',
            self::TYPE_DIAMOND => 'Diamond',
            self::TYPE_RUBY => 'Ruby',
            self::TYPE_EMERALD => 'Emerald',
            self::TYPE_SAPPHIRE => 'Sapphire',
            self::TYPE_PEARL => 'Pearl',
            self::TYPE_OTHER => 'Other',
        ];
    }

    /**
     * Get purities for a metal type.
     */
    public static function getPuritiesForType(string $type): array
    {
        return match($type) {
            self::TYPE_GOLD => ['24k' => '24K (99.9%)', '22k' => '22K (91.6%)', '18k' => '18K (75%)', '14k' => '14K (58.3%)'],
            self::TYPE_SILVER => ['999' => '999 Fine', '925' => '925 Sterling', '800' => '800 Standard'],
            self::TYPE_PLATINUM => ['950' => '950 Platinum', '900' => '900 Platinum', '850' => '850 Platinum'],
            self::TYPE_DIAMOND => ['VVS1' => 'VVS1', 'VVS2' => 'VVS2', 'VS1' => 'VS1', 'VS2' => 'VS2', 'SI1' => 'SI1', 'SI2' => 'SI2'],
            default => [],
        };
    }
}
