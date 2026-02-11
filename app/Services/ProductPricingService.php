<?php

namespace App\Services;

use App\Model\Product;
use App\Models\ProductMetal;
use App\Models\MetalRate;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ProductPricingService
{
    /**
     * Calculate the total price for a product based on its metal components.
     * 
     * Price Formula:
     * Total = Base Metal Value + Making Charges + Stone Charges + Wastage + Other Charges + GST
     * 
     * Making Charges can be:
     * - Fixed: A fixed amount
     * - Percentage: Percentage of metal value
     * - Per Gram: Amount × total weight
     */
    public function calculateProductPrice(Product $product): array
    {
        // Get all metal components
        $metals = $product->metals()->orderBy('sort_order')->get();
        
        // Calculate base metal value
        $baseMetalValue = 0;
        $metalBreakdown = [];
        
        foreach ($metals as $metal) {
            $rate = $this->getMetalRate($metal);
            $value = $metal->weight * $rate;
            
            $metalBreakdown[] = [
                'id' => $metal->id,
                'type' => $metal->metal_type,
                'purity' => $metal->purity,
                'weight' => $metal->weight,
                'weight_unit' => $metal->weight_unit,
                'rate' => $rate,
                'value' => round($value, 2),
            ];
            
            $baseMetalValue += $value;
        }
        
        // Calculate making charges
        $makingCharges = $this->calculateMakingCharges($product, $baseMetalValue);
        
        // Wastage charges
        $wastageCharges = $this->calculateWastageCharges($product, $baseMetalValue);
        
        // Stone charges (fixed, already stored in product)
        $stoneCharges = floatval($product->stone_charges ?? 0);
        
        // Other charges (fixed)
        $otherCharges = floatval($product->other_charges ?? 0);
        
        // Subtotal before tax
        $subtotal = $baseMetalValue + $makingCharges + $wastageCharges + $stoneCharges + $otherCharges;
        
        // Calculate GST (3% for gold jewelry in India)
        $gstRate = 3;
        $gstAmount = ($subtotal * $gstRate) / 100;
        
        // Total price
        $totalPrice = $subtotal + $gstAmount;
        
        return [
            'metal_breakdown' => $metalBreakdown,
            'base_metal_value' => round($baseMetalValue, 2),
            'making_charges' => round($makingCharges, 2),
            'wastage_charges' => round($wastageCharges, 2),
            'stone_charges' => round($stoneCharges, 2),
            'other_charges' => round($otherCharges, 2),
            'subtotal' => round($subtotal, 2),
            'gst_rate' => $gstRate,
            'gst_amount' => round($gstAmount, 2),
            'total_price' => round($totalPrice, 2),
            'calculated_at' => now()->toDateTimeString(),
        ];
    }

    /**
     * Get the current rate for a metal component.
     */
    protected function getMetalRate(ProductMetal $metal): float
    {
        // If using fixed rate, return it
        if ($metal->rate_source === ProductMetal::SOURCE_FIXED && $metal->rate_per_unit > 0) {
            return floatval($metal->rate_per_unit);
        }

        // For precious metals, get from MetalRate
        if ($metal->isPreciousMetal()) {
            $rate = MetalRate::getCurrentRate($metal->metal_type, $metal->purity);
            return $rate ?? 0;
        }

        // For gemstones, use the stored rate
        return floatval($metal->rate_per_unit ?? 0);
    }

    /**
     * Calculate making charges based on type.
     */
    protected function calculateMakingCharges(Product $product, float $metalValue): float
    {
        $makingCharges = floatval($product->making_charges ?? 0);
        $chargeType = $product->making_charge_type ?? 'fixed';

        return match($chargeType) {
            'percentage' => ($metalValue * $makingCharges) / 100,
            'per_gram' => $makingCharges * floatval($product->net_weight ?? $product->gross_weight ?? 0),
            default => $makingCharges, // 'fixed'
        };
    }

    /**
     * Calculate wastage charges based on type.
     */
    protected function calculateWastageCharges(Product $product, float $metalValue): float
    {
        $wastageCharges = floatval($product->wastage_charges ?? 0);
        $chargeType = $product->wastage_type ?? 'percentage';

        return match($chargeType) {
            'percentage' => ($metalValue * $wastageCharges) / 100,
            'per_gram' => $wastageCharges * floatval($product->net_weight ?? $product->gross_weight ?? 0),
            default => $wastageCharges,
        };
    }

    /**
     * Update product price and save to database.
     */
    public function updateProductPrice(Product $product): Product
    {
        if (!$product->is_price_dynamic) {
            return $product;
        }

        $pricing = $this->calculateProductPrice($product);

        $product->update([
            'base_metal_value' => $pricing['base_metal_value'],
            'calculated_price' => $pricing['total_price'],
            'price' => $pricing['total_price'], // Update the main price field
            'price_calculated_at' => now(),
        ]);

        // Update each metal component's rate and value
        foreach ($pricing['metal_breakdown'] as $metalData) {
            ProductMetal::where('id', $metalData['id'])->update([
                'rate_per_unit' => $metalData['rate'],
                'calculated_value' => $metalData['value'],
                'rate_updated_at' => now(),
            ]);
        }

        return $product->fresh();
    }

    /**
     * Recalculate prices for all dynamic-priced products.
     * This should be called when metal rates are updated.
     */
    public function recalculateAllDynamicPrices(): int
    {
        $count = 0;
        
        Product::where('is_price_dynamic', true)
            ->chunkById(100, function ($products) use (&$count) {
                foreach ($products as $product) {
                    try {
                        $this->updateProductPrice($product);
                        $count++;
                    } catch (\Exception $e) {
                        Log::error("Failed to update price for product {$product->id}: " . $e->getMessage());
                    }
                }
            });

        Log::info("Recalculated prices for {$count} products");
        
        return $count;
    }

    /**
     * Recalculate prices for products with a specific metal type.
     */
    public function recalculatePricesForMetal(string $metalType, ?string $purity = null): int
    {
        $count = 0;
        
        $query = Product::where('is_price_dynamic', true)
            ->whereHas('metals', function ($q) use ($metalType, $purity) {
                $q->where('metal_type', $metalType);
                if ($purity) {
                    $q->where('purity', $purity);
                }
            });

        $query->chunkById(100, function ($products) use (&$count) {
            foreach ($products as $product) {
                try {
                    $this->updateProductPrice($product);
                    $count++;
                } catch (\Exception $e) {
                    Log::error("Failed to update price for product {$product->id}: " . $e->getMessage());
                }
            }
        });

        Log::info("Recalculated prices for {$count} products containing {$metalType}");
        
        return $count;
    }

    /**
     * Preview price calculation without saving.
     * Useful for showing price breakdown in admin forms.
     */
    public function previewPrice(array $metals, array $charges): array
    {
        $baseMetalValue = 0;
        $metalBreakdown = [];
        $totalWeight = 0;

        foreach ($metals as $metal) {
            $rate = $this->getPreviewRate($metal);
            $weight = floatval($metal['weight'] ?? 0);
            $value = $weight * $rate;
            
            $metalBreakdown[] = [
                'type' => $metal['metal_type'],
                'purity' => $metal['purity'] ?? null,
                'weight' => $weight,
                'weight_unit' => $metal['weight_unit'] ?? 'gram',
                'rate' => $rate,
                'value' => round($value, 2),
            ];
            
            $baseMetalValue += $value;
            
            // Add to total weight if it's in grams
            if (($metal['weight_unit'] ?? 'gram') === 'gram') {
                $totalWeight += $weight;
            }
        }

        // Making charges
        $makingCharges = floatval($charges['making_charges'] ?? 0);
        $makingChargeType = $charges['making_charge_type'] ?? 'fixed';
        $makingAmount = match($makingChargeType) {
            'percentage' => ($baseMetalValue * $makingCharges) / 100,
            'per_gram' => $makingCharges * $totalWeight,
            default => $makingCharges,
        };

        // Wastage
        $wastageCharges = floatval($charges['wastage_charges'] ?? 0);
        $wastageType = $charges['wastage_type'] ?? 'percentage';
        $wastageAmount = match($wastageType) {
            'percentage' => ($baseMetalValue * $wastageCharges) / 100,
            'per_gram' => $wastageCharges * $totalWeight,
            default => $wastageCharges,
        };

        // Other charges
        $stoneCharges = floatval($charges['stone_charges'] ?? 0);
        $otherCharges = floatval($charges['other_charges'] ?? 0);

        // Subtotal
        $subtotal = $baseMetalValue + $makingAmount + $wastageAmount + $stoneCharges + $otherCharges;

        // GST
        $gstRate = 3;
        $gstAmount = ($subtotal * $gstRate) / 100;

        return [
            'metal_breakdown' => $metalBreakdown,
            'base_metal_value' => round($baseMetalValue, 2),
            'making_charges' => round($makingAmount, 2),
            'wastage_charges' => round($wastageAmount, 2),
            'stone_charges' => round($stoneCharges, 2),
            'other_charges' => round($otherCharges, 2),
            'subtotal' => round($subtotal, 2),
            'gst_rate' => $gstRate,
            'gst_amount' => round($gstAmount, 2),
            'total_price' => round($subtotal + $gstAmount, 2),
        ];
    }

    /**
     * Get rate for preview calculation.
     */
    protected function getPreviewRate(array $metal): float
    {
        if (isset($metal['rate_per_unit']) && $metal['rate_per_unit'] > 0) {
            return floatval($metal['rate_per_unit']);
        }

        $metalType = $metal['metal_type'] ?? 'gold';
        $purity = $metal['purity'] ?? null;

        if (in_array($metalType, ['gold', 'silver', 'platinum'])) {
            return MetalRate::getCurrentRate($metalType, $purity) ?? 0;
        }

        return floatval($metal['rate_per_unit'] ?? 0);
    }
}
