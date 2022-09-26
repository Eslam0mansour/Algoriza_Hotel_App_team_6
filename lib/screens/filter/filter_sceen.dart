import 'package:algoriza_team_6_realestate_app/business_logic/cubit/filter_cubit/filter_cubit.dart';
import 'package:algoriza_team_6_realestate_app/constants/screens.dart';
import 'package:algoriza_team_6_realestate_app/widgets/default_icon_button.dart';
import 'package:algoriza_team_6_realestate_app/widgets/default_loading_indicator.dart';
import 'package:algoriza_team_6_realestate_app/widgets/default_material_button.dart';
import 'package:algoriza_team_6_realestate_app/widgets/default_text.dart';
import 'package:algoriza_team_6_realestate_app/widgets/horizontal_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../data/di/di.dart';
import '../../styles/colors.dart';
import '../../widgets/search_form_field.dart';

class FilterScreen extends StatefulWidget {
  final String searchText;

  const FilterScreen({Key? key, required this.searchText}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late RangeValues _priceRange;
  final TextEditingController searchController = TextEditingController();
  late double distance;
  late FilterCubit filterCubit;

  @override
  void initState() {
    searchController.text = widget.searchText;
    filterCubit = sl<FilterCubit>();

    _priceRange = const RangeValues(200, 1200);
    distance = 20.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => filterCubit..getFacilities(),
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, searchController.text);

          return true;
        },
        child: Scaffold(
          body: SafeArea(
              child: BlocConsumer<FilterCubit, FilterState>(
            listener: (context, state) {
              if (state is GetFilterHotelsSuccessState) {
                Navigator.pushNamed(context, filterResultRoute,
                    arguments: state.filterResult);
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: SearchFormField(
                              autofocus: true,
                              horizontalPadding: 2.w,
                              controller: searchController,
                              backgroundColor: defaultBlack.withOpacity(0.4),
                              keyboardType: TextInputType.text,
                              hintText: 'Where are you going',
                            ),
                          ),
                          Row(
                            children: [
                              DefaultText(
                                  text: 'Price ',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: defaultGray),
                              DefaultText(
                                  text: '(for 1 night)',
                                  fontSize: 14.sp,
                                  color: defaultGray),
                              const Spacer()
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.0.w,
                            ).copyWith(top: 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DefaultText(
                                    text: '${_priceRange.start.round()}\$',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                                DefaultText(
                                    text: '${_priceRange.end.round()}\$',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ],
                            ),
                          ),
                          RangeSlider(
                            divisions: 30,
                            semanticFormatterCallback: (double newValue) {
                              return '${newValue.round()} dollars';
                            },
                            values: _priceRange,
                            max: 1500,
                            min: 50,
                            onChanged: (value) {
                              setState(() {
                                _priceRange = value;
                              });
                            },
                          ),
                          const HorizontalDivider(color: defaultGray),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DefaultText(
                                    text: 'Distance from city center',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: defaultGray,
                                  ),
                                ),
                                DefaultIconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, filterPickLocationRoute,
                                          arguments: distance.toInt());
                                    },
                                    icon: const Icon(
                                      Icons.edit_location_rounded,
                                    ))
                              ],
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: DefaultText(
                                text: 'Less than ${distance.round()} Km',
                                fontSize: 14.sp),
                          ),
                          Slider(
                            max: 200,
                            min: 10,
                            value: distance,
                            onChanged: (value) {
                              setState(() {
                                distance = value;
                              });
                            },
                          ),
                          const HorizontalDivider(color: defaultGray),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                          childCount: filterCubit.facilities.data.length,
                          (context, index) => CheckboxListTile(
                                checkboxShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.sp)),
                                title: DefaultText(
                                    text: filterCubit
                                        .facilities.data[index].name),
                                value:
                                    filterCubit.facilities.data[index].checked,
                                onChanged: (value) {
                                  setState(() {
                                    filterCubit
                                            .facilities.data[index].setChecked =
                                        !filterCubit
                                            .facilities.data[index].checked;
                                  });
                                },
                              ))),
                  SliverToBoxAdapter(child: Builder(
                    builder: (context) {
                      if (state is GetFilterHotelsLoadingState) {
                        return DefaultLoadingIndicator();
                      } else {
                        return DefaultMaterialButton(
                          onPressed: () {
                            filterCubit.getFilterHotels(
                              maxPrice: _priceRange.end.toInt(),
                              minPrice: _priceRange.start.toInt(),
                              distance: distance.toInt(),
                              name: searchController.text,
                            );
                          },
                          text: 'Apply',
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.0.w, vertical: 2.h),
                        );
                      }
                    },
                  ))
                ],
              );
            },
          )),
        ),
      ),
    );
  }
}
