import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/vaccine_entity.dart';
import '../../widgets/common/common_widgets.dart';

class RecordVaccinationPage extends StatefulWidget {
  final String? preselectedChildId;
  final String? preselectedDoseId;

  const RecordVaccinationPage({
    super.key,
    this.preselectedChildId,
    this.preselectedDoseId,
  });

  @override
  State<RecordVaccinationPage> createState() => _RecordVaccinationPageState();
}

class _RecordVaccinationPageState extends State<RecordVaccinationPage> {
  final _remarksController = TextEditingController();
  final _clinicController = TextEditingController();
  final _lotController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  List<ChildEntity> _children = const [];
  List<VaccineEntity> _doses = const [];
  String? _selectedChildId;
  String? _selectedDoseId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _clinicController.dispose();
    _lotController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final children = await LocalAppStorage.instance.getChildren();
    if (!mounted) return;
    setState(() => _children = children);

    if (children.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    _selectedChildId =
        widget.preselectedChildId != null &&
            children.any((c) => c.id == widget.preselectedChildId)
        ? widget.preselectedChildId
        : children.first.id;

    await _loadDosesForChild(_selectedChildId!);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadDosesForChild(String childId) async {
    final doses = await LocalAppStorage.instance.getRecordableDoses(childId);
    if (!mounted) return;
    setState(() {
      _doses = doses;
      if (_doses.isEmpty) {
        _selectedDoseId = null;
        return;
      }
      final preselectedValid =
          widget.preselectedDoseId != null &&
          _doses.any(
            (d) =>
                d.plannedDoseId == widget.preselectedDoseId ||
                d.id == widget.preselectedDoseId,
          );
      if (preselectedValid) {
        _selectedDoseId = widget.preselectedDoseId;
      } else if (_selectedDoseId == null ||
          !_doses.any((d) => (d.plannedDoseId ?? d.id) == _selectedDoseId)) {
        _selectedDoseId = _doses.first.plannedDoseId ?? _doses.first.id;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a child')));
      return;
    }
    if (_selectedDoseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending dose available to record')),
      );
      return;
    }
    setState(() => _saving = true);
    await LocalAppStorage.instance.recordVaccination(
      childId: _selectedChildId!,
      plannedDoseId: _selectedDoseId!,
      administeredDate: _selectedDate,
      remark: _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
      clinicName: _clinicController.text.trim().isEmpty
          ? null
          : _clinicController.text.trim(),
      lotNumber: _lotController.text.trim().isEmpty
          ? null
          : _lotController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vaccination recorded successfully')),
    );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_children.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record Vaccination')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.child_care_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  'No child profile found',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Record Vaccination'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Child',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              _buildChildDropdown(),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Select Dose',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              _buildDoseDropdown(),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Administration Date',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Clinic Name (optional)',
                hint: 'Example: Central Pediatric Clinic',
                controller: _clinicController,
                prefixIcon: const Icon(Icons.local_hospital_outlined),
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Lot Number (optional)',
                hint: 'Example: BCG-4281',
                controller: _lotController,
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Remarks',
                hint: 'Any post-vaccine notes...',
                controller: _remarksController,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              const SizedBox(height: AppSizes.lg),
              AppButton(
                label: 'Confirm Vaccination',
                onPressed: _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedChildId,
          isExpanded: true,
          items: _children
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(
                    c.name,
                    style: const TextStyle(fontFamily: 'Nunito'),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) async {
            if (value == null) return;
            setState(() => _selectedChildId = value);
            await _loadDosesForChild(value);
          },
        ),
      ),
    );
  }

  Widget _buildDoseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDoseId,
          hint: const Text('No pending dose'),
          isExpanded: true,
          items: _doses
              .map(
                (d) => DropdownMenuItem<String>(
                  value: d.plannedDoseId ?? d.id,
                  child: Text(
                    '${d.name} - Dose ${d.doseNumber}',
                    style: const TextStyle(fontFamily: 'Nunito'),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedDoseId = value),
        ),
      ),
    );
  }
}
