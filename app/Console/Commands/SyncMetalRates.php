<?php

namespace App\Console\Commands;

use App\Services\MetalPriceService;
use Illuminate\Console\Command;

class SyncMetalRates extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'metal:sync-rates {--force : Force sync even if disabled}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Sync metal rates from MetalPriceAPI';

    /**
     * Execute the console command.
     */
    public function handle(MetalPriceService $metalPriceService): int
    {
        if (!env('METAL_RATE_SYNC_ENABLED', false) && !$this->option('force')) {
            $this->warn('Metal rate sync is disabled. Use --force to override.');
            return Command::SUCCESS;
        }

        $this->info('Fetching latest metal rates from API...');

        $result = $metalPriceService->syncRatesToDatabase();

        if ($result['success']) {
            $this->info($result['message']);
            foreach ($result['updated'] as $update) {
                $this->line("  ✓ {$update}");
            }
            return Command::SUCCESS;
        }

        $this->error($result['message']);
        return Command::FAILURE;
    }
}
