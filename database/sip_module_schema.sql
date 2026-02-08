-- SIP Module Database Schema
-- Run this SQL after importing the base database

-- 1. KYC Documents Table
CREATE TABLE IF NOT EXISTS `kyc_documents` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `user_id` bigint(20) unsigned NOT NULL,
    `document_type` enum('pan','aadhar','passport','voter_id') NOT NULL DEFAULT 'pan',
    `document_number` varchar(255) DEFAULT NULL,
    `document_front_image` varchar(255) DEFAULT NULL,
    `document_back_image` varchar(255) DEFAULT NULL,
    `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    `rejection_reason` text DEFAULT NULL,
    `verified_by` bigint(20) unsigned DEFAULT NULL,
    `verified_at` timestamp NULL DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `kyc_documents_user_id_status_index` (`user_id`, `status`),
    CONSTRAINT `kyc_documents_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. SIP Plans Table
CREATE TABLE IF NOT EXISTS `sip_plans` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `description` text DEFAULT NULL,
    `frequency` enum('daily','weekly','monthly') NOT NULL DEFAULT 'monthly',
    `min_amount` decimal(10,2) NOT NULL DEFAULT 100.00,
    `max_amount` decimal(10,2) NOT NULL DEFAULT 100000.00,
    `duration_months` int(11) NOT NULL DEFAULT 12,
    `bonus_months` int(11) NOT NULL DEFAULT 0,
    `bonus_percentage` decimal(5,2) NOT NULL DEFAULT 0.00,
    `metal_type` enum('gold','silver','platinum') NOT NULL DEFAULT 'gold',
    `gold_purity` enum('24k','22k','18k') NOT NULL DEFAULT '22k',
    `is_active` tinyint(1) NOT NULL DEFAULT 1,
    `sort_order` int(11) NOT NULL DEFAULT 0,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `sip_plans_is_active_metal_type_index` (`is_active`, `metal_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. User SIP Subscriptions Table
CREATE TABLE IF NOT EXISTS `user_sips` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `user_id` bigint(20) unsigned NOT NULL,
    `sip_plan_id` bigint(20) unsigned NOT NULL,
    `monthly_amount` decimal(10,2) NOT NULL,
    `start_date` date NOT NULL,
    `end_date` date NOT NULL,
    `next_payment_date` date DEFAULT NULL,
    `total_invested` decimal(12,2) NOT NULL DEFAULT 0.00,
    `total_gold_grams` decimal(10,4) NOT NULL DEFAULT 0.0000,
    `installments_paid` int(11) NOT NULL DEFAULT 0,
    `installments_pending` int(11) NOT NULL DEFAULT 0,
    `status` enum('active','paused','completed','cancelled') NOT NULL DEFAULT 'active',
    `mandate_id` varchar(255) DEFAULT NULL,
    `mandate_status` enum('pending','active','cancelled') DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `user_sips_user_id_status_index` (`user_id`, `status`),
    KEY `user_sips_next_payment_date_status_index` (`next_payment_date`, `status`),
    CONSTRAINT `user_sips_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `user_sips_sip_plan_id_foreign` FOREIGN KEY (`sip_plan_id`) REFERENCES `sip_plans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. SIP Transactions Table
CREATE TABLE IF NOT EXISTS `sip_transactions` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `user_sip_id` bigint(20) unsigned NOT NULL,
    `user_id` bigint(20) unsigned NOT NULL,
    `amount` decimal(10,2) NOT NULL,
    `gold_rate` decimal(10,2) NOT NULL,
    `gold_grams` decimal(10,4) NOT NULL,
    `transaction_id` varchar(255) DEFAULT NULL,
    `payment_method` varchar(255) DEFAULT NULL,
    `status` enum('pending','success','failed','refunded') NOT NULL DEFAULT 'pending',
    `installment_date` date NOT NULL,
    `installment_number` int(11) NOT NULL,
    `payment_response` text DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `sip_transactions_user_sip_id_status_index` (`user_sip_id`, `status`),
    KEY `sip_transactions_user_id_created_at_index` (`user_id`, `created_at`),
    CONSTRAINT `sip_transactions_user_sip_id_foreign` FOREIGN KEY (`user_sip_id`) REFERENCES `user_sips` (`id`) ON DELETE CASCADE,
    CONSTRAINT `sip_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Metal Rates Table
CREATE TABLE IF NOT EXISTS `metal_rates` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `metal_type` enum('gold','silver','platinum') NOT NULL DEFAULT 'gold',
    `purity` enum('24k','22k','18k','14k','999','925') DEFAULT NULL,
    `rate_per_gram` decimal(12,2) NOT NULL,
    `rate_per_10gram` decimal(12,2) DEFAULT NULL,
    `currency` varchar(3) NOT NULL DEFAULT 'INR',
    `source` enum('api','manual') NOT NULL DEFAULT 'manual',
    `is_current` tinyint(1) NOT NULL DEFAULT 0,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `metal_rates_metal_type_purity_is_current_index` (`metal_type`, `purity`, `is_current`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. SIP Withdrawal Requests Table
CREATE TABLE IF NOT EXISTS `sip_withdrawals` (
    `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `user_sip_id` bigint(20) unsigned NOT NULL,
    `user_id` bigint(20) unsigned NOT NULL,
    `withdrawal_type` enum('gold_delivery','cash_redemption') NOT NULL DEFAULT 'cash_redemption',
    `gold_grams` decimal(10,4) NOT NULL,
    `gold_rate` decimal(10,2) DEFAULT NULL,
    `cash_amount` decimal(12,2) DEFAULT NULL,
    `status` enum('pending','processing','completed','rejected') NOT NULL DEFAULT 'pending',
    `delivery_address` text DEFAULT NULL,
    `tracking_number` varchar(255) DEFAULT NULL,
    `admin_notes` text DEFAULT NULL,
    `created_at` timestamp NULL DEFAULT NULL,
    `updated_at` timestamp NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `sip_withdrawals_user_sip_id_foreign` FOREIGN KEY (`user_sip_id`) REFERENCES `user_sips` (`id`) ON DELETE CASCADE,
    CONSTRAINT `sip_withdrawals_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert ICICI Payment Gateway Config (if not exists)
INSERT IGNORE INTO `addon_settings` (`id`, `key_name`, `live_values`, `test_values`, `settings_type`, `mode`, `is_active`, `created_at`, `updated_at`, `additional_data`) VALUES
(UUID(), 'icici_eazypay', '{"gateway":"icici_eazypay","mode":"live","status":"0","merchant_id":"","terminal_id":"","encryption_key":"","sub_merchant_id":""}', '{"gateway":"icici_eazypay","mode":"test","status":"0","merchant_id":"","terminal_id":"","encryption_key":"","sub_merchant_id":""}', 'payment_config', 'test', 0, NOW(), NOW(), '{"gateway_title":"ICICI Eazypay","gateway_image":""}');

-- Insert sample SIP plans
INSERT INTO `sip_plans` (`name`, `description`, `frequency`, `min_amount`, `max_amount`, `duration_months`, `bonus_months`, `bonus_percentage`, `metal_type`, `gold_purity`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
('Gold Monthly SIP', 'Start your gold savings journey with our flexible monthly SIP. Invest as low as ₹500 and build your gold portfolio.', 'monthly', 500.00, 100000.00, 12, 1, 0.00, 'gold', '22k', 1, 1, NOW(), NOW()),
('Gold Annual Plan', 'Premium annual plan with bonus gold. Perfect for long-term wealth building with 22K pure gold.', 'monthly', 1000.00, 500000.00, 12, 1, 5.00, 'gold', '22k', 1, 2, NOW(), NOW()),
('Silver Monthly SIP', 'Diversify your precious metal portfolio with silver. Start with just ₹250 per month.', 'monthly', 250.00, 50000.00, 12, 0, 0.00, 'silver', '999', 1, 3, NOW(), NOW());

-- Insert sample metal rates
INSERT INTO `metal_rates` (`metal_type`, `purity`, `rate_per_gram`, `rate_per_10gram`, `currency`, `source`, `is_current`, `created_at`, `updated_at`) VALUES
('gold', '24k', 7500.00, 75000.00, 'INR', 'manual', 1, NOW(), NOW()),
('gold', '22k', 6900.00, 69000.00, 'INR', 'manual', 1, NOW(), NOW()),
('gold', '18k', 5625.00, 56250.00, 'INR', 'manual', 1, NOW(), NOW()),
('silver', '999', 85.00, 850.00, 'INR', 'manual', 1, NOW(), NOW());
