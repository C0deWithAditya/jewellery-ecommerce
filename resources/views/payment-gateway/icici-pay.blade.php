@extends('payment-gateway.layouts.master')

@section('content')
    <div class="container" style="margin-top: 10vh;">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow-lg">
                    <div class="card-header bg-primary text-white text-center">
                        <img src="{{ $business_logo }}" alt="Logo" style="height: 50px; margin-bottom: 10px;">
                        <h4>ICICI Bank Payment</h4>
                    </div>
                    <div class="card-body text-center">
                        <div class="mb-4">
                            <img src="{{ asset('assets/admin/img/payment/icici-bank.png') }}" 
                                 alt="ICICI Bank" 
                                 style="height: 60px;"
                                 onerror="this.src='https://www.icicibank.com/content/dam/icicibank/india/assets/images/header/icici-bank-logo@2x.webp'">
                        </div>
                        
                        <h5 class="mb-3">Payment Details</h5>
                        <div class="table-responsive">
                            <table class="table table-borderless">
                                <tr>
                                    <td class="text-muted">Amount:</td>
                                    <td class="font-weight-bold">₹{{ number_format($data->payment_amount, 2) }}</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Customer:</td>
                                    <td>{{ $payer->name ?? 'Customer' }}</td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Email:</td>
                                    <td>{{ $payer->email ?? 'N/A' }}</td>
                                </tr>
                            </table>
                        </div>
                        
                        <form action="{{ route('icici.initiate') }}" method="POST">
                            @csrf
                            <input type="hidden" name="payment_id" value="{{ $data->id }}">
                            
                            <button type="submit" class="btn btn-primary btn-lg w-100 mt-3">
                                <i class="fas fa-lock me-2"></i> Pay with ICICI Bank
                            </button>
                        </form>
                        
                        <p class="text-muted mt-3 small">
                            <i class="fas fa-shield-alt"></i> 
                            Secured by ICICI Bank. Your payment information is encrypted.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
