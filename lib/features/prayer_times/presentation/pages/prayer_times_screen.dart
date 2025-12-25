import 'package:flutter/material.dart';
import '../widgets/main_home_view_body.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: MainHomeViewBody()));
  }
}
