<!-- Jewelry Specific Fields Section (Edit) -->
<div class="card mb-3">
    <div class="card-header bg-gold text-white" style="background: linear-gradient(90deg, #f5af19, #f12711);">
        <h5 class="mb-0 text-white">
            <i class="tio-diamond mr-2"></i>{{translate('Jewelry Details')}}
        </h5>
    </div>
    <div class="card-body">
        <!-- Enable Dynamic Pricing Toggle -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="custom-control custom-switch">
                    <input type="checkbox" class="custom-control-input" id="is_price_dynamic" name="is_price_dynamic" value="1" {{ $product->is_price_dynamic ? 'checked' : '' }}>
                    <label class="custom-control-label" for="is_price_dynamic">
                        <strong>{{translate('Enable Dynamic Pricing')}}</strong>
                        <small class="text-muted d-block">{{translate('Price will be calculated from live metal rates automatically')}}</small>
                    </label>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Metal Type -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Metal Type')}}</label>
                    <select name="metal_type" id="metal_type" class="form-control js-select2-custom" onchange="updatePurityOptions()">
                        <option value="none" {{ ($product->metal_type ?? 'none') == 'none' ? 'selected' : '' }}>{{translate('Not Applicable')}}</option>
                        <option value="gold" {{ ($product->metal_type ?? '') == 'gold' ? 'selected' : '' }}>{{translate('Gold')}}</option>
                        <option value="silver" {{ ($product->metal_type ?? '') == 'silver' ? 'selected' : '' }}>{{translate('Silver')}}</option>
                        <option value="platinum" {{ ($product->metal_type ?? '') == 'platinum' ? 'selected' : '' }}>{{translate('Platinum')}}</option>
                    </select>
                </div>
            </div>

            <!-- Metal Purity -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Metal Purity')}}</label>
                    <select name="metal_purity" id="metal_purity" class="form-control">
                        @if(($product->metal_type ?? 'none') == 'gold')
                            <option value="24k" {{ ($product->metal_purity ?? '') == '24k' ? 'selected' : '' }}>24 Karat (99.9%)</option>
                            <option value="22k" {{ ($product->metal_purity ?? '') == '22k' ? 'selected' : '' }}>22 Karat (91.6%)</option>
                            <option value="18k" {{ ($product->metal_purity ?? '') == '18k' ? 'selected' : '' }}>18 Karat (75%)</option>
                            <option value="14k" {{ ($product->metal_purity ?? '') == '14k' ? 'selected' : '' }}>14 Karat (58.3%)</option>
                        @elseif(($product->metal_type ?? 'none') == 'silver')
                            <option value="999" {{ ($product->metal_purity ?? '') == '999' ? 'selected' : '' }}>999 Fine Silver</option>
                            <option value="925" {{ ($product->metal_purity ?? '') == '925' ? 'selected' : '' }}>925 Sterling Silver</option>
                        @elseif(($product->metal_type ?? 'none') == 'platinum')
                            <option value="999" {{ ($product->metal_purity ?? '') == '999' ? 'selected' : '' }}>999 Platinum</option>
                            <option value="950" {{ ($product->metal_purity ?? '') == '950' ? 'selected' : '' }}>950 Platinum</option>
                        @else
                            <option value="none">{{translate('Select Metal First')}}</option>
                        @endif
                    </select>
                </div>
            </div>

            <!-- Jewelry Type -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Jewelry Type')}}</label>
                    <select name="jewelry_type" class="form-control js-select2-custom">
                        <option value="">{{translate('Select Type')}}</option>
                        <option value="ring" {{ ($product->jewelry_type ?? '') == 'ring' ? 'selected' : '' }}>{{translate('Ring')}}</option>
                        <option value="necklace" {{ ($product->jewelry_type ?? '') == 'necklace' ? 'selected' : '' }}>{{translate('Necklace')}}</option>
                        <option value="bracelet" {{ ($product->jewelry_type ?? '') == 'bracelet' ? 'selected' : '' }}>{{translate('Bracelet')}}</option>
                        <option value="earring" {{ ($product->jewelry_type ?? '') == 'earring' ? 'selected' : '' }}>{{translate('Earring')}}</option>
                        <option value="bangle" {{ ($product->jewelry_type ?? '') == 'bangle' ? 'selected' : '' }}>{{translate('Bangle')}}</option>
                        <option value="pendant" {{ ($product->jewelry_type ?? '') == 'pendant' ? 'selected' : '' }}>{{translate('Pendant')}}</option>
                        <option value="chain" {{ ($product->jewelry_type ?? '') == 'chain' ? 'selected' : '' }}>{{translate('Chain')}}</option>
                        <option value="anklet" {{ ($product->jewelry_type ?? '') == 'anklet' ? 'selected' : '' }}>{{translate('Anklet')}}</option>
                        <option value="other" {{ ($product->jewelry_type ?? '') == 'other' ? 'selected' : '' }}>{{translate('Other')}}</option>
                    </select>
                </div>
            </div>

            <!-- Size -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Size')}}</label>
                    <input type="text" name="size" class="form-control" value="{{ $product->size ?? '' }}" placeholder="{{ translate('e.g., Ring Size 18, Chain 22 inches') }}">
                </div>
            </div>
        </div>

        <hr class="my-3">

        <div class="row">
            <!-- Gross Weight -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Gross Weight')}} ({{translate('grams')}})</label>
                    <input type="number" step="0.001" min="0" name="gross_weight" id="gross_weight" class="form-control weight-input" value="{{ $product->gross_weight ?? '' }}" placeholder="{{ translate('Total weight') }}" onchange="calculateNetWeight()">
                </div>
            </div>

            <!-- Stone Weight -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Stone Weight')}} ({{translate('carats')}})</label>
                    <input type="number" step="0.001" min="0" name="stone_weight" id="stone_weight" class="form-control weight-input" value="{{ $product->stone_weight ?? 0 }}" placeholder="{{ translate('Stone weight in carats') }}" onchange="calculateNetWeight()">
                </div>
            </div>

            <!-- Net Weight (Auto-calculated) -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Net Metal Weight')}} ({{translate('grams')}})</label>
                    <input type="number" step="0.001" min="0" name="net_weight" id="net_weight" class="form-control bg-light" value="{{ $product->net_weight ?? '' }}" placeholder="{{ translate('Auto-calculated') }}" readonly>
                </div>
            </div>

            <!-- Design Code -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Design Code')}}</label>
                    <input type="text" name="design_code" class="form-control" value="{{ $product->design_code ?? '' }}" placeholder="{{ translate('e.g., GR-2024-001') }}">
                </div>
            </div>
        </div>

        <hr class="my-3">

        <div class="row">
            <!-- Making Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Making Charges')}}</label>
                    <input type="number" step="0.01" min="0" name="making_charges" class="form-control" value="{{ $product->making_charges ?? 0 }}" placeholder="{{ translate('Making charges') }}">
                </div>
            </div>

            <!-- Making Charge Type -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Making Charge Type')}}</label>
                    <select name="making_charge_type" class="form-control">
                        <option value="fixed" {{ ($product->making_charge_type ?? 'fixed') == 'fixed' ? 'selected' : '' }}>{{translate('Fixed Amount')}}</option>
                        <option value="percentage" {{ ($product->making_charge_type ?? '') == 'percentage' ? 'selected' : '' }}>{{translate('Percentage of Metal Value')}}</option>
                        <option value="per_gram" {{ ($product->making_charge_type ?? '') == 'per_gram' ? 'selected' : '' }}>{{translate('Per Gram')}}</option>
                    </select>
                </div>
            </div>

            <!-- Stone Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Stone Charges')}} (₹)</label>
                    <input type="number" step="0.01" min="0" name="stone_charges" class="form-control" value="{{ $product->stone_charges ?? 0 }}" placeholder="{{ translate('Stone value') }}">
                </div>
            </div>

            <!-- Other Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Other Charges')}} (₹)</label>
                    <input type="number" step="0.01" min="0" name="other_charges" class="form-control" value="{{ $product->other_charges ?? 0 }}" placeholder="{{ translate('Certificate, polish, etc.') }}">
                </div>
            </div>
        </div>

        <hr class="my-3">

        <div class="row">
            <!-- Hallmark Number -->
            <div class="col-lg-4 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Hallmark Number')}}</label>
                    <input type="text" name="hallmark_number" class="form-control" value="{{ $product->hallmark_number ?? '' }}" placeholder="{{ translate('BIS Hallmark Number') }}">
                </div>
            </div>

            <!-- HUID -->
            <div class="col-lg-4 col-sm-6">
                <div class="form-group">
                    <label class="input-label">
                        {{translate('HUID')}}
                        <i class="tio-info-outlined" data-toggle="tooltip" title="{{translate('6-digit Hallmarking Unique ID')}}"></i>
                    </label>
                    <input type="text" name="huid" class="form-control" maxlength="6" value="{{ $product->huid ?? '' }}" placeholder="{{ translate('6-digit HUID') }}">
                </div>
            </div>

            <!-- Stone Details -->
            <div class="col-lg-4 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Stone Details')}}</label>
                    <textarea name="stone_details" class="form-control" rows="2" placeholder='{{ translate("e.g., 4 diamonds, VVS clarity") }}'>{{ $product->stone_details ?? '' }}</textarea>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function updatePurityOptions() {
        var metalType = document.getElementById('metal_type').value;
        var puritySelect = document.getElementById('metal_purity');
        puritySelect.innerHTML = '';

        if (metalType === 'gold') {
            puritySelect.innerHTML = `
                <option value="24k">24 Karat (99.9%)</option>
                <option value="22k" selected>22 Karat (91.6%)</option>
                <option value="18k">18 Karat (75%)</option>
                <option value="14k">14 Karat (58.3%)</option>
            `;
        } else if (metalType === 'silver') {
            puritySelect.innerHTML = `
                <option value="999" selected>999 Fine Silver</option>
                <option value="925">925 Sterling Silver</option>
            `;
        } else if (metalType === 'platinum') {
            puritySelect.innerHTML = `
                <option value="999" selected>999 Platinum</option>
                <option value="950">950 Platinum</option>
            `;
        } else {
            puritySelect.innerHTML = '<option value="none">{{translate("Not Applicable")}}</option>';
        }
    }

    function calculateNetWeight() {
        var grossWeight = parseFloat(document.getElementById('gross_weight').value) || 0;
        var stoneWeight = parseFloat(document.getElementById('stone_weight').value) || 0;
        // Convert carats to grams (1 carat = 0.2 grams)
        var stoneWeightGrams = stoneWeight * 0.2;
        var netWeight = grossWeight - stoneWeightGrams;
        document.getElementById('net_weight').value = netWeight > 0 ? netWeight.toFixed(3) : 0;
    }

    document.getElementById('is_price_dynamic').addEventListener('change', function() {
        var priceField = document.querySelector('input[name="price"]');
        if (this.checked) {
            priceField.readOnly = true;
            priceField.classList.add('bg-light');
        } else {
            priceField.readOnly = false;
            priceField.classList.remove('bg-light');
        }
    });

    // Initialize on load
    document.addEventListener('DOMContentLoaded', function() {
        var isDynamic = document.getElementById('is_price_dynamic').checked;
        var priceField = document.querySelector('input[name="price"]');
        if (isDynamic) {
            priceField.readOnly = true;
            priceField.classList.add('bg-light');
        }
    });
</script>
