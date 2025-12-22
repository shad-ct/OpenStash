import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'app/app_shell.dart';
import 'theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.apiClient,
  });

  final ApiClient? apiClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Openstash',
      debugShowCheckedModeBanner: false,
      theme: buildOpenstashTheme(),
      home: AppShell(apiClient: apiClient),
    );
  }
}
