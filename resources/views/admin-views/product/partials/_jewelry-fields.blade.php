<!-- Multi-Metal Jewelry Fields Section -->
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
                    <input type="checkbox" class="custom-control-input" id="is_price_dynamic" name="is_price_dynamic" value="1" {{ !isset($product) || $product->is_price_dynamic ? 'checked' : '' }}>
                    <label class="custom-control-label" for="is_price_dynamic">
                        <strong>{{translate('Enable Dynamic Pricing')}}</strong>
                        <small class="text-muted d-block">{{translate('Price will be calculated from live metal rates automatically')}}</small>
                    </label>
                </div>
            </div>
        </div>

        <!-- Metal Components Section -->
        <div class="card mb-3" id="metal_components_section">
            <div class="card-header d-flex justify-content-between align-items-center bg-light">
                <h6 class="mb-0">
                    <i class="tio-layers mr-1"></i>
                    {{translate('Metal Components')}}
                    <small class="text-muted">({{translate('Add gold, silver, diamond, etc.')}})</small>
                </h6>
                <button type="button" class="btn btn-sm btn-primary" id="add_metal_component">
                    <i class="tio-add mr-1"></i>{{translate('Add Metal')}}
                </button>
            </div>
            <div class="card-body" id="metal_components_container">
                @if(isset($product) && $product->metals && $product->metals->count() > 0)
                    @foreach($product->metals as $index => $metal)
                        @include('admin-views.product.partials._metal-component-row', [
                            'index' => $index,
                            'metal' => $metal
                        ])
                    @endforeach
                @else
                    <!-- Default empty row -->
                    <div class="metal-component-row" data-index="0">
                        <div class="row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label class="input-label">{{translate('Metal Type')}} <span class="text-danger">*</span></label>
                                    <select name="metals[0][metal_type]" class="form-control metal-type-select" onchange="updatePurityForIndex(0)">
                                        <option value="gold">{{translate('Gold')}}</option>
                                        <option value="silver">{{translate('Silver')}}</option>
                                        <option value="platinum">{{translate('Platinum')}}</option>
                                        <option value="diamond">{{translate('Diamond')}}</option>
                                        <option value="ruby">{{translate('Ruby')}}</option>
                                        <option value="emerald">{{translate('Emerald')}}</option>
                                        <option value="sapphire">{{translate('Sapphire')}}</option>
                                        <option value="pearl">{{translate('Pearl')}}</option>
                                        <option value="other">{{translate('Other')}}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label class="input-label">{{translate('Purity/Grade')}}</label>
                                    <select name="metals[0][purity]" class="form-control purity-select" id="purity_0">
                                        <option value="22k">22K (91.6%)</option>
                                        <option value="24k">24K (99.9%)</option>
                                        <option value="18k">18K (75%)</option>
                                        <option value="14k">14K (58.3%)</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label class="input-label">{{translate('Weight')}} <span class="text-danger">*</span></label>
                                    <input type="number" step="0.0001" min="0" name="metals[0][weight]" class="form-control metal-weight" placeholder="0.000" onchange="recalculatePrice()">
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label class="input-label">{{translate('Unit')}}</label>
                                    <select name="metals[0][weight_unit]" class="form-control weight-unit-select">
                                        <option value="gram">{{translate('Grams')}}</option>
                                        <option value="carat">{{translate('Carats')}}</option>
                                        <option value="milligram">{{translate('Milligrams')}}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label class="input-label">{{translate('Rate/Unit')}} (₹)</label>
                                    <input type="number" step="0.01" min="0" name="metals[0][rate_per_unit]" class="form-control metal-rate" placeholder="{{translate('Auto from API')}}">
                                    <small class="text-muted">{{translate('Leave empty for live rate')}}</small>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label class="input-label">{{translate('Value')}} (₹)</label>
                                    <input type="text" class="form-control bg-light calculated-value" readonly placeholder="₹0.00">
                                    <button type="button" class="btn btn-sm btn-outline-danger mt-1 remove-metal-btn" style="display: none;">
                                        <i class="tio-delete"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <hr class="my-2">
                    </div>
                @endif
            </div>
        </div>

        <hr class="my-3">

        <div class="row">
            <!-- Jewelry Type -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Jewelry Type')}}</label>
                    <select name="jewelry_type" class="form-control js-select2-custom">
                        <option value="">{{translate('Select Type')}}</option>
                        <option value="ring" {{ isset($product) && $product->jewelry_type == 'ring' ? 'selected' : '' }}>{{translate('Ring')}}</option>
                        <option value="necklace" {{ isset($product) && $product->jewelry_type == 'necklace' ? 'selected' : '' }}>{{translate('Necklace')}}</option>
                        <option value="bracelet" {{ isset($product) && $product->jewelry_type == 'bracelet' ? 'selected' : '' }}>{{translate('Bracelet')}}</option>
                        <option value="earring" {{ isset($product) && $product->jewelry_type == 'earring' ? 'selected' : '' }}>{{translate('Earring')}}</option>
                        <option value="bangle" {{ isset($product) && $product->jewelry_type == 'bangle' ? 'selected' : '' }}>{{translate('Bangle')}}</option>
                        <option value="pendant" {{ isset($product) && $product->jewelry_type == 'pendant' ? 'selected' : '' }}>{{translate('Pendant')}}</option>
                        <option value="chain" {{ isset($product) && $product->jewelry_type == 'chain' ? 'selected' : '' }}>{{translate('Chain')}}</option>
                        <option value="anklet" {{ isset($product) && $product->jewelry_type == 'anklet' ? 'selected' : '' }}>{{translate('Anklet')}}</option>
                        <option value="mangalsutra" {{ isset($product) && $product->jewelry_type == 'mangalsutra' ? 'selected' : '' }}>{{translate('Mangalsutra')}}</option>
                        <option value="other" {{ isset($product) && $product->jewelry_type == 'other' ? 'selected' : '' }}>{{translate('Other')}}</option>
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

            <!-- Design Code -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Design Code')}}</label>
                    <input type="text" name="design_code" class="form-control" value="{{ $product->design_code ?? '' }}" placeholder="{{ translate('e.g., GR-2024-001') }}">
                </div>
            </div>

            <!-- Gross Weight (Display Only) -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Gross Weight')}} ({{translate('grams')}})</label>
                    <input type="number" step="0.001" name="gross_weight" id="gross_weight" class="form-control bg-light" value="{{ $product->gross_weight ?? '' }}" readonly placeholder="{{ translate('Auto-calculated from metals') }}">
                </div>
            </div>
        </div>

        <hr class="my-3">

        <div class="row">
            <!-- Making Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Making Charges')}}</label>
                    <input type="number" step="0.01" min="0" name="making_charges" id="making_charges" class="form-control charge-input" value="{{ $product->making_charges ?? 0 }}" placeholder="{{ translate('Making charges') }}" onchange="recalculatePrice()">
                </div>
            </div>

            <!-- Making Charge Type -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Making Charge Type')}}</label>
                    <select name="making_charge_type" id="making_charge_type" class="form-control" onchange="recalculatePrice()">
                        <option value="fixed" {{ isset($product) && $product->making_charge_type == 'fixed' ? 'selected' : '' }}>{{translate('Fixed Amount')}}</option>
                        <option value="percentage" {{ isset($product) && $product->making_charge_type == 'percentage' ? 'selected' : '' }}>{{translate('Percentage of Metal Value')}}</option>
                        <option value="per_gram" {{ isset($product) && $product->making_charge_type == 'per_gram' ? 'selected' : '' }}>{{translate('Per Gram')}}</option>
                    </select>
                </div>
            </div>

            <!-- Wastage Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Wastage Charges')}} (%)</label>
                    <input type="number" step="0.01" min="0" name="wastage_charges" id="wastage_charges" class="form-control charge-input" value="{{ $product->wastage_charges ?? 0 }}" placeholder="{{ translate('e.g., 2.5%') }}" onchange="recalculatePrice()">
                </div>
            </div>

            <!-- Stone Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Stone Charges')}} (₹)</label>
                    <input type="number" step="0.01" min="0" name="stone_charges" id="stone_charges" class="form-control charge-input" value="{{ $product->stone_charges ?? 0 }}" placeholder="{{ translate('Stone value') }}" onchange="recalculatePrice()">
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Other Charges -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Other Charges')}} (₹)</label>
                    <input type="number" step="0.01" min="0" name="other_charges" id="other_charges" class="form-control charge-input" value="{{ $product->other_charges ?? 0 }}" placeholder="{{ translate('Certificate, polish, etc.') }}" onchange="recalculatePrice()">
                </div>
            </div>

            <!-- Hallmark Number -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Hallmark Number')}}</label>
                    <input type="text" name="hallmark_number" class="form-control" value="{{ $product->hallmark_number ?? '' }}" placeholder="{{ translate('BIS Hallmark Number') }}">
                </div>
            </div>

            <!-- HUID -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">
                        {{translate('HUID')}}
                        <i class="tio-info-outlined" data-toggle="tooltip" title="{{translate('6-digit Hallmarking Unique ID')}}"></i>
                    </label>
                    <input type="text" name="huid" class="form-control" maxlength="6" value="{{ $product->huid ?? '' }}" placeholder="{{ translate('6-digit HUID') }}">
                </div>
            </div>

            <!-- Certificate Details -->
            <div class="col-lg-3 col-sm-6">
                <div class="form-group">
                    <label class="input-label">{{translate('Certificate Number')}}</label>
                    <input type="text" name="certificate_number" class="form-control" value="{{ $product->certificate_number ?? '' }}" placeholder="{{ translate('IGI/GIA Certificate Number') }}">
                </div>
            </div>
        </div>

        <!-- Price Preview (for dynamic pricing) -->
        <div class="row mt-3" id="price_preview_section" style="display: none;">
            <div class="col-12">
                <div class="card border-info">
                    <div class="card-header bg-info text-white py-2">
                        <h6 class="mb-0"><i class="tio-diamond mr-1"></i> {{translate('Live Price Calculation')}}</h6>
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col">
                                <small class="text-muted d-block">{{translate('Metal Value')}}</small>
                                <div class="h5 text-primary" id="preview_metal_value">₹0.00</div>
                            </div>
                            <div class="col">
                                <small class="text-muted d-block">{{translate('Making')}}</small>
                                <div class="h5" id="preview_making">₹0.00</div>
                            </div>
                            <div class="col">
                                <small class="text-muted d-block">{{translate('Wastage')}}</small>
                                <div class="h5" id="preview_wastage">₹0.00</div>
                            </div>
                            <div class="col">
                                <small class="text-muted d-block">{{translate('Stone + Other')}}</small>
                                <div class="h5" id="preview_other">₹0.00</div>
                            </div>
                            <div class="col bg-success text-white rounded py-2">
                                <small class="d-block">{{translate('Base Price')}}</small>
                                <small class="d-block text-white-50">{{translate('(Before Tax)')}}</small>
                                <div class="h4 mb-0 font-weight-bold" id="preview_total">₹0.00</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Hidden field for current metal rates -->
<input type="hidden" id="current_metal_rates" value="{{ json_encode([
    'gold' => [
        '24k' => \App\Models\MetalRate::getCurrentRate('gold', '24k') ?? 0,
        '22k' => \App\Models\MetalRate::getCurrentRate('gold', '22k') ?? 0,
        '18k' => \App\Models\MetalRate::getCurrentRate('gold', '18k') ?? 0,
        '14k' => \App\Models\MetalRate::getCurrentRate('gold', '14k') ?? 0,
    ],
    'silver' => [
        '999' => \App\Models\MetalRate::getCurrentRate('silver', '999') ?? 0,
        '925' => \App\Models\MetalRate::getCurrentRate('silver', '925') ?? 0,
    ],
    'platinum' => [
        '999' => \App\Models\MetalRate::getCurrentRate('platinum', '999') ?? 0,
        '950' => \App\Models\MetalRate::getCurrentRate('platinum', '950') ?? 0,
        '900' => \App\Models\MetalRate::getCurrentRate('platinum', '900') ?? 0,
    ],
]) }}">

<script>
    let metalIndex = {{ isset($product) && $product->metals ? $product->metals->count() : 1 }};
    let metalRates = {};

    // Load metal rates on page load
    try {
        metalRates = JSON.parse(document.getElementById('current_metal_rates').value);
    } catch (e) {
        console.error('Failed to parse metal rates', e);
    }

    // Purity options by metal type
    const purityOptions = {
        gold: {'24k': '24K (99.9%)', '22k': '22K (91.6%)', '18k': '18K (75%)', '14k': '14K (58.3%)'},
        silver: {'999': '999 Fine', '925': '925 Sterling'},
        platinum: {'950': '950 Platinum', '900': '900 Platinum'},
        diamond: {'VVS1': 'VVS1', 'VVS2': 'VVS2', 'VS1': 'VS1', 'VS2': 'VS2', 'SI1': 'SI1', 'SI2': 'SI2'},
        ruby: {'AAA': 'AAA Grade', 'AA': 'AA Grade', 'A': 'A Grade'},
        emerald: {'AAA': 'AAA Grade', 'AA': 'AA Grade', 'A': 'A Grade'},
        sapphire: {'AAA': 'AAA Grade', 'AA': 'AA Grade', 'A': 'A Grade'},
        pearl: {'AAA': 'AAA Grade', 'AA': 'AA Grade', 'A': 'A Grade'},
        other: {}
    };

    // Weight unit by metal type
    const defaultUnits = {
        gold: 'gram',
        silver: 'gram',
        platinum: 'gram',
        diamond: 'carat',
        ruby: 'carat',
        emerald: 'carat',
        sapphire: 'carat',
        pearl: 'carat',
        other: 'gram'
    };

    function updatePurityForIndex(index) {
        const row = document.querySelector(`.metal-component-row[data-index="${index}"]`);
        if (!row) return;

        const metalType = row.querySelector('.metal-type-select').value;
        const puritySelect = row.querySelector('.purity-select');
        const unitSelect = row.querySelector('.weight-unit-select');

        // Update purity options
        puritySelect.innerHTML = '';
        const options = purityOptions[metalType] || {};
        if (Object.keys(options).length === 0) {
            puritySelect.innerHTML = '<option value="">N/A</option>';
        } else {
            for (const [value, label] of Object.entries(options)) {
                puritySelect.innerHTML += `<option value="${value}">${label}</option>`;
            }
        }

        // Update default unit
        if (unitSelect) {
            unitSelect.value = defaultUnits[metalType] || 'gram';
        }

        recalculatePrice();
    }

    function addMetalComponent() {
        const container = document.getElementById('metal_components_container');
        const newRow = document.createElement('div');
        newRow.className = 'metal-component-row';
        newRow.dataset.index = metalIndex;

        newRow.innerHTML = `
            <div class="row">
                <div class="col-md-2">
                    <div class="form-group">
                        <label class="input-label">{{translate('Metal Type')}} <span class="text-danger">*</span></label>
                        <select name="metals[${metalIndex}][metal_type]" class="form-control metal-type-select" onchange="updatePurityForIndex(${metalIndex})">
                            <option value="gold">{{translate('Gold')}}</option>
                            <option value="silver">{{translate('Silver')}}</option>
                            <option value="platinum">{{translate('Platinum')}}</option>
                            <option value="diamond">{{translate('Diamond')}}</option>
                            <option value="ruby">{{translate('Ruby')}}</option>
                            <option value="emerald">{{translate('Emerald')}}</option>
                            <option value="sapphire">{{translate('Sapphire')}}</option>
                            <option value="pearl">{{translate('Pearl')}}</option>
                            <option value="other">{{translate('Other')}}</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label class="input-label">{{translate('Purity/Grade')}}</label>
                        <select name="metals[${metalIndex}][purity]" class="form-control purity-select" id="purity_${metalIndex}">
                            <option value="22k">22K (91.6%)</option>
                            <option value="24k">24K (99.9%)</option>
                            <option value="18k">18K (75%)</option>
                            <option value="14k">14K (58.3%)</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label class="input-label">{{translate('Weight')}} <span class="text-danger">*</span></label>
                        <input type="number" step="0.0001" min="0" name="metals[${metalIndex}][weight]" class="form-control metal-weight" placeholder="0.000" onchange="recalculatePrice()">
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label class="input-label">{{translate('Unit')}}</label>
                        <select name="metals[${metalIndex}][weight_unit]" class="form-control weight-unit-select">
                            <option value="gram">{{translate('Grams')}}</option>
                            <option value="carat">{{translate('Carats')}}</option>
                            <option value="milligram">{{translate('Milligrams')}}</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label class="input-label">{{translate('Rate/Unit')}} (₹)</label>
                        <input type="number" step="0.01" min="0" name="metals[${metalIndex}][rate_per_unit]" class="form-control metal-rate" placeholder="{{translate('Auto from API')}}">
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label class="input-label">{{translate('Value')}} (₹)</label>
                        <input type="text" class="form-control bg-light calculated-value" readonly placeholder="₹0.00">
                        <button type="button" class="btn btn-sm btn-outline-danger mt-1 remove-metal-btn" onclick="removeMetalComponent(${metalIndex})">
                            <i class="tio-delete"></i> {{translate('Remove')}}
                        </button>
                    </div>
                </div>
            </div>
            <hr class="my-2">
        `;

        container.appendChild(newRow);
        metalIndex++;

        // Show remove buttons on all rows if more than one
        updateRemoveButtons();
    }

    function removeMetalComponent(index) {
        const row = document.querySelector(`.metal-component-row[data-index="${index}"]`);
        if (row && document.querySelectorAll('.metal-component-row').length > 1) {
            row.remove();
            recalculatePrice();
            updateRemoveButtons();
        }
    }

    function updateRemoveButtons() {
        const rows = document.querySelectorAll('.metal-component-row');
        rows.forEach((row, i) => {
            const btn = row.querySelector('.remove-metal-btn');
            if (btn) {
                btn.style.display = rows.length > 1 ? 'inline-block' : 'none';
            }
        });
    }

    function getMetalRate(metalType, purity) {
        // First check if we have the rate in our loaded rates
        if (metalRates[metalType] && metalRates[metalType][purity]) {
            return parseFloat(metalRates[metalType][purity]);
        }
        return 0;
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

        // Calculate value for each metal component
        document.querySelectorAll('.metal-component-row').forEach(row => {
            const metalType = row.querySelector('.metal-type-select').value;
            const purity = row.querySelector('.purity-select').value;
            const weight = parseFloat(row.querySelector('.metal-weight').value) || 0;
            const customRate = parseFloat(row.querySelector('.metal-rate').value) || 0;
            const valueField = row.querySelector('.calculated-value');
            const unitSelect = row.querySelector('.weight-unit-select');
            const unit = unitSelect ? unitSelect.value : 'gram';

            // Get rate (custom or from API)
            let rate = customRate > 0 ? customRate : getMetalRate(metalType, purity);

            // Calculate value
            const value = weight * rate;
            totalMetalValue += value;

            // Add to total weight only for grams
            if (unit === 'gram') {
                totalWeight += weight;
            }

            // Update display
            if (valueField) {
                valueField.value = '₹' + value.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            }
        });

        // Update gross weight
        document.getElementById('gross_weight').value = totalWeight.toFixed(3);

        // Get charges
        const makingCharges = parseFloat(document.getElementById('making_charges').value) || 0;
        const makingType = document.getElementById('making_charge_type').value;
        const wastageCharges = parseFloat(document.getElementById('wastage_charges').value) || 0;
        const stoneCharges = parseFloat(document.getElementById('stone_charges').value) || 0;
        const otherCharges = parseFloat(document.getElementById('other_charges').value) || 0;

        // Calculate making charges based on type
        let makingAmount = makingCharges;
        if (makingType === 'percentage') {
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
        // This prevents interference with normal tax/discount calculations
        const priceField = document.querySelector('input[name="price"]');
        if (priceField && isDynamic) {
            priceField.value = totalPrice.toFixed(2);
        }
    }

    // Event listeners
    document.getElementById('add_metal_component').addEventListener('click', addMetalComponent);
    document.getElementById('is_price_dynamic').addEventListener('change', function() {
        // If dynamic pricing is enabled, make the price field readonly
        const priceField = document.querySelector('input[name="price"]');
        if (priceField) {
            if (this.checked) {
                priceField.readOnly = true;
                priceField.classList.add('bg-light');
                // Calculate price when enabling dynamic pricing
                recalculatePrice();
            } else {
                priceField.readOnly = false;
                priceField.classList.remove('bg-light');
                // When disabling dynamic pricing, hide the preview but don't change price
                document.getElementById('price_preview_section').style.display = 'none';
            }
        }
    });

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        updateRemoveButtons();
        
        // Only run recalculate if dynamic pricing is already enabled (for edit mode)
        const isDynamicCheckbox = document.getElementById('is_price_dynamic');
        if (isDynamicCheckbox && isDynamicCheckbox.checked) {
            recalculatePrice();
            // Make price field readonly
            const priceField = document.querySelector('input[name="price"]');
            if (priceField) {
                priceField.readOnly = true;
                priceField.classList.add('bg-light');
            }
        } else {
            // Ensure price preview is hidden when dynamic pricing is off
            document.getElementById('price_preview_section').style.display = 'none';
        }
    });
</script>

