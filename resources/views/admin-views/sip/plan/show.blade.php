@extends('layouts.admin.app')

@section('title', translate('Scheme Details'))

@push('css_or_js')
    <style>
        .scheme-hero {
            border-radius: 20px;
            color: white;
            padding: 40px;
            position: relative;
            overflow: hidden;
        }
        .scheme-hero::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 100%;
            height: 200%;
            background: rgba(255,255,255,0.1);
            transform: rotate(30deg);
        }
        .scheme-hero h1 {
            font-size: 36px;
            font-weight: 800;
            margin-bottom: 10px;
        }
        .scheme-hero .tagline {
            font-size: 18px;
            opacity: 0.9;
        }
        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-card h4 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        .stat-card p {
            margin: 0;
            color: #6c757d;
        }
        .benefit-list {
            list-style: none;
            padding: 0;
        }
        .benefit-list li {
            padding: 12px 0;
            border-bottom: 1px solid #eee;
            display: flex;
            align-items: center;
        }
        .benefit-list li:last-child {
            border-bottom: none;
        }
        .benefit-list li i {
            color: #28a745;
            margin-right: 12px;
            font-size: 18px;
        }
        .discount-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            margin-bottom: 15px;
        }
        .discount-card h3 {
            font-size: 32px;
            font-weight: 800;
            margin: 0;
        }
        .discount-card p {
            margin: 5px 0 0;
            opacity: 0.9;
        }
        .reward-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
        }
        .reward-item {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 15px;
            text-align: center;
        }
        .reward-item img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 50%;
            margin-bottom: 10px;
        }
        .maturity-calc {
            background: linear-gradient(135deg, #f5af19 0%, #f12711 100%);
            border-radius: 15px;
            color: white;
            padding: 25px;
        }
        .maturity-calc input {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            font-size: 24px;
            text-align: center;
            padding: 15px;
        }
        .maturity-calc input::placeholder {
            color: rgba(255,255,255,0.7);
        }
    </style>
@endpush

@section('content')
    <div class="content container-fluid">
        <!-- Page Header -->
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <a href="{{ route('admin.sip.plan.index') }}" class="btn btn-sm btn-secondary">
                        <i class="tio-chevron-left mr-1"></i> {{translate('Back to Schemes')}}
                    </a>
                </div>
                <div class="col-sm-auto">
                    <a href="{{ route('admin.sip.plan.edit', $plan->id) }}" class="btn btn-primary">
                        <i class="tio-edit mr-1"></i> {{translate('Edit Scheme')}}
                    </a>
                </div>
            </div>
        </div>

        <!-- Scheme Hero -->
        <div class="scheme-hero mb-4" style="background: linear-gradient(135deg, {{ $plan->color_code ?? '#f5af19' }} 0%, {{ $plan->color_code ?? '#f5af19' }}cc 100%);">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <span class="badge badge-light mb-2">{{ $plan->scheme_type_label }}</span>
                    <h1>{{ $plan->display_name ?? $plan->name }}</h1>
                    @if($plan->tagline)
                        <p class="tagline">{{ $plan->tagline }}</p>
                    @endif
                    <div class="mt-3">
                        <span class="badge badge-light mr-2">
                            <i class="tio-clock mr-1"></i> {{ $plan->duration_months }} Months
                        </span>
                        <span class="badge badge-light mr-2">
                            <i class="tio-gem mr-1"></i> {{ ucfirst($plan->metal_type) }} ({{ strtoupper($plan->gold_purity) }})
                        </span>
                        @if($plan->bonus_months > 0)
                            <span class="badge badge-success">
                                <i class="tio-gift mr-1"></i> +{{ $plan->bonus_months }} Month Bonus
                            </span>
                        @endif
                    </div>
                </div>
                <div class="col-lg-4 text-right">
                    <h2 class="mb-0">₹{{ number_format($plan->min_amount) }}</h2>
                    <p class="mb-0">to ₹{{ number_format($plan->max_amount) }}/month</p>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Main Content -->
            <div class="col-lg-8">
                <!-- Stats Row -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h4>{{ $plan->user_sips_count ?? 0 }}</h4>
                            <p>{{translate('Total Subscribers')}}</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h4>{{ $plan->userSips()->where('status', 'active')->count() }}</h4>
                            <p>{{translate('Active')}}</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h4>{{ $plan->userSips()->where('status', 'completed')->count() }}</h4>
                            <p>{{translate('Completed')}}</p>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <h4>{{ $plan->rewards()->count() }}</h4>
                            <p>{{translate('Rewards')}}</p>
                        </div>
                    </div>
                </div>

                <!-- Description -->
                @if($plan->description)
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="card-header-title">{{translate('About This Scheme')}}</h5>
                        </div>
                        <div class="card-body">
                            <p class="mb-0">{{ $plan->description }}</p>
                        </div>
                    </div>
                @endif

                <!-- Benefits -->
                @if($plan->benefits && count($plan->benefits) > 0)
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="card-header-title">
                                <i class="tio-checkmark-circle text-success mr-2"></i>
                                {{translate('Scheme Benefits')}}
                            </h5>
                        </div>
                        <div class="card-body">
                            <ul class="benefit-list">
                                @foreach($plan->benefits as $benefit)
                                    <li>
                                        <i class="tio-checkmark-circle-outlined"></i>
                                        {{ $benefit }}
                                    </li>
                                @endforeach
                            </ul>
                        </div>
                    </div>
                @endif

                <!-- Rewards -->
                @if($plan->rewards && $plan->rewards->count() > 0)
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="card-header-title">
                                <i class="tio-trophy text-warning mr-2"></i>
                                {{translate('Rewards & Gifts')}}
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="reward-grid">
                                @foreach($plan->rewards as $reward)
                                    <div class="reward-item">
                                        <img src="{{ $reward->image_url }}" alt="{{ $reward->reward_name }}">
                                        <h6 class="mb-1">{{ $reward->reward_name }}</h6>
                                        <small class="text-muted d-block">{{ $reward->type_label }}</small>
                                        <small class="text-success">
                                            <i class="tio-checkmark-circle mr-1"></i>
                                            {{ $reward->remaining_quantity }}/{{ $reward->quantity_available }} available
                                        </small>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                    </div>
                @endif

                <!-- Terms & Conditions -->
                @if($plan->terms_conditions)
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="card-header-title">{{translate('Terms & Conditions')}}</h5>
                        </div>
                        <div class="card-body">
                            <p class="mb-0 text-muted">{{ $plan->terms_conditions }}</p>
                        </div>
                    </div>
                @endif

                <!-- Recent Subscribers -->
                @if($plan->userSips && $plan->userSips->count() > 0)
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-header-title">{{translate('Recent Subscribers')}}</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead class="thead-light">
                                        <tr>
                                            <th>{{translate('User')}}</th>
                                            <th>{{translate('Amount')}}</th>
                                            <th>{{translate('Progress')}}</th>
                                            <th>{{translate('Status')}}</th>
                                            <th>{{translate('Joined')}}</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach($plan->userSips as $sip)
                                            <tr>
                                                <td>{{ $sip->user->f_name ?? 'N/A' }} {{ $sip->user->l_name ?? '' }}</td>
                                                <td>₹{{ number_format($sip->monthly_amount) }}/mo</td>
                                                <td>
                                                    <div class="progress" style="height: 8px;">
                                                        <div class="progress-bar bg-success" style="width: {{ $sip->progress_percentage }}%"></div>
                                                    </div>
                                                    <small class="text-muted">{{ $sip->installments_paid }}/{{ $sip->installments_paid + $sip->installments_pending }}</small>
                                                </td>
                                                <td>
                                                    <span class="badge badge-{{ $sip->status == 'active' ? 'success' : ($sip->status == 'completed' ? 'info' : 'secondary') }}">
                                                        {{ ucfirst($sip->status) }}
                                                    </span>
                                                </td>
                                                <td>{{ $sip->created_at->format('d M Y') }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                @endif
            </div>

            <!-- Sidebar -->
            <div class="col-lg-4">
                <!-- Making Charge Discounts -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="card-header-title">{{translate('Making Charge Discounts')}}</h5>
                    </div>
                    <div class="card-body">
                        @if($plan->gold_making_discount > 0)
                            <div class="discount-card">
                                <h3>{{ $plan->gold_making_discount }}%</h3>
                                <p>{{translate('Gold Making Charges')}}</p>
                            </div>
                        @endif
                        @if($plan->diamond_making_discount > 0)
                            <div class="discount-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                                <h3>{{ $plan->diamond_making_discount }}%</h3>
                                <p>{{translate('Diamond Jewellery')}}</p>
                            </div>
                        @endif
                        @if($plan->silver_making_discount > 0)
                            <div class="discount-card" style="background: linear-gradient(135deg, #c0c0c0 0%, #808080 100%);">
                                <h3>{{ $plan->silver_making_discount }}%</h3>
                                <p>{{translate('Silver Making Charges')}}</p>
                            </div>
                        @endif
                    </div>
                </div>

                <!-- Premium Reward -->
                @if($plan->premium_reward)
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="card-header-title">
                                <i class="tio-car text-warning mr-2"></i>
                                {{translate('Premium Reward')}}
                            </h5>
                        </div>
                        <div class="card-body text-center">
                            <i class="tio-car" style="font-size: 60px; color: #f5af19;"></i>
                            <h4 class="mt-3">{{ $plan->premium_reward }}</h4>
                            <p class="text-muted">{{translate('Lucky draw grand prize for eligible subscribers')}}</p>
                            @if($plan->has_lucky_draw)
                                <span class="badge badge-success">{{translate('Lucky Draw Enabled')}}</span>
                            @endif
                        </div>
                    </div>
                @endif

                <!-- Scheme Configuration -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="card-header-title">{{translate('Scheme Configuration')}}</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">{{translate('Scheme Code')}}</span>
                            <strong>{{ $plan->scheme_code ?? 'N/A' }}</strong>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">{{translate('Frequency')}}</span>
                            <strong>{{ ucfirst($plan->frequency) }}</strong>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">{{translate('Maturity Days')}}</span>
                            <strong>{{ $plan->maturity_days }} days</strong>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">{{translate('Redemption Window')}}</span>
                            <strong>{{ $plan->redemption_window_days }} days</strong>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">{{translate('Amount Increment')}}</span>
                            <strong>₹{{ number_format($plan->amount_increment) }}</strong>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span class="text-muted">{{translate('Price Lock')}}</span>
                            <strong>
                                @if($plan->price_lock_enabled)
                                    <span class="text-success"><i class="tio-checkmark-circle"></i> Enabled</span>
                                @else
                                    <span class="text-muted"><i class="tio-clear-circle"></i> Disabled</span>
                                @endif
                            </strong>
                        </div>
                        <div class="d-flex justify-content-between py-2">
                            <span class="text-muted">{{translate('Refundable')}}</span>
                            <strong>
                                @if($plan->is_refundable)
                                    <span class="text-success">Yes</span>
                                @else
                                    <span class="text-danger">No (Jewelry Only)</span>
                                @endif
                            </strong>
                        </div>
                    </div>
                </div>

                <!-- Status -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-header-title">{{translate('Status')}}</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span>{{translate('Active')}}</span>
                            <span class="badge badge-{{ $plan->is_active ? 'success' : 'secondary' }}">
                                {{ $plan->is_active ? 'Yes' : 'No' }}
                            </span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span>{{translate('Featured')}}</span>
                            <span class="badge badge-{{ $plan->featured ? 'warning' : 'secondary' }}">
                                {{ $plan->featured ? 'Yes' : 'No' }}
                            </span>
                        </div>
                        <div class="d-flex justify-content-between py-2 border-bottom">
                            <span>{{translate('Show on App')}}</span>
                            <span class="badge badge-{{ $plan->show_on_app ? 'info' : 'secondary' }}">
                                {{ $plan->show_on_app ? 'Yes' : 'No' }}
                            </span>
                        </div>
                        <div class="d-flex justify-content-between py-2">
                            <span>{{translate('Show on Web')}}</span>
                            <span class="badge badge-{{ $plan->show_on_web ? 'info' : 'secondary' }}">
                                {{ $plan->show_on_web ? 'Yes' : 'No' }}
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
