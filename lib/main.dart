import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? _webViewController;
  final Set<InAppWebViewController> _popupWebViews = {};

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 뒤로 가기 버튼을 처리할 때 호출되는 함수
      onWillPop: () async {
        if (_webViewController != null &&
            await _webViewController!.canGoBack()) {
          // 웹뷰에서 뒤로 가기가 가능한 경우 웹뷰에서 페이지를 뒤로 이동
          _webViewController!.goBack();
          return false; // 뒤로 가기 이벤트 막음
        }
        return true; // 앱 종료 (뒤로 가기 이벤트 허용)
      },
      child: Scaffold(
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse('https://first-drive-jwt.vercel.app/login'),
              ),
              initialOptions: InAppWebViewGroupOptions(
                android: AndroidInAppWebViewOptions(
                  allowContentAccess: true,
                  builtInZoomControls: true,
                  thirdPartyCookiesEnabled: true,
                  allowFileAccess: true,
                  supportMultipleWindows: true,
                ),
                crossPlatform: InAppWebViewOptions(
                  verticalScrollBarEnabled: true,
                  clearCache: true,
                  disableContextMenu: false,
                  cacheEnabled: true,
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  transparentBackground: true,
                ),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              onCreateWindow: (controller, createWindowRequest) async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: InAppWebView(
                          // Setting the windowId property is important here!
                          windowId: createWindowRequest.windowId,
                          initialOptions: InAppWebViewGroupOptions(
                            android: AndroidInAppWebViewOptions(
                                builtInZoomControls: true,
                                thirdPartyCookiesEnabled: true,
                                useWideViewPort: true),
                            crossPlatform: InAppWebViewOptions(
                              cacheEnabled: true,
                              javaScriptEnabled: true,
                              userAgent:
                                  "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
                            ),
                          ),
                          onWebViewCreated:
                              (InAppWebViewController controller) {},
                          onCloseWindow: (controller) {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
                return true;
              },
            ),
            for (var webView in _popupWebViews)
              Positioned.fill(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse('about:blank'),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    controller.loadUrl(
                        urlRequest: URLRequest(url: Uri.parse('about:blank')));
                    _webViewController = controller;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
