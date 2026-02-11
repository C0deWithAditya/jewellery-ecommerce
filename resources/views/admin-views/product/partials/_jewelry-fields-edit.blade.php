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
                <div class="custom-control custom-switch p-3 bg-light rounded border">
                    <input type="checkbox" class="custom-control-input" id="is_price_dynamic" name="is_price_dynamic" value="1" {{ $product->is_price_dynamic ? 'checked' : '' }}>
                    <label class="custom-control-label" for="is_price_dynamic">
                        <strong class="text-dark">{{translate('Enable Dynamic Pricing')}}</strong>
                        <small class="text-muted d-block">{{translate('Price will be calculated from live metal rates automatically based on all components below')}}</small>
                    </label>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Jewelry Type -->
            <div class="col-lg-4 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Jewelry Type')}}</label>
                    <select name="jewelry_type" class="form-control js-select2-custom">
                        <option value="">{{translate('Select Type')}}</option>
                        <option value="ring" {{ $product->jewelry_type == 'ring' ? 'selected' : '' }}>{{translate('Ring')}}</option>
                        <option value="necklace" {{ $product->jewelry_type == 'necklace' ? 'selected' : '' }}>{{translate('Necklace')}}</option>
                        <option value="bracelet" {{ $product->jewelry_type == 'bracelet' ? 'selected' : '' }}>{{translate('Bracelet')}}</option>
                        <option value="earring" {{ $product->jewelry_type == 'earring' ? 'selected' : '' }}>{{translate('Earring')}}</option>
                        <option value="bangle" {{ $product->jewelry_type == 'bangle' ? 'selected' : '' }}>{{translate('Bangle')}}</option>
                        <option value="pendant" {{ $product->jewelry_type == 'pendant' ? 'selected' : '' }}>{{translate('Pendant')}}</option>
                        <option value="chain" {{ $product->jewelry_type == 'chain' ? 'selected' : '' }}>{{translate('Chain')}}</option>
                        <option value="anklet" {{ $product->jewelry_type == 'anklet' ? 'selected' : '' }}>{{translate('Anklet')}}</option>
                        <option value="other" {{ $product->jewelry_type == 'other' ? 'selected' : '' }}>{{translate('Other')}}</option>
                    </select>
                </div>
            </div>

            <!-- Size -->
            <div class="col-lg-4 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Size')}}</label>
                    <input type="text" name="size" class="form-control" value="{{ $product->size }}" placeholder="{{ translate('e.g., 12(51.8mm)') }}">
                </div>
            </div>

            <!-- Design Code -->
            <div class="col-lg-4 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Design Code')}}</label>
                    <input type="text" name="design_code" class="form-control" value="{{ $product->design_code }}" placeholder="{{ translate('e.g., GR-2024-001') }}">
                </div>
            </div>
        </div>

        <hr class="my-3">

        <!-- Metal Components Section -->
        <h6 class="text-uppercase mb-3 font-weight-bold"><i class="tio-layers-outlined mr-1"></i> {{translate('Metal Components')}}</h6>
        <div id="metal_components_container">
            @if(isset($product->metals) && count($product->metals) > 0)
                @foreach($product->metals as $index => $pm)
                    <div class="metal-component-row bg-light border p-3 rounded mb-3 position-relative">
                        @if($index > 0)
                            <button type="button" class="btn btn-sm btn-danger position-absolute remove-metal-component" style="top: -10px; right: -10px; border-radius: 50%; width: 25px; height: 25px; padding: 0;">&times;</button>
                        @endif
                        <div class="row gy-2">
                            <div class="col-md-4">
                                <label class="small text-muted mb-1">{{translate('Metal Type')}}</label>
                                <select name="metal_components[{{ $index }}][type]" class="form-control metal-type-select" onchange="updatePurityOptions(this)">
                                    <option value="gold" {{ $pm->metal_type == 'gold' ? 'selected' : '' }}>{{translate('Gold')}}</option>
                                    <option value="silver" {{ $pm->metal_type == 'silver' ? 'selected' : '' }}>{{translate('Silver')}}</option>
                                    <option value="platinum" {{ $pm->metal_type == 'platinum' ? 'selected' : '' }}>{{translate('Platinum')}}</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="small text-muted mb-1">{{translate('Purity')}}</label>
                                <select name="metal_components[{{ $index }}][purity]" class="form-control metal-purity-select">
                                    @if($pm->metal_type == 'gold')
                                        <option value="24k" {{ $pm->metal_purity == '24k' ? 'selected' : '' }}>24 Karat (99.9%)</option>
                                        <option value="22k" {{ $pm->metal_purity == '22k' ? 'selected' : '' }}>22 Karat (91.6%)</option>
                                        <option value="18k" {{ $pm->metal_purity == '18k' ? 'selected' : '' }}>18 Karat (75%)</option>
                                        <option value="14k" {{ $pm->metal_purity == '14k' ? 'selected' : '' }}>14 Karat (58.3%)</option>
                                    @elseif($pm->metal_type == 'silver')
                                        <option value="999" {{ $pm->metal_purity == '999' ? 'selected' : '' }}>999 Fine Silver</option>
                                        <option value="925" {{ $pm->metal_purity == '925' ? 'selected' : '' }}>925 Sterling Silver</option>
                                    @elseif($pm->metal_type == 'platinum')
                                        <option value="999" {{ $pm->metal_purity == '999' ? 'selected' : '' }}>999 Platinum</option>
                                        <option value="950" {{ $pm->metal_purity == '950' ? 'selected' : '' }}>950 Platinum</option>
                                    @endif
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="small text-muted mb-1">{{translate('Weight (Grams)')}}</label>
                                <input type="number" step="0.001" name="metal_components[{{ $index }}][weight]" value="{{ $pm->weight }}" class="form-control metal-weight-input" placeholder="{{translate('0.000')}}" onchange="recalculatePrice()">
                            </div>
                        </div>
                    </div>
                @endforeach
            @else
                <div class="metal-component-row bg-light border p-3 rounded mb-3 position-relative">
                    <div class="row gy-2">
                        <div class="col-md-4">
                            <label class="small text-muted mb-1">{{translate('Metal Type')}}</label>
                            <select name="metal_components[0][type]" class="form-control metal-type-select" onchange="updatePurityOptions(this)">
                                <option value="gold" {{ $product->metal_type == 'gold' ? 'selected' : '' }}>{{translate('Gold')}}</option>
                                <option value="silver" {{ $product->metal_type == 'silver' ? 'selected' : '' }}>{{translate('Silver')}}</option>
                                <option value="platinum" {{ $product->metal_type == 'platinum' ? 'selected' : '' }}>{{translate('Platinum')}}</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="small text-muted mb-1">{{translate('Purity')}}</label>
                            <select name="metal_components[0][purity]" class="form-control metal-purity-select">
                                @if($product->metal_type == 'gold')
                                    <option value="24k" {{ $product->metal_purity == '24k' ? 'selected' : '' }}>24 Karat (99.9%)</option>
                                    <option value="22k" {{ $product->metal_purity == '22k' ? 'selected' : '' }}>22 Karat (91.6%)</option>
                                    <option value="18k" {{ $product->metal_purity == '18k' ? 'selected' : '' }}>18 Karat (75%)</option>
                                    <option value="14k" {{ $product->metal_purity == '14k' ? 'selected' : '' }}>14 Karat (58.3%)</option>
                                @elseif($product->metal_type == 'silver')
                                    <option value="999" {{ $product->metal_purity == '999' ? 'selected' : '' }}>999 Fine Silver</option>
                                    <option value="925" {{ $product->metal_purity == '925' ? 'selected' : '' }}>925 Sterling Silver</option>
                                @else
                                    <option value="none">{{translate('Select Metal First')}}</option>
                                @endif
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="small text-muted mb-1">{{translate('Weight (Grams)')}}</label>
                            <input type="number" step="0.001" name="metal_components[0][weight]" value="{{ $product->net_weight }}" class="form-control metal-weight-input" placeholder="{{translate('0.000')}}" onchange="recalculatePrice()">
                        </div>
                    </div>
                </div>
            @endif
        </div>

        <button type="button" id="add_metal_component" class="btn btn-sm btn-outline-primary mb-3">
            <i class="tio-add"></i> {{translate('Add Another Metal Component')}}
        </button>

        <hr class="my-3">

        <div class="row">
            <!-- Making Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Making Charges')}}</label>
                    <input type="number" step="0.01" min="0" name="making_charges" id="making_charges" class="form-control" value="{{ $product->making_charges }}" placeholder="{{ translate('0') }}" onchange="recalculatePrice()">
                </div>
            </div>

            <!-- Making Charge Type -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Making Charge Type')}}</label>
                    <select name="making_charge_type" id="making_charge_type" class="form-control" onchange="recalculatePrice()">
                        <option value="fixed" {{ $product->making_charge_type == 'fixed' ? 'selected' : '' }}>{{translate('Fixed Amount')}}</option>
                        <option value="per_gram" {{ $product->making_charge_type == 'per_gram' ? 'selected' : '' }}>{{translate('Per Gram')}}</option>
                        <option value="percentage" {{ $product->making_charge_type == 'percentage' ? 'selected' : '' }}>{{translate('Percentage of Metal Value')}}</option>
                    </select>
                </div>
            </div>

            <!-- Wastage Charges (%) -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Wastage Charges')}} (%)</label>
                    <input type="number" step="0.01" min="0" name="wastage_charges" id="wastage_charges" class="form-control" value="{{ $product->wastage_charges ?? 0 }}" placeholder="{{ translate('0') }}" onchange="recalculatePrice()">
                </div>
            </div>

            <!-- Stone Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Stone Charges')}} (₹)</label>
                    <input type="number" step="0.01" min="0" name="stone_charges" id="stone_charges" class="form-control" value="{{ $product->stone_charges }}" placeholder="{{ translate('0') }}" onchange="recalculatePrice()">
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Other Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Other Charges')}} (₹)</label>
                    <input type="number" step="0.01" min="0" name="other_charges" id="other_charges" class="form-control" value="{{ $product->other_charges }}" placeholder="{{ translate('0') }}" onchange="recalculatePrice()">
                </div>
            </div>
            <!-- Hallmark Number -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Hallmark Number')}}</label>
                    <input type="text" name="hallmark_number" class="form-control" value="{{ $product->hallmark_number }}" placeholder="{{ translate('BIS Hallmark Number') }}">
                </div>
            </div>
            <!-- HUID -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('HUID')}}</label>
                    <input type="text" name="huid" class="form-control" maxlength="6" value="{{ $product->huid }}" placeholder="{{ translate('6-digit HUID') }}">
                </div>
            </div>
            <!-- Stone Details -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Stone Details')}}</label>
                    <textarea name="stone_details" class="form-control" rows="1" placeholder="{{ translate('4 diamonds VVS clarity') }}">{{ $product->stone_details }}</textarea>
                </div>
            </div>
        </div>

        <!-- Dynamic Price Preview (Visible only when dynamic pricing enabled) -->
        <div id="price_preview_section" class="mt-4 p-3 border rounded bg-light" style="display: none; border-left: 5px solid #f5af19 !important;">
            <h6 class="text-gold mb-3 font-weight-bold"><i class="tio-receipt-outlined mr-1"></i> {{translate('Live Price Breakdown')}} (GST 3% included)</h6>
            <div class="row">
                <div class="col-md-4">
                    <div class="d-flex justify-content-between mb-1">
                        <span>{{translate('Metal Value')}}:</span>
                        <span id="preview_metal_value">₹0.00</span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="d-flex justify-content-between mb-1">
                        <span>{{translate('Making')}}:</span>
                        <span id="preview_making">₹0.00</span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="d-flex justify-content-between mb-1">
                        <span>{{translate('Wastage')}}:</span>
                        <span id="preview_wastage">₹0.00</span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="d-flex justify-content-between mb-1">
                        <span>{{translate('Stone/Other')}}:</span>
                        <span id="preview_other">₹0.00</span>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="d-flex justify-content-between mb-1 text-primary font-weight-bold">
                        <span>{{translate('Base Price (Before Tax)')}}:</span>
                        <span id="preview_total" style="font-size: 1.1rem;">₹0.00</span>
                    </div>
                </div>
            </div>
            <div class="mt-2 small text-muted">
                <i class="tio-info-outined mr-1"></i> {{translate('This is an estimate based on current rates. Final price will be updated automatically on save.')}}
            </div>
        </div>
    </div>
</div>

<script>
    // Metal purity data
    const metalRates = {
        'gold': {
            '24k': 1.0,
            '22k': 0.916,
            '18k': 0.75,
            '14k': 0.583
        },
        'silver': {
            '999': 0.999,
            '925': 0.925
        },
        'platinum': {
            '999': 0.999,
            '950': 0.95
        }
    };

    // Live metal prices (dummy for preview, actual handled by server)
    // In a real app, you might fetch these via AJAX for more accuracy in preview
    @php
        $goldPrice = \App\Models\MetalRate::where(['metal_type' => 'gold', 'purity' => '24k'])->value('rate_per_gram') ?? 0;
        $silverPrice = \App\Models\MetalRate::where(['metal_type' => 'silver', 'purity' => '999'])->value('rate_per_gram') ?? 0;
        $platinumPrice = \App\Models\MetalRate::where(['metal_type' => 'platinum', 'purity' => '999'])->value('rate_per_gram') ?? 0;
    @endphp
    const baseRates = {
        'gold': {{ $goldPrice }},
        'silver': {{ $silverPrice }},
        'platinum': {{ $platinumPrice }}
    };

    function updatePurityOptions(selectElement) {
        const metalType = selectElement.value;
        const puritySelect = selectElement.closest('.metal-component-row').querySelector('.metal-purity-select');
        let options = '';

        if (metalType === 'gold') {
            options = `
                <option value="24k">24 Karat (99.9%)</option>
                <option value="22k" selected>22 Karat (91.6%)</option>
                <option value="18k">18 Karat (75%)</option>
                <option value="14k">14 Karat (58.3%)</option>
            `;
        } else if (metalType === 'silver') {
            options = `
                <option value="999" selected>999 Fine Silver</option>
                <option value="925">925 Sterling Silver</option>
            `;
        } else if (metalType === 'platinum') {
            options = `
                <option value="999" selected>999 Platinum</option>
                <option value="950">950 Platinum</option>
            `;
        }

        puritySelect.innerHTML = options;
        recalculatePrice();
    }

    function addMetalComponent() {
        const container = document.getElementById('metal_components_container');
        const count = container.querySelectorAll('.metal-component-row').length;
        const newRow = document.createElement('div');
        newRow.className = 'metal-component-row bg-light border p-3 rounded mb-3 position-relative';
        newRow.innerHTML = `
            <button type="button" class="btn btn-sm btn-danger position-absolute remove-metal-component" style="top: -10px; right: -10px; border-radius: 50%; width: 25px; height: 25px; padding: 0;">&times;</button>
            <div class="row gy-2">
                <div class="col-md-4">
                    <label class="small text-muted mb-1">{{translate('Metal Type')}}</label>
                    <select name="metal_components[${count}][type]" class="form-control metal-type-select" onchange="updatePurityOptions(this)">
                        <option value="gold">{{translate('Gold')}}</option>
                        <option value="silver">{{translate('Silver')}}</option>
                        <option value="platinum">{{translate('Platinum')}}</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="small text-muted mb-1">{{translate('Purity')}}</label>
                    <select name="metal_components[${count}][purity]" class="form-control metal-purity-select" onchange="recalculatePrice()">
                        <option value="22k" selected>22 Karat (91.6%)</option>
                        <option value="24k">24 Karat (99.9%)</option>
                        <option value="18k">18 Karat (75%)</option>
                        <option value="14k">14 Karat (58.3%)</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="small text-muted mb-1">{{translate('Weight (Grams)')}}</label>
                    <input type="number" step="0.001" name="metal_components[${count}][weight]" class="form-control metal-weight-input" placeholder="{{translate('0.000')}}" onchange="recalculatePrice()">
                </div>
            </div>
        `;
        container.appendChild(newRow);
        updateRemoveButtons();
    }

    function updateRemoveButtons() {
        const rows = document.querySelectorAll('.metal-component-row');
        rows.forEach((row, index) => {
            const removeBtn = row.querySelector('.remove-metal-component');
            if (removeBtn) {
                removeBtn.onclick = () => {
                    row.remove();
                    recalculatePrice();
                    updateRemoveButtons();
                };
            }
        });
    }

    function recalculatePrice() {
        const isDynamic = document.getElementById('is_price_dynamic').checked;
        const previewSection = document.getElementById('price_preview_section');
        
        if (!isDynamic) {
            previewSection.style.display = 'none';
            return;
        }

        previewSection.style.display = 'block';

        let totalMetalValue = 0;
        let totalWeight = 0;

        const rows = document.querySelectorAll('.metal-component-row');
        rows.forEach(row => {
            const type = row.querySelector('.metal-type-select').value;
            const purity = row.querySelector('.metal-purity-select').value;
            const weight = parseFloat(row.querySelector('.metal-weight-input').value) || 0;

            if (weight > 0) {
                const purityMultiplier = metalRates[type][purity] || 1;
                const componentValue = baseRates[type] * purityMultiplier * weight;
                totalMetalValue += componentValue;
                totalWeight += weight;
            }
        });

        const makingCharges = parseFloat(document.getElementById('making_charges').value) || 0;
        const wastageCharges = parseFloat(document.getElementById('wastage_charges').value) || 0;
        const makingType = document.getElementById('making_charge_type').value;
        const stoneCharges = parseFloat(document.getElementById('stone_charges').value) || 0;
        const otherCharges = parseFloat(document.getElementById('other_charges').value) || 0;

        let makingAmount = 0;
        if (makingType === 'fixed') {
            makingAmount = makingCharges;
        } else if (makingType === 'percentage') {
            makingAmount = (totalMetalValue * makingCharges) / 100;
        } else if (makingType === 'per_gram') {
            makingAmount = makingCharges * totalWeight;
        }

        // Calculate wastage (always percentage)
        const wastageAmount = (totalMetalValue * wastageCharges) / 100;

        // Subtotal
        const subtotal = totalMetalValue + makingAmount + wastageAmount + stoneCharges + otherCharges;

        // Total (Base Price - without GST, GST will be applied via Tax field)
        const totalPrice = subtotal;

        // Update preview
        document.getElementById('preview_metal_value').textContent = '₹' + totalMetalValue.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        document.getElementById('preview_making').textContent = '₹' + makingAmount.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        document.getElementById('preview_wastage').textContent = '₹' + wastageAmount.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        document.getElementById('preview_other').textContent = '₹' + (stoneCharges + otherCharges).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        document.getElementById('preview_total').textContent = '₹' + totalPrice.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});

        // ONLY update main price field if dynamic pricing is enabled
        const priceField = document.querySelector('input[name="price"]');
        if (priceField && isDynamic) {
            priceField.value = totalPrice.toFixed(2);
            // Trigger selling price calculation in main form
            if (typeof calculateSellingPrice === 'function') {
                calculateSellingPrice();
            }
        }
    }

    // Event listeners
    document.getElementById('add_metal_component').addEventListener('click', addMetalComponent);
    document.getElementById('is_price_dynamic').addEventListener('change', function() {
        const priceField = document.querySelector('input[name="price"]');
        if (priceField) {
            if (this.checked) {
                priceField.readOnly = true;
                priceField.classList.add('bg-light');
                recalculatePrice();
            } else {
                priceField.readOnly = false;
                priceField.classList.remove('bg-light');
                document.getElementById('price_preview_section').style.display = 'none';
            }
        }
    });

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        updateRemoveButtons();
        
        const isDynamicCheckbox = document.getElementById('is_price_dynamic');
        if (isDynamicCheckbox && isDynamicCheckbox.checked) {
            recalculatePrice();
            const priceField = document.querySelector('input[name="price"]');
            if (priceField) {
                priceField.readOnly = true;
                priceField.classList.add('bg-light');
            }
        } else {
            document.getElementById('price_preview_section').style.display = 'none';
        }
    });
</script>

