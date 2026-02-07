import 'package:hexacom_user/helper/responsive_helper.dart';
import 'package:hexacom_user/localization/language_constrants.dart';
import 'package:hexacom_user/utill/dimensions.dart';
import 'package:hexacom_user/utill/styles.dart';
import 'package:hexacom_user/common/widgets/custom_loader_widget.dart';
import 'package:flutter/material.dart';

class PaginatedListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function(int? offset) onPaginate;
  final int? totalSize;
  final int? offset;
  final int? limit;
  final Widget itemView;
  final bool enabledPagination;
  final bool reverse;
  const PaginatedListView({
    super.key, required this.scrollController, required this.onPaginate, required this.totalSize,
    required this.offset, required this.itemView, this.enabledPagination = true, this.reverse = false, this.limit = 10,
  });

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  int? _offset;
  late List<int?> _offsetList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _offset = 1;
    _offsetList = [1];

    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels == widget.scrollController.position.maxScrollExtent
          && widget.totalSize != null && !_isLoading && widget.enabledPagination) {
        if(mounted && !ResponsiveHelper.isDesktop(context)) {
          _paginate();
        }
      }
    });
  }

  void _paginate() async {
    int pageSize = (widget.totalSize! / widget.limit!).ceil();
    if (_offset! < pageSize && !_offsetList.contains(_offset!+1)) {

      setState(() {
        _offset = _offset! + 1;
        _offsetList.add(_offset);
        _isLoading = true;
      });
      await widget.onPaginate(_offset);
      setState(() {
        _isLoading = false;
      });

    }else {
      if(_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.offset != null) {
      _offset = widget.offset;
      _offsetList = [];
      for(int index=1; index<=widget.offset!; index++) {
        _offsetList.add(index);
      }
    }


    return Column(children: [

      widget.reverse ? const SizedBox() : widget.itemView,

      (ResponsiveHelper.isDesktop(context) && (widget.totalSize == null || _offset! >= (widget.totalSize! / (widget.limit!)).ceil() || _offsetList.contains(_offset!+1))) ? const SizedBox(height: Dimensions.paddingSizeDefault) : Center(child: Padding(
        padding: (_isLoading || ResponsiveHelper.isDesktop(context)) ?  const EdgeInsets.all(Dimensions.paddingSizeDefault) : EdgeInsets.zero,
        child: _isLoading ? CustomLoaderWidget(color: Theme.of(context).primaryColor) : (ResponsiveHelper.isDesktop(context) && widget.totalSize != null) ? InkWell(
          onTap: _paginate,
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeLarge,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Text(getTranslated('see_more', context), style: rubikMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).primaryColor,
            )),

          ),
        ) : const SizedBox(),
      )),

      widget.reverse ? widget.itemView : const SizedBox(),

    ]);
  }
}
