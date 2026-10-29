import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<String?> requestCaptcha(BuildContext context) async {
  const url = String.fromEnvironment('LIBRET_CAPTCHA_URL');
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    throw StateError('Falta configurar la verificación CAPTCHA del servicio.');
  }
  return showModalBottomSheet<String>(context: context, useRootNavigator: true,
    useSafeArea: true, isScrollControlled: true,
    builder: (_) => _CaptchaSheet(uri: uri));
}

class _CaptchaSheet extends StatefulWidget {
  const _CaptchaSheet({required this.uri});
  final Uri uri;
  @override
  State<_CaptchaSheet> createState() => _CaptchaSheetState();
}

class _CaptchaSheetState extends State<_CaptchaSheet> {
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('LibretCaptcha', onMessageReceived: (message) {
        if (mounted && message.message.isNotEmpty && message.message.length <= 4096) {
          Navigator.pop(context, message.message);
        }
      })
      ..setNavigationDelegate(NavigationDelegate(onNavigationRequest: (request) {
        final uri = Uri.tryParse(request.url);
        return uri?.scheme == 'https' &&
            (uri?.host == widget.uri.host || uri?.host == 'challenges.cloudflare.com')
            ? NavigationDecision.navigate : NavigationDecision.prevent;
      }))
      ..loadRequest(widget.uri);
  }
  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * .65,
    child: Column(children: [
      ListTile(title: const Text('Verifica que eres una persona'),
        trailing: IconButton(icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context))),
      Expanded(child: WebViewWidget(controller: _controller)),
    ]),
  );
}
