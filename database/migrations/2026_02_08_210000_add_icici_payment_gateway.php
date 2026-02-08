<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Insert ICICI Eazypay payment configuration
        $iciciConfig = [
            'id' => Str::uuid(),
            'key_name' => 'icici_eazypay',
            'live_values' => json_encode([
                'gateway' => 'icici_eazypay',
                'mode' => 'live',
                'status' => '0',
                'merchant_id' => '',
                'terminal_id' => '',
                'encryption_key' => '',
                'sub_merchant_id' => '',
            ]),
            'test_values' => json_encode([
                'gateway' => 'icici_eazypay',
                'mode' => 'test',
                'status' => '0',
                'merchant_id' => '',
                'terminal_id' => '',
                'encryption_key' => '',
                'sub_merchant_id' => '',
            ]),
            'settings_type' => 'payment_config',
            'mode' => 'test',
            'is_active' => 0,
            'created_at' => now(),
            'updated_at' => now(),
            'additional_data' => json_encode([
                'gateway_title' => 'ICICI Eazypay',
                'gateway_image' => '',
            ]),
        ];

        // Check if already exists
        $exists = DB::table('addon_settings')
            ->where('key_name', 'icici_eazypay')
            ->where('settings_type', 'payment_config')
            ->exists();

        if (!$exists) {
            DB::table('addon_settings')->insert($iciciConfig);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('addon_settings')
            ->where('key_name', 'icici_eazypay')
            ->where('settings_type', 'payment_config')
            ->delete();
    }
};
