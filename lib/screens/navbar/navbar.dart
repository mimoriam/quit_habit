import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/community/community_home_screen.dart';
import 'package:quit_habit/screens/navbar/goals/goals_screen.dart';
import 'package:quit_habit/screens/navbar/home/home_screen.dart';
import 'package:quit_habit/screens/navbar/plan/plan_screen.dart';
import 'package:quit_habit/screens/navbar/profile/profile_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    PersistentTabController controller = PersistentTabController(initialIndex: 0);

    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      backgroundColor: AppColors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(0),
        colorBehindNavBar: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight + 8,
      navBarStyle: NavBarStyle.style6,
    );
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const GoalsScreen(),
      const CommunityHomeScreen(),
      const PlanScreen(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_rounded),
        title: "Home",
        activeColorPrimary: AppColors.lightPrimary,
        inactiveColorPrimary: AppColors.lightTextTertiary,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.rounded_corner),
        title: "Challenges",
        activeColorPrimary: AppColors.lightPrimary,
        inactiveColorPrimary: AppColors.lightTextTertiary,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.people_rounded),
        title: "Community",
        activeColorPrimary: AppColors.lightPrimary,
        inactiveColorPrimary: AppColors.lightTextTertiary,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.calendar_today_rounded),
        title: "Plan",
        activeColorPrimary: AppColors.lightPrimary,
        inactiveColorPrimary: AppColors.lightTextTertiary,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_rounded),
        title: "Profile",
        activeColorPrimary: AppColors.lightPrimary,
        inactiveColorPrimary: AppColors.lightTextTertiary,
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
  }
}