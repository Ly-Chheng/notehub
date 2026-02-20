import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChangeLanguageController extends GetxController {
  static ChangeLanguageController instance = Get.find();
  final storage = GetStorage();
  var km = const Locale('km', 'KM');
  var us = const Locale('en', 'US');

  List localeList = [
    {
      'name': 'ភាសាខ្មែរ',
      'key': ['km', 'KM'],
      'locale': const Locale('km', 'KM'),
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Flag_of_Cambodia.svg/800px-Flag_of_Cambodia.svg.png',
    },
    {
      'name': 'English',
      'key': ['en', 'US'],
      'locale': const Locale('en', 'US'),
      'image': 'https://upload.wikimedia.org/wikipedia/commons/f/fc/Flag_of_Great_Britain_%28English_version%29.png',
    }
  ];

  final langs = ['Khmer', 'English'];

  final locales = [const Locale('km', 'KM'), const Locale('en', 'US')];

  Locale _getSaved(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale!;
  }

  updateLanguage(String lang) {
    final locale = _getSaved(lang);
    if (Get.locale == us) {
      Get.updateLocale(km);
      storage.write('langCode', 'km');
      storage.write('countryCode', 'KM');
    } else {
      Get.updateLocale(us);
      storage.write('langCode', 'en');
      storage.write('countryCode', 'US');
    }
    update();
    Get.back();
    Get.updateLocale(locale);
  }
}
