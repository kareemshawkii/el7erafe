import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:http/http.dart' as http;
import '../models/service_item.dart';

class HomeRepository {
  final String baseUrl =
      "https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net";

  Future<Either<String, List<ServiceItem>>> getServices() async {
    AuthLocalStorage authLocalStorage = AuthLocalStorage();

    String? token = await authLocalStorage.getToken();

    try {
      final Uri url = Uri.parse('$baseUrl/cf/services');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);

        if (decodedResponse.containsKey('services')) {
          final List<dynamic> list = decodedResponse['services'];
          return Right(list.map((e) => ServiceItem.fromJson(e)).toList());
        } else {
          return const Right([]);
        }
      } else if (response.statusCode == 401) {
        await authLocalStorage.clearSession();
        return const Left("401 Unauthorized");
      } else {
        return const Left("فشل تحميل الخدمات الرجاء المحاولة مرة اخرى.");
      }
    } catch (e) {
      return const Left(
          "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.");
    }
  }
}
