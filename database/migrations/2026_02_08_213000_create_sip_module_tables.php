<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations - Create SIP Module Tables
     */
    public function up(): void
    {
        // 1. KYC Documents Table
        Schema::create('kyc_documents', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->enum('document_type', ['pan', 'aadhar', 'passport', 'voter_id'])->default('pan');
            $table->string('document_number')->nullable();
            $table->string('document_front_image')->nullable();
            $table->string('document_back_image')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->text('rejection_reason')->nullable();
            $table->unsignedBigInteger('verified_by')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['user_id', 'status']);
        });

        // 2. SIP Plans Table
        Schema::create('sip_plans', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->enum('frequency', ['daily', 'weekly', 'monthly'])->default('monthly');
            $table->decimal('min_amount', 10, 2)->default(100);
            $table->decimal('max_amount', 10, 2)->default(100000);
            $table->integer('duration_months')->default(12);
            $table->integer('bonus_months')->default(0); // e.g., 11+1 scheme
            $table->decimal('bonus_percentage', 5, 2)->default(0); // Bonus gold percentage
            $table->enum('metal_type', ['gold', 'silver', 'platinum'])->default('gold');
            $table->enum('gold_purity', ['24k', '22k', '18k'])->default('22k');
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
            
            $table->index(['is_active', 'metal_type']);
        });

        // 3. User SIP Subscriptions Table
        Schema::create('user_sips', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('sip_plan_id');
            $table->decimal('monthly_amount', 10, 2);
            $table->date('start_date');
            $table->date('end_date');
            $table->date('next_payment_date')->nullable();
            $table->decimal('total_invested', 12, 2)->default(0);
            $table->decimal('total_gold_grams', 10, 4)->default(0);
            $table->integer('installments_paid')->default(0);
            $table->integer('installments_pending')->default(0);
            $table->enum('status', ['active', 'paused', 'completed', 'cancelled'])->default('active');
            $table->string('mandate_id')->nullable(); // For auto-debit
            $table->enum('mandate_status', ['pending', 'active', 'cancelled'])->nullable();
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('sip_plan_id')->references('id')->on('sip_plans')->onDelete('cascade');
            $table->index(['user_id', 'status']);
            $table->index(['next_payment_date', 'status']);
        });

        // 4. SIP Transactions Table
        Schema::create('sip_transactions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_sip_id');
            $table->unsignedBigInteger('user_id');
            $table->decimal('amount', 10, 2);
            $table->decimal('gold_rate', 10, 2); // Rate at time of purchase
            $table->decimal('gold_grams', 10, 4); // Grams purchased
            $table->string('transaction_id')->nullable();
            $table->string('payment_method')->nullable();
            $table->enum('status', ['pending', 'success', 'failed', 'refunded'])->default('pending');
            $table->date('installment_date');
            $table->integer('installment_number');
            $table->text('payment_response')->nullable();
            $table->timestamps();
            
            $table->foreign('user_sip_id')->references('id')->on('user_sips')->onDelete('cascade');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['user_sip_id', 'status']);
            $table->index(['user_id', 'created_at']);
        });

        // 5. Metal Rates Table (for rate history and calculations)
        Schema::create('metal_rates', function (Blueprint $table) {
            $table->id();
            $table->enum('metal_type', ['gold', 'silver', 'platinum'])->default('gold');
            $table->enum('purity', ['24k', '22k', '18k', '14k', '999', '925'])->nullable();
            $table->decimal('rate_per_gram', 12, 2);
            $table->decimal('rate_per_10gram', 12, 2)->nullable();
            $table->string('currency', 3)->default('INR');
            $table->enum('source', ['api', 'manual'])->default('manual');
            $table->boolean('is_current')->default(false);
            $table->timestamps();
            
            $table->index(['metal_type', 'purity', 'is_current']);
        });

        // 6. SIP Withdrawal Requests Table
        Schema::create('sip_withdrawals', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_sip_id');
            $table->unsignedBigInteger('user_id');
            $table->enum('withdrawal_type', ['gold_delivery', 'cash_redemption'])->default('cash_redemption');
            $table->decimal('gold_grams', 10, 4);
            $table->decimal('gold_rate', 10, 2)->nullable(); // Rate for cash redemption
            $table->decimal('cash_amount', 12, 2)->nullable();
            $table->enum('status', ['pending', 'processing', 'completed', 'rejected'])->default('pending');
            $table->text('delivery_address')->nullable();
            $table->string('tracking_number')->nullable();
            $table->text('admin_notes')->nullable();
            $table->timestamps();
            
            $table->foreign('user_sip_id')->references('id')->on('user_sips')->onDelete('cascade');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sip_withdrawals');
        Schema::dropIfExists('metal_rates');
        Schema::dropIfExists('sip_transactions');
        Schema::dropIfExists('user_sips');
        Schema::dropIfExists('sip_plans');
        Schema::dropIfExists('kyc_documents');
    }
};
