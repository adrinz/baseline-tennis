import 'package:baseline/theme/baseline_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BaselineTabBar(
        selectedIndex: navigationShell.currentIndex,
        onSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _BaselineTabBar extends StatelessWidget {
  const _BaselineTabBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.school_outlined, 'Learn'),
    (Icons.sports_tennis_outlined, 'Train'),
    (Icons.place_outlined, 'Discover'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaselineColors.nightCourt,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: BaselineColors.line.withValues(alpha: 0.24),
              width: 2,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selectedIndex == i,
                    label: _items[i].$2,
                    child: ExcludeSemantics(
                      child: InkWell(
                        onTap: () => onSelected(i),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 56),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: selectedIndex == i
                                        ? BaselineColors.ball
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Icon(
                                  _items[i].$1,
                                  size: 24,
                                  color: selectedIndex == i
                                      ? BaselineColors.line
                                      : BaselineColors.mist,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _items[i].$2,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selectedIndex == i
                                        ? BaselineColors.line
                                        : BaselineColors.mist,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchIconButton extends StatelessWidget {
  const SearchIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Search lessons and drills',
      constraints: const BoxConstraints(
        minWidth: kMinTapTarget,
        minHeight: kMinTapTarget,
      ),
      onPressed: () => context.push('/search'),
      icon: const Icon(Icons.search),
    );
  }
}
