import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key, required this.url, required this.title, this.onFinishSetupWiFi});

  final String url;
  final String title;
  final VoidCallback? onFinishSetupWiFi;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _isError = false;
  bool _isDisconnectedFromDevice = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Close',
        onMessageReceived: (message) {
          if (message.message == 'close') {
            widget.onFinishSetupWiFi?.call();
            Navigator.of(context).pop(); 
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Có thể cập nhật thanh loading tại đây nếu muốn
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _isError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Chỉ xử lý nếu lỗi xảy ra ở khung chính (Main Frame)
            // để tránh hiện lỗi khi chỉ có 1 hình ảnh nhỏ bị lỗi
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _isError = true;
                  _isLoading = false;
                  _errorMessage = _mapErrorToMessage(error);
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openNetworkSetting() async {
    await AppSettings.openAppSettingsPanel(
      AppSettingsPanelType.internetConnectivity,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
    });
    await controller.reload();
    setState(() {
      _isLoading = false;
    });
  }

  String _mapErrorToMessage(WebResourceError error) {
    final description = error.description.toLowerCase();
    final isArticle = widget.title == 'Tin tức';

    if (description.contains('net::err_address_unreachable') && !isArticle) {
      _isDisconnectedFromDevice = true;
      return 'Không thể kết nối đến thiết bị.\nVui lòng kiểm tra xem bạn đã kết nối vào WiFi của thiết bị và ngắt kết nối mạng di động chưa.';
    }

    return 'Đã xảy ra lỗi kết nối:\n${error.description}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.title,
        automaticallyImplyLeading: false,
        leading: const BackIcon(),
        actions: [
          IconButton(
            icon: Icon(
              Symbols.refresh,
              color: AppColors.mainGreen[200],
              weight: 700,
            ),
            onPressed: _reload,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Không có lỗi
          if (!_isError) WebViewWidget(controller: controller),

          // Lỗi
          if (_isError)
            Center(
              heightFactor: 0.6,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.wifi_off,
                        size: 50,
                        color: Colors.orange,
                        fill: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kết nối thất bại',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage.isNotEmpty
                          ? _errorMessage
                          : 'Vui lòng kiểm tra kết nối mạng',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nút mở cài đặt WiFi
                    if (_isDisconnectedFromDevice)
                      ElevatedButton.icon(
                        onPressed: _openNetworkSetting,
                        icon: Icon(Symbols.network_manage),
                        label: const Text('Cài đặt Mạng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainBlue[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                        ),
                      ),

                    SizedBox(height: 16),
                    // Nút Thử lại
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Symbols.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGreen[200],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
