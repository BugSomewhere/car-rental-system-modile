import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/network/api_exception.dart';
import 'features/user/data/user_api.dart';
import 'features/user/domain/user_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CarRentalApp());
}

class CarRentalApp extends StatefulWidget {
  const CarRentalApp({super.key});

  @override
  State<CarRentalApp> createState() => _CarRentalAppState();
}

class _CarRentalAppState extends State<CarRentalApp> {
  late final Future<UserApi> _userApi = _createUserApi();

  Future<UserApi> _createUserApi() async {
    final client = await ApiClient.create();
    return UserApi(client);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Car Rental',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: FutureBuilder<UserApi>(
          future: _userApi,
          builder: (context, snapshot) {
            if (snapshot.hasData) return LoginPage(userApi: snapshot.data!);
            if (snapshot.hasError)
              return StartupErrorPage(error: snapshot.error!);
            return const StartupLoadingPage();
          },
        ),
      );
}

class StartupLoadingPage extends StatelessWidget {
  const StartupLoadingPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class StartupErrorPage extends StatelessWidget {
  const StartupErrorPage({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Không thể khởi tạo ứng dụng.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.userApi});
  final UserApi userApi;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.userApi
          .login(email: _email.text.trim(), password: _password.text);
      final profile = await widget.userApi.getProfile();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ProfilePage(userApi: widget.userApi, profile: profile),
      ));
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Car Rental')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Đăng nhập',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Nhập email hợp lệ',
                  ),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                    validator: (value) => value != null && value.length >= 6
                        ? null
                        : 'Mật khẩu cần ít nhất 6 ký tự',
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    child: Text(_loading ? 'Đang đăng nhập...' : 'Đăng nhập'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.userApi, required this.profile});
  final UserApi userApi;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Tài khoản'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await userApi.logout();
                if (context.mounted)
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => LoginPage(userApi: userApi)),
                  );
              },
            ),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Text(profile.fullName,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(profile.email),
          if (profile.phone?.isNotEmpty ?? false) Text(profile.phone!),
          if (profile.roles.isNotEmpty)
            Text('Vai trò: ${profile.roles.join(', ')}'),
        ]),
      );
}
