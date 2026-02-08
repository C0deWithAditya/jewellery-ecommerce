@extends('layouts.admin.app')

@section('title', translate('SIP Subscriptions'))

@section('content')
    <div class="content container-fluid">
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-chart-line-up mr-2"></i>
                        {{translate('SIP Subscriptions')}}
                        <span class="badge badge-soft-primary ml-2">{{ $subscriptions->total() }}</span>
                    </h1>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-3">
            <div class="card-body">
                <form action="{{ route('admin.sip.subscriptions.index') }}" method="GET">
                    <div class="row">
                        <div class="col-md-5">
                            <input type="text" name="search" class="form-control" 
                                   placeholder="{{translate('Search by customer name or email')}}" 
                                   value="{{ request('search') }}">
                        </div>
                        <div class="col-md-3">
                            <select name="status" class="form-control">
                                <option value="">{{translate('All Status')}}</option>
                                <option value="active" {{ request('status') == 'active' ? 'selected' : '' }}>{{translate('Active')}}</option>
                                <option value="paused" {{ request('status') == 'paused' ? 'selected' : '' }}>{{translate('Paused')}}</option>
                                <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>{{translate('Completed')}}</option>
                                <option value="cancelled" {{ request('status') == 'cancelled' ? 'selected' : '' }}>{{translate('Cancelled')}}</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary btn-block">{{translate('Filter')}}</button>
                        </div>
                        <div class="col-md-2">
                            <a href="{{ route('admin.sip.subscriptions.index') }}" class="btn btn-outline-secondary btn-block">{{translate('Reset')}}</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Subscriptions Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{translate('SL')}}</th>
                                <th>{{translate('Customer')}}</th>
                                <th>{{translate('Plan')}}</th>
                                <th>{{translate('Amount')}}</th>
                                <th>{{translate('Total Invested')}}</th>
                                <th>{{translate('Gold Accumulated')}}</th>
                                <th>{{translate('Progress')}}</th>
                                <th>{{translate('Status')}}</th>
                                <th>{{translate('Actions')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($subscriptions as $key => $sip)
                                <tr>
                                    <td>{{ $subscriptions->firstItem() + $key }}</td>
                                    <td>
                                        <strong>{{ $sip->user->f_name ?? '' }} {{ $sip->user->l_name ?? '' }}</strong>
                                        <br>
                                        <small class="text-muted">{{ $sip->user->email ?? '' }}</small>
                                    </td>
                                    <td>
                                        {{ $sip->sipPlan->name ?? 'N/A' }}
                                        <br>
                                        <small class="text-muted badge badge-soft-warning">
                                            {{ ucfirst($sip->sipPlan->metal_type ?? '') }} ({{ strtoupper($sip->sipPlan->gold_purity ?? '') }})
                                        </small>
                                    </td>
                                    <td>₹{{ number_format($sip->monthly_amount, 2) }}/{{ $sip->sipPlan->frequency ?? 'month' }}</td>
                                    <td class="text-success">₹{{ number_format($sip->total_invested, 2) }}</td>
                                    <td class="text-warning">{{ number_format($sip->total_gold_grams, 4) }}g</td>
                                    <td>
                                        <div class="progress" style="height: 20px;">
                                            <div class="progress-bar bg-success" role="progressbar" 
                                                 style="width: {{ $sip->progress_percentage }}%">
                                                {{ $sip->progress_percentage }}%
                                            </div>
                                        </div>
                                        <small class="text-muted">{{ $sip->installments_paid }}/{{ $sip->installments_paid + $sip->installments_pending }} installments</small>
                                    </td>
                                    <td>
                                        @if($sip->status == 'active')
                                            <span class="badge badge-success">{{translate('Active')}}</span>
                                        @elseif($sip->status == 'paused')
                                            <span class="badge badge-warning">{{translate('Paused')}}</span>
                                        @elseif($sip->status == 'completed')
                                            <span class="badge badge-primary">{{translate('Completed')}}</span>
                                        @else
                                            <span class="badge badge-danger">{{translate('Cancelled')}}</span>
                                        @endif
                                    </td>
                                    <td>
                                        <a href="{{ route('admin.sip.subscriptions.show', $sip->id) }}" 
                                           class="btn btn-sm btn-outline-info">
                                            <i class="tio-visible"></i>
                                        </a>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="9" class="text-center py-5">
                                        <p class="text-muted">{{translate('No subscriptions found')}}</p>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if($subscriptions->hasPages())
                <div class="card-footer">
                    {{ $subscriptions->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection
