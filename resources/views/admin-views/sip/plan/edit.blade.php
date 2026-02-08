@extends('layouts.admin.app')

@section('title', translate('Edit SIP Plan'))

@section('content')
    <div class="content container-fluid">
        <!-- Page Header -->
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-edit mr-2"></i>
                        {{translate('Edit SIP Plan')}}
                    </h1>
                </div>
                <div class="col-sm-auto">
                    <a href="{{ route('admin.sip.plan.index') }}" class="btn btn-secondary">
                        <i class="tio-back-ui mr-1"></i> {{translate('Back')}}
                    </a>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-body">
                <form action="{{ route('admin.sip.plan.update', $plan->id) }}" method="POST">
                    @csrf
                    
                    <div class="row">
                        <!-- Basic Info -->
                        <div class="col-md-6">
                            <h5 class="mb-3">{{translate('Basic Information')}}</h5>
                            
                            <div class="form-group">
                                <label class="input-label">{{translate('Plan Name')}} <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control" 
                                       value="{{ old('name', $plan->name) }}" required>
                            </div>

                            <div class="form-group">
                                <label class="input-label">{{translate('Description')}}</label>
                                <textarea name="description" class="form-control" rows="3">{{ old('description', $plan->description) }}</textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="input-label">{{translate('Metal Type')}} <span class="text-danger">*</span></label>
                                        <select name="metal_type" id="metalType" class="form-control" required>
                                            <option value="gold" {{ $plan->metal_type == 'gold' ? 'selected' : '' }}>{{translate('Gold')}}</option>
                                            <option value="silver" {{ $plan->metal_type == 'silver' ? 'selected' : '' }}>{{translate('Silver')}}</option>
                                            <option value="platinum" {{ $plan->metal_type == 'platinum' ? 'selected' : '' }}>{{translate('Platinum')}}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group" id="purityGroup" style="{{ $plan->metal_type != 'gold' ? 'display:none' : '' }}">
                                        <label class="input-label">{{translate('Gold Purity')}} <span class="text-danger">*</span></label>
                                        <select name="gold_purity" class="form-control">
                                            <option value="24k" {{ $plan->gold_purity == '24k' ? 'selected' : '' }}>{{translate('24 Karat (99.9%)')}}</option>
                                            <option value="22k" {{ $plan->gold_purity == '22k' ? 'selected' : '' }}>{{translate('22 Karat (91.6%)')}}</option>
                                            <option value="18k" {{ $plan->gold_purity == '18k' ? 'selected' : '' }}>{{translate('18 Karat (75%)')}}</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="input-label">{{translate('Payment Frequency')}} <span class="text-danger">*</span></label>
                                <select name="frequency" class="form-control" required>
                                    <option value="monthly" {{ $plan->frequency == 'monthly' ? 'selected' : '' }}>{{translate('Monthly')}}</option>
                                    <option value="weekly" {{ $plan->frequency == 'weekly' ? 'selected' : '' }}>{{translate('Weekly')}}</option>
                                    <option value="daily" {{ $plan->frequency == 'daily' ? 'selected' : '' }}>{{translate('Daily')}}</option>
                                </select>
                            </div>
                        </div>

                        <!-- Amount & Duration -->
                        <div class="col-md-6">
                            <h5 class="mb-3">{{translate('Amount & Duration')}}</h5>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="input-label">{{translate('Minimum Amount')}} (₹) <span class="text-danger">*</span></label>
                                        <input type="number" name="min_amount" class="form-control" 
                                               value="{{ old('min_amount', $plan->min_amount) }}" min="1" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="input-label">{{translate('Maximum Amount')}} (₹) <span class="text-danger">*</span></label>
                                        <input type="number" name="max_amount" class="form-control" 
                                               value="{{ old('max_amount', $plan->max_amount) }}" min="1" required>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="input-label">{{translate('Duration (Months)')}} <span class="text-danger">*</span></label>
                                <input type="number" name="duration_months" class="form-control" 
                                       value="{{ old('duration_months', $plan->duration_months) }}" min="1" max="120" required>
                            </div>

                            <h5 class="mb-3 mt-4">{{translate('Bonus Settings')}}</h5>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="input-label">{{translate('Bonus Months')}}</label>
                                        <input type="number" name="bonus_months" class="form-control" 
                                               value="{{ old('bonus_months', $plan->bonus_months) }}" min="0">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="input-label">{{translate('Bonus Percentage')}} (%)</label>
                                        <input type="number" name="bonus_percentage" class="form-control" 
                                               value="{{ old('bonus_percentage', $plan->bonus_percentage) }}" min="0" max="100" step="0.01">
                                    </div>
                                </div>
                            </div>

                            <div class="form-group mt-3">
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" name="is_active" class="custom-control-input" 
                                           id="isActive" {{ $plan->is_active ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="isActive">{{translate('Active')}}</label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="d-flex justify-content-end">
                        <a href="{{ route('admin.sip.plan.index') }}" class="btn btn-secondary mr-2">{{translate('Cancel')}}</a>
                        <button type="submit" class="btn btn-primary">
                            <i class="tio-save mr-1"></i> {{translate('Update Plan')}}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection

@push('script_2')
    <script>
        $('#metalType').on('change', function() {
            if ($(this).val() === 'gold') {
                $('#purityGroup').show();
            } else {
                $('#purityGroup').hide();
            }
        });
    </script>
@endpush
