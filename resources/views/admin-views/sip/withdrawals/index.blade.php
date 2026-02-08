@extends('layouts.admin.app')

@section('title', translate('SIP Withdrawals'))

@section('content')
    <div class="content container-fluid">
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-money-vs mr-2"></i>
                        {{translate('Withdrawal Requests')}}
                        <span class="badge badge-soft-primary ml-2">{{ $withdrawals->total() }}</span>
                    </h1>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-3">
            <div class="card-body">
                <form action="{{ route('admin.sip.withdrawals.index') }}" method="GET">
                    <div class="row">
                        <div class="col-md-4">
                            <input type="text" name="search" class="form-control" 
                                   placeholder="{{translate('Search by customer name or phone')}}" 
                                   value="{{ request('search') }}">
                        </div>
                        <div class="col-md-3">
                            <select name="status" class="form-control">
                                <option value="">{{translate('All Status')}}</option>
                                <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>{{translate('Pending')}}</option>
                                <option value="processing" {{ request('status') == 'processing' ? 'selected' : '' }}>{{translate('Processing')}}</option>
                                <option value="completed" {{ request('status') == 'completed' ? 'selected' : '' }}>{{translate('Completed')}}</option>
                                <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>{{translate('Rejected')}}</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select name="type" class="form-control">
                                <option value="">{{translate('All Types')}}</option>
                                <option value="gold_delivery" {{ request('type') == 'gold_delivery' ? 'selected' : '' }}>{{translate('Gold Delivery')}}</option>
                                <option value="cash_redemption" {{ request('type') == 'cash_redemption' ? 'selected' : '' }}>{{translate('Cash Redemption')}}</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary btn-block">{{translate('Filter')}}</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card card-body border-left-warning">
                    <h6 class="text-muted mb-1">{{translate('Pending')}}</h6>
                    <h4 class="mb-0 text-warning">{{ $stats['pending'] ?? 0 }}</h4>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body border-left-info">
                    <h6 class="text-muted mb-1">{{translate('Processing')}}</h6>
                    <h4 class="mb-0 text-info">{{ $stats['processing'] ?? 0 }}</h4>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body border-left-success">
                    <h6 class="text-muted mb-1">{{translate('Completed')}}</h6>
                    <h4 class="mb-0 text-success">{{ $stats['completed'] ?? 0 }}</h4>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body border-left-danger">
                    <h6 class="text-muted mb-1">{{translate('Rejected')}}</h6>
                    <h4 class="mb-0 text-danger">{{ $stats['rejected'] ?? 0 }}</h4>
                </div>
            </div>
        </div>

        <!-- Withdrawals Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{translate('SL')}}</th>
                                <th>{{translate('Customer')}}</th>
                                <th>{{translate('Type')}}</th>
                                <th>{{translate('Gold (g)')}}</th>
                                <th>{{translate('Cash Amount')}}</th>
                                <th>{{translate('Status')}}</th>
                                <th>{{translate('Requested On')}}</th>
                                <th class="text-center">{{translate('Actions')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($withdrawals as $key => $withdrawal)
                                <tr>
                                    <td>{{ $withdrawals->firstItem() + $key }}</td>
                                    <td>
                                        <strong>{{ $withdrawal->user->f_name ?? '' }} {{ $withdrawal->user->l_name ?? '' }}</strong>
                                        <br>
                                        <small class="text-muted">{{ $withdrawal->user->phone ?? '' }}</small>
                                    </td>
                                    <td>
                                        @if($withdrawal->withdrawal_type == 'gold_delivery')
                                            <span class="badge badge-warning">
                                                <i class="tio-diamond mr-1"></i> {{translate('Gold Delivery')}}
                                            </span>
                                        @else
                                            <span class="badge badge-info">
                                                <i class="tio-money mr-1"></i> {{translate('Cash Redemption')}}
                                            </span>
                                        @endif
                                    </td>
                                    <td class="text-warning font-weight-bold">{{ number_format($withdrawal->gold_grams, 4) }}g</td>
                                    <td>
                                        @if($withdrawal->cash_amount)
                                            <span class="text-success font-weight-bold">₹{{ number_format($withdrawal->cash_amount, 2) }}</span>
                                        @else
                                            <span class="text-muted">-</span>
                                        @endif
                                    </td>
                                    <td>
                                        @if($withdrawal->status == 'pending')
                                            <span class="badge badge-warning">{{translate('Pending')}}</span>
                                        @elseif($withdrawal->status == 'processing')
                                            <span class="badge badge-info">{{translate('Processing')}}</span>
                                        @elseif($withdrawal->status == 'completed')
                                            <span class="badge badge-success">{{translate('Completed')}}</span>
                                        @else
                                            <span class="badge badge-danger">{{translate('Rejected')}}</span>
                                        @endif
                                    </td>
                                    <td>{{ $withdrawal->created_at->format('d M Y, h:i A') }}</td>
                                    <td class="text-center">
                                        <button type="button" class="btn btn-sm btn-outline-info" 
                                                data-toggle="modal" data-target="#viewModal{{ $withdrawal->id }}">
                                            <i class="tio-visible"></i>
                                        </button>
                                        @if($withdrawal->status == 'pending')
                                            <button type="button" class="btn btn-sm btn-outline-success" 
                                                    data-toggle="modal" data-target="#processModal{{ $withdrawal->id }}">
                                                <i class="tio-done"></i>
                                            </button>
                                        @endif
                                    </td>
                                </tr>

                                <!-- View Modal -->
                                <div class="modal fade" id="viewModal{{ $withdrawal->id }}" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">{{translate('Withdrawal Details')}}</h5>
                                                <button type="button" class="close" data-dismiss="modal">
                                                    <span>&times;</span>
                                                </button>
                                            </div>
                                            <div class="modal-body">
                                                <table class="table table-borderless">
                                                    <tr>
                                                        <th>{{translate('Customer')}}</th>
                                                        <td>{{ $withdrawal->user->f_name ?? '' }} {{ $withdrawal->user->l_name ?? '' }}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>{{translate('Type')}}</th>
                                                        <td>{{ ucfirst(str_replace('_', ' ', $withdrawal->withdrawal_type)) }}</td>
                                                    </tr>
                                                    <tr>
                                                        <th>{{translate('Gold Amount')}}</th>
                                                        <td>{{ number_format($withdrawal->gold_grams, 4) }}g</td>
                                                    </tr>
                                                    @if($withdrawal->cash_amount)
                                                    <tr>
                                                        <th>{{translate('Cash Amount')}}</th>
                                                        <td>₹{{ number_format($withdrawal->cash_amount, 2) }}</td>
                                                    </tr>
                                                    @endif
                                                    @if($withdrawal->delivery_address)
                                                    <tr>
                                                        <th>{{translate('Delivery Address')}}</th>
                                                        <td>{{ $withdrawal->delivery_address }}</td>
                                                    </tr>
                                                    @endif
                                                    @if($withdrawal->tracking_number)
                                                    <tr>
                                                        <th>{{translate('Tracking Number')}}</th>
                                                        <td><code>{{ $withdrawal->tracking_number }}</code></td>
                                                    </tr>
                                                    @endif
                                                    @if($withdrawal->admin_notes)
                                                    <tr>
                                                        <th>{{translate('Admin Notes')}}</th>
                                                        <td>{{ $withdrawal->admin_notes }}</td>
                                                    </tr>
                                                    @endif
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Process Modal -->
                                @if($withdrawal->status == 'pending')
                                <div class="modal fade" id="processModal{{ $withdrawal->id }}" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <h5 class="modal-title">{{translate('Process Withdrawal')}}</h5>
                                                <button type="button" class="close" data-dismiss="modal">
                                                    <span>&times;</span>
                                                </button>
                                            </div>
                                            <form action="{{ route('admin.sip.withdrawals.process', $withdrawal->id) }}" method="POST">
                                                @csrf
                                                <div class="modal-body">
                                                    <div class="form-group">
                                                        <label>{{translate('Status')}}</label>
                                                        <select name="status" class="form-control" required>
                                                            <option value="processing">{{translate('Processing')}}</option>
                                                            <option value="completed">{{translate('Completed')}}</option>
                                                            <option value="rejected">{{translate('Rejected')}}</option>
                                                        </select>
                                                    </div>
                                                    @if($withdrawal->withdrawal_type == 'gold_delivery')
                                                    <div class="form-group">
                                                        <label>{{translate('Tracking Number')}}</label>
                                                        <input type="text" name="tracking_number" class="form-control" 
                                                               placeholder="{{translate('Enter shipping tracking number')}}">
                                                    </div>
                                                    @endif
                                                    <div class="form-group">
                                                        <label>{{translate('Admin Notes')}}</label>
                                                        <textarea name="admin_notes" class="form-control" rows="3" 
                                                                  placeholder="{{translate('Add notes about this withdrawal')}}"></textarea>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Cancel')}}</button>
                                                    <button type="submit" class="btn btn-primary">{{translate('Update')}}</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                                @endif
                            @empty
                                <tr>
                                    <td colspan="8" class="text-center py-5">
                                        <img src="{{ asset('assets/admin/svg/illustrations/sorry.svg') }}" 
                                             alt="" style="width: 100px;">
                                        <p class="text-muted mt-3 mb-0">{{translate('No withdrawal requests found')}}</p>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if($withdrawals->hasPages())
                <div class="card-footer">
                    {{ $withdrawals->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection
