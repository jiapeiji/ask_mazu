// lib/features/main_shell.dart
// 底部 3 tab 容器(反思 / 记录 / 妈祖)
//
// V1.2 (v5):
//   - 反思(reflect) — V1 home_page 改造后的反思主流程
//   - 记录(records) — V1.2 records_page 日记流
//   - 妈祖(mazu) — V1.2 占位页(章节阅读推迟到 V2)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _Tab('/reflect', '反思', Icons.self_improvement_outlined, Icons.self_improvement),
    _Tab('/records', '记录', Icons.history_outlined, Icons.history),
    _Tab('/mazu', '妈祖', Icons.temple_hindu_outlined, Icons.temple_hindu),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexOfLocation(location);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.riceWhite,
          border: Border(top: BorderSide(color: AppColors.lightGray, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                for (int i = 0; i < _tabs.length; i++)
                  Expanded(child: _TabButton(
                    tab: _tabs[i],
                    selected: i == currentIndex,
                    onTap: () => context.go(_tabs[i].path),
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _indexOfLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }
}

class _Tab {
  final String path;
  final String label;
  final IconData icon;
  final IconData iconActive;
  const _Tab(this.path, this.label, this.icon, this.iconActive);
}

class _TabButton extends StatelessWidget {
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? tab.iconActive : tab.icon,
            size: 24,
            color: selected ? AppColors.mazuRed : AppColors.gray,
          ),
          const SizedBox(height: 4),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? AppColors.mazuRed : AppColors.gray,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'ChillJinshuSong',
            ),
          ),
        ],
      ),
    );
  }
}