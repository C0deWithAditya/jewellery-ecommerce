<!-- Metal Component Row -->
<div class="metal-component-row" data-index="{{ $index }}">
    <input type="hidden" name="metals[{{ $index }}][id]" value="{{ $metal->id ?? '' }}">
    <div class="row">
        <div class="col-md-2">
            <div class="form-group">
                <label class="input-label">{{translate('Metal Type')}} <span class="text-danger">*</span></label>
                <select name="metals[{{ $index }}][metal_type]" class="form-control metal-type-select" onchange="updatePurityForIndex({{ $index }})">
                    <option value="gold" {{ ($metal->metal_type ?? '') == 'gold' ? 'selected' : '' }}>{{translate('Gold')}}</option>
                    <option value="silver" {{ ($metal->metal_type ?? '') == 'silver' ? 'selected' : '' }}>{{translate('Silver')}}</option>
                    <option value="platinum" {{ ($metal->metal_type ?? '') == 'platinum' ? 'selected' : '' }}>{{translate('Platinum')}}</option>
                    <option value="diamond" {{ ($metal->metal_type ?? '') == 'diamond' ? 'selected' : '' }}>{{translate('Diamond')}}</option>
                    <option value="ruby" {{ ($metal->metal_type ?? '') == 'ruby' ? 'selected' : '' }}>{{translate('Ruby')}}</option>
                    <option value="emerald" {{ ($metal->metal_type ?? '') == 'emerald' ? 'selected' : '' }}>{{translate('Emerald')}}</option>
                    <option value="sapphire" {{ ($metal->metal_type ?? '') == 'sapphire' ? 'selected' : '' }}>{{translate('Sapphire')}}</option>
                    <option value="pearl" {{ ($metal->metal_type ?? '') == 'pearl' ? 'selected' : '' }}>{{translate('Pearl')}}</option>
                    <option value="other" {{ ($metal->metal_type ?? '') == 'other' ? 'selected' : '' }}>{{translate('Other')}}</option>
                </select>
            </div>
        </div>
        <div class="col-md-2">
            <div class="form-group">
                <label class="input-label">{{translate('Purity/Grade')}}</label>
                <select name="metals[{{ $index }}][purity]" class="form-control purity-select" id="purity_{{ $index }}">
                    @php
                        $metalType = $metal->metal_type ?? 'gold';
                        $currentPurity = $metal->purity ?? '';
                        
                        $purities = match($metalType) {
                            'gold' => ['24k' => '24K (99.9%)', '22k' => '22K (91.6%)', '18k' => '18K (75%)', '14k' => '14K (58.3%)'],
                            'silver' => ['999' => '999 Fine', '925' => '925 Sterling'],
                            'platinum' => ['950' => '950 Platinum', '900' => '900 Platinum'],
                            'diamond' => ['VVS1' => 'VVS1', 'VVS2' => 'VVS2', 'VS1' => 'VS1', 'VS2' => 'VS2', 'SI1' => 'SI1', 'SI2' => 'SI2'],
                            default => [],
                        };
                    @endphp
                    @if(count($purities) == 0)
                        <option value="">N/A</option>
                    @else
                        @foreach($purities as $value => $label)
                            <option value="{{ $value }}" {{ $currentPurity == $value ? 'selected' : '' }}>{{ $label }}</option>
                        @endforeach
                    @endif
                </select>
            </div>
        </div>
        <div class="col-md-2">
            <div class="form-group">
                <label class="input-label">{{translate('Weight')}} <span class="text-danger">*</span></label>
                <input type="number" step="0.0001" min="0" name="metals[{{ $index }}][weight]" class="form-control metal-weight" value="{{ $metal->weight ?? '' }}" placeholder="0.000" onchange="recalculatePrice()">
            </div>
        </div>
        <div class="col-md-2">
            <div class="form-group">
                <label class="input-label">{{translate('Unit')}}</label>
                <select name="metals[{{ $index }}][weight_unit]" class="form-control weight-unit-select">
                    <option value="gram" {{ ($metal->weight_unit ?? 'gram') == 'gram' ? 'selected' : '' }}>{{translate('Grams')}}</option>
                    <option value="carat" {{ ($metal->weight_unit ?? '') == 'carat' ? 'selected' : '' }}>{{translate('Carats')}}</option>
                    <option value="milligram" {{ ($metal->weight_unit ?? '') == 'milligram' ? 'selected' : '' }}>{{translate('Milligrams')}}</option>
                </select>
            </div>
        </div>
        <div class="col-md-2">
            <div class="form-group">
                <label class="input-label">{{translate('Rate/Unit')}} (₹)</label>
                <input type="number" step="0.01" min="0" name="metals[{{ $index }}][rate_per_unit]" class="form-control metal-rate" value="{{ $metal->rate_per_unit ?? '' }}" placeholder="{{translate('Auto from API')}}">
                <small class="text-muted">
                    @if($metal->rate_source ?? '' == 'live_api')
                        <i class="tio-sync text-success"></i> {{translate('Live Rate')}}
                    @elseif($metal->rate_source ?? '' == 'manual')
                        <i class="tio-edit text-warning"></i> {{translate('Manual')}}
                    @else
                        {{translate('Leave empty for live')}}
                    @endif
                </small>
            </div>
        </div>
        <div class="col-md-2">
            <div class="form-group">
                <label class="input-label">{{translate('Value')}} (₹)</label>
                <input type="text" class="form-control bg-light calculated-value" readonly value="₹{{ number_format($metal->calculated_value ?? 0, 2) }}">
                <button type="button" class="btn btn-sm btn-outline-danger mt-1 remove-metal-btn" onclick="removeMetalComponent({{ $index }})" style="display: none;">
                    <i class="tio-delete"></i> {{translate('Remove')}}
                </button>
            </div>
        </div>
    </div>
    <hr class="my-2">
</div>
