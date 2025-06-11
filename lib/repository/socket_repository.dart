import 'package:ink_sync/clients/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socket => _socketClient;

  SocketRepository() {
    _socketClient.onConnect((_) {
      print('Socket connected: ${_socketClient.id}');
    });

    _socketClient.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socketClient.onConnectError((data) {
      print('Socket connection error: $data');
    });
  }

  void joinRoom(String documentId) {
    _socketClient.emit('join', documentId);
    print('Joined room $documentId');
  }

  void typing(Map<String, dynamic> data) {
    print('Emitting data: $data');
    _socketClient.emit('typing', data);
  }

  void autoSave(Map<String, dynamic> data) {
    _socketClient.emit('save', data);
    
  }

  void changeListener(Function(Map<String, dynamic> data) func) {
    _socketClient.on('changes', (data) {
      print('Received data: $data');
      func(data);
    });

    void joinMeetingRoom(String roomId, String userId) {
  _socketClient.emit('join-meeting', {
    'roomId': roomId,
    'userId': userId,
  });
}

void sendSignal(String roomId, dynamic signal, String userId) {
  _socketClient.emit('signal', {
    'roomId': roomId,
    'signal': signal,
    'userId': userId,
  });
}

void onUserJoined(Function(dynamic userId) callback) {
  _socketClient.on('user-joined', callback);
}

void onReceiveSignal(Function(Map<String, dynamic>) callback) {
  _socketClient.on('receive-signal', (data) {
    callback(Map<String, dynamic>.from(data));
  });
}

void disconnectMeeting(String roomId, String userId) {
  _socketClient.emit('disconnect-meeting', {
    'roomId': roomId,
    'userId': userId,
  });
}

  }


}
