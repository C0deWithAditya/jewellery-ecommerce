<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations - Enhance SIP Plans for Swarna Suraksha Yojana
     */
    public function up(): void
    {
        // Add additional fields to sip_plans for scheme features
        Schema::table('sip_plans', function (Blueprint $table) {
            // Scheme type and branding
            $table->string('scheme_code', 50)->nullable()->after('name');
            $table->string('display_name')->nullable()->after('scheme_code');
            $table->string('tagline')->nullable()->after('display_name');
            $table->string('banner_image')->nullable()->after('tagline');
            $table->string('icon')->nullable()->after('banner_image');
            $table->string('color_code', 7)->default('#f5af19')->after('icon');
            
            // Scheme specific features
            $table->integer('maturity_days')->default(330)->after('duration_months'); // e.g., 330 days
            $table->integer('redemption_window_days')->default(35)->after('maturity_days'); // 35 days after maturity
            $table->decimal('amount_increment', 10, 2)->default(500)->after('max_amount'); // Increment multiples
            
            // Making charges discounts
            $table->decimal('gold_making_discount', 5, 2)->default(75)->after('bonus_percentage'); // 75% discount
            $table->decimal('diamond_making_discount', 5, 2)->default(60)->after('gold_making_discount'); // 60% discount
            $table->decimal('silver_making_discount', 5, 2)->default(100)->after('diamond_making_discount'); // 100% discount
            
            // Rewards and gifts (for Swarna Suraksha Yojana)
            $table->text('appreciation_gifts')->nullable()->after('silver_making_discount'); // JSON array of gifts
            $table->string('premium_reward')->nullable()->after('appreciation_gifts'); // e.g., "Car", "Bike"
            $table->boolean('has_lucky_draw')->default(false)->after('premium_reward');
            
            // Scheme conditions
            $table->boolean('is_refundable')->default(false)->after('has_lucky_draw');
            $table->boolean('price_lock_enabled')->default(true)->after('is_refundable'); // Lock gold price on payment day
            $table->text('terms_conditions')->nullable()->after('price_lock_enabled');
            $table->text('benefits')->nullable()->after('terms_conditions'); // JSON array of benefits
            
            // Scheme type classification
            $table->enum('scheme_type', ['super_gold', 'swarna_suraksha', 'flexi_save', 'regular'])->default('regular')->after('benefits');
            
            // Visibility
            $table->boolean('show_on_app')->default(true)->after('is_active');
            $table->boolean('show_on_web')->default(true)->after('show_on_app');
            $table->boolean('featured')->default(false)->after('show_on_web');
        });

        // Add scheme-specific fields to user_sips
        Schema::table('user_sips', function (Blueprint $table) {
            $table->date('maturity_date')->nullable()->after('end_date');
            $table->date('redemption_deadline')->nullable()->after('maturity_date');
            $table->decimal('locked_gold_rate', 12, 2)->nullable()->after('total_gold_grams'); // Locked rate on join
            $table->decimal('appreciation_bonus', 10, 4)->default(0)->after('locked_gold_rate'); // Bonus gold grams
            $table->boolean('eligible_for_reward')->default(false)->after('appreciation_bonus');
            $table->string('reward_status')->nullable()->after('eligible_for_reward'); // pending, claimed, expired
            $table->timestamp('redeemed_at')->nullable()->after('reward_status');
        });

        // Create scheme rewards table for Swarna Suraksha Yojana lucky draws and gifts
        Schema::create('sip_scheme_rewards', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('sip_plan_id');
            $table->string('reward_name');
            $table->text('reward_description')->nullable();
            $table->string('reward_image')->nullable();
            $table->decimal('reward_value', 12, 2)->default(0);
            $table->enum('reward_type', ['appreciation_gift', 'premium_reward', 'lucky_draw', 'milestone'])->default('appreciation_gift');
            $table->integer('min_installments_required')->default(6); // Minimum payments to qualify
            $table->integer('quantity_available')->default(1);
            $table->integer('quantity_claimed')->default(0);
            $table->boolean('is_active')->default(true);
            $table->date('valid_from')->nullable();
            $table->date('valid_until')->nullable();
            $table->timestamps();

            $table->foreign('sip_plan_id')->references('id')->on('sip_plans')->onDelete('cascade');
        });

        // Create reward claims table
        Schema::create('sip_reward_claims', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_sip_id');
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('reward_id');
            $table->enum('status', ['pending', 'approved', 'claimed', 'rejected'])->default('pending');
            $table->text('claim_notes')->nullable();
            $table->text('admin_notes')->nullable();
            $table->timestamp('claimed_at')->nullable();
            $table->timestamps();

            $table->foreign('user_sip_id')->references('id')->on('user_sips')->onDelete('cascade');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('reward_id')->references('id')->on('sip_scheme_rewards')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sip_reward_claims');
        Schema::dropIfExists('sip_scheme_rewards');

        Schema::table('user_sips', function (Blueprint $table) {
            $table->dropColumn([
                'maturity_date', 'redemption_deadline', 'locked_gold_rate',
                'appreciation_bonus', 'eligible_for_reward', 'reward_status', 'redeemed_at'
            ]);
        });

        Schema::table('sip_plans', function (Blueprint $table) {
            $table->dropColumn([
                'scheme_code', 'display_name', 'tagline', 'banner_image', 'icon', 'color_code',
                'maturity_days', 'redemption_window_days', 'amount_increment',
                'gold_making_discount', 'diamond_making_discount', 'silver_making_discount',
                'appreciation_gifts', 'premium_reward', 'has_lucky_draw',
                'is_refundable', 'price_lock_enabled', 'terms_conditions', 'benefits',
                'scheme_type', 'show_on_app', 'show_on_web', 'featured'
            ]);
        });
    }
};
