<?php

return [
    /*
    |--------------------------------------------------------------------------
    | ICICI Eazypay Configuration
    |--------------------------------------------------------------------------
    |
    | These values are used to configure the ICICI Eazypay payment gateway.
    | You can obtain these credentials from ICICI Merchant Services.
    |
    */

    'merchant_id' => env('ICICI_MERCHANT_ID', ''),
    'terminal_id' => env('ICICI_TERMINAL_ID', ''),
    'encryption_key' => env('ICICI_ENCRYPTION_KEY', ''),
    'sub_merchant_id' => env('ICICI_SUB_MERCHANT_ID', ''),
    
    // API Endpoints
    'test_url' => 'https://eazypay.icicibank.com/EazyPayCheckout/PaymentInitServletTest',
    'live_url' => 'https://eazypay.icicibank.com/EazyPayCheckout/PaymentInitServlet',
    
    // Callback URLs (will be set dynamically)
    'return_url' => env('ICICI_RETURN_URL', ''),
    'callback_url' => env('ICICI_CALLBACK_URL', ''),
];
