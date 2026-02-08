@extends('layouts.admin.app')

@section('title', translate('SIP Transactions'))

@section('content')
    <div class="content container-fluid">
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-receipt-outlined mr-2"></i>
                        {{translate('SIP Transactions')}}
                        <span class="badge badge-soft-primary ml-2">{{ $transactions->total() }}</span>
                    </h1>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-3">
            <div class="card-body">
                <form action="{{ route('admin.sip.transactions.index') }}" method="GET">
                    <div class="row">
                        <div class="col-md-3">
                            <input type="text" name="search" class="form-control" 
                                   placeholder="{{translate('Search by customer name')}}" 
                                   value="{{ request('search') }}">
                        </div>
                        <div class="col-md-2">
                            <select name="status" class="form-control">
                                <option value="">{{translate('All Status')}}</option>
                                <option value="success" {{ request('status') == 'success' ? 'selected' : '' }}>{{translate('Success')}}</option>
                                <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>{{translate('Pending')}}</option>
                                <option value="failed" {{ request('status') == 'failed' ? 'selected' : '' }}>{{translate('Failed')}}</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <input type="date" name="from_date" class="form-control" 
                                   value="{{ request('from_date') }}" placeholder="{{translate('From Date')}}">
                        </div>
                        <div class="col-md-2">
                            <input type="date" name="to_date" class="form-control" 
                                   value="{{ request('to_date') }}" placeholder="{{translate('To Date')}}">
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary btn-block">{{translate('Filter')}}</button>
                        </div>
                        <div class="col-md-1">
                            <a href="{{ route('admin.sip.transactions.index') }}" class="btn btn-outline-secondary btn-block">
                                <i class="tio-refresh"></i>
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-muted mb-1">{{translate('Total Transactions')}}</h6>
                            <h4 class="mb-0">{{ $stats['total'] ?? 0 }}</h4>
                        </div>
                        <div class="bg-soft-primary rounded-circle p-3">
                            <i class="tio-receipt text-primary"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-muted mb-1">{{translate('Successful')}}</h6>
                            <h4 class="mb-0 text-success">{{ $stats['success'] ?? 0 }}</h4>
                        </div>
                        <div class="bg-soft-success rounded-circle p-3">
                            <i class="tio-checkmark-circle text-success"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-muted mb-1">{{translate('Total Amount')}}</h6>
                            <h4 class="mb-0 text-primary">₹{{ number_format($stats['total_amount'] ?? 0, 2) }}</h4>
                        </div>
                        <div class="bg-soft-info rounded-circle p-3">
                            <i class="tio-money text-info"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-muted mb-1">{{translate('Total Gold')}}</h6>
                            <h4 class="mb-0 text-warning">{{ number_format($stats['total_gold'] ?? 0, 4) }}g</h4>
                        </div>
                        <div class="bg-soft-warning rounded-circle p-3">
                            <i class="tio-diamond text-warning"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Transactions Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{translate('SL')}}</th>
                                <th>{{translate('Transaction ID')}}</th>
                                <th>{{translate('Customer')}}</th>
                                <th>{{translate('SIP Plan')}}</th>
                                <th>{{translate('Amount')}}</th>
                                <th>{{translate('Gold Rate')}}</th>
                                <th>{{translate('Gold (g)')}}</th>
                                <th>{{translate('Installment')}}</th>
                                <th>{{translate('Status')}}</th>
                                <th>{{translate('Date')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($transactions as $key => $txn)
                                <tr>
                                    <td>{{ $transactions->firstItem() + $key }}</td>
                                    <td>
                                        <code>{{ $txn->transaction_id ?? 'N/A' }}</code>
                                    </td>
                                    <td>
                                        <strong>{{ $txn->user->f_name ?? '' }} {{ $txn->user->l_name ?? '' }}</strong>
                                        <br>
                                        <small class="text-muted">{{ $txn->user->phone ?? '' }}</small>
                                    </td>
                                    <td>{{ $txn->userSip->sipPlan->name ?? 'N/A' }}</td>
                                    <td class="text-success font-weight-bold">₹{{ number_format($txn->amount, 2) }}</td>
                                    <td>₹{{ number_format($txn->gold_rate, 2) }}/g</td>
                                    <td class="text-warning font-weight-bold">{{ number_format($txn->gold_grams, 4) }}</td>
                                    <td>
                                        <span class="badge badge-soft-info">
                                            #{{ $txn->installment_number }}
                                        </span>
                                    </td>
                                    <td>
                                        @if($txn->status == 'success')
                                            <span class="badge badge-success">{{translate('Success')}}</span>
                                        @elseif($txn->status == 'pending')
                                            <span class="badge badge-warning">{{translate('Pending')}}</span>
                                        @elseif($txn->status == 'failed')
                                            <span class="badge badge-danger">{{translate('Failed')}}</span>
                                        @else
                                            <span class="badge badge-secondary">{{ ucfirst($txn->status) }}</span>
                                        @endif
                                    </td>
                                    <td>{{ $txn->created_at->format('d M Y, h:i A') }}</td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="10" class="text-center py-5">
                                        <img src="{{ asset('assets/admin/svg/illustrations/sorry.svg') }}" 
                                             alt="" style="width: 100px;">
                                        <p class="text-muted mt-3 mb-0">{{translate('No transactions found')}}</p>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if($transactions->hasPages())
                <div class="card-footer">
                    {{ $transactions->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection
