import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/pressable.dart';
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
  const _BaselineTabBar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.school_outlined, Icons.school_rounded, 'Learn'),
    (Icons.sports_tennis_outlined, Icons.sports_tennis, 'Train'),
    (Icons.place_outlined, Icons.place, 'Discover'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BaselineColors.nightCourt,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: BaselineColors.nightCourt.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: selectedIndex == i,
                      label: _items[i].$3,
                      child: ExcludeSemantics(
                        child: InkResponse(
                          onTap: () {
                            if (selectedIndex != i) tapFeedback();
                            onSelected(i);
                          },
                          radius: 36,
                          highlightShape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(18),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 56),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  width: selectedIndex == i ? 58 : 34,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: selectedIndex == i
                                        ? BaselineColors.ball
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    selectedIndex == i
                                        ? _items[i].$2
                                        : _items[i].$1,
                                    size: 23,
                                    color: selectedIndex == i
                                        ? BaselineColors.nightCourt
                                        : BaselineColors.mist,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _items[i].$3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selectedIndex == i
                                        ? FontWeight.w800
                                        : FontWeight.w600,
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
              ],
            ),
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
    return Tooltip(
      message: 'Search lessons and drills',
      child: Semantics(
        button: true,
        label: 'Search lessons and drills',
        child: ExcludeSemantics(
          child: PressScale(
            child: Material(
              color: BaselineColors.card,
              shape: CircleBorder(
                side: BorderSide(
                  color: BaselineColors.ink.withValues(alpha: 0.08),
                ),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  tapFeedback();
                  context.push('/search');
                },
                child: const SizedBox(
                  width: kMinTapTarget,
                  height: kMinTapTarget,
                  child: Icon(Icons.search_rounded, color: BaselineColors.ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
