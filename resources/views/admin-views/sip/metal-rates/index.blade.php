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
                </div>
            </div>
        </div>

        <!-- Add New Rate -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-header-title">{{translate('Update Metal Rate')}}</h5>
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
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>{{translate('Rate per Gram')}} (₹) <span class="text-danger">*</span></label>
                                <input type="number" name="rate_per_gram" class="form-control" 
                                       placeholder="e.g. 6500" step="0.01" required>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>&nbsp;</label>
                                <button type="submit" class="btn btn-primary btn-block">
                                    <i class="tio-save mr-1"></i> {{translate('Update')}}
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Current Rates -->
        <div class="row mb-4">
            @forelse($currentRates as $rate)
                <div class="col-md-4">
                    <div class="card border-left-warning h-100">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="text-muted mb-1">{{ ucfirst($rate->metal_type) }} ({{ strtoupper($rate->purity) }})</h6>
                                    <h3 class="text-warning mb-0">₹{{ number_format($rate->rate_per_gram, 2) }}/g</h3>
                                </div>
                                <div>
                                    <i class="tio-gem" style="font-size: 40px; color: #f5af19;"></i>
                                </div>
                            </div>
                            <small class="text-muted">{{translate('Updated')}}: {{ $rate->updated_at->diffForHumans() }}</small>
                        </div>
                    </div>
                </div>
            @empty
                <div class="col-12">
                    <div class="alert alert-info">
                        {{translate('No metal rates configured yet. Add rates using the form above.')}}
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
                                <th>{{translate('Source')}}</th>
                                <th>{{translate('Status')}}</th>
                                <th>{{translate('Date')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($rates as $rate)
                                <tr class="{{ $rate->is_current ? 'table-success' : '' }}">
                                    <td>{{ ucfirst($rate->metal_type) }}</td>
                                    <td>{{ strtoupper($rate->purity) }}</td>
                                    <td>₹{{ number_format($rate->rate_per_gram, 2) }}</td>
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
                                    <td colspan="6" class="text-center py-4">
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
@endsection

@push('script_2')
    <script>
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
    </script>
@endpush
