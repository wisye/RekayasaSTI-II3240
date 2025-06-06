import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:reksti_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:reksti_app/app.dart';
import 'package:reksti_app/user_provider.dart';

const String lastActiveRouteKey = 'last_active_route';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final prefs = await SharedPreferences.getInstance();
  final TokenStorageService tokenStorage = TokenStorageService();

  String determinedInitialRoute = '/login';
  String? sessionUsername;

  try {
    String? token = await tokenStorage.getAccessToken();
    String? username = await tokenStorage.getUsername();

    if (token != null &&
        username != null &&
        username.isNotEmpty &&
        !JwtDecoder.isExpired(token)) {
      sessionUsername = username;

      determinedInitialRoute = prefs.getString(lastActiveRouteKey) ?? '/home';
    } else {
      await tokenStorage.deleteAllTokens();
      await prefs.remove(lastActiveRouteKey);
    }
  } catch (e) {
    await tokenStorage.deleteAllTokens();
    await prefs.remove(lastActiveRouteKey);
    determinedInitialRoute = '/login';
    sessionUsername = null;
  }

  final userProvider = UserProvider();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: userProvider)],
      child: MyApp(
        initialRoute: determinedInitialRoute,
        sessionUsername: sessionUsername,
      ),
    ),
  );
}
