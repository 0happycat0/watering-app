import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watering_app/core/constants/app_assets.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: '...',
    buildNumber: '...',
    buildSignature: '',
    installerStore: null,
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  // Hàm mở URL (Website, Map)
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        CustomSnackBar.showSnackBar(text: 'Không thể mở liên kết');
      }
    }
  }

  // gửi Email
  Future<void> _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Hỗ trợ Smart Watering',
      }),
    );
    if (!await launchUrl(emailLaunchUri)) {
      if (mounted) {
        CustomSnackBar.showSnackBar(text: 'Không thể gửi email');
      }
    }
  }

  // gọi điện
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColors.secondaryGreen[10];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Thông tin ứng dụng',
        leading: BackIcon(),
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Logo & version
            const SizedBox(height: 10),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.mainGreen[150],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Image.asset(AppAssets.splash),
            ),
            const SizedBox(height: 16),
            Text(
              'Smart Watering',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hệ thống tưới cây thông minh',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Phiên bản ${_packageInfo.version}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Về ứng dụng
            _buildInfoCard(
              children: [
                Row(
                  children: [
                    _buildSectionIcon(
                      Symbols.info,
                      AppColors.secondaryGreen[200]!,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Về ứng dụng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Smart Watering là giải pháp tưới cây tự động thông minh, giúp bạn quản lý và điều khiển hệ thống tưới từ xa một cách dễ dàng. Từ đó tiết kiệm thời gian và nâng cao hiệu quả chăm sóc cây trồng.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tính năng chính
            _buildInfoCard(
              children: [
                Text(
                  'Tính năng chính',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureRow('Điều khiển thiết bị từ xa'),
                _buildFeatureRow('Hiển thị dữ liệu thời gian thực'),
                _buildFeatureRow('Lập lịch tưới tự động thông minh'),
                _buildFeatureRow('Giám sát trạng thái thiết bị 24/7'),
                _buildFeatureRow('Nhóm quản lý thiết bị linh hoạt'),
                _buildFeatureRow('Tư vấn chăm sóc cây trồng bằng AI'),
              ],
            ),
            const SizedBox(height: 16),

            // Liên hệ
            _buildInfoCard(
              children: [
                Text(
                  'Liên hệ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactRow(
                  icon: Symbols.mail,
                  title: 'Email',
                  content: AppStrings.supportEmail,
                  onTap: () => _sendEmail(AppStrings.supportEmail),
                ),
                _buildContactRow(
                  icon: Symbols.call,
                  title: 'Hotline',
                  content: AppStrings.hotline,
                  onTap: () => _makePhoneCall(AppStrings.hotline),
                ),
                _buildContactRow(
                  icon: Symbols.location_on,
                  title: 'Địa chỉ',
                  content: AppStrings.address,
                  onTap: () {
                    final String query = Uri.encodeComponent(
                      AppStrings.address,
                    );
                    final String mapUrl =
                        'https://www.google.com/maps/search/?api=1&query=$query';

                    _launchUrl(mapUrl);
                  },
                ),
                _buildContactRow(
                  icon: Symbols.language,
                  title: 'Website',
                  content: AppStrings.website,
                  onTap: () => _launchUrl('https://${AppStrings.website}'),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pháp lý
            _buildInfoCard(
              children: [
                Text(
                  'Pháp lý',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegalRow(
                  icon: Symbols.description,
                  title: 'Điều khoản sử dụng',
                  onTap: () {},
                ),
                _buildLegalRow(
                  icon: Symbols.security,
                  title: 'Chính sách bảo mật',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryGreen[200]!,
                    AppColors.secondaryGreen[300]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainGreen[300]!.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.favorite,
                        color: Colors.white,
                        fill: 1,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'From Smart Watering Team with love',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    '© ${DateTime.now().year} Smart Watering. All rights reserved.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Card
  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Icon header
  Widget _buildSectionIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  // Dòng tính năng
  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.check,
            size: 20,
            color: AppColors.secondaryGreen[200],
            weight: 600,
            fill: 1,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dòng liên hệ
  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreen[200]!.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.secondaryGreen[200],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryGreen[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dòng pháp lý
Widget _buildLegalRow({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isLast = false,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Symbols.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    ),
  );
}
