<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * This migration creates a junction table for products and their metal components.
     * A product can have multiple metals (e.g., Gold + Silver + Diamond).
     * Each metal has its own weight, purity, and rate.
     */
    public function up(): void
    {
        // Create product_metals table for multi-metal products
        Schema::create('product_metals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            
            // Metal identification
            $table->enum('metal_type', ['gold', 'silver', 'platinum', 'diamond', 'pearl', 'ruby', 'emerald', 'sapphire', 'other'])->default('gold');
            $table->string('purity', 20)->nullable(); // '24k', '22k', '18k', '999', 'VVS', 'VS', etc.
            
            // Weight details
            $table->decimal('weight', 10, 4)->default(0); // Weight in grams for metals, carats for stones
            $table->enum('weight_unit', ['gram', 'carat', 'milligram'])->default('gram');
            
            // Rate and value calculation
            $table->decimal('rate_per_unit', 12, 2)->nullable(); // Current rate per gram/carat
            $table->decimal('calculated_value', 14, 2)->default(0); // weight * rate_per_unit
            $table->timestamp('rate_updated_at')->nullable(); // When was this rate last updated
            
            // Source of rate (for audit)
            $table->enum('rate_source', ['live_api', 'manual', 'fixed'])->default('live_api');
            
            // Additional details
            $table->string('quality_grade')->nullable(); // For diamonds: VVS, VS, SI; For pearls: AAA, AA, A
            $table->string('color')->nullable(); // D, E, F for diamonds; white, golden for pearls
            $table->string('certificate')->nullable(); // IGI, GIA certificate number
            
            // Sort order (to display gold first, then diamonds, then silver)
            $table->integer('sort_order')->default(0);
            
            $table->timestamps();
            
            // Index for quick lookups
            $table->index(['product_id', 'metal_type']);
        });
        
        // Add new columns to products table for multi-metal support
        Schema::table('products', function (Blueprint $table) {
            // Base metal value (sum of all metal values)
            $table->decimal('base_metal_value', 14, 2)->default(0)->after('is_price_dynamic');
            
            // Total calculated price (base_metal_value + making + stone + other + tax)
            $table->decimal('calculated_price', 14, 2)->default(0)->after('base_metal_value');
            
            // Wastage charges (some jewelers charge this)
            $table->decimal('wastage_charges', 10, 2)->default(0)->after('other_charges');
            $table->enum('wastage_type', ['fixed', 'percentage', 'per_gram'])->default('percentage')->after('wastage_charges');
            
            // When was the price last recalculated
            $table->timestamp('price_calculated_at')->nullable()->after('calculated_price');
            
            // Flag to indicate if this product has multiple metals
            $table->boolean('is_multi_metal')->default(false)->after('is_price_dynamic');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('product_metals');
        
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn([
                'base_metal_value',
                'calculated_price',
                'wastage_charges',
                'wastage_type',
                'price_calculated_at',
                'is_multi_metal',
            ]);
        });
    }
};
