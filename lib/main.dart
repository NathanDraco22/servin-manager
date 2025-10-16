import 'package:flutter/material.dart';
import 'package:service_manager_front/provider_container.dart';
import 'package:service_manager_front/src/modules/servin/view/servin_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderContainer(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Servin Manager',
        home: ServinScreen(),
      ),
    );
  }
}
