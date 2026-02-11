@extends('layouts.admin.app')

@section('title', translate('Gold Saving Schemes'))

@push('css_or_js')
    <style>
        .scheme-card {
            border-radius: 15px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            margin-bottom: 20px;
            position: relative;
        }
        .scheme-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }
        .scheme-header {
            padding: 20px;
            color: white;
            position: relative;
            border-radius: 15px 15px 0 0;
            overflow: hidden;
        }
        .scheme-header .badge-featured {
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(255,255,255,0.2);
            backdrop-filter: blur(10px);
        }
        .scheme-header h4 {
            margin: 0;
            font-weight: 700;
        }
        .scheme-header .tagline {
            opacity: 0.9;
            font-size: 13px;
            margin-top: 5px;
        }
        .scheme-body {
            padding: 20px;
            background: white;
        }
        .scheme-stats {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
        }
        .scheme-stat {
            text-align: center;
        }
        .scheme-stat h5 {
            margin: 0;
            font-size: 18px;
            font-weight: 700;
        }
        .scheme-stat small {
            color: #6c757d;
            font-size: 11px;
        }
        .discount-badges {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-bottom: 15px;
        }
        .discount-badge {
            font-size: 11px;
            padding: 4px 8px;
            border-radius: 20px;
        }
        .scheme-type-badge {
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .reward-highlight {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 15px;
            border-radius: 10px;
            margin-top: 10px;
            font-size: 12px;
        }
        .reward-highlight i {
            margin-right: 5px;
        }
        .super-gold-theme {
            background: linear-gradient(135deg, #f5af19 0%, #f12711 100%);
        }
        .swarna-suraksha-theme {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .regular-theme {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        .flexi-save-theme {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        .scheme-card .dropdown {
            position: relative;
            z-index: 10;
        }
        .scheme-card .dropdown-menu {
            z-index: 1050;
        }
        .scheme-card:hover {
            z-index: 5;
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
                        <i class="tio-layers mr-2"></i>
                        {{translate('Gold Saving Schemes')}}
                    </h1>
                    <p class="text-muted">{{translate('Manage SuperGold, Swarna Suraksha Yojana, and other saving schemes')}}</p>
                </div>
                <div class="col-sm-auto">
                    <form action="{{ route('admin.sip.plan.seed-defaults') }}" method="POST" class="d-inline">
                        @csrf
                        <button type="submit" class="btn btn-outline-info">
                            <i class="tio-magic-wand mr-1"></i> {{translate('Add Default Schemes')}}
                        </button>
                    </form>
                    <a href="{{ route('admin.sip.plan.create') }}" class="btn btn-primary">
                        <i class="tio-add mr-1"></i> {{translate('Create New Scheme')}}
                    </a>
                </div>
            </div>
        </div>
        <!-- End Page Header -->

        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form action="{{ route('admin.sip.plan.index') }}" method="GET">
                    <div class="row align-items-end">
                        <div class="col-md-3">
                            <div class="form-group mb-0">
                                <label>{{translate('Search')}}</label>
                                <input type="text" name="search" class="form-control" 
                                       value="{{ request('search') }}" placeholder="{{translate('Name or Code')}}">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group mb-0">
                                <label>{{translate('Scheme Type')}}</label>
                                <select name="scheme_type" class="form-control">
                                    <option value="">{{translate('All Types')}}</option>
                                    <option value="super_gold" {{ request('scheme_type') == 'super_gold' ? 'selected' : '' }}>SuperGold</option>
                                    <option value="swarna_suraksha" {{ request('scheme_type') == 'swarna_suraksha' ? 'selected' : '' }}>Swarna Suraksha</option>
                                    <option value="flexi_save" {{ request('scheme_type') == 'flexi_save' ? 'selected' : '' }}>Flexi Save</option>
                                    <option value="regular" {{ request('scheme_type') == 'regular' ? 'selected' : '' }}>Regular</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group mb-0">
                                <label>{{translate('Metal')}}</label>
                                <select name="metal_type" class="form-control">
                                    <option value="">{{translate('All Metals')}}</option>
                                    <option value="gold" {{ request('metal_type') == 'gold' ? 'selected' : '' }}>Gold</option>
                                    <option value="silver" {{ request('metal_type') == 'silver' ? 'selected' : '' }}>Silver</option>
                                    <option value="platinum" {{ request('metal_type') == 'platinum' ? 'selected' : '' }}>Platinum</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group mb-0">
                                <label>{{translate('Status')}}</label>
                                <select name="status" class="form-control">
                                    <option value="">{{translate('All')}}</option>
                                    <option value="active" {{ request('status') == 'active' ? 'selected' : '' }}>Active</option>
                                    <option value="inactive" {{ request('status') == 'inactive' ? 'selected' : '' }}>Inactive</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <button type="submit" class="btn btn-primary">
                                <i class="tio-search mr-1"></i> {{translate('Filter')}}
                            </button>
                            <a href="{{ route('admin.sip.plan.index') }}" class="btn btn-outline-secondary">
                                {{translate('Reset')}}
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Schemes Grid -->
        <div class="row">
            @forelse($plans as $plan)
                <div class="col-lg-4 col-md-6">
                    <div class="card scheme-card">
                        <div class="scheme-header {{ $plan->scheme_type == 'super_gold' ? 'super-gold-theme' : ($plan->scheme_type == 'swarna_suraksha' ? 'swarna-suraksha-theme' : ($plan->scheme_type == 'flexi_save' ? 'flexi-save-theme' : 'regular-theme')) }}" style="{{ $plan->color_code ? 'background: linear-gradient(135deg, '.$plan->color_code.' 0%, '.$plan->color_code.'cc 100%);' : '' }}">
                            
                            @if($plan->featured)
                                <span class="badge badge-light badge-featured">
                                    <i class="tio-star"></i> {{translate('Featured')}}
                                </span>
                            @endif
                            
                            <span class="badge badge-light scheme-type-badge mb-2">{{ $plan->scheme_type_label }}</span>
                            <h4>{{ $plan->display_name ?? $plan->name }}</h4>
                            @if($plan->tagline)
                                <div class="tagline">{{ $plan->tagline }}</div>
                            @endif
                        </div>
                        
                        <div class="scheme-body">
                            <div class="scheme-stats">
                                <div class="scheme-stat">
                                    <h5>₹{{ number_format($plan->min_amount) }}</h5>
                                    <small>{{translate('Min Amount')}}</small>
                                </div>
                                <div class="scheme-stat">
                                    <h5>{{ $plan->duration_months }}</h5>
                                    <small>{{translate('Months')}}</small>
                                </div>
                                <div class="scheme-stat">
                                    <h5>{{ $plan->user_sips_count ?? 0 }}</h5>
                                    <small>{{translate('Subscribers')}}</small>
                                </div>
                            </div>

                            <div class="discount-badges">
                                @if($plan->gold_making_discount > 0)
                                    <span class="badge badge-warning discount-badge">
                                        <i class="tio-gem"></i> {{ $plan->gold_making_discount }}% Gold Making
                                    </span>
                                @endif
                                @if($plan->bonus_months > 0)
                                    <span class="badge badge-success discount-badge">
                                        <i class="tio-gift"></i> +{{ $plan->bonus_months }} Month Bonus
                                    </span>
                                @endif
                                @if($plan->has_lucky_draw)
                                    <span class="badge badge-info discount-badge">
                                        <i class="tio-trophy"></i> Lucky Draw
                                    </span>
                                @endif
                            </div>

                            @if($plan->premium_reward)
                                <div class="reward-highlight">
                                    <i class="tio-car"></i> {{translate('Premium Reward')}}: {{ $plan->premium_reward }}
                                </div>
                            @endif

                            <hr class="my-3">

                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="badge {{ $plan->is_active ? 'badge-success' : 'badge-secondary' }}">
                                        {{ $plan->is_active ? translate('Active') : translate('Inactive') }}
                                    </span>
                                    @if($plan->show_on_app)
                                        <span class="badge badge-light ml-1">
                                            <i class="tio-phone-android"></i> App
                                        </span>
                                    @endif
                                </div>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" 
                                            type="button" 
                                            id="dropdownMenuButton{{ $plan->id }}" 
                                            data-toggle="dropdown" 
                                            aria-haspopup="true" 
                                            aria-expanded="false">
                                        {{translate('Actions')}}
                                    </button>
                                    <div class="dropdown-menu dropdown-menu-right" aria-labelledby="dropdownMenuButton{{ $plan->id }}">
                                        <a class="dropdown-item" href="{{ route('admin.sip.plan.show', $plan->id) }}">
                                            <i class="tio-visible mr-2"></i>{{translate('View Details')}}
                                        </a>
                                        <a class="dropdown-item" href="{{ route('admin.sip.plan.edit', $plan->id) }}">
                                            <i class="tio-edit mr-2"></i>{{translate('Edit')}}
                                        </a>
                                        <form action="{{ route('admin.sip.plan.toggle-status', $plan->id) }}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="dropdown-item">
                                                <i class="tio-toggle-off mr-2"></i>
                                                {{ $plan->is_active ? translate('Deactivate') : translate('Activate') }}
                                            </button>
                                        </form>
                                        <form action="{{ route('admin.sip.plan.toggle-featured', $plan->id) }}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="dropdown-item">
                                                <i class="tio-star{{ $plan->featured ? '-outlined' : '' }} mr-2"></i>
                                                {{ $plan->featured ? translate('Unfeature') : translate('Feature') }}
                                            </button>
                                        </form>
                                        <div class="dropdown-divider"></div>
                                        <form action="{{ route('admin.sip.plan.destroy', $plan->id) }}" method="POST" 
                                              onsubmit="return confirm('{{translate('Are you sure you want to delete this scheme?')}}')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="dropdown-item text-danger">
                                                <i class="tio-delete mr-2"></i>{{translate('Delete')}}
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            @empty
                <div class="col-12">
                    <div class="card">
                        <div class="card-body text-center py-5">
                            <img src="{{ asset('public/assets/admin/img/empty.png') }}" alt="" style="width: 120px; opacity: 0.5;">
                            <h5 class="mt-4 text-muted">{{translate('No Schemes Found')}}</h5>
                            <p class="text-muted">{{translate('Create your first gold saving scheme or add default schemes.')}}</p>
                            <form action="{{ route('admin.sip.plan.seed-defaults') }}" method="POST" class="d-inline">
                                @csrf
                                <button type="submit" class="btn btn-primary">
                                    <i class="tio-magic-wand mr-1"></i> {{translate('Add SuperGold & Swarna Suraksha Schemes')}}
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            @endforelse
        </div>

        <!-- Pagination -->
        @if($plans->hasPages())
            <div class="d-flex justify-content-center mt-4">
                {{ $plans->links() }}
            </div>
        @endif
    </div>
@endsection
