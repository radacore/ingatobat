import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import 'family_more_screen.dart';
import 'history_report_screen.dart';
import 'medicines_screen.dart';
import 'today_screen.dart';

/// Cangkang utama dengan navigasi bawah 4 tab (FR-01).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titles = ['Hari Ini', 'Obat & Stok', 'Riwayat', 'Keluarga'];

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingTodayCountProvider);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          TodayScreen(),
          MedicinesScreen(),
          HistoryReportScreen(),
          FamilyMoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.today_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.today),
            ),
            label: _titles[0],
          ),
          const NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Obat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Keluarga',
          ),
        ],
      ),
    );
  }
}
