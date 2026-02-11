<?php

namespace App\Console\Commands;

use App\Services\ProductPricingService;
use Illuminate\Console\Command;

class RecalculateProductPrices extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'products:recalculate-prices 
                            {--metal= : Recalculate only for specific metal type (gold, silver, platinum)}
                            {--purity= : Filter by purity (22k, 24k, etc.)}
                            {--product= : Recalculate for a specific product ID}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Recalculate prices for all dynamic-priced products based on current metal rates';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $pricingService = app(ProductPricingService::class);
        
        $this->info('Starting price recalculation...');
        $this->newLine();
        
        $start = microtime(true);
        
        if ($productId = $this->option('product')) {
            // Single product
            $product = \App\Model\Product::find($productId);
            
            if (!$product) {
                $this->error("Product not found: {$productId}");
                return 1;
            }
            
            if (!$product->is_price_dynamic) {
                $this->warn("Product {$productId} does not have dynamic pricing enabled.");
                return 0;
            }
            
            $oldPrice = $product->price;
            $pricingService->updateProductPrice($product);
            $product->refresh();
            
            $this->info("Updated product {$productId}:");
            $this->line("  Old Price: ₹" . number_format($oldPrice, 2));
            $this->line("  New Price: ₹" . number_format($product->price, 2));
            $this->line("  Difference: ₹" . number_format($product->price - $oldPrice, 2));
            
            return 0;
        }
        
        if ($metal = $this->option('metal')) {
            // Specific metal type
            $purity = $this->option('purity');
            $count = $pricingService->recalculatePricesForMetal($metal, $purity);
            
            $label = ucfirst($metal);
            if ($purity) {
                $label .= " ({$purity})";
            }
            
            $this->info("Recalculated prices for {$count} products containing {$label}");
        } else {
            // All dynamic-priced products
            $count = $pricingService->recalculateAllDynamicPrices();
            $this->info("Recalculated prices for {$count} dynamic-priced products");
        }
        
        $elapsed = round(microtime(true) - $start, 2);
        $this->newLine();
        $this->line("Completed in {$elapsed} seconds");
        
        return 0;
    }
}
