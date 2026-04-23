import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/pending_offer_model.dart';
import 'package:http/http.dart' as http;
import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:el7erafe/core/utils/app_event_bus.dart';

class PendingOffersRepo {
  final AuthLocalStorage _authLocal = AuthLocalStorage();
  final String _baseUrl = "https://el7rafeapp.azurewebsites.net";
  StreamSubscription? _fcmSubscription;

  Future<Either<String, List<PendingOfferModel>>> getPendingOffers() async {
    try {
      final token = await _authLocal.getToken();
      if (token == null || token.isEmpty) return const Left("401");

      final url = Uri.parse("$_baseUrl/api/tech/pending-offers");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final listData =
            decodedData is List ? decodedData : decodedData['data'] as List;
        return Right(listData
            .map((e) => PendingOfferModel.fromJson(e as Map<String, dynamic>))
            .toList());
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const Left("401");
      } else {
        try {
          final decodedData = jsonDecode(response.body);
          return Left(decodedData['errorMessage'] ?? "حدث خطأ غير متوقع");
        } catch (_) {
          return const Left("حدث خطأ غير متوقع");
        }
      }
    } catch (e) {
      return const Left("حدث خطأ في الاتصال بالخادم");
    }
  }

  Future<void> connectAndListen({
    required Function() onSignalRRefreshNeeded,
    required Function() onForceDisconnect,
  }) async {
    _fcmSubscription?.cancel();
    _fcmSubscription = AppEventBus().stream.listen((action) {
      if (action == 'OFFER_ACCEPTED' || action == 'OFFER_REJECTED') {
        onSignalRRefreshNeeded();
      }
    });

    final hub = SignalRService.instance.techHub;
    if (hub == null) {
      await SignalRService.instance.initAndConnect();
    }

    final activeHub = SignalRService.instance.techHub;
    if (activeHub == null) return;

    activeHub.off("OfferRejected");
    activeHub.off("OfferAccepted");
    activeHub.off("ForceDisconnect");

    activeHub.on("OfferRejected", (_) => onSignalRRefreshNeeded());
    activeHub.on("OfferAccepted", (_) => onSignalRRefreshNeeded());
    activeHub.on("ForceDisconnect", (_) => onForceDisconnect());

    activeHub.onclose(({error}) {
      onSignalRRefreshNeeded();
    });

    activeHub.onreconnected(({connectionId}) {
      onSignalRRefreshNeeded();
    });
  }

  Future<void> disconnect() async {
    _fcmSubscription?.cancel();
    _fcmSubscription = null;
    final hub = SignalRService.instance.techHub;
    if (hub == null) return;
    hub.off("OfferRejected");
    hub.off("OfferAccepted");
    hub.off("ForceDisconnect");
  }
}
