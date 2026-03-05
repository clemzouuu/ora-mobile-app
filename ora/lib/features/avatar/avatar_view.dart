import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AvatarView extends StatefulWidget {
  const AvatarView({super.key});

  @override
  State<AvatarView> createState() => _AvatarViewState();
}

class _AvatarViewState extends State<AvatarView> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/avatar/avatar.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Avatar")),
      body: WebViewWidget(controller: controller),
    );
  }
}