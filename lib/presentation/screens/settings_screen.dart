import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/alarm_service.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';

/// Pengaturan tampilan, aksesibilitas, alarm, dan suara (FR-10, FR-13).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    _detectTts();
  }

  Future<void> _detectTts() async {
    try {
      final ok = await AlarmService.isTtsAvailable();
      if (!mounted) return;
      if (ok != ref.read(appSettingsProvider).ttsAvailable) {
        await ref.read(appSettingsProvider.notifier).setTtsAvailable(ok);
      }
    } catch (_) {}
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickTone() async {
    List<Map<String, String>> tones;
    try {
      tones = await AlarmService.getAlarmTones();
    } catch (_) {
      tones = const [];
    }
    if (!mounted) return;
    final p = context.palette;
    final picked = await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Pilih Nada Alarm',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: p.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const SoftIcon(icon: Icons.music_note, color: Colors.grey),
              title: const Text('Nada bawaan sistem'),
              subtitle: const Text('Alarm default perangkat'),
              onTap: () => Navigator.pop(
                  ctx, const {'title': 'Nada bawaan sistem', 'uri': ''}),
            ),
            ...tones.map((t) => ListTile(
                  leading: const Icon(Icons.library_music_outlined),
                  title: Text(t['title'] ?? ''),
                  onTap: () => Navigator.pop(ctx, t),
                )),
            if (tones.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Daftar nada hanya tersedia di perangkat Android.',
                  style: TextStyle(color: p.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await ref.read(appSettingsProvider.notifier).setAlarmTone(
          picked['uri'] ?? '',
          picked['title'] ?? 'Nada bawaan sistem',
        );
  }

  Future<void> _preview() async {
    final s = ref.read(appSettingsProvider);
    try {
      await AlarmService.previewAlarm(
          toneUri: s.alarmTone, volume: s.alarmVolumePreview);
      setState(() => _previewing = true);
    } catch (e) {
      _snack('Pratinjau hanya tersedia di perangkat Android.');
    }
  }

  Future<void> _stopPreview() async {
    try {
      await AlarmService.stopPreview();
    } catch (_) {}
    if (mounted) setState(() => _previewing = false);
  }

  Future<void> _testAlarm() async {
    final s = ref.read(appSettingsProvider);
    try {
      await AlarmService.startAlarmNow(
        title: 'Uji Coba Alarm ${AppInfo.appName}',
        body: 'Ini contoh tampilan alarm minum obat.',
        ttsEnabled: s.ttsEnabled,
        ttsText: 'Waktunya minum obat. Ini uji coba alarm.',
        toneUri: s.alarmTone,
      );
    } catch (_) {
      _snack('Uji alarm hanya tersedia di perangkat Android.');
    }
  }

  Future<void> _testTts() async {
    try {
      await AlarmService.testTts('Waktunya minum obat. Ini contoh suara pengingat.');
    } catch (_) {
      _snack('Suara pengingat hanya tersedia di perangkat Android.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = ref.watch(appSettingsProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final modes = ref.watch(alarmModesProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xxl),
        children: [
          const SectionHeader('Tampilan & Aksesibilitas'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ukuran huruf',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: p.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perbesar huruf agar lebih mudah dibaca.',
                    style: TextStyle(fontSize: 13, color: p.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<FontScale>(
                      segments: FontScale.values
                          .map((f) => ButtonSegment<FontScale>(
                                value: f,
                                label: Text(f.label),
                              ))
                          .toList(),
                      selected: {s.fontScale},
                      showSelectedIcon: false,
                      onSelectionChanged: (set) => ref
                          .read(appSettingsProvider.notifier)
                          .setFontScale(set.first),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: s.largeButtons,
                  onChanged: (v) =>
                      ref.read(appSettingsProvider.notifier).setLargeButtons(v),
                  title: const Text('Tombol besar'),
                  subtitle: const Text('Tombol lebih tinggi untuk mudah ditekan'),
                  secondary: SoftIcon(icon: Icons.touch_app_rounded, color: p.primary),
                ),
                Divider(height: 1, color: p.divider),
                SwitchListTile(
                  value: s.highContrast,
                  onChanged: (v) =>
                      ref.read(appSettingsProvider.notifier).setHighContrast(v),
                  title: const Text('Kontras tinggi'),
                  subtitle: const Text('Latar hitam & teks kuning agar jelas'),
                  secondary: SoftIcon(icon: Icons.contrast_rounded, color: p.primary),
                ),
              ],
            ),
          ),
          const SectionHeader('Alarm & Suara'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: SoftIcon(icon: Icons.music_note_rounded, color: p.primary),
                  title: const Text('Nada alarm'),
                  subtitle: Text(s.alarmToneTitle),
                  trailing: Icon(Icons.chevron_right, color: p.textHint),
                  onTap: _pickTone,
                ),
                Divider(height: 1, color: p.divider),
                ListTile(
                  leading: SoftIcon(icon: Icons.volume_up_rounded, color: p.primary),
                  title: const Text('Volume pratinjau'),
                  subtitle: Text('${s.alarmVolumePreview}%'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
                  child: Slider(
                    value: s.alarmVolumePreview.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${s.alarmVolumePreview}%',
                    onChanged: (v) => ref
                        .read(appSettingsProvider.notifier)
                        .setAlarmVolumePreview(v.round()),
                  ),
                ),
                Divider(height: 1, color: p.divider),
                ListTile(
                  leading: SoftIcon(icon: Icons.snooze_rounded, color: p.primary),
                  title: const Text('Tunda bawaan'),
                  trailing: DropdownButton<int>(
                    value: s.snoozeDefault,
                    underline: const SizedBox.shrink(),
                    items: const [5, 10, 15, 20, 30]
                        .map((m) => DropdownMenuItem<int>(
                              value: m,
                              child: Text('$m menit'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setSnoozeDefault(v);
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: p.divider),
                SwitchListTile(
                  value: s.ttsEnabled,
                  onChanged: s.ttsAvailable
                      ? (v) =>
                          ref.read(appSettingsProvider.notifier).setTtsEnabled(v)
                      : null,
                  title: const Text('Suara pengingat (TTS)'),
                  subtitle: Text(s.ttsAvailable
                      ? 'Membacakan nama obat saat alarm berbunyi'
                      : 'Tidak tersedia di perangkat ini'),
                  secondary: SoftIcon(
                      icon: Icons.record_voice_over_rounded, color: p.primary),
                ),
                if (s.ttsEnabled && s.ttsAvailable) ...[
                  Divider(height: 1, color: p.divider),
                  ListTile(
                    leading: SoftIcon(
                        icon: Icons.play_circle_outline_rounded, color: p.accent),
                    title: const Text('Coba suara pengingat'),
                    onTap: _testTts,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _testAlarm,
                    icon: const Icon(Icons.alarm_on_rounded),
                    label: const Text('Uji Alarm'),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previewing ? _stopPreview : _preview,
                    icon: Icon(_previewing
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded),
                    label: Text(_previewing ? 'Hentikan' : 'Dengar Nada'),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader('Mode Alarm Anggota'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Text(
                'Atur di HP ini: anggota mana yang perlu membunyikan alarm keras, '
                'dan siapa yang cukup dipantau.',
                style: TextStyle(
                    fontSize: 13, height: 1.4, color: p.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (members.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Belum ada anggota keluarga.',
                    style: TextStyle(color: p.textSecondary)),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < members.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: p.divider),
                    ListTile(
                      leading: MemberAvatar(
                        name: members[i].name,
                        avatarPath: members[i].avatarPath,
                        thumbB64: members[i].avatarThumbB64,
                        size: 40,
                      ),
                      title: Text(members[i].name),
                      subtitle: Text(modes[members[i].id] == 'full_alarm'
                          ? 'Alarm keras'
                          : 'Pantau saja'),
                      trailing: DropdownButton<String>(
                        value: modes[members[i].id] ?? 'monitor_only',
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                              value: 'full_alarm', child: Text('Alarm keras')),
                          DropdownMenuItem(
                              value: 'monitor_only', child: Text('Pantau saja')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            ref
                                .read(repositoryProvider)
                                .setAlarmMode(members[i].id, v);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SectionHeader('Tentang'),
          Card(
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.info_outline_rounded,
                  title: '${AppInfo.appName} ${AppInfo.version}',
                  subtitle: 'Gratis selamanya • Data tersimpan di perangkat',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
