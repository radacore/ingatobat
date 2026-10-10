import 'dart:io';

import 'package:drift/drift.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/utils/dates.dart';
import '../../data/database/app_database.dart';

/// Rekap kepatuhan (FR-08) satu anggota dalam rentang tanggal.
class ComplianceReport {
  final Member member;
  final DateTime from;
  final DateTime to;
  final List<DoseLog> logs;
  final List<SideEffect> sideEffects;
  final List<ControlVisit> upcomingVisits;
  final Map<String, Medicine> medicines;

  ComplianceReport({
    required this.member,
    required this.from,
    required this.to,
    required this.logs,
    required this.sideEffects,
    required this.upcomingVisits,
    required this.medicines,
  });

  int get total => logs.length;
  int count(String s) => logs.where((l) => l.status == s).length;
  int get taken => count('taken');
  int get missed => count('missed');
  int get skipped => count('skipped');
  int get snoozed => count('snoozed');
  int get pending => count('pending');

  /// Persentase tepat waktu = taken / (total terjadwal yang sudah lewat).
  double get onTimePercent {
    final relevant = total - pending;
    if (relevant <= 0) return 0;
    return (taken / relevant) * 100;
  }

  String medicineName(String id) => medicines[id]?.name ?? '-';
}

class ReportService {
  final AppDatabase db;
  ReportService(this.db);

  Future<ComplianceReport> build(
    String memberId,
    DateTime from,
    DateTime to,
  ) async {
    final member = await db.getMember(memberId);
    final logs = await (db.select(db.doseLogs)
          ..where((t) =>
              t.memberId.equals(memberId) &
              t.scheduledAt.isBiggerOrEqualValue(Dates.startOfDayMs(from)) &
              t.scheduledAt.isSmallerThanValue(Dates.endOfDayMs(to)))
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)]))
        .get();
    final sideEffects = await (db.select(db.sideEffects)
          ..where((t) =>
              t.memberId.equals(memberId) &
              t.occurredAt.isBiggerOrEqualValue(Dates.startOfDayMs(from)) &
              t.occurredAt.isSmallerThanValue(Dates.endOfDayMs(to)))
          ..orderBy([(t) => OrderingTerm(expression: t.occurredAt)]))
        .get();
    final visits = await (db.select(db.controlVisits)
          ..where((t) =>
              t.memberId.equals(memberId) &
              t.status.equals('upcoming') &
              t.visitAt.isBiggerOrEqualValue(Dates.startOfDayMs(DateTime.now())))
          ..orderBy([(t) => OrderingTerm(expression: t.visitAt)]))
        .get();
    final meds = await db.select(db.medicines).get();

    return ComplianceReport(
      member: member ?? _fallbackMember(memberId),
      from: from,
      to: to,
      logs: logs,
      sideEffects: sideEffects,
      upcomingVisits: visits,
      medicines: {for (final m in meds) m.id: m},
    );
  }

  Member _fallbackMember(String id) => Member(
        id: id,
        name: 'Anggota',
        isArchived: false,
        createdAt: 0,
        updatedAt: 0,
      );

  // ------------------------------------------------------------------- CSV

  String toCsv(ComplianceReport r) {
    final b = StringBuffer();
    b.writeln('Laporan Kepatuhan Minum Obat - ${r.member.name}');
    b.writeln('Rentang;${Dates.dateFull(r.from)} - ${Dates.dateFull(r.to)}');
    b.writeln('');
    b.writeln('Total Terjadwal;${r.total}');
    b.writeln('Sudah Minum;${r.taken}');
    b.writeln('Terlewat;${r.missed}');
    b.writeln('Dilewati;${r.skipped}');
    b.writeln('Ditunda;${r.snoozed}');
    b.writeln('Tepat Waktu (%);${r.onTimePercent.toStringAsFixed(1)}');
    b.writeln('');
    b.writeln('Tanggal;Jam;Anggota;Obat;Takaran;Status;Oleh;Catatan');
    for (final l in r.logs) {
      final med = r.medicines[l.medicineId];
      final qty = med?.doseQty;
      final qtyText = qty == null
          ? ''
          : (qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toString());
      b.writeln([
        Dates.dateFull(DateTime.fromMillisecondsSinceEpoch(l.scheduledAt)),
        Dates.time(DateTime.fromMillisecondsSinceEpoch(l.scheduledAt)),
        r.member.name,
        med?.name ?? '-',
        '$qtyText ${med?.unit ?? ''}'.trim(),
        doseStatusLabel(l.status),
        l.actionByEmail ?? '-',
        (l.note ?? '').replaceAll(';', ','),
      ].join(';'));
    }
    if (r.sideEffects.isNotEmpty) {
      b.writeln('');
      b.writeln('Efek Samping');
      b.writeln('Tanggal;Obat;Jenis;Tingkat;Catatan');
      for (final s in r.sideEffects) {
        final kind = s.kind == 'kustom' ? (s.customKind ?? 'Lainnya') : s.kind;
        b.writeln([
          Dates.dateFull(DateTime.fromMillisecondsSinceEpoch(s.occurredAt)),
          r.medicines[s.medicineId]?.name ?? '-',
          kind,
          s.severity,
          (s.note ?? '').replaceAll(';', ','),
        ].join(';'));
      }
    }
    return b.toString();
  }

  Future<File> writeCsv(ComplianceReport r) async {
    final dir = await getApplicationDocumentsDirectory();
    final reports = Directory('${dir.path}/reports');
    if (!await reports.exists()) await reports.create(recursive: true);
    final file = File(
        '${reports.path}/laporan_${r.member.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(toCsv(r));
    return file;
  }

  Future<void> shareCsv(ComplianceReport r) async {
    final file = await writeCsv(r);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Laporan Kepatuhan ${r.member.name}',
    ));
  }

  // ------------------------------------------------------------------- PDF

  Future<File> writePdf(ComplianceReport r) async {
    final doc = pw.Document();
    final teal = PdfColor.fromHex('#00897B');
    final blue = PdfColor.fromHex('#1565C0');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Laporan Kepatuhan Minum Obat',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold, color: blue)),
                pw.Text(AppInfo.appName,
                    style: pw.TextStyle(fontSize: 12, color: teal)),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Anggota: ${r.member.name}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text('Rentang: ${Dates.dateFull(r.from)} - ${Dates.dateFull(r.to)}'),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Total',
              'Sudah Minum',
              'Terlewat',
              'Dilewati',
              'Ditunda',
              'Tepat Waktu'
            ],
            data: [
              [
                '${r.total}',
                '${r.taken}',
                '${r.missed}',
                '${r.skipped}',
                '${r.snoozed}',
                '${r.onTimePercent.toStringAsFixed(1)}%',
              ]
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: blue),
            cellAlignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 16),
          pw.Text('Rincian Riwayat Minum',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: const ['Tanggal', 'Jam', 'Obat', 'Takaran', 'Status', 'Oleh'],
            data: r.logs
                .map((l) => [
                      Dates.dateFull(DateTime.fromMillisecondsSinceEpoch(l.scheduledAt)),
                      Dates.time(DateTime.fromMillisecondsSinceEpoch(l.scheduledAt)),
                      r.medicines[l.medicineId]?.name ?? '-',
                      r.medicines[l.medicineId] == null
                          ? '-'
                          : '${r.medicines[l.medicineId]!.doseQty} ${r.medicines[l.medicineId]!.unit}',
                      doseStatusLabel(l.status),
                      l.actionByEmail ?? '-',
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: teal),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerCellDecoration: const pw.BoxDecoration(),
          ),
          if (r.sideEffects.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Catatan Efek Samping',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: const ['Tanggal', 'Obat', 'Jenis', 'Tingkat', 'Catatan'],
              data: r.sideEffects
                  .map((s) => [
                        Dates.dateFull(DateTime.fromMillisecondsSinceEpoch(s.occurredAt)),
                        r.medicines[s.medicineId]?.name ?? '-',
                        s.kind == 'kustom' ? (s.customKind ?? 'Lainnya') : s.kind,
                        s.severity,
                        s.note ?? '-',
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: blue),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ],
          if (r.upcomingVisits.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Jadwal Kontrol RS Mendatang',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: const ['Tanggal', 'Jam', 'RS/Klinik', 'Dokter'],
              data: r.upcomingVisits
                  .map((v) => [
                        Dates.dateFull(DateTime.fromMillisecondsSinceEpoch(v.visitAt)),
                        Dates.time(DateTime.fromMillisecondsSinceEpoch(v.visitAt)),
                        v.hospital,
                        v.doctor ?? '-',
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: teal),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Text(
            'Dibuat otomatis oleh ${AppInfo.appName} pada ${Dates.dateTimeFull(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final reports = Directory('${dir.path}/reports');
    if (!await reports.exists()) await reports.create(recursive: true);
    final file = File(
        '${reports.path}/laporan_${r.member.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> sharePdf(ComplianceReport r) async {
    final file = await writePdf(r);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Laporan Dokter ${r.member.name}',
    ));
  }
}
