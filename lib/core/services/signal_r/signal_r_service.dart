import 'package:signalr_netcore/signalr_client.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';

class SignalRService {
  static final SignalRService instance = SignalRService._internal();
  factory SignalRService() => instance;
  SignalRService._internal();

  HubConnection? chatHub;
  HubConnection? clientHub;
  HubConnection? techHub;

  Future<void> initAndConnect() async {
    disconnect();

    String? token = await AuthLocalStorage().getToken();
    String? userType = await AuthLocalStorage().getUserType();

    if (token == null || token.isEmpty) return;

    chatHub = _buildHub("https://el7rafeapp.azurewebsites.net/chatHub", token);

    if (userType == "C") {
      clientHub =
          _buildHub("https://el7rafeapp.azurewebsites.net/clientHub", token);
    } else if (userType == "T") {
      techHub = _buildHub(
          "https://el7rafeapp.azurewebsites.net/technicianHub?access_token=${Uri.encodeComponent(token)}",
          token);
    }

    try {
      if (chatHub?.state == HubConnectionState.Disconnected) {
        await chatHub?.start();
      }
    } catch (_) {}

    try {
      if (clientHub?.state == HubConnectionState.Disconnected) {
        await clientHub?.start();
      }
    } catch (_) {}

    try {
      if (techHub?.state == HubConnectionState.Disconnected) {
        await techHub?.start();
      }
    } catch (_) {}
  }

  HubConnection _buildHub(String url, String token) {
    return HubConnectionBuilder()
        .withUrl(url,
            options:
                HttpConnectionOptions(accessTokenFactory: () async => token))
        .withAutomaticReconnect()
        .build();
  }

  void disconnect() {
    chatHub?.stop();
    clientHub?.stop();
    techHub?.stop();
    chatHub = null;
    clientHub = null;
    techHub = null;
  }
}
