<?php

namespace App\Observers;

use App\Models\MetalRate;
use App\Services\ProductPricingService;
use Illuminate\Support\Facades\Log;

class MetalRateObserver
{
    protected ProductPricingService $pricingService;

    public function __construct(ProductPricingService $pricingService)
    {
        $this->pricingService = $pricingService;
    }

    /**
     * Handle the MetalRate "created" event.
     * When a new rate is created, recalculate affected product prices.
     */
    public function created(MetalRate $metalRate): void
    {
        $this->recalculatePricesForRate($metalRate);
    }

    /**
     * Handle the MetalRate "updated" event.
     * When a rate is updated (e.g., manual update), recalculate affected product prices.
     */
    public function updated(MetalRate $metalRate): void
    {
        // Only recalculate if the rate value actually changed
        if ($metalRate->wasChanged(['rate', 'rate_per_gram'])) {
            $this->recalculatePricesForRate($metalRate);
        }
    }

    /**
     * Recalculate prices for products containing this metal.
     */
    protected function recalculatePricesForRate(MetalRate $metalRate): void
    {
        try {
            // Queue this for async processing in production
            // For now, we'll do it synchronously but log it
            $metalType = $metalRate->metal_type;
            $purity = $metalRate->purity ?? null;

            Log::info("Metal rate changed for {$metalType} ({$purity}), recalculating product prices...");

            $count = $this->pricingService->recalculatePricesForMetal($metalType, $purity);

            Log::info("Recalculated prices for {$count} products containing {$metalType}");

        } catch (\Exception $e) {
            Log::error("Failed to recalculate prices after rate change: " . $e->getMessage());
        }
    }
}
