@extends('layouts.admin.app')

@section('title', translate('KYC Management'))

@section('content')
    <div class="content container-fluid">
        <!-- Page Header -->
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-user-outlined mr-2"></i>
                        {{translate('KYC Management')}}
                    </h1>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card card-body text-center">
                    <h3 class="text-primary mb-0">{{ $stats['total'] }}</h3>
                    <small class="text-muted">{{translate('Total KYC')}}</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body text-center border-warning">
                    <h3 class="text-warning mb-0">{{ $stats['pending'] }}</h3>
                    <small class="text-muted">{{translate('Pending')}}</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body text-center border-success">
                    <h3 class="text-success mb-0">{{ $stats['approved'] }}</h3>
                    <small class="text-muted">{{translate('Approved')}}</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card card-body text-center border-danger">
                    <h3 class="text-danger mb-0">{{ $stats['rejected'] }}</h3>
                    <small class="text-muted">{{translate('Rejected')}}</small>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-3">
            <div class="card-body">
                <form action="{{ route('admin.sip.kyc.index') }}" method="GET">
                    <div class="row">
                        <div class="col-md-5">
                            <input type="text" name="search" class="form-control" 
                                   placeholder="{{translate('Search by name, email or document number')}}" 
                                   value="{{ request('search') }}">
                        </div>
                        <div class="col-md-3">
                            <select name="status" class="form-control">
                                <option value="">{{translate('All Status')}}</option>
                                <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>{{translate('Pending')}}</option>
                                <option value="approved" {{ request('status') == 'approved' ? 'selected' : '' }}>{{translate('Approved')}}</option>
                                <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>{{translate('Rejected')}}</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="tio-search"></i> {{translate('Filter')}}
                            </button>
                        </div>
                        <div class="col-md-2">
                            <a href="{{ route('admin.sip.kyc.index') }}" class="btn btn-outline-secondary btn-block">
                                {{translate('Reset')}}
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- KYC Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{translate('SL')}}</th>
                                <th>{{translate('Customer')}}</th>
                                <th>{{translate('Document Type')}}</th>
                                <th>{{translate('Document No.')}}</th>
                                <th>{{translate('Submitted')}}</th>
                                <th>{{translate('Status')}}</th>
                                <th class="text-center">{{translate('Actions')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($kycDocuments as $key => $kyc)
                                <tr>
                                    <td>{{ $kycDocuments->firstItem() + $key }}</td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <img src="{{ $kyc->user->image_full_url ?? asset('assets/admin/img/placeholder.png') }}" 
                                                 class="rounded-circle mr-2" style="width: 35px; height: 35px; object-fit: cover;">
                                            <div>
                                                <strong>{{ $kyc->user->f_name ?? '' }} {{ $kyc->user->l_name ?? '' }}</strong>
                                                <br>
                                                <small class="text-muted">{{ $kyc->user->email ?? '' }}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge badge-soft-primary">{{ strtoupper($kyc->document_type) }}</span>
                                    </td>
                                    <td>{{ $kyc->document_number }}</td>
                                    <td>{{ $kyc->created_at->format('d M Y, h:i A') }}</td>
                                    <td>
                                        @if($kyc->status == 'pending')
                                            <span class="badge badge-warning">{{translate('Pending')}}</span>
                                        @elseif($kyc->status == 'approved')
                                            <span class="badge badge-success">{{translate('Approved')}}</span>
                                        @else
                                            <span class="badge badge-danger">{{translate('Rejected')}}</span>
                                        @endif
                                    </td>
                                    <td class="text-center">
                                        <a href="{{ route('admin.sip.kyc.show', $kyc->id) }}" 
                                           class="btn btn-sm btn-outline-info" title="{{translate('View Details')}}">
                                            <i class="tio-visible"></i>
                                        </a>
                                        @if($kyc->status == 'pending')
                                            <button type="button" class="btn btn-sm btn-success approve-btn" 
                                                    data-id="{{ $kyc->id }}" title="{{translate('Approve')}}">
                                                <i class="tio-checkmark-circle"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-danger reject-btn" 
                                                    data-id="{{ $kyc->id }}" title="{{translate('Reject')}}">
                                                <i class="tio-clear-circle"></i>
                                            </button>
                                        @endif
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="text-center py-5">
                                        <p class="text-muted mb-0">{{translate('No KYC submissions found')}}</p>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if($kycDocuments->hasPages())
                <div class="card-footer">
                    {{ $kycDocuments->links() }}
                </div>
            @endif
        </div>
    </div>

    <!-- Approve Modal -->
    <div class="modal fade" id="approveModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">{{translate('Approve KYC')}}</h5>
                    <button type="button" class="close text-white" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>{{translate('Are you sure you want to approve this KYC submission?')}}</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Cancel')}}</button>
                    <form id="approveForm" method="POST" style="display: inline;">
                        @csrf
                        <button type="submit" class="btn btn-success">{{translate('Approve')}}</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Reject Modal -->
    <div class="modal fade" id="rejectModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">{{translate('Reject KYC')}}</h5>
                    <button type="button" class="close text-white" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="rejectForm" method="POST">
                    @csrf
                    <div class="modal-body">
                        <p>{{translate('Please provide a reason for rejection:')}}</p>
                        <textarea name="rejection_reason" class="form-control" rows="3" required
                                  placeholder="{{translate('Enter rejection reason')}}"></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Cancel')}}</button>
                        <button type="submit" class="btn btn-danger">{{translate('Reject')}}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection

@push('script_2')
    <script>
        // Approve
        $('.approve-btn').on('click', function() {
            let id = $(this).data('id');
            $('#approveForm').attr('action', "{{ route('admin.sip.kyc.approve', '') }}/" + id);
            $('#approveModal').modal('show');
        });

        // Reject
        $('.reject-btn').on('click', function() {
            let id = $(this).data('id');
            $('#rejectForm').attr('action', "{{ route('admin.sip.kyc.reject', '') }}/" + id);
            $('#rejectModal').modal('show');
        });
    </script>
@endpush
