import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vikunja_app/global.dart';
import 'package:vikunja_app/pages/home.dart';
import 'package:vikunja_app/pages/user/login.dart';
import 'package:vikunja_app/theme/theme.dart';
import 'package:http/http.dart';

class IgnoreCertHttpOverrides extends HttpOverrides {
  bool ignoreCerts = false;
  IgnoreCertHttpOverrides(bool  _ignore) {ignoreCerts = _ignore;}
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, __, ___) => ignoreCerts;
  }
}

void main() {
    runApp(VikunjaGlobal(
        child: new VikunjaApp(home: HomePage(), key: UniqueKey(),),
        login: new VikunjaApp(home: LoginPage(), key: UniqueKey(),)));
}


class VikunjaApp extends StatelessWidget {
  final Widget home;

  const VikunjaApp({Key? key, required this.home}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Vikunja',
      theme: buildVikunjaTheme(),
      darkTheme: buildVikunjaDarkTheme(),
      scaffoldMessengerKey: VikunjaGlobal.of(context).snackbarKey, // <= this
      home: this.home,
    );
  }
}
