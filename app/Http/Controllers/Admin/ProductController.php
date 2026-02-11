<?php

namespace App\Http\Controllers\Admin;

use App\CentralLogics\Helpers;
use App\Http\Controllers\Controller;
use App\Model\Category;
use App\Model\Product;
use App\Model\Review;
use App\Model\Translation;
use Box\Spout\Common\Exception\InvalidArgumentException;
use Box\Spout\Common\Exception\IOException;
use Box\Spout\Common\Exception\UnsupportedTypeException;
use Box\Spout\Writer\Exception\WriterNotOpenedException;
use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Rap2hpoutre\FastExcel\FastExcel;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ProductController extends Controller
{
    public function __construct(
        private Category $category,
        private Product $product,
        private Review $review,
        private Translation $translation
    ){}

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function variantCombination(Request $request): JsonResponse
    {
        $options = [];
        $price = $request->price;
        $productName = $request->name;

        if ($request->has('choice_no')) {
            foreach ($request->choice_no as $key => $no) {
                $name = 'choice_options_' . $no;
                $my_str = implode('', $request[$name]);
                $options[] = explode(',', $my_str);
            }
        }

        $result = [[]];
        foreach ($options as $property => $property_values) {
            $tmp = [];
            foreach ($result as $result_item) {
                foreach ($property_values as $property_value) {
                    $tmp[] = array_merge($result_item, [$property => $property_value]);
                }
            }
            $result = $tmp;
        }
        $combinations = $result;
        return response()->json([
            'view' => view('admin-views.product.partials._variant-combinations', compact('combinations', 'price', 'productName'))->render(),
        ]);
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function getCategories(Request $request): JsonResponse
    {
        $categories = $this->category->where(['parent_id' => $request->parent_id])->get();
        $res = '<option value="' . 0 . '" disabled selected>---Select subcategory---</option>';
        foreach ($categories as $row) {
            if ($row->id == $request->sub_category) {
                $res .= '<option value="' . $row->id . '" selected >' . $row->name . '</option>';
            } else {
                $res .= '<option value="' . $row->id . '">' . $row->name . '</option>';
            }
        }
        return response()->json([
            'options' => $res,
        ]);
    }

    /**
     * @return Application|Factory|View
     */
    public function index(): Factory|View|Application
    {
        $categories = $this->category->where(['position' => 0])->get();
        return view('admin-views.product.index', compact('categories'));
    }

    /**
     * @param Request $request
     * @return Application|Factory|View
     */
    public function list(Request $request): View|Factory|Application
    {
        $queryParam = [];
        $search = $request['search'];
        if ($request->has('search')) {
            $key = explode(' ', $request['search']);
            $query = $this->product->where(function ($q) use ($key) {
                foreach ($key as $value) {
                    $q->orWhere('id', 'like', "%{$value}%")
                        ->orWhere('name', 'like', "%{$value}%");
                }
            })->latest();
            $queryParam = ['search' => $request['search']];
        } else {
            $query = $this->product->latest();
        }
        $products = $query->paginate(Helpers::pagination_limit())->appends($queryParam);
        return view('admin-views.product.list', compact('products', 'search'));
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function search(Request $request): JsonResponse
    {
        $key = explode(' ', $request['search']);
        $products = $this->product->where(function ($q) use ($key) {
            foreach ($key as $value) {
                $q->orWhere('name', 'like', "%{$value}%");
            }
        })->get();
        return response()->json([
            'view' => view('admin-views.product.partials._table', compact('products'))->render()
        ]);
    }

    /**
     * @param $id
     * @return Application|Factory|View
     */
    public function view($id): Factory|View|Application
    {
        $product = $this->product->where(['id' => $id])->first();
        $reviews = $this->review->where(['product_id' => $id])->latest()->paginate(Helpers::pagination_limit());
        return view('admin-views.product.view', compact('product', 'reviews'));
    }

    /**
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|unique:products',
            'category_id' => 'required',
            'images' => 'required',
            'total_stock' => 'required|numeric|min:1',
            'price' => 'required|numeric|min:1',
        ], [
            'name.required' => 'Product name is required!',
            'category_id.required' => 'category  is required!',
        ]);

        if ($request['discount_type'] == 'percent') {
            $discount = ($request['price'] / 100) * $request['discount'];
        } else {
            $discount = $request['discount'];
        }

        if ($request['price'] <= $discount) {
            $validator->getMessageBag()->add('unit_price', 'Discount can not be more or equal to the price!');
        }

        $imageName = [];
        if (!empty($request->file('images'))) {
            foreach ($request->images as $img) {
                $image_data = Helpers::upload('product/', 'png', $img);
                $imageName[] = $image_data;
            }
            $image_data = json_encode($imageName);
        } else {
            $image_data = json_encode([]);
        }

        $product= new Product;
        $product->name = $request->name[array_search('en', $request->lang)];

        $category = [];
        if ($request->category_id != null) {
            $category[] = [
                'id' => $request->category_id,
                'position' => 1,
            ];
        }
        if ($request->sub_category_id != null) {
            $category[] = [
                'id' => $request->sub_category_id,
                'position' => 2,
            ];
        }
        if ($request->sub_sub_category_id != null) {
            $category[] = [
                'id' => $request->sub_sub_category_id,
                'position' => 3,
            ];
        }

        $product->category_ids = json_encode($category);
        $product->description = $request->description[array_search('en', $request->lang)];

        $choiceOptions = [];
        if ($request->has('choice')) {
            foreach ($request->choice_no as $key => $no) {
                $str = 'choice_options_' . $no;
                if ($request[$str][0] == null) {
                    $validator->getMessageBag()->add('name', 'Attribute choice option values can not be null!');
                    return response()->json(['errors' => Helpers::error_processor($validator)]);
                }
                $item['name'] = 'choice_' . $no;
                $item['title'] = $request->choice[$key];
                $item['options'] = explode(',', implode('|', preg_replace('/\s+/', ' ', $request[$str])));
                $choiceOptions[] = $item;
            }
        }

        $product->choice_options = json_encode($choiceOptions);
        $variations = [];
        $options = [];
        if ($request->has('choice_no')) {
            foreach ($request->choice_no as $key => $no) {
                $name = 'choice_options_' . $no;
                $my_str = implode('|', $request[$name]);
                $options[] = explode(',', $my_str);
            }
        }
        //Generates the combinations of customer choice options
        $combinations = Helpers::combinations($options);

        $stockCount = 0;
        if (count($combinations[0]) > 0) {
            foreach ($combinations as $key => $combination) {
                $str = '';
                foreach ($combination as $k => $item) {
                    if ($k > 0) {
                        $str .= '-' . str_replace(' ', '', $item);
                    } else {
                        $str .= str_replace(' ', '', $item);
                    }
                }
                $item = [];
                $item['type'] = $str;
                $item['price'] = abs($request['price_' . str_replace('.', '_', $str)]);
                $item['stock'] = abs($request['stock_' . str_replace('.', '_', $str)]);
                $variations[] = $item;
                $stockCount += $item['stock'];
            }
        } else {
            $stockCount = (integer)$request['total_stock'];
        }

        if ((integer)$request['total_stock'] != $stockCount) {
            $validator->getMessageBag()->add('total_stock', 'Stock calculation mismatch!');
        }

        if ($validator->getMessageBag()->count() > 0) {
            return response()->json(['errors' => Helpers::error_processor($validator)]);
        }

        //combinations end
        $product->variations = json_encode($variations);
        $product->price = $request->price;
        $product->unit = $request->unit;
        $product->image = $image_data;

        $product->tax = $request->tax_type == 'amount' ? $request->tax : $request->tax;
        $product->tax_type = $request->tax_type;

        $product->discount = $request->discount_type == 'amount' ? $request->discount : $request->discount;
        $product->discount_type = $request->discount_type;
        $product->total_stock = $request->total_stock;

        $product->attributes = $request->has('attribute_id') ? json_encode($request->attribute_id) : json_encode([]);

        // Jewelry Specific Fields
        $product->metal_type = $request->metal_type ?? 'none';
        $product->metal_purity = $request->metal_purity ?? 'none';
        $product->gross_weight = $request->gross_weight;
        $product->net_weight = $request->net_weight;
        $product->stone_weight = $request->stone_weight;
        $product->making_charges = $request->making_charges ?? 0;
        $product->making_charge_type = $request->making_charge_type ?? 'fixed';
        $product->stone_charges = $request->stone_charges ?? 0;
        $product->other_charges = $request->other_charges ?? 0;
        $product->wastage_charges = $request->wastage_charges ?? 0;
        $product->wastage_type = $request->wastage_type ?? 'percentage';
        $product->is_price_dynamic = $request->has('is_price_dynamic') ? 1 : 0;
        $product->hallmark_number = $request->hallmark_number;
        $product->huid = $request->huid;
        $product->stone_details = $request->stone_details;
        $product->design_code = $request->design_code;
        $product->jewelry_type = $request->jewelry_type;
        $product->size = $request->size;
        
        // Check if multi-metal product
        $hasMultipleMetals = $request->has('metal_components') && is_array($request->metal_components) && count($request->metal_components) > 0;
        $product->is_multi_metal = $hasMultipleMetals;

        $product->save();

        // Handle multi-metal components
        if ($hasMultipleMetals) {
            $this->saveProductMetals($product, $request->metal_components);
            
            // If dynamic pricing is enabled, calculate price from metal components
            if ($product->is_price_dynamic) {
                $pricingService = app(\App\Services\ProductPricingService::class);
                $pricingService->updateProductPrice($product);
            }
        } elseif ($product->is_price_dynamic && $product->metal_type != 'none' && $product->net_weight > 0) {
            // Legacy single metal dynamic pricing
            $metalPriceService = app(\App\Services\MetalPriceService::class);
            $priceResult = $metalPriceService->calculateProductPrice(
                $product->metal_type,
                $product->metal_purity,
                $product->net_weight,
                $product->making_charges,
                $product->making_charge_type,
                $product->stone_charges,
                0 // GST is handled via Tax field, not here
            );
            
            if ($priceResult['success']) {
                $product->price = $priceResult['breakdown']['total_price'] + ($product->other_charges ?? 0);
                $product->save();
            }
        }

        $data = [];
        foreach ($request->lang as $index => $key) {
            if ($request->name[$index] && $key != 'en') {
                $data[] = array(
                    'translationable_type' => 'App\Model\Product',
                    'translationable_id' => $product->id,
                    'locale' => $key,
                    'key' => 'name',
                    'value' => $request->name[$index],
                );
            }
            if ($request->description[$index] && $key != 'en') {
                $data[] = array(
                    'translationable_type' => 'App\Model\Product',
                    'translationable_id' => $product->id,
                    'locale' => $key,
                    'key' => 'description',
                    'value' => $request->description[$index],
                );
            }
        }

        $this->translation->insert($data);

        return response()->json(['success' => true, 'message' => 'Product created successfully!'], 200);
    }


    /**
     * Save product metal components.
     */
    protected function saveProductMetals(Product $product, array $metals): void
    {
        // Delete existing metals
        $product->metals()->delete();
        
        $totalWeight = 0;
        $sortOrder = 0;
        
        foreach ($metals as $metalData) {
            // Skip empty metal entries
            $metalType = $metalData['metal_type'] ?? $metalData['type'] ?? null;
            if (empty($metalType) || empty($metalData['weight'])) {
                continue;
            }
            
            $weight = floatval($metalData['weight'] ?? 0);
            $purity = $metalData['purity'] ?? null;
            $ratePerUnit = !empty($metalData['rate_per_unit']) ? floatval($metalData['rate_per_unit']) : null;
            $weightUnit = $metalData['weight_unit'] ?? 'gram';
            
            // Determine rate source
            $rateSource = 'live_api';
            if ($ratePerUnit > 0) {
                $rateSource = 'manual';
            }
            
            // Get current rate if not manually set
            if (!$ratePerUnit && in_array($metalType, ['gold', 'silver', 'platinum'])) {
                $ratePerUnit = \App\Models\MetalRate::getCurrentRate($metalType, $purity) ?? 0;
                $rateSource = 'live_api';
            }
            
            // Calculate value
            $calculatedValue = $weight * ($ratePerUnit ?? 0);
            
            $product->metals()->create([
                'metal_type' => $metalType,
                'purity' => $purity,
                'weight' => $weight,
                'weight_unit' => $weightUnit,
                'rate_per_unit' => $ratePerUnit,
                'calculated_value' => $calculatedValue,
                'rate_updated_at' => now(),
                'rate_source' => $rateSource,
                'quality_grade' => $metalData['quality_grade'] ?? null,
                'color' => $metalData['color'] ?? null,
                'certificate' => $metalData['certificate'] ?? null,
                'sort_order' => $sortOrder++,
            ]);
            
            // Add to total weight only for grams
            if ($weightUnit === 'gram') {
                $totalWeight += $weight;
            }
        }
        
        // Update gross weight
        if ($totalWeight > 0) {
            $product->update(['gross_weight' => $totalWeight]);
        }
    }


    /**
     * @param $id
     * @return Application|Factory|View
     */
    public function edit($id): Factory|View|Application
    {
        $product = $this->product->withoutGlobalScopes()->with(['translations', 'metals'])->find($id);
        $product_category = json_decode($product->category_ids);
        $categories = $this->category->where(['parent_id' => 0])->get();
        return view('admin-views.product.edit', compact('product', 'product_category', 'categories'));
    }


    /**
     * @param Request $request
     * @return RedirectResponse
     */
    public function status(Request $request): RedirectResponse
    {
        $product = $this->product->find($request->id);
        $product->status = $request->status;
        $product->save();
        Toastr::success(translate('Product status updated!'));
        return back();
    }

    /**
     * @param Request $request
     * @param $id
     * @return JsonResponse
     */
    public function update(Request $request, $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required',
            'category_id' => 'required',
            'total_stock' => 'required|numeric|min:1',
            'price' => 'required|numeric|min:1',
        ], [
            'name.required' => 'Product name is required!',
            'category_id.required' => 'category  is required!',
        ]);

        if ($request['discount_type'] == 'percent') {
            $discount = ($request['price'] / 100) * $request['discount'];
        } else {
            $discount = $request['discount'];
        }

        if ($request['price'] <= $discount) {
            $validator->getMessageBag()->add('unit_price', 'Discount can not be more or equal to the price!');
        }

        $product = $this->product->find($id);
        $images = json_decode($product->image);
        if (!empty($request->file('images'))) {
            foreach ($request->images as $img) {
                $image_data = Helpers::upload('product/', 'png', $img);
                $images[] = $image_data;
            }

        }

        if (!count($images)) {
            $validator->getMessageBag()->add('images', 'Image can not be empty!');
        }

        $product->name = $request->name[array_search('en', $request->lang)];

        $category = [];
        if ($request->category_id != null) {
            $category[] = [
                'id' => $request->category_id,
                'position' => 1,
            ];
        }
        if ($request->sub_category_id != null) {
            $category[] = [
                'id' => $request->sub_category_id,
                'position' => 2,
            ];
        }
        if ($request->sub_sub_category_id != null) {
            $category[] = [
                'id' => $request->sub_sub_category_id,
                'position' => 3,
            ];
        }

        $product->category_ids = json_encode($category);
        $product->description = $request->description[array_search('en', $request->lang)];

        $choiceOptions = [];
        if ($request->has('choice')) {
            foreach ($request->choice_no as $key => $no) {
                $str = 'choice_options_' . $no;
                if ($request[$str][0] == null) {
                    $validator->getMessageBag()->add('name', 'Attribute choice option values can not be null!');
                    return response()->json(['errors' => Helpers::error_processor($validator)]);
                }
                $item['name'] = 'choice_' . $no;
                $item['title'] = $request->choice[$key];
                $item['options'] = explode(',', implode('|', preg_replace('/\s+/', ' ', $request[$str])));
                $choiceOptions[] = $item;
            }
        }
        $product->choice_options = json_encode($choiceOptions);
        $variations = [];
        $options = [];

        if ($request->has('choice_no')) {
            foreach ($request->choice_no as $key => $no) {
                $name = 'choice_options_' . $no;
                $my_str = implode('|', $request[$name]);
                $options[] = explode(',', $my_str);
            }
        }

        //Generates the combinations of customer choice options
        $combinations = Helpers::combinations($options);
        $stockCount = 0;
        if (count($combinations[0]) > 0) {
            foreach ($combinations as $key => $combination) {
                $str = '';
                foreach ($combination as $k => $item) {
                    if ($k > 0) {
                        $str .= '-' . str_replace(' ', '', $item);
                    } else {
                        $str .= str_replace(' ', '', $item);
                    }
                }
                $item = [];
                $item['type'] = $str;
                $item['price'] = abs($request['price_' . str_replace('.', '_', $str)]);
                $item['stock'] = abs($request['stock_' . str_replace('.', '_', $str)]);
                $variations[] = $item;
                $stockCount += $item['stock'];
            }
        } else {
            $stockCount = (integer)$request['total_stock'];
        }

        if ((integer)$request['total_stock'] != $stockCount) {
            $validator->getMessageBag()->add('total_stock', 'Stock calculation mismatch!');
        }

        if ($validator->getMessageBag()->count() > 0) {
            return response()->json(['errors' => Helpers::error_processor($validator)]);
        }

        //combinations end
        $product->variations = json_encode($variations);
        $product->price = $request->price;
        $product->unit = $request->unit;
        $product->image = json_encode($images);

        $product->tax = $request->tax_type == 'amount' ? $request->tax : $request->tax;
        $product->tax_type = $request->tax_type;

        $product->discount = $request->discount_type == 'amount' ? $request->discount : $request->discount;
        $product->discount_type = $request->discount_type;
        $product->total_stock = $request->total_stock;

        $product->attributes = $request->has('attribute_id') ? json_encode($request->attribute_id) : json_encode([]);

        // Jewelry Specific Fields
        $product->metal_type = $request->metal_type ?? 'none';
        $product->metal_purity = $request->metal_purity ?? 'none';
        $product->gross_weight = $request->gross_weight;
        $product->net_weight = $request->net_weight;
        $product->stone_weight = $request->stone_weight;
        $product->making_charges = $request->making_charges ?? 0;
        $product->making_charge_type = $request->making_charge_type ?? 'fixed';
        $product->stone_charges = $request->stone_charges ?? 0;
        $product->other_charges = $request->other_charges ?? 0;
        $product->wastage_charges = $request->wastage_charges ?? 0;
        $product->wastage_type = $request->wastage_type ?? 'percentage';
        $product->is_price_dynamic = $request->has('is_price_dynamic') ? 1 : 0;
        $product->hallmark_number = $request->hallmark_number;
        $product->huid = $request->huid;
        $product->stone_details = $request->stone_details;
        $product->design_code = $request->design_code;
        $product->jewelry_type = $request->jewelry_type;
        $product->size = $request->size;
        
        // Check if multi-metal product
        $hasMultipleMetals = $request->has('metal_components') && is_array($request->metal_components) && count($request->metal_components) > 0;
        $product->is_multi_metal = $hasMultipleMetals;

        $product->save();

        // Handle multi-metal components
        if ($hasMultipleMetals) {
            $this->saveProductMetals($product, $request->metal_components);
            
            // If dynamic pricing is enabled, calculate price from metal components
            if ($product->is_price_dynamic) {
                $pricingService = app(\App\Services\ProductPricingService::class);
                $pricingService->updateProductPrice($product);
            }
        } elseif ($product->is_price_dynamic && $product->metal_type != 'none' && $product->net_weight > 0) {
            // Legacy single metal dynamic pricing
            $metalPriceService = app(\App\Services\MetalPriceService::class);
            $priceResult = $metalPriceService->calculateProductPrice(
                $product->metal_type,
                $product->metal_purity,
                $product->net_weight,
                $product->making_charges,
                $product->making_charge_type,
                $product->stone_charges,
                0 // GST is handled via Tax field, not here
            );
            
            if ($priceResult['success']) {
                $product->price = $priceResult['breakdown']['total_price'] + ($product->other_charges ?? 0);
                $product->save();
            }
        }


        foreach ($request->lang as $index => $key) {
            if ($request->name[$index] && $key != 'en') {
                $this->translation->updateOrInsert(
                    ['translationable_type' => 'App\Model\Product',
                        'translationable_id' => $product->id,
                        'locale' => $key,
                        'key' => 'name'],
                    ['value' => $request->name[$index]]
                );
            }
            if ($request->description[$index] && $key != 'en') {
                $this->translation->updateOrInsert(
                    ['translationable_type' => 'App\Model\Product',
                        'translationable_id' => $product->id,
                        'locale' => $key,
                        'key' => 'description'],
                    ['value' => $request->description[$index]]
                );
            }
        }

        return response()->json(['success' => true, 'message' => 'Product updated successfully!'], 200);
    }



    /**
     * @param Request $request
     * @return RedirectResponse
     */
    public function delete(Request $request): RedirectResponse
    {
        $product = $this->product->find($request->id);
        foreach (json_decode($product['image'], true) as $img) {
            if (Storage::disk('public')->exists('product/' . $img)) {
                Storage::disk('public')->delete('product/' . $img);
            }
        }
        $product->delete();
        Toastr::success(translate('Product removed!'));
        return back();
    }

    /**
     * @param $id
     * @param $name
     * @return RedirectResponse
     */
    public function removeImage($id, $name): RedirectResponse
    {
        $product = $this->product->find($id);
        $imageArray = [];
        foreach (json_decode($product['image'], true) as $img) {
            if (strcmp($img, $name) != 0) {
                $imageArray[] = $img;
            }
        }

        if (count($imageArray) == 0) {
            Toastr::warning(translate('Product must have at least one image!'));
            return back();
        }

        if (Storage::disk('public')->exists('product/' . $name)) {
            Storage::disk('public')->delete('product/' . $name);
        }

        $this->product->where(['id' => $id])->update([
            'image' => json_encode($imageArray)
        ]);

        Toastr::success(translate('Image removed successfully!'));
        return back();
    }

    /**
     * @return Application|Factory|View
     */
    public function bulkImportIndex(): Factory|View|Application
    {
        return view('admin-views.product.bulk-import');
    }

    /**
     * @param Request $request
     * @return RedirectResponse
     */
    public function bulkImportProduct(Request $request): RedirectResponse
    {
        try {
            $collections = (new FastExcel)->import($request->file('products_file'));
        } catch (\Exception $exception) {
            Toastr::error(translate('You have uploaded a wrong format file, please upload the right file.'));
            return back();
        }

        $col_key = ['name','description','price','tax','category_id','sub_category_id','discount','discount_type','tax_type','unit','total_stock'];
        foreach ($collections as $key => $collection) {

            foreach ($collection as $collectionKey => $value) {
                if ($collectionKey != "" && !in_array($collectionKey, $col_key)) {
                    Toastr::error('Please upload the correct format file.');
                    return back();
                }
            }
        }

        $data = [];

        foreach ($collections as $key => $collection) {
            if ($collection['name'] === "") {
                Toastr::error('Please fill name field of row ' . ($key + 2));
                return back();
            }
            if ($collection['description'] === "") {
                Toastr::error('Please fill description field of row ' . ($key + 2));
                return back();
            }
            if ($collection['price'] === "") {
                Toastr::error('Please fill price field of row ' . ($key + 2));
                return back();
            }
            if ($collection['tax'] === "") {
                Toastr::error('Please fill tax field of row ' . ($key + 2));
                return back();
            }
            if ($collection['category_id'] === "") {
                Toastr::error('Please fill category_id field of row ' . ($key + 2));
                return back();
            }
            if ($collection['sub_category_id'] === "") {
                Toastr::error('Please fill sub_category_id field of row ' . ($key + 2));
                return back();
            }
            if ($collection['discount'] === "") {
                Toastr::error('Please fill discount field of row ' . ($key + 2));
                return back();
            }
            if ($collection['discount_type'] === "") {
                Toastr::error('Please fill discount_type field of row ' . ($key + 2));
                return back();
            }
            if ($collection['tax_type'] === "") {
                Toastr::error('Please fill tax_type field of row ' . ($key + 2));
                return back();
            }
            if ($collection['unit'] === "") {
                Toastr::error('Please fill unit field of row ' . ($key + 2));
                return back();
            }
            if ($collection['total_stock'] === "") {
                Toastr::error('Please fill total_stock field of row ' . ($key + 2));
                return back();
            }

            if (!is_numeric($collection['price'])) {
                Toastr::error('Price of row ' . ($key + 2) . ' must be number');
                return back();
            }

            if (!is_numeric($collection['discount'])) {
                Toastr::error('Discount of row ' . ($key + 2) . ' must be number');
                return back();
            }

            if (!is_numeric($collection['tax'])) {
                Toastr::error('Tax of row ' . ($key + 2) . ' must be number');
                return back();
            }

            if (!is_numeric($collection['total_stock'])) {
                Toastr::error('Total stock of row ' . ($key + 2) . ' must be number');
                return back();
            }

            $product = [
                'discount_type' => $collection['discount_type'],
                'discount' => $collection['discount'],
            ];
            if ($collection['price'] <= Helpers::discount_calculate($product, $collection['price'])) {
                Toastr::error('Discount can not be more or equal to the price!');
                return back();
            }
        }

        foreach ($collections as $collection) {
            $data[] = [
                'name' => $collection['name'],
                'description' => $collection['description'],
                'image' => json_encode(['def.png']),
                'price' => $collection['price'],
                'variations' => json_encode([]),
                'tax' => $collection['tax'],
                'status' => 1,
                'attributes' => json_encode([]),
                'category_ids' => json_encode([['id' => (string)$collection['category_id'], 'position' => 0], ['id' => (string)$collection['sub_category_id'], 'position' => 1]]),
                'choice_options' => json_encode([]),
                'discount' => $collection['discount'],
                'discount_type' => $collection['discount_type'],
                'tax_type' => $collection['tax_type'],
                'unit' => $collection['unit'],
                'total_stock' => $collection['total_stock'],
                'created_at' => now(),
                'updated_at' => now()
            ];
        }
        DB::table('products')->insert($data);
        Toastr::success(count($data) . translate('_Products imported successfully'));
        return back();
    }

    /**
     * @return string|StreamedResponse
     * @throws IOException
     * @throws InvalidArgumentException
     * @throws UnsupportedTypeException
     * @throws WriterNotOpenedException
     */
    public function bulkExportProduct(): StreamedResponse|string
    {
        $storage = [];
        $products = $this->product->all();

        foreach ($products as $item) {
            $categoryId = 0;
            $subCategoryId = 0;
            foreach (json_decode($item->category_ids, true) as $category) {
                if ($category['position'] == 1) {
                    $categoryId = $category['id'];
                } else if ($category['position'] == 2) {
                    $subCategoryId = $category['id'];
                }
            }

            if (!isset($item->name)) {
                $item->name = 'Unnamed Product';
            }

            if (!isset($item->description)) {
                $item->description = 'No description available';
            }

            $storage[] = [
                'name' => $item->name,
                'description' => $item->description,
                'category_id' => $categoryId,
                'sub_category_id' => $subCategoryId,
                'price' => $item->price,
                'tax' => $item->tax,
                'status' => $item->status,
                'discount' => $item->discount,
                'discount_type' => $item->discount_type,
                'tax_type' => $item->tax_type,
                'unit' => $item->unit,
                'total_stock' => $item->total_stock,
            ];
        }

        return (new FastExcel($storage))->download('products.xlsx');
    }

    /**
     * Preview price calculation for multi-metal products (AJAX).
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function previewPrice(Request $request): JsonResponse
    {
        try {
            $metals = $request->input('metals', []);
            $charges = [
                'making_charges' => $request->input('making_charges', 0),
                'making_charge_type' => $request->input('making_charge_type', 'fixed'),
                'wastage_charges' => $request->input('wastage_charges', 0),
                'wastage_type' => $request->input('wastage_type', 'percentage'),
                'stone_charges' => $request->input('stone_charges', 0),
                'other_charges' => $request->input('other_charges', 0),
            ];

            $pricingService = app(\App\Services\ProductPricingService::class);
            $preview = $pricingService->previewPrice($metals, $charges);

            return response()->json([
                'success' => true,
                'data' => $preview,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Recalculate price for a specific product (AJAX).
     * 
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function recalculatePrice(Request $request, $id): JsonResponse
    {
        try {
            $product = Product::findOrFail($id);

            if (!$product->is_price_dynamic) {
                return response()->json([
                    'success' => false,
                    'message' => 'This product does not have dynamic pricing enabled.',
                ]);
            }

            $pricingService = app(\App\Services\ProductPricingService::class);
            $pricing = $pricingService->calculateProductPrice($product);
            $pricingService->updateProductPrice($product);

            return response()->json([
                'success' => true,
                'data' => [
                    'old_price' => $product->getOriginal('price'),
                    'new_price' => $product->fresh()->price,
                    'breakdown' => $pricing,
                ],
                'message' => 'Price recalculated successfully.',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}

