@extends('layouts.admin.app')

@section('title', translate('SIP Dashboard'))

@push('css_or_js')
    <style>
        .sip-stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px;
            color: white;
            padding: 20px;
            margin-bottom: 20px;
        }
        .sip-stats-card.gold {
            background: linear-gradient(135deg, #f5af19 0%, #f12711 100%);
        }
        .sip-stats-card.green {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        .sip-stats-card.blue {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        .sip-stats-card .icon {
            font-size: 40px;
            opacity: 0.8;
        }
        .sip-stats-card h3 {
            font-size: 28px;
            margin-bottom: 5px;
        }
        .sip-stats-card p {
            margin: 0;
            opacity: 0.9;
        }
        .rate-card {
            border-left: 4px solid #f5af19;
        }
    </style>
@endpush

@section('content')
    <div class="content container-fluid">
        <!-- Page Header -->
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-gold-bar mr-2"></i>
                        {{translate('SIP Dashboard')}}
                    </h1>
                </div>
            </div>
        </div>
        <!-- End Page Header -->

        <!-- Stats Cards -->
        <div class="row">
            <div class="col-md-3">
                <div class="sip-stats-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3>{{ $stats['active_sips'] }}</h3>
                            <p>{{translate('Active SIPs')}}</p>
                        </div>
                        <div class="icon">
                            <i class="tio-trending-up"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="sip-stats-card gold">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3>{{ number_format($stats['total_gold_grams'], 2) }}g</h3>
                            <p>{{translate('Total Gold Accumulated')}}</p>
                        </div>
                        <div class="icon">
                            <i class="tio-gem"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="sip-stats-card green">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3>₹{{ number_format($stats['total_invested']) }}</h3>
                            <p>{{translate('Total Invested')}}</p>
                        </div>
                        <div class="icon">
                            <i class="tio-wallet"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="sip-stats-card blue">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h3>{{ $stats['pending_kyc'] }}</h3>
                            <p>{{translate('Pending KYC')}}</p>
                        </div>
                        <div class="icon">
                            <i class="tio-user-outlined"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-3">
            <!-- Quick Actions -->
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-header">
                        <h5 class="card-header-title">{{translate('Quick Actions')}}</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-6 mb-3">
                                <a href="{{ route('admin.sip.kyc.index') }}" class="btn btn-outline-primary btn-block">
                                    <i class="tio-user-outlined mr-1"></i> {{translate('Manage KYC')}}
                                    @if($stats['pending_kyc'] > 0)
                                        <span class="badge badge-danger">{{ $stats['pending_kyc'] }}</span>
                                    @endif
                                </a>
                            </div>
                            <div class="col-6 mb-3">
                                <a href="{{ route('admin.sip.plan.index') }}" class="btn btn-outline-warning btn-block">
                                    <i class="tio-layers mr-1"></i> {{translate('SIP Plans')}}
                                </a>
                            </div>
                            <div class="col-6 mb-3">
                                <a href="{{ route('admin.sip.subscriptions.index') }}" class="btn btn-outline-success btn-block">
                                    <i class="tio-chart-line-up mr-1"></i> {{translate('Subscriptions')}}
                                </a>
                            </div>
                            <div class="col-6 mb-3">
                                <a href="{{ route('admin.sip.withdrawals.index') }}" class="btn btn-outline-info btn-block">
                                    <i class="tio-money-vs mr-1"></i> {{translate('Withdrawals')}}
                                    @if($stats['pending_withdrawals'] > 0)
                                        <span class="badge badge-warning">{{ $stats['pending_withdrawals'] }}</span>
                                    @endif
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Current Metal Rates -->
            <div class="col-md-6">
                <div class="card rate-card h-100">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-header-title">
                            <i class="tio-gem text-warning mr-2"></i>{{translate('Current Metal Rates')}}
                        </h5>
                        <a href="{{ route('admin.sip.metal-rates.index') }}" class="btn btn-sm btn-outline-primary">
                            {{translate('Update Rates')}}
                        </a>
                    </div>
                    <div class="card-body">
                        @forelse($currentRates as $rate)
                            <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom">
                                <div>
                                    <strong>{{ ucfirst($rate->metal_type) }}</strong>
                                    <span class="text-muted">({{ strtoupper($rate->purity) }})</span>
                                </div>
                                <div>
                                    <strong class="text-success">₹{{ number_format($rate->rate_per_gram, 2) }}/g</strong>
                                    <br>
                                    <small class="text-muted">Updated: {{ $rate->updated_at->diffForHumans() }}</small>
                                </div>
                            </div>
                        @empty
                            <div class="text-center text-muted py-4">
                                <i class="tio-info-circle" style="font-size: 40px;"></i>
                                <p class="mt-2">{{translate('No metal rates configured')}}</p>
                                <a href="{{ route('admin.sip.metal-rates.index') }}" class="btn btn-primary btn-sm">
                                    {{translate('Configure Now')}}
                                </a>
                            </div>
                        @endforelse
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Transactions -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-header-title">{{translate('Recent Transactions')}}</h5>
                        <a href="{{ route('admin.sip.transactions.index') }}" class="btn btn-sm btn-outline-primary">
                            {{translate('View All')}}
                        </a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead class="thead-light">
                                    <tr>
                                        <th>{{translate('User')}}</th>
                                        <th>{{translate('Amount')}}</th>
                                        <th>{{translate('Gold')}}</th>
                                        <th>{{translate('Rate')}}</th>
                                        <th>{{translate('Status')}}</th>
                                        <th>{{translate('Date')}}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @forelse($recentTransactions as $txn)
                                        <tr>
                                            <td>{{ $txn->user->f_name ?? 'N/A' }} {{ $txn->user->l_name ?? '' }}</td>
                                            <td>₹{{ number_format($txn->amount, 2) }}</td>
                                            <td>{{ number_format($txn->gold_grams, 4) }}g</td>
                                            <td>₹{{ number_format($txn->gold_rate, 2) }}/g</td>
                                            <td>
                                                @if($txn->status == 'success')
                                                    <span class="badge badge-success">{{translate('Success')}}</span>
                                                @elseif($txn->status == 'pending')
                                                    <span class="badge badge-warning">{{translate('Pending')}}</span>
                                                @else
                                                    <span class="badge badge-danger">{{translate('Failed')}}</span>
                                                @endif
                                            </td>
                                            <td>{{ $txn->created_at->format('d M Y, h:i A') }}</td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="6" class="text-center py-4">
                                                <p class="text-muted mb-0">{{translate('No transactions yet')}}</p>
                                            </td>
                                        </tr>
                                    @endforelse
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
