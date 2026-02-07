<?php

namespace App\Model;

use Illuminate\Database\Eloquent\Model;

class BusinessSetting extends Model
{
    protected $fillable = [
        'key',
        'value'
    ];
}
