import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum Language { arabic, english }

enum Layout { vertical, horizontal }

class Governorate {
  final String nameEn;
  final String nameAr;
  final List<City> cities;

  Governorate({required this.nameEn, required this.nameAr, this.cities = const []});

  factory Governorate.fromJson(Map<String, dynamic> json) {
    var cityList = json['cities'] as List? ?? [];
    List<City> cities = cityList.map((c) => City.fromJson(c)).toList();
    return Governorate(
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
      cities: cities,
    );
  }
}

class City {
  final String nameEn;
  final String nameAr;

  City({required this.nameEn, required this.nameAr});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
    );
  }
}

class EgyptGovernoratePicker extends StatefulWidget {
  final ValueChanged<String?>? onGovernorateChanged;
  final ValueChanged<String?>? onCityChanged;
  final String? currentGovernorate;
  final String? currentCity;
  final Language language;
  final bool showCities;
  final Layout layout;
  final TextStyle? selectedItemStyle;
  final BoxDecoration? dropdownDecoration;
  final BoxDecoration? disabledDropdownDecoration;
  final String governorateDropdownLabel;
  final String cityDropdownLabel;
  final String assetDataPath;

  const EgyptGovernoratePicker({
    super.key,
    this.onGovernorateChanged,
    this.onCityChanged,
    this.currentGovernorate,
    this.currentCity,
    this.language = Language.arabic,
    this.showCities = true,
    this.layout = Layout.vertical,
    this.selectedItemStyle,
    this.dropdownDecoration,
    this.disabledDropdownDecoration,
    this.governorateDropdownLabel = "Governorate",
    this.cityDropdownLabel = "City",
    this.assetDataPath = "assets/data/egypt_data.json",
  });

  @override
  State<EgyptGovernoratePicker> createState() => _EgyptGovernoratePickerState();
}

class _EgyptGovernoratePickerState extends State<EgyptGovernoratePicker> {
  final List<Governorate> _governorates = [];
  List<City> _cities = [];

  Governorate? _selectedGovernorate;

  final ValueNotifier<Governorate?> _govNotifier = ValueNotifier<Governorate?>(null);
  final ValueNotifier<City?> _cityNotifier = ValueNotifier<City?>(null);

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  @override
  void dispose() {
    _govNotifier.dispose();
    _cityNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadGovernorates() async {
    try {
      var jsonString = await rootBundle.loadString(widget.assetDataPath);
      var jsonMap = jsonDecode(jsonString);
      var govList = jsonMap['governorates'] as List;

      var governorates = govList.map((g) => Governorate.fromJson(g)).toList();
      governorates.sort((a, b) {
        return widget.language == Language.arabic
            ? a.nameAr.compareTo(b.nameAr)
            : a.nameEn.compareTo(b.nameEn);
      });

      setState(() {
        _governorates.addAll(governorates);
      });

      if (widget.currentGovernorate != null) {
        _setDefaults();
      }
    } catch (e) {
      debugPrint("Error loading governorate data: $e");
    }
  }

  void _setDefaults() {
    Governorate? defaultGov;
    try {
      defaultGov = _governorates.firstWhere((g) =>
          g.nameEn == widget.currentGovernorate ||
          g.nameAr == widget.currentGovernorate);
    } catch (e) {
      defaultGov = null;
    }

    if (defaultGov != null) {
      _onGovernorateSelected(defaultGov, isInit: true);

      if (widget.currentCity != null && widget.showCities) {
        City? defaultCity;
        try {
          defaultCity = defaultGov.cities.firstWhere((c) =>
              c.nameEn == widget.currentCity || c.nameAr == widget.currentCity);
        } catch (e) {
          defaultCity = null;
        }
        if (defaultCity != null) {
          _onCitySelected(defaultCity, isInit: true);
        }
      }
    }
  }

  String _getGovernorateName(Governorate gov) {
    return widget.language == Language.arabic ? gov.nameAr : gov.nameEn;
  }

  String _getCityName(City city) {
    return widget.language == Language.arabic ? city.nameAr : city.nameEn;
  }

  void _onGovernorateSelected(Governorate? gov, {bool isInit = false}) {
    if (gov == null) return;
    if (!isInit) {
      widget.onGovernorateChanged?.call(_getGovernorateName(gov));
      widget.onCityChanged?.call(null);
    }
    setState(() {
      _selectedGovernorate = gov;
      _govNotifier.value = gov;
      _cities = gov.cities;
      _cities.sort((a, b) {
        return widget.language == Language.arabic
            ? a.nameAr.compareTo(b.nameAr)
            : a.nameEn.compareTo(b.nameEn);
      });
      _cityNotifier.value = null;
    });
  }

  void _onCitySelected(City? city, {bool isInit = false}) {
    if (city == null) return;
    if (!isInit) {
      widget.onCityChanged?.call(_getCityName(city));
    }
    setState(() {
      _cityNotifier.value = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.layout == Layout.vertical
        ? _buildVerticalLayout()
        : _buildHorizontalLayout();
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: [
        _buildGovernorateDropdown(),
        if (widget.showCities) SizedBox(height: 16.0.h),
        if (widget.showCities) _buildCityDropdown(),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildGovernorateDropdown()),
            if (widget.showCities) SizedBox(width: 16.0.w),
            if (widget.showCities) Expanded(child: _buildCityDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildGovernorateDropdown() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DropdownButtonFormField2<Governorate>(
        valueListenable: _govNotifier,
        alignment: AlignmentDirectional.centerEnd,
        hint: Align(
          alignment: Alignment.centerRight,
          child: Text(
            widget.governorateDropdownLabel.tr(widget.language),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
            ),
          ),
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0.r)),
          contentPadding: EdgeInsets.all(8.r),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE2DFDF)),
            borderRadius: BorderRadius.circular(12.0.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF3775FA)),
            borderRadius: BorderRadius.circular(12.0.r),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          isOverButton: false,
          offset: const Offset(0, -5),
          maxHeight: 250.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0.r),
            color: Colors.white,
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        isExpanded: true,
        items: _governorates.map((Governorate gov) {
          return DropdownItem<Governorate>(
              value: gov,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _getGovernorateName(gov),
                  style: widget.selectedItemStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ));
        }).toList(),
        onChanged: (val) => _onGovernorateSelected(val),
      ),
    );
  }

  Widget _buildCityDropdown() {
    bool isGovSelected = _selectedGovernorate != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DropdownButtonFormField2<City>(
        valueListenable: _cityNotifier,
        items: _cities.map((City city) {
          return DropdownItem<City>(
            value: city,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _getCityName(city),
                style: widget.selectedItemStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        onChanged: isGovSelected ? (val) => _onCitySelected(val) : null,
        decoration: InputDecoration(
          hintText: widget.cityDropdownLabel.tr(widget.language),
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFE2DFDF)),
            borderRadius: BorderRadius.circular(12.0.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF3775FA)),
            borderRadius: BorderRadius.circular(12.0.r),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 250.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0.r),
            color: Colors.white,
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        isExpanded: true,
        hint: Text(widget.cityDropdownLabel.tr(widget.language)),
      ),
    );
  }
}

extension _PublicTranslator on String {
  String tr(Language language) {
    bool isArabic = language == Language.arabic;
    switch (this) {
      case "Governorate":
        return isArabic ? "المحافظة" : "Governorate";
      case "City":
        return isArabic ? "المدينة" : "City";
      default:
        return this;
    }
  }
}