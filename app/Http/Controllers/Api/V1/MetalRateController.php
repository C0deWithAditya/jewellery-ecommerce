<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\MetalRate;
use App\Services\MetalPriceService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class MetalRateController extends Controller
{
    protected $metalPriceService;

    public function __construct(MetalPriceService $metalPriceService)
    {
        $this->metalPriceService = $metalPriceService;
    }

    /**
     * Get current metal rates (for home widget)
     */
    public function currentRates(): JsonResponse
    {
        try {
            $widgetData = $this->metalPriceService->getWidgetData();
            
            return response()->json([
                'success' => true,
                'data' => $widgetData,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch metal rates',
            ], 500);
        }
    }

    /**
     * Get detailed rates with all purities
     */
    public function detailedRates(): JsonResponse
    {
        try {
            $rates = $this->metalPriceService->getCurrentRates();
            
            return response()->json([
                'success' => true,
                'data' => [
                    'rates' => $rates,
                    'currency' => 'INR',
                    'last_updated' => now()->toIso8601String(),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch detailed rates',
            ], 500);
        }
    }

    /**
     * Get rate history for charts
     */
    public function rateHistory(Request $request): JsonResponse
    {
        $metalType = $request->get('metal', 'gold');
        $days = min($request->get('days', 30), 90); // Max 90 days

        try {
            $history = $this->metalPriceService->getRateHistory($metalType, $days);
            
            return response()->json([
                'success' => true,
                'data' => [
                    'metal' => $metalType,
                    'days' => $days,
                    'history' => $history,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch rate history',
            ], 500);
        }
    }

    /**
     * Calculate price for a product configuration
     */
    public function calculatePrice(Request $request): JsonResponse
    {
        $request->validate([
            'metal_type' => 'required|in:gold,silver,platinum',
            'purity' => 'required|string',
            'weight' => 'required|numeric|min:0.01',
            'making_charges' => 'nullable|numeric|min:0',
            'making_charge_type' => 'nullable|in:fixed,percentage',
            'stone_charges' => 'nullable|numeric|min:0',
            'tax_percent' => 'nullable|numeric|min:0|max:28',
        ]);

        try {
            $result = $this->metalPriceService->calculateProductPrice(
                $request->metal_type,
                $request->purity,
                $request->weight,
                $request->making_charges ?? 0,
                $request->making_charge_type ?? 'fixed',
                $request->stone_charges ?? 0,
                $request->tax_percent ?? 3
            );

            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to calculate price',
            ], 500);
        }
    }

    /**
     * Get metal rate for specific metal and purity
     */
    public function getRate(Request $request): JsonResponse
    {
        $request->validate([
            'metal_type' => 'required|in:gold,silver,platinum',
            'purity' => 'required|string',
        ]);

        $rate = MetalRate::getCurrentRate($request->metal_type, $request->purity);

        if (!$rate) {
            return response()->json([
                'success' => false,
                'message' => 'Rate not found for specified metal and purity',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'metal_type' => $request->metal_type,
                'purity' => $request->purity,
                'rate_per_gram' => $rate,
                'rate_per_10gram' => $rate * 10,
                'currency' => 'INR',
            ],
        ]);
    }
}
