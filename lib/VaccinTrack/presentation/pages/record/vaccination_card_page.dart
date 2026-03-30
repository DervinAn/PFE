import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../domain/entities/user_entity.dart';
import '../../widgets/common/common_widgets.dart';

class VaccinationCardPage extends StatelessWidget {
  final String childId;
  const VaccinationCardPage({super.key, required this.childId});

  Future<Map<String, dynamic>> _loadCardData() async {
    final child = await LocalAppStorage.instance.getChildById(childId);
    final records = await LocalAppStorage.instance.getVaccinationHistory(
      childId: childId,
    );

    final lastUpdated = records.isNotEmpty
        ? records.first.administeredDate
        : null;

    return {
      'childName': child?.name ?? 'Unknown Child',
      'dob': child?.dateOfBirth,
      'records': records,
      'lastUpdated': lastUpdated,
      'recordId': 'VT-$childId',
    };
  }

  String _dateLabel(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<Uint8List> _buildPdfBytes() async {
    final data = await _loadCardData();
    final childName = data['childName'] as String;
    final dob = data['dob'] as DateTime?;
    final records = data['records'] as List<VaccinationRecordEntity>;
    final recordId = data['recordId'] as String;

    final tableData = records.isEmpty
        ? [
            ['No vaccination records yet', '-', '-', '-', '-'],
          ]
        : records.map((r) {
            return [
              r.vaccineName,
              r.doseLabel,
              _dateLabel(r.administeredDate),
              r.clinicName ?? '-',
              r.notes ?? '-',
            ];
          }).toList();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'VacciTrack - Vaccination Card',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Child: $childName'),
          pw.Text('DOB: ${dob != null ? _dateLabel(dob) : 'Unknown'}'),
          pw.Text('Record ID: $recordId'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Vaccine', 'Dose', 'Date', 'Clinic', 'Notes'],
            data: tableData,
          ),
        ],
      ),
    );
    return pdf.save();
  }

  Future<void> _printCard(BuildContext context) async {
    try {
      final bytes = await _buildPdfBytes();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to print vaccination card')),
      );
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = await _buildPdfBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'vaccination_card_$childId.pdf',
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export vaccination card')),
      );
    }
  }

  Color _statusBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('administered') || s.contains('complete')) {
      return AppColors.successLight;
    }
    if (s.contains('overdue')) return AppColors.errorLight;
    if (s.contains('due')) return AppColors.warningLight;
    return AppColors.primaryLight;
  }

  Color _statusFg(String status) {
    final s = status.toLowerCase();
    if (s.contains('administered') || s.contains('complete')) {
      return AppColors.success;
    }
    if (s.contains('overdue')) return AppColors.error;
    if (s.contains('due')) return AppColors.warning;
    return AppColors.primary;
  }

  String _statusLabel(String status) {
    final s = status.toLowerCase();
    if (s.contains('administered')) return 'DONE';
    if (s.contains('complete')) return 'DONE';
    if (s.contains('overdue')) return 'OVERDUE';
    if (s.contains('due')) return 'DUE';
    return status.toUpperCase();
  }

  List<Widget> _recordRows(List<VaccinationRecordEntity> records) {
    if (records.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: Text(
            'No vaccination records yet.',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ];
    }

    return records.map((r) {
      final status = _statusLabel(r.status);
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.vaccineName,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Lot: ${r.lotNumber ?? '-'}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontXs,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                _dateLabel(r.administeredDate),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.doseLabel,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg(r.status),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXs),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w700,
                        color: _statusFg(r.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCard(Map<String, dynamic> data) {
    final childName = data['childName'] as String;
    final dob = data['dob'] as DateTime?;
    final lastUpdated = data['lastUpdated'] as DateTime?;
    final records = data['records'] as List<VaccinationRecordEntity>;
    final recordId = data['recordId'] as String;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                AppAvatar(name: childName, size: 60),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PATIENT NAME',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        childName,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXxl,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        'ID: $recordId • DOB: ${dob != null ? _dateLabel(dob) : 'Unknown'}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontSm,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Row(
                        children: const [
                          Icon(
                            Icons.verified,
                            color: Colors.greenAccent,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'VACCITRACK VERIFIED',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w700,
                              color: Colors.greenAccent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Last Updated: ${lastUpdated != null ? _dateLabel(lastUpdated) : '-'}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              0,
              AppSizes.md,
              AppSizes.md,
            ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 48,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSizes.radiusLg),
                bottomRight: Radius.circular(AppSizes.radiusLg),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.sm,
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'VACCINE NAME',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontXs,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'DATE ADMINISTERED',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontXs,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'DOSE',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontXs,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ..._recordRows(records),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROVIDER INFORMATION',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        records.isNotEmpty
                            ? (records.first.clinicName ?? 'Not specified')
                            : 'Not specified',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Text(
                        'AUTHENTICATOR SEAL',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          const Expanded(
                            child: Text(
                              'This document is generated from local vaccination records saved in VacciTrack.',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: AppSizes.fontXs,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text('Vaccination Card'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadCardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: Text(
                'Unable to load vaccination card',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final recordId = data['recordId'] as String;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Official Health Record',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                const Text(
                  'Verified digital copy of immunization history',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                _buildCard(data),
                const SizedBox(height: AppSizes.lg),
                AppButton(
                  label: 'Print Card',
                  onPressed: () => _printCard(context),
                  icon: const Icon(
                    Icons.print_outlined,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                AppButton(
                  label: 'Share PDF',
                  onPressed: () => _sharePdf(context),
                  isOutlined: true,
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                AppButton(
                  label: 'Save to Wallet',
                  onPressed: () => _sharePdf(context),
                  isOutlined: true,
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.white,
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Need an official stamp?\n',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    'This digital card is accepted by most schools and travel authorities. If you require a wet-ink signature, please visit your clinic and provide your Record ID: ',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: AppSizes.fontSm,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: recordId,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: AppSizes.fontSm,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const TextSpan(
                                text: '.',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: AppSizes.fontSm,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) =>
            handleMainBottomNavTap(context, index: index, currentIndex: 0),
        items: kMainBottomNavItems,
      ),
    );
  }
}
