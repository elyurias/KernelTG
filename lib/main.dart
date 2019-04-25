import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/home.dart';
import './scoped-models/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            accentColor: Colors.blueAccent,
            buttonColor: Colors.blueAccent),
        // home: AuthPage(),
        routes: {
          '/': (BuildContext context) =>
          !_isAuthenticated ? AuthPage() : HomePage(_model),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : HomePage(_model));
        },
      ),
    );
  }
}
