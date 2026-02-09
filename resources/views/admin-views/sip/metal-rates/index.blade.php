@extends('layouts.admin.app')

@section('title', translate('Metal Rates'))

@section('content')
    <div class="content container-fluid">
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-gem mr-2"></i>
                        {{translate('Metal Rates Management')}}
                    </h1>
                    <p class="text-muted small mb-0">
                        {{translate('Manage live metal rates from API or set manually.')}}
                    </p>
                </div>
                <div class="col-sm-auto">
                    @if($apiSettings['enabled'] ?? false)
                        <form action="{{ route('admin.sip.metal-rates.sync') }}" method="POST" class="d-inline">
                            @csrf
                            <button type="submit" class="btn btn-success">
                                <i class="tio-refresh mr-1"></i> {{translate('Sync from API')}}
                            </button>
                        </form>
                    @else
                        <button type="button" class="btn btn-secondary" disabled title="{{translate('Enable API to sync')}}">
                            <i class="tio-refresh mr-1"></i> {{translate('Sync from API')}}
                        </button>
                    @endif
                </div>
            </div>
        </div>

        <!-- API Configuration Card -->
        <div class="card mb-4">
            <div class="card-header" style="background: linear-gradient(90deg, #667eea, #764ba2);">
                <h5 class="card-header-title text-white">
                    <i class="tio-key mr-2"></i>{{translate('Metal Price API Configuration')}}
                </h5>
            </div>
            <div class="card-body">
                <form action="{{ route('admin.sip.metal-rates.save-api-settings') }}" method="POST">
                    @csrf
                    <div class="row align-items-end">
                        <div class="col-md-4">
                            <div class="form-group mb-0">
                                <label class="font-weight-bold">{{translate('API Key')}} <span class="text-danger">*</span></label>
                                <input type="text" name="api_key" class="form-control" 
                                       value="{{ $apiSettings['api_key'] ?? '' }}" 
                                       placeholder="{{translate('Enter Metal Price API Key')}}">
                                <small class="text-muted">{{translate('Get your API key from')}} <a href="https://metalpriceapi.com" target="_blank">metalpriceapi.com</a></small>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group mb-0">
                                <label class="font-weight-bold">{{translate('API Status')}}</label>
                                <div class="custom-control custom-switch custom-switch-lg">
                                    <input type="checkbox" class="custom-control-input" id="api_enabled" name="api_enabled" value="1" {{ ($apiSettings['enabled'] ?? false) ? 'checked' : '' }}>
                                    <label class="custom-control-label" for="api_enabled">
                                        <span class="badge {{ ($apiSettings['enabled'] ?? false) ? 'badge-success' : 'badge-secondary' }}" id="api_status_badge">
                                            {{ ($apiSettings['enabled'] ?? false) ? translate('Enabled') : translate('Disabled') }}
                                        </span>
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group mb-0">
                                <label class="font-weight-bold">{{translate('Auto Sync Interval')}}</label>
                                <select name="sync_interval" class="form-control">
                                    <option value="5" {{ ($apiSettings['sync_interval'] ?? 5) == 5 ? 'selected' : '' }}>{{translate('Every 5 minutes')}}</option>
                                    <option value="15" {{ ($apiSettings['sync_interval'] ?? 5) == 15 ? 'selected' : '' }}>{{translate('Every 15 minutes')}}</option>
                                    <option value="30" {{ ($apiSettings['sync_interval'] ?? 5) == 30 ? 'selected' : '' }}>{{translate('Every 30 minutes')}}</option>
                                    <option value="60" {{ ($apiSettings['sync_interval'] ?? 5) == 60 ? 'selected' : '' }}>{{translate('Every 1 hour')}}</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="tio-save mr-1"></i> {{translate('Save')}}
                            </button>
                        </div>
                    </div>
                    
                    @if($apiSettings['enabled'] ?? false)
                        <div class="mt-3 p-3 bg-light rounded">
                            <div class="row">
                                <div class="col-md-4">
                                    <small class="text-muted">{{translate('Last Synced')}}</small>
                                    <p class="mb-0 font-weight-bold">{{ $apiSettings['last_synced'] ?? translate('Never') }}</p>
                                </div>
                                <div class="col-md-4">
                                    <small class="text-muted">{{translate('API Status')}}</small>
                                    <p class="mb-0">
                                        @if($apiSettings['api_key'] ?? false)
                                            <span class="badge badge-success"><i class="tio-checkmark-circle mr-1"></i>{{translate('Configured')}}</span>
                                        @else
                                            <span class="badge badge-warning"><i class="tio-warning mr-1"></i>{{translate('Not Configured')}}</span>
                                        @endif
                                    </p>
                                </div>
                                <div class="col-md-4">
                                    <small class="text-muted">{{translate('Test API')}}</small>
                                    <p class="mb-0">
                                        <button type="button" class="btn btn-sm btn-outline-info" onclick="testApiConnection()">
                                            <i class="tio-flash mr-1"></i>{{translate('Test Connection')}}
                                        </button>
                                    </p>
                                </div>
                            </div>
                        </div>
                    @endif
                </form>
            </div>
        </div>

        <!-- Manual Rate Update Card -->
        <div class="card mb-4">
            <div class="card-header bg-warning">
                <h5 class="card-header-title">
                    <i class="tio-edit mr-2"></i>{{translate('Manual Rate Update')}}
                    <small class="text-muted ml-2">({{translate('Updates all product prices using this metal')}})</small>
                </h5>
            </div>
            <div class="card-body">
                <form action="{{ route('admin.sip.metal-rates.update') }}" method="POST">
                    @csrf
                    <div class="row">
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>{{translate('Metal Type')}} <span class="text-danger">*</span></label>
                                <select name="metal_type" id="metalTypeSelect" class="form-control" required>
                                    <option value="gold">{{translate('Gold')}}</option>
                                    <option value="silver">{{translate('Silver')}}</option>
                                    <option value="platinum">{{translate('Platinum')}}</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>{{translate('Purity')}} <span class="text-danger">*</span></label>
                                <select name="purity" id="puritySelect" class="form-control" required>
                                    <option value="24k">24 Karat (99.9%)</option>
                                    <option value="22k" selected>22 Karat (91.6%)</option>
                                    <option value="18k">18 Karat (75%)</option>
                                    <option value="14k">14 Karat (58.3%)</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>{{translate('Rate per Gram')}} (₹) <span class="text-danger">*</span></label>
                                <input type="number" name="rate_per_gram" class="form-control" 
                                       placeholder="e.g. 6500" step="0.01" required>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="form-group">
                                <div class="custom-control custom-checkbox mt-4 pt-2">
                                    <input type="checkbox" class="custom-control-input" id="update_products" name="update_products" value="1" checked>
                                    <label class="custom-control-label" for="update_products">
                                        {{translate('Update all product prices')}}
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="text-right">
                        <button type="submit" class="btn btn-warning">
                            <i class="tio-save mr-1"></i> {{translate('Update Rate & Recalculate Prices')}}
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Current Rates -->
        <div class="row mb-4">
            @forelse($currentRates as $rate)
                <div class="col-md-4 mb-3">
                    <div class="card h-100" style="border-left: 4px solid {{ $rate->metal_type == 'gold' ? '#f5af19' : ($rate->metal_type == 'silver' ? '#c0c0c0' : '#e5e4e2') }};">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="text-muted mb-1">{{ ucfirst($rate->metal_type) }} ({{ strtoupper($rate->purity) }})</h6>
                                    <h3 class="mb-0" style="color: {{ $rate->metal_type == 'gold' ? '#f5af19' : ($rate->metal_type == 'silver' ? '#6c757d' : '#343a40') }};">
                                        ₹{{ number_format($rate->rate_per_gram, 2) }}/g
                                    </h3>
                                    <small class="text-muted">₹{{ number_format($rate->rate_per_10gram, 2) }}/10g</small>
                                </div>
                                <div>
                                    @if($rate->metal_type == 'gold')
                                        <i class="tio-gem" style="font-size: 40px; color: #f5af19;"></i>
                                    @elseif($rate->metal_type == 'silver')
                                        <i class="tio-gem" style="font-size: 40px; color: #c0c0c0;"></i>
                                    @else
                                        <i class="tio-gem" style="font-size: 40px; color: #e5e4e2;"></i>
                                    @endif
                                </div>
                            </div>
                            <hr class="my-2">
                            <div class="d-flex justify-content-between align-items-center">
                                <small class="text-muted">
                                    <i class="tio-time mr-1"></i>{{ $rate->updated_at->diffForHumans() }}
                                </small>
                                <span class="badge {{ $rate->source == 'api' ? 'badge-info' : 'badge-secondary' }}">
                                    {{ $rate->source == 'api' ? 'API' : 'Manual' }}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            @empty
                <div class="col-12">
                    <div class="alert alert-info">
                        <i class="tio-info mr-2"></i>{{translate('No metal rates configured yet. Add rates using the form above or sync from API.')}}
                    </div>
                </div>
            @endforelse
        </div>

        <!-- Rate History -->
        <div class="card">
            <div class="card-header">
                <h5 class="card-header-title">{{translate('Rate History')}}</h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{translate('Metal')}}</th>
                                <th>{{translate('Purity')}}</th>
                                <th>{{translate('Rate/Gram')}}</th>
                                <th>{{translate('Rate/10Gram')}}</th>
                                <th>{{translate('Source')}}</th>
                                <th>{{translate('Status')}}</th>
                                <th>{{translate('Date')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($rates as $rate)
                                <tr class="{{ $rate->is_current ? 'table-success' : '' }}">
                                    <td>
                                        <span class="badge" style="background-color: {{ $rate->metal_type == 'gold' ? '#f5af19' : ($rate->metal_type == 'silver' ? '#c0c0c0' : '#e5e4e2') }}; color: {{ $rate->metal_type == 'silver' ? '#000' : '#fff' }};">
                                            {{ ucfirst($rate->metal_type) }}
                                        </span>
                                    </td>
                                    <td>{{ strtoupper($rate->purity) }}</td>
                                    <td>₹{{ number_format($rate->rate_per_gram, 2) }}</td>
                                    <td>₹{{ number_format($rate->rate_per_10gram, 2) }}</td>
                                    <td>
                                        @if($rate->source == 'api')
                                            <span class="badge badge-info">API</span>
                                        @else
                                            <span class="badge badge-secondary">Manual</span>
                                        @endif
                                    </td>
                                    <td>
                                        @if($rate->is_current)
                                            <span class="badge badge-success">{{translate('Current')}}</span>
                                        @else
                                            <span class="badge badge-light">{{translate('Historical')}}</span>
                                        @endif
                                    </td>
                                    <td>{{ $rate->created_at->format('d M Y, h:i A') }}</td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="7" class="text-center py-4">
                                        <p class="text-muted mb-0">{{translate('No rate history available')}}</p>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if($rates->hasPages())
                <div class="card-footer">
                    {{ $rates->links() }}
                </div>
            @endif
        </div>
    </div>

    <!-- API Test Modal -->
    <div class="modal fade" id="apiTestModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">{{translate('API Connection Test')}}</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body" id="apiTestResult">
                    <div class="text-center">
                        <div class="spinner-border text-primary" role="status">
                            <span class="sr-only">Loading...</span>
                        </div>
                        <p class="mt-2">{{translate('Testing API connection...')}}</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Close')}}</button>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script_2')
    <script>
        // Metal type change handler
        $('#metalTypeSelect').on('change', function() {
            let metal = $(this).val();
            let puritySelect = $('#puritySelect');
            puritySelect.empty();
            
            if (metal === 'gold') {
                puritySelect.append('<option value="24k">24 Karat (99.9%)</option>');
                puritySelect.append('<option value="22k" selected>22 Karat (91.6%)</option>');
                puritySelect.append('<option value="18k">18 Karat (75%)</option>');
                puritySelect.append('<option value="14k">14 Karat (58.3%)</option>');
            } else if (metal === 'silver') {
                puritySelect.append('<option value="999" selected>999 Fine Silver</option>');
                puritySelect.append('<option value="925">925 Sterling Silver</option>');
            } else {
                puritySelect.append('<option value="999" selected>999 Platinum</option>');
            }
        });

        // API enabled toggle
        $('#api_enabled').on('change', function() {
            let badge = $('#api_status_badge');
            if ($(this).is(':checked')) {
                badge.removeClass('badge-secondary').addClass('badge-success').text('{{translate("Enabled")}}');
            } else {
                badge.removeClass('badge-success').addClass('badge-secondary').text('{{translate("Disabled")}}');
            }
        });

        // Test API connection
        function testApiConnection() {
            $('#apiTestModal').modal('show');
            
            $.ajax({
                url: '{{ route("admin.sip.metal-rates.test-api") }}',
                type: 'GET',
                success: function(response) {
                    if (response.success) {
                        $('#apiTestResult').html(`
                            <div class="alert alert-success">
                                <i class="tio-checkmark-circle mr-2"></i>
                                <strong>{{translate('Connection Successful!')}}</strong>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-sm">
                                    <tr><td><strong>Gold (24K)</strong></td><td>₹${response.data.gold || 'N/A'}/g</td></tr>
                                    <tr><td><strong>Silver</strong></td><td>₹${response.data.silver || 'N/A'}/g</td></tr>
                                    <tr><td><strong>Platinum</strong></td><td>₹${response.data.platinum || 'N/A'}/g</td></tr>
                                </table>
                            </div>
                        `);
                    } else {
                        $('#apiTestResult').html(`
                            <div class="alert alert-danger">
                                <i class="tio-warning mr-2"></i>
                                <strong>{{translate('Connection Failed!')}}</strong>
                                <p class="mb-0 mt-2">${response.message}</p>
                            </div>
                        `);
                    }
                },
                error: function(xhr) {
                    $('#apiTestResult').html(`
                        <div class="alert alert-danger">
                            <i class="tio-warning mr-2"></i>
                            <strong>{{translate('Error!')}}</strong>
                            <p class="mb-0 mt-2">{{translate('Failed to test API connection. Please try again.')}}</p>
                        </div>
                    `);
                }
            });
        }
    </script>
@endpush
