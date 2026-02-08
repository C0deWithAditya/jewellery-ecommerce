<?php

namespace App\Services;

use App\Models\MetalRate;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class MetalPriceService
{
    protected $apiKey;
    protected $baseUrl = 'https://api.metalpriceapi.com/v1';
    protected $baseCurrency = 'INR';
    
    // Metal symbols
    const GOLD = 'XAU';
    const SILVER = 'XAG';
    const PLATINUM = 'XPT';
    
    // Gold purity percentages
    const PURITY_24K = 0.999;
    const PURITY_22K = 0.916;
    const PURITY_18K = 0.750;
    const PURITY_14K = 0.583;

    public function __construct()
    {
        $this->apiKey = config('services.metal_price.api_key', env('METAL_PRICE_API_KEY'));
    }

    /**
     * Fetch latest metal rates from API
     */
    public function fetchLatestRates(): array
    {
        try {
            $response = Http::get("{$this->baseUrl}/latest", [
                'api_key' => $this->apiKey,
                'base' => $this->baseCurrency,
                'currencies' => implode(',', [self::GOLD, self::SILVER, self::PLATINUM]),
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if ($data['success'] ?? false) {
                    return $this->processApiResponse($data);
                }
            }

            Log::error('MetalPriceAPI: Failed to fetch rates', [
                'response' => $response->body()
            ]);

            return $this->getFallbackRates();

        } catch (\Exception $e) {
            Log::error('MetalPriceAPI: Exception', [
                'message' => $e->getMessage()
            ]);
            
            return $this->getFallbackRates();
        }
    }

    /**
     * Fetch carat-specific gold rates
     */
    public function fetchCaratRates(): array
    {
        try {
            $response = Http::get("{$this->baseUrl}/carat", [
                'api_key' => $this->apiKey,
                'base' => $this->baseCurrency,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if ($data['success'] ?? false) {
                    return $data['rates'] ?? [];
                }
            }

            return [];

        } catch (\Exception $e) {
            Log::error('MetalPriceAPI: Carat rates exception', [
                'message' => $e->getMessage()
            ]);
            
            return [];
        }
    }

    /**
     * Fetch historical rates for a specific date
     */
    public function fetchHistoricalRates(string $date): array
    {
        try {
            $response = Http::get("{$this->baseUrl}/{$date}", [
                'api_key' => $this->apiKey,
                'base' => $this->baseCurrency,
                'currencies' => implode(',', [self::GOLD, self::SILVER, self::PLATINUM]),
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if ($data['success'] ?? false) {
                    return $this->processApiResponse($data, $date);
                }
            }

            return [];

        } catch (\Exception $e) {
            Log::error('MetalPriceAPI: Historical rates exception', [
                'message' => $e->getMessage()
            ]);
            
            return [];
        }
    }

    /**
     * Fetch rates for a time range
     */
    public function fetchTimeframeRates(string $startDate, string $endDate): array
    {
        try {
            $response = Http::get("{$this->baseUrl}/timeframe", [
                'api_key' => $this->apiKey,
                'base' => $this->baseCurrency,
                'start_date' => $startDate,
                'end_date' => $endDate,
                'currencies' => implode(',', [self::GOLD, self::SILVER, self::PLATINUM]),
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if ($data['success'] ?? false) {
                    return $data['rates'] ?? [];
                }
            }

            return [];

        } catch (\Exception $e) {
            Log::error('MetalPriceAPI: Timeframe rates exception', [
                'message' => $e->getMessage()
            ]);
            
            return [];
        }
    }

    /**
     * Process API response and convert to per-gram rates
     */
    protected function processApiResponse(array $data, ?string $date = null): array
    {
        $rates = $data['rates'] ?? [];
        $processedRates = [];

        // API returns price per troy ounce, convert to grams
        // 1 troy ounce = 31.1035 grams
        $troyOunceToGram = 31.1035;

        foreach ($rates as $symbol => $pricePerOunce) {
            // Price is in base currency per 1 unit of metal
            // We need to invert it (INR per ounce of metal)
            $ratePerGram = $pricePerOunce > 0 ? (1 / $pricePerOunce) / $troyOunceToGram : 0;
            
            $metalType = $this->symbolToMetal($symbol);
            if ($metalType) {
                $processedRates[$metalType] = [
                    'rate_per_gram' => round($ratePerGram, 2),
                    'rate_per_ounce' => round(1 / $pricePerOunce, 2),
                    'symbol' => $symbol,
                    'date' => $date ?? $data['date'] ?? now()->toDateString(),
                ];
            }
        }

        return $processedRates;
    }

    /**
     * Convert API symbol to metal type
     */
    protected function symbolToMetal(string $symbol): ?string
    {
        return match ($symbol) {
            self::GOLD => 'gold',
            self::SILVER => 'silver',
            self::PLATINUM => 'platinum',
            default => null,
        };
    }

    /**
     * Get fallback rates from database
     */
    protected function getFallbackRates(): array
    {
        $rates = MetalRate::current()->get();
        
        $fallbackRates = [];
        foreach ($rates as $rate) {
            $fallbackRates[$rate->metal_type][$rate->purity] = [
                'rate_per_gram' => $rate->rate_per_gram,
                'source' => 'database',
                'is_fallback' => true,
            ];
        }

        return $fallbackRates;
    }

    /**
     * Update database with latest rates from API
     */
    public function syncRatesToDatabase(): array
    {
        $latestRates = $this->fetchLatestRates();
        
        if (empty($latestRates)) {
            return ['success' => false, 'message' => 'Failed to fetch rates from API'];
        }

        $updated = [];

        foreach ($latestRates as $metalType => $rateData) {
            // For gold, calculate different purities
            if ($metalType === 'gold') {
                $baseRate = $rateData['rate_per_gram'];
                
                $purities = [
                    '24k' => self::PURITY_24K,
                    '22k' => self::PURITY_22K,
                    '18k' => self::PURITY_18K,
                    '14k' => self::PURITY_14K,
                ];

                foreach ($purities as $purity => $multiplier) {
                    $purityRate = round($baseRate * $multiplier, 2);
                    MetalRate::updateRate($metalType, $purity, $purityRate, 'api');
                    $updated[] = "{$metalType} ({$purity}): ₹{$purityRate}/g";
                }
            } else {
                // Silver and Platinum
                $purity = $metalType === 'silver' ? '999' : '999';
                MetalRate::updateRate($metalType, $purity, $rateData['rate_per_gram'], 'api');
                $updated[] = "{$metalType} ({$purity}): ₹{$rateData['rate_per_gram']}/g";
            }
        }

        // Clear rate cache
        Cache::forget('current_metal_rates');
        Cache::forget('metal_rates_widget');

        return [
            'success' => true,
            'message' => 'Rates updated successfully',
            'updated' => $updated,
        ];
    }

    /**
     * Get current rates (cached)
     */
    public function getCurrentRates(): array
    {
        return Cache::remember('current_metal_rates', 300, function () {
            $rates = MetalRate::current()->get();
            
            $formatted = [];
            foreach ($rates as $rate) {
                $formatted[$rate->metal_type][$rate->purity] = [
                    'rate_per_gram' => $rate->rate_per_gram,
                    'rate_per_10gram' => $rate->rate_per_gram * 10,
                    'updated_at' => $rate->updated_at->toIso8601String(),
                    'source' => $rate->source,
                ];
            }

            return $formatted;
        });
    }

    /**
     * Calculate product price based on metal
     */
    public function calculateProductPrice(
        string $metalType,
        string $purity,
        float $weightGrams,
        float $makingCharges = 0,
        string $makingChargeType = 'fixed', // 'fixed' or 'percentage'
        float $stoneCharges = 0,
        float $taxPercent = 3
    ): array {
        $rate = MetalRate::getCurrentRate($metalType, $purity);
        
        if (!$rate) {
            return [
                'success' => false,
                'message' => 'Metal rate not found',
            ];
        }

        $metalValue = $weightGrams * $rate;
        
        // Calculate making charges
        $makingAmount = $makingChargeType === 'percentage' 
            ? ($metalValue * $makingCharges / 100)
            : $makingCharges;

        $subtotal = $metalValue + $makingAmount + $stoneCharges;
        $taxAmount = $subtotal * ($taxPercent / 100);
        $totalPrice = $subtotal + $taxAmount;

        return [
            'success' => true,
            'breakdown' => [
                'metal_rate' => $rate,
                'metal_value' => round($metalValue, 2),
                'making_charges' => round($makingAmount, 2),
                'stone_charges' => round($stoneCharges, 2),
                'subtotal' => round($subtotal, 2),
                'tax_percent' => $taxPercent,
                'tax_amount' => round($taxAmount, 2),
                'total_price' => round($totalPrice, 2),
            ],
        ];
    }

    /**
     * Get rate history for trend analysis
     */
    public function getRateHistory(string $metalType, int $days = 30): array
    {
        return MetalRate::where('metal_type', $metalType)
            ->where('created_at', '>=', now()->subDays($days))
            ->orderBy('created_at', 'asc')
            ->get()
            ->groupBy(function ($rate) {
                return $rate->created_at->format('Y-m-d');
            })
            ->map(function ($rates) {
                return $rates->first();
            })
            ->values()
            ->toArray();
    }

    /**
     * Get widget data for Flutter app
     */
    public function getWidgetData(): array
    {
        return Cache::remember('metal_rates_widget', 300, function () {
            $rates = MetalRate::current()->get();
            
            $widget = [
                'last_updated' => now()->toIso8601String(),
                'currency' => 'INR',
                'metals' => [],
            ];

            foreach ($rates as $rate) {
                $widget['metals'][] = [
                    'type' => $rate->metal_type,
                    'purity' => $rate->purity,
                    'rate_per_gram' => $rate->rate_per_gram,
                    'rate_per_10gram' => $rate->rate_per_gram * 10,
                    'display_name' => ucfirst($rate->metal_type) . ' (' . strtoupper($rate->purity) . ')',
                    'icon' => $this->getMetalIcon($rate->metal_type),
                    'color' => $this->getMetalColor($rate->metal_type),
                ];
            }

            return $widget;
        });
    }

    protected function getMetalIcon(string $metalType): string
    {
        return match ($metalType) {
            'gold' => '🥇',
            'silver' => '🥈',
            'platinum' => '💎',
            default => '💰',
        };
    }

    protected function getMetalColor(string $metalType): string
    {
        return match ($metalType) {
            'gold' => '#FFD700',
            'silver' => '#C0C0C0',
            'platinum' => '#E5E4E2',
            default => '#808080',
        };
    }
}
