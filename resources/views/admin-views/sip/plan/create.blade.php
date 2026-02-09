@extends('layouts.admin.app')

@section('title', translate('Create Gold Saving Scheme'))

@push('css_or_js')
    <style>
        .scheme-preview {
            background: linear-gradient(135deg, #f5af19 0%, #f12711 100%);
            border-radius: 15px;
            color: white;
            padding: 30px;
            margin-bottom: 20px;
        }
        .scheme-preview h2 {
            margin: 0;
            font-weight: 700;
        }
        .scheme-preview .tagline {
            opacity: 0.9;
            font-size: 14px;
            margin-top: 5px;
        }
        .benefit-item {
            display: flex;
            align-items: center;
            padding: 10px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            margin-bottom: 10px;
        }
        .benefit-item i {
            margin-right: 10px;
            color: #28a745;
        }
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
                        {{translate('Create Gold Saving Scheme')}}
                    </h1>
                    <p class="text-muted">{{translate('Configure SuperGold, Swarna Suraksha Yojana, or custom schemes')}}</p>
                </div>
            </div>
        </div>
        <!-- End Page Header -->

        <form action="{{ route('admin.sip.plan.store') }}" method="POST" enctype="multipart/form-data">
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
                                        <input type="text" name="name" class="form-control" value="{{ old('name') }}" 
                                               placeholder="e.g. SuperGold 11+1" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Scheme Code')}}</label>
                                        <input type="text" name="scheme_code" class="form-control" value="{{ old('scheme_code') }}" 
                                               placeholder="e.g. SUPERGOLD" style="text-transform: uppercase;">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Display Name')}}</label>
                                        <input type="text" name="display_name" class="form-control" value="{{ old('display_name') }}" 
                                               placeholder="e.g. SuperGold 11+1 Scheme">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Tagline')}}</label>
                                        <input type="text" name="tagline" class="form-control" value="{{ old('tagline') }}" 
                                               placeholder="e.g. Save for 11 months, Get 1 month FREE!">
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div class="form-group">
                                        <label>{{translate('Description')}}</label>
                                        <textarea name="description" class="form-control" rows="3" 
                                                  placeholder="{{translate('Describe the scheme benefits and features')}}">{{ old('description') }}</textarea>
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
                                            <option value="super_gold" {{ old('scheme_type') == 'super_gold' ? 'selected' : '' }}>SuperGold (11+1)</option>
                                            <option value="swarna_suraksha" {{ old('scheme_type') == 'swarna_suraksha' ? 'selected' : '' }}>Swarna Suraksha Yojana</option>
                                            <option value="flexi_save" {{ old('scheme_type') == 'flexi_save' ? 'selected' : '' }}>Flexi Save</option>
                                            <option value="regular" {{ old('scheme_type') == 'regular' ? 'selected' : '' }}>Regular SIP</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Metal Type')}} <span class="text-danger">*</span></label>
                                        <select name="metal_type" class="form-control" required>
                                            <option value="gold" {{ old('metal_type') == 'gold' ? 'selected' : '' }}>Gold</option>
                                            <option value="silver" {{ old('metal_type') == 'silver' ? 'selected' : '' }}>Silver</option>
                                            <option value="platinum" {{ old('metal_type') == 'platinum' ? 'selected' : '' }}>Platinum</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Gold Purity')}}</label>
                                        <select name="gold_purity" class="form-control">
                                            <option value="22k" {{ old('gold_purity') == '22k' ? 'selected' : '' }}>22 Karat (91.6%)</option>
                                            <option value="24k" {{ old('gold_purity') == '24k' ? 'selected' : '' }}>24 Karat (99.9%)</option>
                                            <option value="18k" {{ old('gold_purity') == '18k' ? 'selected' : '' }}>18 Karat (75%)</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Payment Frequency')}} <span class="text-danger">*</span></label>
                                        <select name="frequency" class="form-control" required>
                                            <option value="monthly" {{ old('frequency') == 'monthly' ? 'selected' : '' }}>Monthly</option>
                                            <option value="weekly" {{ old('frequency') == 'weekly' ? 'selected' : '' }}>Weekly</option>
                                            <option value="daily" {{ old('frequency') == 'daily' ? 'selected' : '' }}>Daily</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Duration (Months)')}} <span class="text-danger">*</span></label>
                                        <input type="number" name="duration_months" class="form-control" value="{{ old('duration_months', 11) }}" min="1" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Maturity Days')}}</label>
                                        <input type="number" name="maturity_days" class="form-control" value="{{ old('maturity_days', 330) }}" min="1">
                                        <small class="text-muted">{{translate('Days from joining to maturity')}}</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Redemption Window (Days)')}}</label>
                                        <input type="number" name="redemption_window_days" class="form-control" value="{{ old('redemption_window_days', 35) }}" min="1">
                                        <small class="text-muted">{{translate('Days after maturity for redemption')}}</small>
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
                                        <input type="number" name="min_amount" class="form-control" value="{{ old('min_amount', 1000) }}" min="0" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Maximum Amount')}} (₹) <span class="text-danger">*</span></label>
                                        <input type="number" name="max_amount" class="form-control" value="{{ old('max_amount', 100000) }}" min="0" required>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Amount Increment')}} (₹)</label>
                                        <input type="number" name="amount_increment" class="form-control" value="{{ old('amount_increment', 500) }}" min="0">
                                        <small class="text-muted">{{translate('Multiples for subsequent payments')}}</small>
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
                                        <label>{{translate('Bonus Months')}} <span class="text-info">(e.g., 11+1 scheme)</span></label>
                                        <input type="number" name="bonus_months" class="form-control" value="{{ old('bonus_months', 1) }}" min="0">
                                        <small class="text-muted">{{translate('Extra months added as bonus')}}</small>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Bonus Percentage')}} (%)</label>
                                        <input type="number" name="bonus_percentage" class="form-control" value="{{ old('bonus_percentage', 0) }}" min="0" max="100" step="0.01">
                                        <small class="text-muted">{{translate('Additional gold bonus on total')}}</small>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>{{translate('Premium Reward')}}</label>
                                        <input type="text" name="premium_reward" class="form-control" value="{{ old('premium_reward') }}" placeholder="e.g., Car, Bike, Scooty">
                                        <small class="text-muted">{{translate('Lucky draw grand prize')}}</small>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group pt-4">
                                        <div class="custom-control custom-checkbox">
                                            <input type="checkbox" class="custom-control-input" id="has_lucky_draw" name="has_lucky_draw" value="1" {{ old('has_lucky_draw') ? 'checked' : '' }}>
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
                                        <input type="number" name="gold_making_discount" class="form-control" value="{{ old('gold_making_discount', 75) }}" min="0" max="100" step="0.01">
                                        <small class="text-muted">{{translate('Discount on gold jewelry making')}}</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Diamond Making Discount')}} (%)</label>
                                        <input type="number" name="diamond_making_discount" class="form-control" value="{{ old('diamond_making_discount', 60) }}" min="0" max="100" step="0.01">
                                        <small class="text-muted">{{translate('Discount on diamond jewelry')}}</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label>{{translate('Silver Making Discount')}} (%)</label>
                                        <input type="number" name="silver_making_discount" class="form-control" value="{{ old('silver_making_discount', 100) }}" min="0" max="100" step="0.01">
                                        <small class="text-muted">{{translate('Discount on silver items')}}</small>
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
                                <textarea name="benefits" class="form-control" rows="5" placeholder="75% discount on Gold Making Charges&#10;60% discount on Diamond Jewellery&#10;100% discount on Silver Making Charges&#10;Gold price locked on payment day">{{ old('benefits') }}</textarea>
                            </div>
                            <div class="form-group">
                                <label>{{translate('Terms & Conditions')}}</label>
                                <textarea name="terms_conditions" class="form-control" rows="4" placeholder="{{translate('Enter terms and conditions for this scheme')}}">{{ old('terms_conditions') }}</textarea>
                            </div>
                        </div>
                    </div>
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
                                <input type="color" name="color_code" class="form-control" value="{{ old('color_code', '#f5af19') }}" style="height: 50px;">
                            </div>
                            <div class="form-group">
                                <label>{{translate('Banner Image')}}</label>
                                <input type="file" name="banner_image" class="form-control" accept="image/*">
                                <small class="text-muted">{{translate('Recommended: 1200x400px')}}</small>
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
                                    <input type="checkbox" class="custom-control-input" id="is_active" name="is_active" value="1" {{ old('is_active', true) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="is_active">{{translate('Active')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="show_on_app" name="show_on_app" value="1" {{ old('show_on_app', true) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="show_on_app">{{translate('Show on Mobile App')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="show_on_web" name="show_on_web" value="1" {{ old('show_on_web', true) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="show_on_web">{{translate('Show on Website')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="featured" name="featured" value="1" {{ old('featured') ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="featured">{{translate('Featured Scheme')}}</label>
                                </div>
                                <div class="custom-control custom-switch mb-3">
                                    <input type="checkbox" class="custom-control-input" id="price_lock_enabled" name="price_lock_enabled" value="1" {{ old('price_lock_enabled', true) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="price_lock_enabled">{{translate('Lock Gold Price on Payment')}}</label>
                                </div>
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" class="custom-control-input" id="is_refundable" name="is_refundable" value="1" {{ old('is_refundable') ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="is_refundable">{{translate('Allow Refunds')}}</label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>{{translate('Sort Order')}}</label>
                                <input type="number" name="sort_order" class="form-control" value="{{ old('sort_order', 0) }}" min="0">
                            </div>
                        </div>
                    </div>

                    <!-- Submit -->
                    <div class="card">
                        <div class="card-body">
                            <button type="submit" class="btn btn-primary btn-lg btn-block">
                                <i class="tio-save mr-1"></i> {{translate('Create Scheme')}}
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
@endsection
