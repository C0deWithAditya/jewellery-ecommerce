@extends('layouts.admin.app')

@section('title', translate('KYC Details'))

@section('content')
    <div class="content container-fluid">
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-user-outlined mr-2"></i>
                        {{translate('KYC Details')}}
                    </h1>
                </div>
                <div class="col-sm-auto">
                    <a href="{{ route('admin.sip.kyc.index') }}" class="btn btn-secondary">
                        <i class="tio-back-ui mr-1"></i> {{translate('Back')}}
                    </a>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-header-title">{{translate('Customer Info')}}</h5>
                    </div>
                    <div class="card-body text-center">
                        <img src="{{ $kyc->user->image_full_url ?? asset('assets/admin/img/placeholder.png') }}" 
                             class="rounded-circle mb-3" style="width: 100px; height: 100px; object-fit: cover;">
                        <h5>{{ $kyc->user->f_name ?? '' }} {{ $kyc->user->l_name ?? '' }}</h5>
                        <p class="text-muted mb-1">{{ $kyc->user->email ?? 'N/A' }}</p>
                        <p class="text-muted">{{ $kyc->user->phone ?? 'N/A' }}</p>
                    </div>
                </div>
            </div>

            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-header-title">{{translate('Document Details')}}</h5>
                        @if($kyc->status == 'pending')
                            <span class="badge badge-warning badge-pill px-3 py-2">{{translate('Pending Review')}}</span>
                        @elseif($kyc->status == 'approved')
                            <span class="badge badge-success badge-pill px-3 py-2">{{translate('Approved')}}</span>
                        @else
                            <span class="badge badge-danger badge-pill px-3 py-2">{{translate('Rejected')}}</span>
                        @endif
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="text-muted">{{translate('Document Type')}}</label>
                                <p><strong>{{ strtoupper($kyc->document_type) }}</strong></p>
                            </div>
                            <div class="col-md-6">
                                <label class="text-muted">{{translate('Document Number')}}</label>
                                <p><strong>{{ $kyc->document_number }}</strong></p>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="text-muted">{{translate('Submitted On')}}</label>
                                <p>{{ $kyc->created_at->format('d M Y, h:i A') }}</p>
                            </div>
                            @if($kyc->verified_at)
                                <div class="col-md-6">
                                    <label class="text-muted">{{translate('Verified On')}}</label>
                                    <p>{{ $kyc->verified_at->format('d M Y, h:i A') }}</p>
                                </div>
                            @endif
                        </div>

                        @if($kyc->rejection_reason)
                            <div class="alert alert-danger">
                                <strong>{{translate('Rejection Reason')}}:</strong> {{ $kyc->rejection_reason }}
                            </div>
                        @endif

                        <hr>

                        <h6 class="mb-3">{{translate('Document Images')}}</h6>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="text-muted">{{translate('Front Side')}}</label>
                                <a href="{{ $kyc->front_image_url }}" target="_blank">
                                    <img src="{{ $kyc->front_image_url }}" class="img-fluid rounded border" 
                                         style="max-height: 200px; cursor: pointer;">
                                </a>
                            </div>
                            @if($kyc->document_back_image)
                                <div class="col-md-6">
                                    <label class="text-muted">{{translate('Back Side')}}</label>
                                    <a href="{{ $kyc->back_image_url }}" target="_blank">
                                        <img src="{{ $kyc->back_image_url }}" class="img-fluid rounded border" 
                                             style="max-height: 200px; cursor: pointer;">
                                    </a>
                                </div>
                            @endif
                        </div>

                        @if($kyc->status == 'pending')
                            <hr>
                            <div class="d-flex justify-content-end">
                                <button type="button" class="btn btn-danger mr-2" data-toggle="modal" data-target="#rejectModal">
                                    <i class="tio-clear-circle mr-1"></i> {{translate('Reject')}}
                                </button>
                                <form action="{{ route('admin.sip.kyc.approve', $kyc->id) }}" method="POST" style="display: inline;">
                                    @csrf
                                    <button type="submit" class="btn btn-success">
                                        <i class="tio-checkmark-circle mr-1"></i> {{translate('Approve')}}
                                    </button>
                                </form>
                            </div>
                        @endif
                    </div>
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
                <form action="{{ route('admin.sip.kyc.reject', $kyc->id) }}" method="POST">
                    @csrf
                    <div class="modal-body">
                        <div class="form-group">
                            <label>{{translate('Rejection Reason')}} <span class="text-danger">*</span></label>
                            <textarea name="rejection_reason" class="form-control" rows="3" required 
                                      placeholder="{{translate('Explain why this KYC is being rejected')}}"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Cancel')}}</button>
                        <button type="submit" class="btn btn-danger">{{translate('Reject KYC')}}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection
