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
}
