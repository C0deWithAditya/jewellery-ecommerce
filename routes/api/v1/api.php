<?php

use App\Http\Controllers\Api\V1\BannerController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\ConversationController;
use App\Http\Controllers\Api\V1\CouponController;
use App\Http\Controllers\Api\V1\CustomerController;
use App\Http\Controllers\Api\V1\DeliverymanController;
use App\Http\Controllers\Api\V1\DeliveryManReviewController;
use App\Http\Controllers\Api\V1\LanguageController;
use App\Http\Controllers\Api\V1\MapApiController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\PageController;
use App\Http\Controllers\Api\V1\ProductController;
use App\Http\Controllers\Api\V1\WishlistController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\FlashSaleController;
use App\Http\Controllers\Api\V1\OrderController;
use App\Http\Controllers\Api\V1\Auth\CustomerAuthController;
use App\Http\Controllers\Api\V1\GuestUserController;
use App\Http\Controllers\Api\V1\ConfigController;

Route::group(['namespace' => 'Api\V1', 'middleware' => 'localization'], function () {

    Route::post('fcm-subscribe-to-topic', [CustomerController::class, 'fcmSubscribeToTopic']);

    Route::group(['prefix' => 'auth', 'namespace' => 'Auth'], function () {
        Route::post('registration', 'CustomerAuthController@registration');
        Route::post('login', 'CustomerAuthController@login');
        Route::post('social-customer-login', 'CustomerAuthController@social_customer_login');

        Route::post('check-phone', 'CustomerAuthController@check_phone');
        Route::post('verify-phone', 'CustomerAuthController@verify_phone');

        Route::post('check-email', 'CustomerAuthController@check_email');
        Route::post('verify-email', 'CustomerAuthController@verify_email');

        Route::post('firebase-auth-verify', [CustomerAuthController::class, 'firebaseAuthVerify']);
        Route::post('verify-otp', [CustomerAuthController::class, 'verifyOTP']);
        Route::post('registration-with-otp', [CustomerAuthController::class, 'registrationWithOTP']);
        Route::post('existing-account-check', [CustomerAuthController::class, 'existingAccountCheck']);
        Route::post('registration-with-social-media', [CustomerAuthController::class, 'registrationWithSocialMedia']);

        Route::post('forgot-password', 'PasswordResetController@reset_password_request');
        Route::post('verify-token', 'PasswordResetController@verify_token');
        Route::put('reset-password', 'PasswordResetController@reset_password_submit');


        Route::group(['prefix' => 'delivery-man'], function () {
            Route::post('register', 'DeliveryManLoginController@registration');
            Route::post('login', 'DeliveryManLoginController@login');
        });
    });

    Route::group(['prefix' => 'delivery-man'], function () {
        Route::get('profile', [DeliverymanController::class, 'getProfile']);
        Route::get('current-orders', [DeliverymanController::class, 'getCurrentOrders']);
        Route::get('all-orders', [DeliverymanController::class, 'getAllOrders']);
        Route::post('record-location-data', [DeliverymanController::class, 'recordLocationData']);
        Route::get('order-delivery-history', [DeliverymanController::class, 'getOrderHistory']);
        Route::put('update-order-status', [DeliverymanController::class, 'updateOrderStatus']);
        Route::put('update-payment-status', [DeliverymanController::class, 'orderPaymentStatusUpdate']);
        Route::get('order-details', [DeliverymanController::class, 'getOrderDetails']);
        Route::get('last-location', [DeliverymanController::class, 'getLastLocation']);
        Route::put('update-fcm-token', [DeliverymanController::class, 'updateFcmToken']);
        Route::get('order-model', [DeliverymanController::class, 'orderModel']);

        Route::group(['prefix' => 'message'], function () {
            Route::post('get-message', [ConversationController::class, 'getOrderMessageForDm']);
            Route::post('send/{sender_type}', [ConversationController::class, 'storeMessageByOrder']);
        });

        Route::group(['prefix' => 'reviews', 'middleware' => ['auth:api']], function () {
            Route::get('/{delivery_man_id}', [DeliveryManReviewController::class, 'getReviews']);
            Route::get('rating/{delivery_man_id}', [DeliveryManReviewController::class, 'getRating']);
            Route::post('/submit', [DeliveryManReviewController::class, 'submitReview']);
        });

        Route::delete('remove-account', [DeliverymanController::class, 'removeAccount']);

    });

    Route::group(['prefix' => 'config'], function () {
        Route::get('/', [ConfigController::class, 'configuration']);
        Route::get('delivery-fee', [ConfigController::class, 'deliveryFree']);
    });

    Route::group(['prefix' => 'products'], function () {
        Route::get('latest', [ProductController::class, 'getLatestProduct']);
        Route::get('discounted', [ProductController::class, 'getDiscountedProduct']);
        Route::get('search', [ProductController::class, 'getSearchedProduct']);
        Route::get('details/{id}', [ProductController::class, 'getProduct']);
        Route::get('related-products/{product_id}', [ProductController::class, 'getRelatedProduct']);
        Route::get('reviews/{product_id}', [ProductController::class, 'getProductReviews']);
        Route::get('rating/{product_id}', [ProductController::class, 'getProductRating']);
        Route::post('reviews/submit', [ProductController::class, 'submitProductReview'])->middleware('auth:api');
        Route::get('new-arrival', [ProductController::class, 'getNewArrivalProducts']);
    });

    Route::group(['prefix' => 'banners'], function () {
        Route::get('/', [BannerController::class, 'getBanners']);
    });

    Route::group(['prefix' => 'notifications', 'middleware' => 'guest_user'], function () {
        Route::get('/', [NotificationController::class, 'getNotifications']);
    });

    Route::group(['prefix' => 'categories'], function () {
        Route::get('/', [CategoryController::class, 'getCategories']);
        Route::get('childes/{category_id}', [CategoryController::class, 'getChildes']);
        Route::get('products/{category_id}', [CategoryController::class, 'getProducts']);
        Route::get('products/{category_id}/all', [CategoryController::class, 'getAllProducts']);
        Route::get('featured', [CategoryController::class, 'getFeaturedCategories']);
    });

    Route::group(['prefix' => 'customer', 'middleware' => 'auth:api'], function () {
        Route::get('info', [CustomerController::class, 'info']);
        Route::put('update-profile', [CustomerController::class, 'updateProfile']);
        Route::put('cm-firebase-token', [CustomerController::class, 'updateCmFirebaseToken']);
        Route::post('verify-profile-info', [CustomerController::class, 'verifyProfileInfo']);

        Route::delete('remove-account', [CustomerController::class, 'removeAccount']);

        Route::group(['prefix' => 'address', 'middleware' => 'guest_user'], function () {
            Route::get('list', [CustomerController::class, 'addressList'])->withoutMiddleware('auth:api');
            Route::post('add', [CustomerController::class, 'addNewAddress'])->withoutMiddleware('auth:api');
            Route::put('update/{id}', [CustomerController::class, 'updateAddress'])->withoutMiddleware('auth:api');
            Route::delete('delete', [CustomerController::class, 'deleteAddress'])->withoutMiddleware('auth:api');
        });

        Route::group(['prefix' => 'order', 'middleware' => 'guest_user'], function () {
            Route::get('list', [OrderController::class, 'getOrderList'])->withoutMiddleware('auth:api');
            Route::post('details', [OrderController::class, 'getOrderDetails'])->withoutMiddleware('auth:api');
            Route::post('place', [OrderController::class, 'placeOrder'])->withoutMiddleware('auth:api');
            Route::put('cancel', [OrderController::class, 'cancelOrder'])->withoutMiddleware('auth:api');
            Route::post('track', [OrderController::class, 'trackOrder'])->withoutMiddleware('auth:api');
            Route::put('payment-method', [OrderController::class, 'updatePaymentMethod'])->withoutMiddleware('auth:api');
        });

        Route::get('reorder/products', [OrderController::class, 'getReorderProduct']);
        Route::group(['prefix' => 'message'], function () {
            Route::get('get-admin-message', [ConversationController::class, 'getAdminMessage']);
            Route::post('send-admin-message', [ConversationController::class, 'storeAdminMessage']);
            Route::get('get-order-message', [ConversationController::class, 'getMessageByOrder']);
            Route::post('send/{sender_type}', [ConversationController::class, 'storeMessageByOrder']);
        });

        Route::group(['prefix' => 'wish-list'], function () {
            Route::get('/', [WishlistController::class, 'wishlist']);
            Route::post('add', [WishlistController::class, 'addToWishlist']);
            Route::delete('remove', [WishlistController::class, 'removeFromWishlist']);
        });
    });

    Route::group(['prefix' => 'coupon', 'middleware' => 'guest_user'], function () {
        Route::get('list', [CouponController::class, 'list']);
        Route::get('apply', [CouponController::class, 'apply']);
    });
    Route::group(['prefix' => 'language'], function () {
        Route::get('/', [LanguageController::class, 'get']);
    });

    Route::group(['prefix' => 'mapapi'], function () {
        Route::get('place-api-autocomplete', [MapApiController::class, 'placeApiAutocomplete']);
        Route::get('distance-api', [MapApiController::class, 'distanceApi']);
        Route::get('place-api-details', [MapApiController::class, 'placeApiDetails']);
        Route::get('geocode-api', [MapApiController::class, 'geoCodeApi']);
    });

    Route::post('subscribe-newsletter', [CustomerController::class, 'subscribeNewsLetter']);

    Route::get('pages', [PageController::class, 'index']);

    Route::get('flash-sale', [FlashSaleController::class, 'getFlashSale']);

    Route::group(['prefix' => 'guest'], function () {
        Route::post('/add', [GuestUserController::class, 'guestStore']);
    });

});
