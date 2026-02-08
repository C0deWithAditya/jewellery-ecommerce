<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KycDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'document_type',
        'document_number',
        'document_front_image',
        'document_back_image',
        'status',
        'rejection_reason',
        'verified_by',
        'verified_at',
    ];

    protected $casts = [
        'verified_at' => 'datetime',
    ];

    // Constants for status
    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';

    // Constants for document type
    const TYPE_PAN = 'pan';
    const TYPE_AADHAR = 'aadhar';
    const TYPE_PASSPORT = 'passport';
    const TYPE_VOTER_ID = 'voter_id';

    /**
     * Get the user that owns the KYC document.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the admin who verified this document.
     */
    public function verifier()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    /**
     * Scope for pending KYC documents.
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    /**
     * Scope for approved KYC documents.
     */
    public function scopeApproved($query)
    {
        return $query->where('status', self::STATUS_APPROVED);
    }

    /**
     * Check if the KYC is approved.
     */
    public function isApproved(): bool
    {
        return $this->status === self::STATUS_APPROVED;
    }

    /**
     * Get the front image URL.
     */
    public function getFrontImageUrlAttribute(): string
    {
        return $this->document_front_image 
            ? asset('storage/kyc/' . $this->document_front_image) 
            : asset('assets/admin/img/placeholder.png');
    }

    /**
     * Get the back image URL.
     */
    public function getBackImageUrlAttribute(): string
    {
        return $this->document_back_image 
            ? asset('storage/kyc/' . $this->document_back_image) 
            : asset('assets/admin/img/placeholder.png');
    }
}
