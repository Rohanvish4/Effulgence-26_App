import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminWebPage extends StatefulWidget {
  const AdminWebPage({super.key});

  @override
  State<AdminWebPage> createState() => _AdminWebPageState();
}

class _AdminWebPageState extends State<AdminWebPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // 1. Initialize Controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.bgPrimary)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      );

    // 2. Sync Cookies
    await _syncCookies();

    // 3. Load Page
    _controller.loadRequest(Uri.parse('${AppEnv.websiteBaseUrl}/profile'));

    if (mounted) {
      setState(() {
        _isInit = true;
      });
    }
  }

  Future<void> _syncCookies() async {
    try {
      final cookieJar = context.read<PersistCookieJar>();
      final cookieManager = WebViewCookieManager();

      // Get cookies for the domain
      // Note: We use the API domain or the root domain depending on where the cookie is set
      // Try both to be safe
      final uri = Uri.parse(AppEnv.apiBaseUrl);
      final cookies = await cookieJar.loadForRequest(uri);

      if (cookies.isNotEmpty) {
        for (final cookie in cookies) {
          await cookieManager.setCookie(
            WebViewCookie(
              name: cookie.name,
              value: cookie.value,
              // Set domain to the main domain so it's accessible by the web app
              domain: '.${Uri.parse(AppEnv.websiteBaseUrl).host}',
              path: '/',
            ),
          );
        }
        debugPrint('Synced ${cookies.length} cookies to WebView');
      }
    } catch (e) {
      debugPrint('Error syncing cookies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(
          'ADMIN CONSOLE',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: AppColors.bgPrimary,
        iconTheme: const IconThemeData(color: AppColors.primary),
        elevation: 0,
      ),
      body: !_isInit
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
              ],
            ),
    );
  }
}
