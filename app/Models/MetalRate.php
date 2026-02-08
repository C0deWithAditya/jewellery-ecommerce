<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MetalRate extends Model
{
    use HasFactory;

    protected $fillable = [
        'metal_type',
        'purity',
        'rate_per_gram',
        'rate_per_10gram',
        'currency',
        'source',
        'is_current',
    ];

    protected $casts = [
        'rate_per_gram' => 'decimal:2',
        'rate_per_10gram' => 'decimal:2',
        'is_current' => 'boolean',
    ];

    // Metal types
    const METAL_GOLD = 'gold';
    const METAL_SILVER = 'silver';
    const METAL_PLATINUM = 'platinum';

    // Common purities
    const PURITY_24K = '24k';
    const PURITY_22K = '22k';
    const PURITY_18K = '18k';
    const PURITY_14K = '14k';
    const PURITY_999 = '999'; // Silver
    const PURITY_925 = '925'; // Sterling Silver

    // Source types
    const SOURCE_API = 'api';
    const SOURCE_MANUAL = 'manual';

    /**
     * Scope for current rates.
     */
    public function scopeCurrent($query)
    {
        return $query->where('is_current', true);
    }

    /**
     * Scope by metal type.
     */
    public function scopeByMetal($query, $metalType)
    {
        return $query->where('metal_type', $metalType);
    }

    /**
     * Get current rate for a specific metal and purity.
     */
    public static function getCurrentRate(string $metalType, ?string $purity = null): ?float
    {
        $query = self::where('metal_type', $metalType)
                     ->where('is_current', true);
        
        if ($purity) {
            $query->where('purity', $purity);
        }

        $rate = $query->first();
        
        return $rate ? $rate->rate_per_gram : null;
    }

    /**
     * Set this rate as current (and unset others).
     */
    public function setAsCurrent(): void
    {
        // Unset current for same metal + purity
        self::where('metal_type', $this->metal_type)
            ->where('purity', $this->purity)
            ->where('is_current', true)
            ->update(['is_current' => false]);

        $this->update(['is_current' => true]);
    }

    /**
     * Create or update current rate.
     */
    public static function updateRate(string $metalType, string $purity, float $ratePerGram, string $source = 'manual'): self
    {
        $rate = self::create([
            'metal_type' => $metalType,
            'purity' => $purity,
            'rate_per_gram' => $ratePerGram,
            'rate_per_10gram' => $ratePerGram * 10,
            'currency' => 'INR',
            'source' => $source,
            'is_current' => false,
        ]);

        $rate->setAsCurrent();

        return $rate;
    }

    /**
     * Get formatted rate.
     */
    public function getFormattedRateAttribute(): string
    {
        return '₹' . number_format($this->rate_per_gram, 2) . '/g';
    }

    /**
     * Get available metal types.
     */
    public static function getMetalTypes(): array
    {
        return [
            self::METAL_GOLD => 'Gold',
            self::METAL_SILVER => 'Silver',
            self::METAL_PLATINUM => 'Platinum',
        ];
    }

    /**
     * Get available purities for gold.
     */
    public static function getGoldPurities(): array
    {
        return [
            self::PURITY_24K => '24 Karat (99.9%)',
            self::PURITY_22K => '22 Karat (91.6%)',
            self::PURITY_18K => '18 Karat (75%)',
            self::PURITY_14K => '14 Karat (58.3%)',
        ];
    }
}
