import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/events_page.dart';
import 'pages/individuals_page.dart';
import 'pages/occurrence_page.dart';
import 'pages/splash_page.dart';
import 'theme/app_colors.dart';

class LeopardCatApp extends StatelessWidget {
  const LeopardCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wildlife Intelligence',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Arial',

        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),

        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),

      // Splash menjadi halaman pertama.
      home: const SplashPage(),
    );
  }
}

// ============================================================
// APP SHELL
// ============================================================

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    EventsPage(),
    IndividualsPage(),
    OccurrencePage(),
  ];

  final List<_NavigationItem> _navigationItems = const [
    _NavigationItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    _NavigationItem(label: 'Events', icon: Icons.photo_library_rounded),
    _NavigationItem(label: 'Individuals', icon: Icons.pets_rounded),
    _NavigationItem(label: 'Occurrence', icon: Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return _buildMobileLayout();
        }

        return _buildDesktopLayout();
      },
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _pages[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              _buildSidebarBrand(),

              const SizedBox(height: 30),

              _buildResearchLabel(),

              const SizedBox(height: 9),

              _buildDesktopNavigation(),

              const Spacer(),

              _buildDatasetCard(),

              const SizedBox(height: 12),

              _buildSidebarFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarBrand() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: const Icon(
            Icons.forest_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wildlife',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 1),

              Text(
                'INTELLIGENCE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResearchLabel() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7),
        child: Text(
          'RESEARCH',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNavigation() {
    return Column(
      children: [
        for (int index = 0; index < _navigationItems.length; index++)
          _buildDesktopNavigationItem(
            index: index,
            item: _navigationItems[index],
          ),
      ],
    );
  }

  Widget _buildDesktopNavigationItem({
    required int index,
    required _NavigationItem item,
  }) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryDark : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.12))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),

                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatasetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.storage_rounded,
              color: AppColors.primary,
              size: 15,
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dataset',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  '135 research events',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 8),
                ),

                SizedBox(height: 3),

                Text(
                  '2017 – 2018',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 8),
                ),
              ],
            ),
          ),

          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7),
        child: Text(
          'LEOPARD CAT RESEARCH',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    final _NavigationItem currentItem = _navigationItems[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: _buildMobileAppBar(currentItem),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),

      bottomNavigationBar: _buildMobileNavigation(),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(_NavigationItem currentItem) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 62,
      titleSpacing: 16,

      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.forest_rounded,
              color: AppColors.primary,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wildlife Intelligence',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  currentItem.label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildMobileNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (int index = 0; index < _navigationItems.length; index++)
                Expanded(
                  child: _buildMobileNavigationItem(
                    index: index,
                    item: _navigationItems[index],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavigationItem({
    required int index,
    required _NavigationItem item,
  }) {
    final bool selected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),

            const SizedBox(height: 4),

            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 8,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NAVIGATION ITEM
// ============================================================

class _NavigationItem {
  final String label;
  final IconData icon;

  const _NavigationItem({required this.label, required this.icon});
}
