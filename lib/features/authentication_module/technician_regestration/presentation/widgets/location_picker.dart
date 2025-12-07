library;

import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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

      var governorates =
          govList.map((g) => Governorate.fromJson(g)).toList();
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
              c.nameEn == widget.currentCity ||
              c.nameAr == widget.currentCity);
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
      _cities = gov.cities;
      _cities.sort((a, b) {
        return widget.language == Language.arabic
            ? a.nameAr.compareTo(b.nameAr)
            : a.nameEn.compareTo(b.nameEn);
      });
      _selectedCity = null;
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
        if (widget.showCities) const SizedBox(height: 16.0),
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
            if (widget.showCities) const SizedBox(width: 16.0),
            if (widget.showCities) Expanded(child: _buildCityDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildGovernorateDropdown() {
    return Directionality(textDirection: TextDirection.rtl, 
    child: DropdownButtonFormField2<Governorate>(
      alignment: AlignmentDirectional.centerEnd,
      decoration: InputDecoration(
        hintText: widget.governorateDropdownLabel.tr(widget.language),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(8),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFE2DFDF),
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF3775FA),
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
                  maxHeight: (200/852)*MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
      ),
      isExpanded: true,
      value: _selectedGovernorate,
      items: _governorates.map((Governorate gov) {
        return DropdownMenuItem<Governorate>(
          alignment: AlignmentDirectional.centerEnd,
          value: gov,
          child: Align(
            alignment: Alignment.centerRight,
            child:  Text(
            _getGovernorateName(gov),
            style: widget.selectedItemStyle,
            overflow: TextOverflow.ellipsis,
          ),
          )
        );
      }).toList(),
      onChanged: (val) => _onGovernorateSelected(val),
      disabledHint: Text(widget.governorateDropdownLabel.tr(widget.language)),
    ),
    );
  }

  Widget _buildCityDropdown() {
    bool isGovSelected = _selectedGovernorate != null;
    return Directionality(textDirection: TextDirection.rtl,
    child: DropdownButtonFormField2<City>(
      decoration: InputDecoration(
        hintText: widget.cityDropdownLabel.tr(widget.language),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(8),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFE2DFDF),
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF3775FA),
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
                  maxHeight: (200/852)*MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
      ),
      isExpanded: true,
      value: _selectedCity,
      items: _cities.map((City city) {
        return DropdownMenuItem<City>(
          alignment: AlignmentDirectional.centerEnd,
          value: city,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
            _getCityName(city),
            style: widget.selectedItemStyle,
            overflow: TextOverflow.ellipsis,
          ),
          )
        );
      }).toList(),
      onChanged: isGovSelected ? (val) => _onCitySelected(val) : null,
      disabledHint: Text(widget.cityDropdownLabel.tr(widget.language)),
    ),
    );
  }
}

extension _PublicTranslator on String {
  String tr(Language language) {
    bool isArabic = language == Language.arabic;
    switch (this) {
      case "Governorate":
        if (isArabic) return "المحافظة";
        return "Governorate";
      case "City":
        if (isArabic) return "المدينة";
        return "City";
      default:
        return this;
    }
  }
}