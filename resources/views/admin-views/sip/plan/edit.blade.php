@extends('layouts.admin.app')

@section('title', translate('Edit Gold Saving Scheme'))

@push('css_or_js')
    <style>
        .section-card {
            border-radius: 15px;
            margin-bottom: 20px;
        }
        .section-header {
            background: linear-gradient(90deg, #667eea, #764ba2);
            color: white;
            padding: 15px 20px;
            border-radius: 15px 15px 0 0;
        }
        .section-header h6 {
            margin: 0;
            font-weight: 600;
        }
        .current-banner {
            max-height: 150px;
            border-radius: 10px;
            object-fit: cover;
        }
        .reward-card {
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            background: #f8f9fa;
        }
        .reward-card .badge {
            position: absolute;
            top: 10px;
            right: 10px;
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
                        <a href="{{ route('admin.sip.plan.index') }}" class="btn btn-sm btn-circle btn-secondary mr-2">
                            <i class="tio-chevron-left"></i>
                        </a>
                        {{translate('Edit')}} - {{ $plan->display_name ?? $plan->name }}
                    </h1>
                    <span class="badge" style="background-color: {{ $plan->color_code }}; color: white;">{{ $plan->scheme_type_label }}</span>
                </div>
            </div>
        </div>
        <!-- End Page Header -->

        <form action="{{ route('admin.sip.plan.update', $plan->id) }}" method="POST" enctype="multipart/form-data">
            @csrf
            
            <div class="row">
                <div class="col-lg-8">
                    <!-- Basic Information -->
                    <div class="card section-card">
                        <div class="section-header">
                            <h6><i class="tio-info-circle mr-2"></i>{{translate('Basic Information')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Scheme Name')}} <span class="text-danger">*</span></label>
                                        <input type="text" name="name" class="form-control" value="{{ old('name', $plan->name) }}" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Scheme Code')}}</label>
                                        <input type="text" name="scheme_code" class="form-control" value="{{ old('scheme_code', $plan->scheme_code) }}" style="text-transform: uppercase;">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Display Name')}}</label>
                                        <input type="text" name="display_name" class="form-control" value="{{ old('display_name', $plan->display_name) }}">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Tagline')}}</label>
                                        <input type="text" name="tagline" class="form-control" value="{{ old('tagline', $plan->tagline) }}">
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div class="form-group">
                                        <label>{{translate('Description')}}</label>
                                        <textarea name="description" class="form-control" rows="3">{{ old('description', $plan->description) }}</textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Scheme Configuration -->
                    <div class="card section-card">
                        <div class="section-header">
                            <h6><i class="tio-settings mr-2"></i>{{translate('Scheme Configuration')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Scheme Type')}} <span class="text-danger">*</span></label>
                                        <select name="scheme_type" class="form-control" required>
                                            <option value="super_gold" {{ old('scheme_type', $plan->scheme_type) == 'super_gold' ? 'selected' : '' }}>SuperGold (11+1)</option>
                                            <option value="swarna_suraksha" {{ old('scheme_type', $plan->scheme_type) == 'swarna_suraksha' ? 'selected' : '' }}>Swarna Suraksha Yojana</option>
                                            <option value="flexi_save" {{ old('scheme_type', $plan->scheme_type) == 'flexi_save' ? 'selected' : '' }}>Flexi Save</option>
                                            <option value="regular" {{ old('scheme_type', $plan->scheme_type) == 'regular' ? 'selected' : '' }}>Regular SIP</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Metal Type')}} <span class="text-danger">*</span></label>
                                        <select name="metal_type" class="form-control" required>
                                            <option value="gold" {{ old('metal_type', $plan->metal_type) == 'gold' ? 'selected' : '' }}>Gold</option>
                                            <option value="silver" {{ old('metal_type', $plan->metal_type) == 'silver' ? 'selected' : '' }}>Silver</option>
                                            <option value="platinum" {{ old('metal_type', $plan->metal_type) == 'platinum' ? 'selected' : '' }}>Platinum</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Gold Purity')}}</label>
                                        <select name="gold_purity" class="form-control">
                                            <option value="22k" {{ old('gold_purity', $plan->gold_purity) == '22k' ? 'selected' : '' }}>22 Karat (91.6%)</option>
                                            <option value="24k" {{ old('gold_purity', $plan->gold_purity) == '24k' ? 'selected' : '' }}>24 Karat (99.9%)</option>
                                            <option value="18k" {{ old('gold_purity', $plan->gold_purity) == '18k' ? 'selected' : '' }}>18 Karat (75%)</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Payment Frequency')}} <span class="text-danger">*</span></label>
                                        <select name="frequency" class="form-control" required>
                                            <option value="monthly" {{ old('frequency', $plan->frequency) == 'monthly' ? 'selected' : '' }}>Monthly</option>
                                            <option value="weekly" {{ old('frequency', $plan->frequency) == 'weekly' ? 'selected' : '' }}>Weekly</option>
                                            <option value="daily" {{ old('frequency', $plan->frequency) == 'daily' ? 'selected' : '' }}>Daily</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Duration (Months)')}} <span class="text-danger">*</span></label>
                                        <input type="number" name="duration_months" class="form-control" value="{{ old('duration_months', $plan->duration_months) }}" min="1" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Maturity Days')}}</label>
                                        <input type="number" name="maturity_days" class="form-control" value="{{ old('maturity_days', $plan->maturity_days) }}" min="1">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Redemption Window (Days)')}}</label>
                                        <input type="number" name="redemption_window_days" class="form-control" value="{{ old('redemption_window_days', $plan->redemption_window_days) }}" min="1">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Amount Configuration -->
                    <div class="card section-card">
                        <div class="section-header" style="background: linear-gradient(90deg, #f5af19, #f12711);">
                            <h6><i class="tio-paid mr-2"></i>{{translate('Amount Configuration')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Minimum Amount')}} (₹) <span class="text-danger">*</span></label>
                                        <input type="number" name="min_amount" class="form-control" value="{{ old('min_amount', $plan->min_amount) }}" min="0" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Maximum Amount')}} (₹) <span class="text-danger">*</span></label>
                                        <input type="number" name="max_amount" class="form-control" value="{{ old('max_amount', $plan->max_amount) }}" min="0" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Amount Increment')}} (₹)</label>
                                        <input type="number" name="amount_increment" class="form-control" value="{{ old('amount_increment', $plan->amount_increment) }}" min="0">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Bonus Configuration -->
                    <div class="card section-card">
                        <div class="section-header" style="background: linear-gradient(90deg, #11998e, #38ef7d);">
                            <h6><i class="tio-gift mr-2"></i>{{translate('Bonus & Rewards Configuration')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Bonus Months')}}</label>
                                        <input type="number" name="bonus_months" class="form-control" value="{{ old('bonus_months', $plan->bonus_months) }}" min="0">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Bonus Percentage')}} (%)</label>
                                        <input type="number" name="bonus_percentage" class="form-control" value="{{ old('bonus_percentage', $plan->bonus_percentage) }}" min="0" max="100" step="0.01">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Premium Reward')}}</label>
                                        <input type="text" name="premium_reward" class="form-control" value="{{ old('premium_reward', $plan->premium_reward) }}" placeholder="e.g., Car, Bike">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group pt-4">
                                        <div class="custom-control custom-checkbox">
                                            <input type="checkbox" class="custom-control-input" id="has_lucky_draw" name="has_lucky_draw" value="1" {{ old('has_lucky_draw', $plan->has_lucky_draw) ? 'checked' : '' }}>
                                            <label class="custom-control-label" for="has_lucky_draw">
                                                {{translate('Enable Lucky Draw')}}
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Making Charges Discounts -->
                    <div class="card section-card">
                        <div class="section-header" style="background: linear-gradient(90deg, #4facfe, #00f2fe);">
                            <h6><i class="tio-percent mr-2"></i>{{translate('Making Charges Discounts')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Gold Making Discount')}} (%)</label>
                                        <input type="number" name="gold_making_discount" class="form-control" value="{{ old('gold_making_discount', $plan->gold_making_discount) }}" min="0" max="100" step="0.01">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Diamond Making Discount')}} (%)</label>
                                        <input type="number" name="diamond_making_discount" class="form-control" value="{{ old('diamond_making_discount', $plan->diamond_making_discount) }}" min="0" max="100" step="0.01">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Silver Making Discount')}} (%)</label>
                                        <input type="number" name="silver_making_discount" class="form-control" value="{{ old('silver_making_discount', $plan->silver_making_discount) }}" min="0" max="100" step="0.01">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Benefits & Terms -->
                    <div class="card section-card">
                        <div class="section-header">
                            <h6><i class="tio-document-text-outlined mr-2"></i>{{translate('Benefits & Terms')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="form-group">
                                <label>{{translate('Benefits')}} <span class="text-muted">({{translate('One per line')}})</span></label>
                                <textarea name="benefits" class="form-control" rows="5">{{ old('benefits', is_array($plan->benefits) ? implode("\n", $plan->benefits) : $plan->benefits) }}</textarea>
                            </div>
                            <div class="form-group">
                                <label>{{translate('Terms & Conditions')}}</label>
                                <textarea name="terms_conditions" class="form-control" rows="4">{{ old('terms_conditions', $plan->terms_conditions) }}</textarea>
                            </div>
                        </div>
                    </div>

                    <!-- Rewards Section -->
                    @if($plan->rewards && $plan->rewards->count() > 0)
                        <div class="card section-card">
                            <div class="section-header" style="background: linear-gradient(90deg, #f093fb, #f5576c);">
                                <h6><i class="tio-trophy mr-2"></i>{{translate('Configured Rewards')}}</h6>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    @foreach($plan->rewards as $reward)
                                        <div class="col-md-6">
                                            <div class="reward-card position-relative">
                                                <span class="badge badge-{{ $reward->is_active ? 'success' : 'secondary' }}">{{ $reward->is_active ? 'Active' : 'Inactive' }}</span>
                                                <h6>{{ $reward->reward_name }}</h6>
                                                <p class="text-muted small mb-2">{{ $reward->reward_description }}</p>
                                                <small class="d-block">
                                                    <i class="tio-checkmark-circle text-success mr-1"></i>
                                                    Min {{ $reward->min_installments_required }} installments
                                                </small>
                                                <small class="d-block">
                                                    <i class="tio-gift mr-1"></i>
                                                    {{ $reward->type_label }} • {{ $reward->remaining_quantity }} left
                                                </small>
                                                <div class="mt-2">
                                                    <form action="{{ route('admin.sip.plan.remove-reward', [$plan->id, $reward->id]) }}" method="POST" class="d-inline"
                                                          onsubmit="return confirm('Remove this reward?')">
                                                        @csrf
                                                        @method('DELETE')
                                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                                            <i class="tio-delete"></i> Remove
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        </div>
                    @endif
                </div>

                <!-- Sidebar -->
                <div class="col-lg-4">
                    <!-- Appearance -->
                    <div class="card section-card">
                        <div class="section-header">
                            <h6><i class="tio-brush mr-2"></i>{{translate('Appearance')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="form-group">
                                <label>{{translate('Theme Color')}}</label>
                                <input type="color" name="color_code" class="form-control" value="{{ old('color_code', $plan->color_code ?? '#f5af19') }}" style="height: 50px;">
                            </div>
                            <div class="form-group">
                                <label>{{translate('Banner Image')}}</label>
                                @if($plan->banner_image)
                                    <div class="mb-2">
                                        <img src="{{ asset('storage/' . $plan->banner_image) }}" alt="Banner" class="img-fluid current-banner">
                                    </div>
                                @endif
                                <input type="file" name="banner_image" class="form-control" accept="image/*">
                                <small class="text-muted">{{translate('Leave empty to keep current')}}</small>
                            </div>
                        </div>
                    </div>

                    <!-- Visibility & Settings -->
                    <div class="card section-card">
                        <div class="section-header">
                            <h6><i class="tio-visible mr-2"></i>{{translate('Visibility & Settings')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="form-group">
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="is_active" name="is_active" value="1" {{ old('is_active', $plan->is_active) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="is_active">{{translate('Active')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="show_on_app" name="show_on_app" value="1" {{ old('show_on_app', $plan->show_on_app) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="show_on_app">{{translate('Show on Mobile App')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="show_on_web" name="show_on_web" value="1" {{ old('show_on_web', $plan->show_on_web) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="show_on_web">{{translate('Show on Website')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="featured" name="featured" value="1" {{ old('featured', $plan->featured) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="featured">{{translate('Featured Scheme')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="price_lock_enabled" name="price_lock_enabled" value="1" {{ old('price_lock_enabled', $plan->price_lock_enabled) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="price_lock_enabled">{{translate('Lock Gold Price on Payment')}}</label>
                                </div>
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" class="custom-control-input" id="is_refundable" name="is_refundable" value="1" {{ old('is_refundable', $plan->is_refundable) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="is_refundable">{{translate('Allow Refunds')}}</label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>{{translate('Sort Order')}}</label>
                                <input type="number" name="sort_order" class="form-control" value="{{ old('sort_order', $plan->sort_order) }}" min="0">
                            </div>
                        </div>
                    </div>

                    <!-- Add Reward -->
                    <div class="card section-card">
                        <div class="section-header" style="background: linear-gradient(90deg, #f093fb, #f5576c);">
                            <h6><i class="tio-trophy mr-2"></i>{{translate('Add Reward')}}</h6>
                        </div>
                        <div class="card-body">
                            <small class="text-muted d-block mb-3">{{translate('Add appreciation gifts or lucky draw rewards')}}</small>
                            
                            <button type="button" class="btn btn-outline-primary btn-block" data-toggle="modal" data-target="#addRewardModal">
                                <i class="tio-add mr-1"></i> {{translate('Add Reward')}}
                            </button>
                        </div>
                    </div>

                    <!-- Stats -->
                    <div class="card section-card">
                        <div class="section-header" style="background: #6c757d;">
                            <h6><i class="tio-chart-bar-2 mr-2"></i>{{translate('Statistics')}}</h6>
                        </div>
                        <div class="card-body">
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">{{translate('Active Subscribers')}}</span>
                                <strong>{{ $plan->userSips()->where('status', 'active')->count() }}</strong>
                            </div>
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">{{translate('Total Subscribers')}}</span>
                                <strong>{{ $plan->userSips()->count() }}</strong>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-muted">{{translate('Rewards Claimed')}}</span>
                                <strong>{{ $plan->rewards()->sum('quantity_claimed') }}</strong>
                            </div>
                        </div>
                    </div>

                    <!-- Submit -->
                    <div class="card">
                        <div class="card-body">
                            <button type="submit" class="btn btn-primary btn-lg btn-block">
                                <i class="tio-save mr-1"></i> {{translate('Update Scheme')}}
                            </button>
                            <a href="{{ route('admin.sip.plan.index') }}" class="btn btn-outline-secondary btn-block mt-2">
                                {{translate('Cancel')}}
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <!-- Add Reward Modal -->
    <div class="modal fade" id="addRewardModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="{{ route('admin.sip.plan.add-reward', $plan->id) }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    <div class="modal-header">
                        <h5 class="modal-title">{{translate('Add Reward')}}</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label>{{translate('Reward Name')}} <span class="text-danger">*</span></label>
                            <input type="text" name="reward_name" class="form-control" required placeholder="e.g., Silver Coin">
                        </div>
                        <div class="form-group">
                            <label>{{translate('Description')}}</label>
                            <textarea name="reward_description" class="form-control" rows="2"></textarea>
                        </div>
                        <div class="form-group">
                            <label>{{translate('Reward Type')}} <span class="text-danger">*</span></label>
                            <select name="reward_type" class="form-control" required>
                                <option value="appreciation_gift">Appreciation Gift</option>
                                <option value="premium_reward">Premium Reward</option>
                                <option value="lucky_draw">Lucky Draw</option>
                                <option value="milestone">Milestone Reward</option>
                            </select>
                        </div>
                        <div class="row">
                            <div class="col-6">
                                <div class="form-group">
                                    <label>{{translate('Min Installments')}} <span class="text-danger">*</span></label>
                                    <input type="number" name="min_installments_required" class="form-control" value="6" min="1" required>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="form-group">
                                    <label>{{translate('Quantity')}} <span class="text-danger">*</span></label>
                                    <input type="number" name="quantity_available" class="form-control" value="10" min="1" required>
                                </div>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>{{translate('Reward Value')}} (₹)</label>
                            <input type="number" name="reward_value" class="form-control" value="0" min="0">
                        </div>
                        <div class="form-group">
                            <label>{{translate('Valid Until')}}</label>
                            <input type="date" name="valid_until" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>{{translate('Reward Image')}}</label>
                            <input type="file" name="reward_image" class="form-control" accept="image/*">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Cancel')}}</button>
                        <button type="submit" class="btn btn-primary">{{translate('Add Reward')}}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection
