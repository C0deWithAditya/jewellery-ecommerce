<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add jewelry-specific columns to products table
        Schema::table('products', function (Blueprint $table) {
            // Metal details
            $table->enum('metal_type', ['gold', 'silver', 'platinum', 'none'])->default('none')->after('unit');
            $table->enum('metal_purity', ['24k', '22k', '18k', '14k', '999', '925', 'none'])->default('none')->after('metal_type');
            $table->decimal('gross_weight', 10, 3)->nullable()->after('metal_purity'); // Total weight in grams
            $table->decimal('net_weight', 10, 3)->nullable()->after('gross_weight'); // Metal weight only
            $table->decimal('stone_weight', 10, 3)->nullable()->after('net_weight'); // Stone weight in carats
            
            // Pricing components
            $table->decimal('making_charges', 12, 2)->default(0)->after('stone_weight');
            $table->enum('making_charge_type', ['fixed', 'percentage', 'per_gram'])->default('fixed')->after('making_charges');
            $table->decimal('stone_charges', 12, 2)->default(0)->after('making_charge_type');
            $table->decimal('other_charges', 12, 2)->default(0)->after('stone_charges');
            $table->boolean('is_price_dynamic')->default(false)->after('other_charges'); // Calculate from live rates
            
            // Jewelry details
            $table->string('hallmark_number', 50)->nullable()->after('is_price_dynamic');
            $table->string('huid', 20)->nullable()->after('hallmark_number'); // Hallmarking Unique ID
            $table->text('stone_details')->nullable()->after('huid'); // JSON for stone info
            $table->string('design_code', 50)->nullable()->after('stone_details');
            $table->enum('jewelry_type', ['ring', 'necklace', 'bracelet', 'earring', 'bangle', 'pendant', 'chain', 'anklet', 'other'])->nullable()->after('design_code');
            $table->string('size')->nullable()->after('jewelry_type'); // Ring size, bangle size, chain length
        });

        // Create a separate table for product stone details
        Schema::create('product_stones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            $table->string('stone_type'); // diamond, ruby, emerald, etc.
            $table->decimal('carat_weight', 8, 3)->nullable();
            $table->string('clarity')->nullable();
            $table->string('color')->nullable();
            $table->string('cut')->nullable();
            $table->integer('quantity')->default(1);
            $table->decimal('price', 12, 2)->default(0);
            $table->string('certificate_number')->nullable();
            $table->timestamps();
        });

        // Create table for product certifications
        Schema::create('product_certifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            $table->string('certification_type'); // BIS, IGI, GIA, etc.
            $table->string('certificate_number');
            $table->date('issue_date')->nullable();
            $table->date('expiry_date')->nullable();
            $table->string('certificate_image')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('product_certifications');
        Schema::dropIfExists('product_stones');
        
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn([
                'metal_type',
                'metal_purity',
                'gross_weight',
                'net_weight',
                'stone_weight',
                'making_charges',
                'making_charge_type',
                'stone_charges',
                'other_charges',
                'is_price_dynamic',
                'hallmark_number',
                'huid',
                'stone_details',
                'design_code',
                'jewelry_type',
                'size',
            ]);
        });
    }
};
