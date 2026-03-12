import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

enum Language { arabic, english }

enum Layout { vertical, horizontal }

class Governorate {
  final String nameEn;
  final String nameAr;
  final List<City> cities;

  Governorate(
      {required this.nameEn, required this.nameAr, this.cities = const []});

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
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
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
      _selectedCity = null;
      _cities = gov.cities;
      _cities.sort((a, b) {
        return widget.language == Language.arabic
            ? a.nameAr.compareTo(b.nameAr)
            : a.nameEn.compareTo(b.nameEn);
      });
    });
  }

  void _onCitySelected(City? city, {bool isInit = false}) {
    if (city == null) return;
    if (!isInit) {
      widget.onCityChanged?.call(_getCityName(city));
    }
    setState(() {
      _selectedCity = city;
    });
  }

  void _showCustomDropdown({
    required BuildContext context,
    required List<dynamic> items,
    required Function(dynamic) onItemSelected,
    required String Function(dynamic) getItemName,
  }) {
    FocusScope.of(context).unfocus();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    showMenu(
      context: context,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: 250.h,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        screenSize.width - offset.dx - size.width,
        screenSize.height - offset.dy,
      ),
      items: items.map((item) {
        return PopupMenuItem(
          value: item,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              getItemName(item),
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        onItemSelected(value);
      }
    });
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required Function(BuildContext) onTap,
    bool isEnabled = true,
  }) {
    return Builder(builder: (fieldBuildContext) {
      return GestureDetector(
        onTap: isEnabled ? () => onTap(fieldBuildContext) : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : Colors.grey.shade100,
            border: Border.all(color: const Color(0xFFE2DFDF)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Iconsax.arrow_bottom,
                  size: 16.r, color: Colors.grey.shade600),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  value ?? hintText,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: value == null ? Colors.grey.shade600 : Colors.black,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
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
        _buildDropdownField(
          hintText: widget.governorateDropdownLabel.tr(widget.language),
          value: _selectedGovernorate != null
              ? _getGovernorateName(_selectedGovernorate!)
              : null,
          onTap: (ctx) {
            _showCustomDropdown(
              context: ctx,
              items: _governorates,
              onItemSelected: (item) =>
                  _onGovernorateSelected(item as Governorate),
              getItemName: (item) => _getGovernorateName(item as Governorate),
            );
          },
        ),
        if (widget.showCities) SizedBox(height: 16.0.h),
        if (widget.showCities)
          _buildDropdownField(
            hintText: widget.cityDropdownLabel.tr(widget.language),
            value: _selectedCity != null ? _getCityName(_selectedCity!) : null,
            isEnabled: _selectedGovernorate != null,
            onTap: (ctx) {
              if (_selectedGovernorate != null) {
                _showCustomDropdown(
                  context: ctx,
                  items: _cities,
                  onItemSelected: (item) => _onCitySelected(item as City),
                  getItemName: (item) => _getCityName(item as City),
                );
              }
            },
          ),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
            hintText: widget.governorateDropdownLabel.tr(widget.language),
            value: _selectedGovernorate != null
                ? _getGovernorateName(_selectedGovernorate!)
                : null,
            onTap: (ctx) {
              _showCustomDropdown(
                context: ctx,
                items: _governorates,
                onItemSelected: (item) =>
                    _onGovernorateSelected(item as Governorate),
                getItemName: (item) => _getGovernorateName(item as Governorate),
              );
            },
          ),
        ),
        if (widget.showCities) SizedBox(width: 16.0.w),
        if (widget.showCities)
          Expanded(
            child: _buildDropdownField(
              hintText: widget.cityDropdownLabel.tr(widget.language),
              value:
                  _selectedCity != null ? _getCityName(_selectedCity!) : null,
              isEnabled: _selectedGovernorate != null,
              onTap: (ctx) {
                if (_selectedGovernorate != null) {
                  _showCustomDropdown(
                    context: ctx,
                    items: _cities,
                    onItemSelected: (item) => _onCitySelected(item as City),
                    getItemName: (item) => _getCityName(item as City),
                  );
                }
              },
            ),
          ),
      ],
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
