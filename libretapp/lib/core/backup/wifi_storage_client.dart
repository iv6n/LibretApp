import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Aborts Storage transfers when Wi-Fi disappears. Auth remains available
/// over other connections; no archive request is started on cellular.
class WifiStorageClient extends http.BaseClient {
  WifiStorageClient(this._inner, {Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();
  final http.Client _inner;
  final Connectivity _connectivity;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!request.url.path.startsWith('/storage/v1/object/')) return _inner.send(request);
    final abort = Completer<void>();
    final subscription = _connectivity.onConnectivityChanged.listen((networks) {
      if (!networks.contains(ConnectivityResult.wifi) && !abort.isCompleted) abort.complete();
    }, onError: (Object _) { if (!abort.isCompleted) abort.complete(); });
    try {
      if (!(await _connectivity.checkConnectivity()).contains(ConnectivityResult.wifi)) {
        throw http.ClientException('Se requiere Wi-Fi para transmitir copias.', request.url);
      }
      final stream = request.finalize();
      final guarded = _WifiRequest(request, stream, abort.future);
      final response = await _inner.send(guarded);
      Stream<List<int>> body() async* {
        try { yield* response.stream; }
        finally { await subscription.cancel(); }
      }
      return http.StreamedResponse(body(), response.statusCode,
        contentLength: response.contentLength, request: request,
        headers: response.headers, isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
    } catch (_) { await subscription.cancel(); rethrow; }
  }
  @override
  void close() => _inner.close();
}

class _WifiRequest extends http.BaseRequest with http.Abortable {
  _WifiRequest(http.BaseRequest original, this._stream, this.abortTrigger)
      : super(original.method, original.url) {
    headers.addAll(original.headers);
    contentLength = original.contentLength;
    followRedirects = original.followRedirects;
    maxRedirects = original.maxRedirects;
    persistentConnection = original.persistentConnection;
  }
  final http.ByteStream _stream;
  @override
  final Future<void> abortTrigger;
  @override
  http.ByteStream finalize() { super.finalize(); return _stream; }
}
