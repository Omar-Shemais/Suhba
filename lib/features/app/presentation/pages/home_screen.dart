import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamic_app/core/constants/assets.dart';

import '../../../quran/presentation/pages/quran_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';
import '../../../prayer_times/presentation/pages/prayer_times_screen.dart'
    as prayer;
import '../../../community/presentation/pages/premium_community_page.dart';
import '../../../community/presentation/cubits/community/community_cubit.dart';
import '../../../community/community_injector.dart' as community_di;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const prayer.MainHomeScreen(),
    const QuranScreen(),
    BlocProvider.value(
      // Use the singleton instance (won't recreate on rebuild)
      value: community_di.sl<CommunityCubit>(),
      child: const PremiumCommunityPage(),
    ),
    const SettingsScreen(),
  ];

  Widget _buildNavIcon(String assetPath, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context).bottomNavigationBarTheme;

    return SvgPicture.asset(
      assetPath,
      width: 24.w,
      height: 24.h,
      colorFilter: ColorFilter.mode(
        isSelected
            ? (theme.selectedItemColor ?? Colors.orange)
            : (theme.unselectedItemColor ?? Colors.grey),
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(AssetsData.homeIcon, 0),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(AssetsData.quranIcon, 1),
            label: 'quran'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(AssetsData.comunIcon, 2),
            label: 'community'.tr(),
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(AssetsData.settingsIcon, 3),
            label: 'settings'.tr(),
          ),
        ],
      ),
    );
  }
}
