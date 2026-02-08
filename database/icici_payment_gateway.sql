-- ICICI Eazypay Payment Gateway Configuration
-- Run this SQL in your database (phpMyAdmin or MySQL Workbench)

INSERT INTO `addon_settings` (`id`, `key_name`, `live_values`, `test_values`, `settings_type`, `mode`, `is_active`, `created_at`, `updated_at`, `additional_data`) 
VALUES (
    UUID(),
    'icici_eazypay',
    '{"gateway":"icici_eazypay","mode":"live","status":"0","merchant_id":"","terminal_id":"","encryption_key":"","sub_merchant_id":""}',
    '{"gateway":"icici_eazypay","mode":"test","status":"0","merchant_id":"","terminal_id":"","encryption_key":"","sub_merchant_id":""}',
    'payment_config',
    'test',
    0,
    NOW(),
    NOW(),
    '{"gateway_title":"ICICI Eazypay","gateway_image":""}'
) ON DUPLICATE KEY UPDATE `updated_at` = NOW();
