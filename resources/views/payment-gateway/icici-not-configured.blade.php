@extends('payment-gateway.layouts.master')

@section('content')
    <div class="container" style="margin-top: 10vh;">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow-lg">
                    <div class="card-header bg-warning text-dark text-center">
                        <h4><i class="fas fa-exclamation-triangle"></i> Payment Gateway Not Configured</h4>
                    </div>
                    <div class="card-body text-center">
                        <div class="mb-4">
                            <img src="https://www.icicibank.com/content/dam/icicibank/india/assets/images/header/icici-bank-logo@2x.webp" 
                                 alt="ICICI Bank" 
                                 style="height: 60px;">
                        </div>
                        
                        <p class="text-muted">
                            ICICI Eazypay payment gateway is not configured yet.
                        </p>
                        <p>
                            Please contact the administrator to set up ICICI payment credentials in the admin panel.
                        </p>
                        
                        <hr>
                        
                        <a href="javascript:history.back()" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Go Back
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
