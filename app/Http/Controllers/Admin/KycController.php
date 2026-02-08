<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Brian2694\Toastr\Facades\Toastr;

class KycController extends Controller
{
    /**
     * Display a listing of KYC documents.
     */
    public function index(Request $request)
    {
        $query = KycDocument::with('user');

        // Filter by status
        if ($request->has('status') && !empty($request->status)) {
            $query->where('status', $request->status);
        }

        // Search by user name or document number
        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('document_number', 'like', '%' . $search . '%')
                  ->orWhereHas('user', function($q2) use ($search) {
                      $q2->where('f_name', 'like', '%' . $search . '%')
                         ->orWhere('l_name', 'like', '%' . $search . '%')
                         ->orWhere('email', 'like', '%' . $search . '%');
                  });
            });
        }

        $kycDocuments = $query->latest()->paginate(config('default_pagination', 25));
        
        // Stats
        $stats = [
            'total' => KycDocument::count(),
            'pending' => KycDocument::pending()->count(),
            'approved' => KycDocument::approved()->count(),
            'rejected' => KycDocument::where('status', 'rejected')->count(),
        ];

        return view('admin-views.sip.kyc.index', compact('kycDocuments', 'stats'));
    }

    /**
     * Show the specified KYC document details.
     */
    public function show($id)
    {
        $kyc = KycDocument::with(['user', 'verifier'])->findOrFail($id);
        return view('admin-views.sip.kyc.show', compact('kyc'));
    }

    /**
     * Approve the specified KYC document.
     */
    public function approve(Request $request, $id)
    {
        $kyc = KycDocument::findOrFail($id);

        if ($kyc->status !== KycDocument::STATUS_PENDING) {
            Toastr::error(translate('This KYC has already been processed!'));
            return back();
        }

        $kyc->update([
            'status' => KycDocument::STATUS_APPROVED,
            'verified_by' => auth('admin')->id(),
            'verified_at' => now(),
            'rejection_reason' => null,
        ]);

        Toastr::success(translate('KYC approved successfully!'));
        return redirect()->route('admin.sip.kyc.index');
    }

    /**
     * Reject the specified KYC document.
     */
    public function reject(Request $request, $id)
    {
        $kyc = KycDocument::findOrFail($id);

        if ($kyc->status !== KycDocument::STATUS_PENDING) {
            Toastr::error(translate('This KYC has already been processed!'));
            return back();
        }

        $request->validate([
            'rejection_reason' => 'required|string|max:500',
        ]);

        $kyc->update([
            'status' => KycDocument::STATUS_REJECTED,
            'verified_by' => auth('admin')->id(),
            'verified_at' => now(),
            'rejection_reason' => $request->rejection_reason,
        ]);

        Toastr::success(translate('KYC rejected successfully!'));
        return redirect()->route('admin.sip.kyc.index');
    }

    /**
     * Download/view the KYC document image.
     */
    public function viewDocument($id, $type)
    {
        $kyc = KycDocument::findOrFail($id);
        
        $filename = $type === 'front' ? $kyc->document_front_image : $kyc->document_back_image;
        
        if (!$filename || !Storage::disk('public')->exists('kyc/' . $filename)) {
            abort(404);
        }

        return response()->file(storage_path('app/public/kyc/' . $filename));
    }
}
