@extends('layouts.admin.app')

@section('title', translate('SIP Plans'))

@section('content')
    <div class="content container-fluid">
        <!-- Page Header -->
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-sm mb-2 mb-sm-0">
                    <h1 class="page-header-title">
                        <i class="tio-layers mr-2"></i>
                        {{translate('SIP Plans')}}
                        <span class="badge badge-soft-primary ml-2">{{ $plans->total() }}</span>
                    </h1>
                </div>
                <div class="col-sm-auto">
                    <a href="{{ route('admin.sip.plan.create') }}" class="btn btn-primary">
                        <i class="tio-add-circle mr-1"></i> {{translate('Add New Plan')}}
                    </a>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-3">
            <div class="card-body">
                <form action="{{ route('admin.sip.plan.index') }}" method="GET">
                    <div class="row">
                        <div class="col-md-4">
                            <input type="text" name="search" class="form-control" 
                                   placeholder="{{translate('Search by name')}}" 
                                   value="{{ request('search') }}">
                        </div>
                        <div class="col-md-3">
                            <select name="metal_type" class="form-control">
                                <option value="">{{translate('All Metals')}}</option>
                                <option value="gold" {{ request('metal_type') == 'gold' ? 'selected' : '' }}>{{translate('Gold')}}</option>
                                <option value="silver" {{ request('metal_type') == 'silver' ? 'selected' : '' }}>{{translate('Silver')}}</option>
                                <option value="platinum" {{ request('metal_type') == 'platinum' ? 'selected' : '' }}>{{translate('Platinum')}}</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <select name="status" class="form-control">
                                <option value="">{{translate('All Status')}}</option>
                                <option value="active" {{ request('status') == 'active' ? 'selected' : '' }}>{{translate('Active')}}</option>
                                <option value="inactive" {{ request('status') == 'inactive' ? 'selected' : '' }}>{{translate('Inactive')}}</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="tio-search"></i> {{translate('Filter')}}
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Plans Table -->
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover table-borderless mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>{{translate('SL')}}</th>
                                <th>{{translate('Plan Name')}}</th>
                                <th>{{translate('Metal')}}</th>
                                <th>{{translate('Amount Range')}}</th>
                                <th>{{translate('Duration')}}</th>
                                <th>{{translate('Bonus')}}</th>
                                <th>{{translate('Status')}}</th>
                                <th class="text-center">{{translate('Actions')}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($plans as $key => $plan)
                                <tr>
                                    <td>{{ $plans->firstItem() + $key }}</td>
                                    <td>
                                        <strong>{{ $plan->name }}</strong>
                                        <br>
                                        <small class="text-muted">{{ Str::limit($plan->description, 50) }}</small>
                                    </td>
                                    <td>
                                        <span class="badge badge-soft-warning">
                                            {{ ucfirst($plan->metal_type) }} ({{ strtoupper($plan->gold_purity) }})
                                        </span>
                                    </td>
                                    <td>{{ $plan->amount_range }}</td>
                                    <td>
                                        {{ $plan->duration_months }} {{translate('months')}}
                                        <br>
                                        <small class="text-muted">{{ $plan->frequency_label }}</small>
                                    </td>
                                    <td>
                                        @if($plan->bonus_months > 0)
                                            <span class="text-success">+{{ $plan->bonus_months }} {{translate('months')}}</span>
                                        @endif
                                        @if($plan->bonus_percentage > 0)
                                            <span class="text-success">+{{ $plan->bonus_percentage }}%</span>
                                        @endif
                                        @if($plan->bonus_months == 0 && $plan->bonus_percentage == 0)
                                            <span class="text-muted">-</span>
                                        @endif
                                    </td>
                                    <td>
                                        <label class="toggle-switch toggle-switch-sm">
                                            <input type="checkbox" class="toggle-switch-input status-toggle" 
                                                   data-id="{{ $plan->id }}"
                                                   {{ $plan->is_active ? 'checked' : '' }}>
                                            <span class="toggle-switch-label">
                                                <span class="toggle-switch-indicator"></span>
                                            </span>
                                        </label>
                                    </td>
                                    <td class="text-center">
                                        <a href="{{ route('admin.sip.plan.edit', $plan->id) }}" 
                                           class="btn btn-sm btn-outline-primary" title="{{translate('Edit')}}">
                                            <i class="tio-edit"></i>
                                        </a>
                                        <button type="button" class="btn btn-sm btn-outline-danger delete-btn" 
                                                data-id="{{ $plan->id }}" title="{{translate('Delete')}}">
                                            <i class="tio-delete"></i>
                                        </button>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="text-center py-5">
                                        <img src="{{ asset('assets/admin/svg/illustrations/sorry.svg') }}" alt="No data" style="width: 150px;">
                                        <p class="mt-3 text-muted">{{translate('No SIP plans found')}}</p>
                                        <a href="{{ route('admin.sip.plan.create') }}" class="btn btn-primary btn-sm">
                                            <i class="tio-add-circle mr-1"></i> {{translate('Create First Plan')}}
                                        </a>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if($plans->hasPages())
                <div class="card-footer">
                    {{ $plans->links() }}
                </div>
            @endif
        </div>
    </div>

    <!-- Delete Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">{{translate('Delete SIP Plan')}}</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p>{{translate('Are you sure you want to delete this SIP plan?')}}</p>
                    <p class="text-danger small">{{translate('This action cannot be undone.')}}</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{{translate('Cancel')}}</button>
                    <form id="deleteForm" method="POST" style="display: inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger">{{translate('Delete')}}</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script_2')
    <script>
        // Status toggle
        $('.status-toggle').on('change', function() {
            let id = $(this).data('id');
            window.location.href = "{{ route('admin.sip.plan.toggle-status', '') }}/" + id;
        });

        // Delete confirmation
        $('.delete-btn').on('click', function() {
            let id = $(this).data('id');
            $('#deleteForm').attr('action', "{{ route('admin.sip.plan.delete', '') }}/" + id);
            $('#deleteModal').modal('show');
        });
    </script>
@endpush
