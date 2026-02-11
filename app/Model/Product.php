<?php

namespace App\Model;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Storage;

class Product extends Model
{

    protected $casts = [
        'tax' => 'float',
        'price' => 'float',
        'status' => 'integer',
        'discount' => 'float',
        'set_menu' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'wishlist_count' => 'integer',
        'total_stock' => 'integer',
        // Jewelry specific fields
        'gross_weight' => 'float',
        'net_weight' => 'float',
        'stone_weight' => 'float',
        'making_charges' => 'float',
        'stone_charges' => 'float',
        'other_charges' => 'float',
        'is_price_dynamic' => 'boolean',
    ];

    protected $appends = ['image_fullpath'];

    public function getImageFullPathAttribute()
    {
        $value = $this->image ?? [];
        $imageUrlArray = is_array($value) ? $value : json_decode($value, true);
        
        if (!is_array($imageUrlArray)) {
            return [];
        }
        
        foreach ($imageUrlArray as $key => $item) {
            if (empty($item)) {
                $imageUrlArray[$key] = asset('public/assets/admin/img/160x160/img2.jpg');
                continue;
            }
            
            // Check if it's already a full URL
            if (filter_var($item, FILTER_VALIDATE_URL)) {
                $imageUrlArray[$key] = $item;
                continue;
            }
            
            // Check if file exists in storage
            if (Storage::disk('public')->exists('product/' . $item)) {
                // Use the correct storage URL
                $imageUrlArray[$key] = asset('storage/product/' . $item);
            } else {
                // Fallback to default image
                $imageUrlArray[$key] = asset('public/assets/admin/img/160x160/img2.jpg');
            }
        }
        
        return $imageUrlArray;
    }

    public function translations(): \Illuminate\Database\Eloquent\Relations\MorphMany
    {
        return $this->morphMany('App\Model\Translation', 'translationable');
    }

    public function scopeActive($query)
    {
        return $query->where('status', '=', 1);
    }

    public function reviews(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Review::class)->latest();
    }

    public function wishlist()
    {
        return $this->hasMany(Wishlist::class)->latest();
    }

    public function rating()
    {
        return $this->hasMany(Review::class)
            ->select(DB::raw('avg(rating) average, product_id'))
            ->groupBy('product_id');
    }

    protected static function booted()
    {
        static::addGlobalScope('translate', function (Builder $builder) {
            $builder->with(['translations' => function($query){
                return $query->where('locale', app()->getLocale());
            }]);
        });
    }

    // ==========================================
    // MULTI-METAL JEWELRY RELATIONSHIPS
    // ==========================================

    /**
     * Get all metal components for this product.
     */
    public function metals(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(\App\Models\ProductMetal::class)->orderBy('sort_order');
    }

    /**
     * Get stone details for this product.
     */
    public function stones(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(\App\Models\ProductStone::class);
    }

    /**
     * Get certifications for this product.
     */
    public function certifications(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(\App\Models\ProductCertification::class);
    }

    // ==========================================
    // DYNAMIC PRICING METHODS
    // ==========================================

    /**
     * Calculate and get the current price.
     */
    public function getCurrentPrice(): float
    {
        if ($this->is_price_dynamic && $this->metals()->exists()) {
            $pricingService = app(\App\Services\ProductPricingService::class);
            $pricing = $pricingService->calculateProductPrice($this);
            return $pricing['total_price'];
        }

        return floatval($this->price);
    }

    /**
     * Get full price breakdown.
     */
    public function getPriceBreakdown(): array
    {
        if (!$this->is_price_dynamic) {
            return [
                'base_metal_value' => 0,
                'making_charges' => floatval($this->making_charges ?? 0),
                'stone_charges' => floatval($this->stone_charges ?? 0),
                'other_charges' => floatval($this->other_charges ?? 0),
                'total_price' => floatval($this->price),
            ];
        }

        $pricingService = app(\App\Services\ProductPricingService::class);
        return $pricingService->calculateProductPrice($this);
    }

    /**
     * Update price from current metal rates.
     */
    public function recalculatePrice(): self
    {
        if ($this->is_price_dynamic) {
            $pricingService = app(\App\Services\ProductPricingService::class);
            $pricingService->updateProductPrice($this);
        }

        return $this->fresh();
    }

    /**
     * Get total metal weight in grams.
     */
    public function getTotalMetalWeight(): float
    {
        return $this->metals()
            ->where('weight_unit', 'gram')
            ->sum('weight');
    }

    /**
     * Get list of metal types in this product.
     */
    public function getMetalTypes(): array
    {
        return $this->metals()
            ->pluck('metal_type')
            ->unique()
            ->values()
            ->toArray();
    }

    /**
     * Check if product has multiple metals.
     */
    public function hasMultipleMetals(): bool
    {
        return $this->metals()->count() > 1;
    }

    /**
     * Get display label for metal composition.
     */
    public function getMetalCompositionLabel(): string
    {
        $metals = $this->metals()->get();
        
        if ($metals->isEmpty()) {
            return ucfirst($this->metal_type ?? 'N/A');
        }

        return $metals->map(function ($metal) {
            $label = ucfirst($metal->metal_type);
            if ($metal->purity) {
                $label .= ' ' . strtoupper($metal->purity);
            }
            $label .= ' (' . $metal->getWeightDisplay() . ')';
            return $label;
        })->implode(' + ');
    }

    /**
     * Scope for products with dynamic pricing.
     */
    public function scopeDynamicPriced($query)
    {
        return $query->where('is_price_dynamic', true);
    }

    /**
     * Scope for products containing a specific metal type.
     */
    public function scopeContainsMetal($query, string $metalType)
    {
        return $query->whereHas('metals', function ($q) use ($metalType) {
            $q->where('metal_type', $metalType);
        });
    }
}

