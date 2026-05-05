import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/notifications/local_notification_service.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../domain/entities/child_entity.dart';
import '../../widgets/common/common_widgets.dart';

class AddChildProfilePage extends StatefulWidget {
  final String? childId;
  const AddChildProfilePage({super.key, this.childId});

  @override
  State<AddChildProfilePage> createState() => _AddChildProfilePageState();
}

class _AddChildProfilePageState extends State<AddChildProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDob;
  String _selectedGender = 'boy';
  bool _isSaving = false;

  bool get _isEditMode =>
      widget.childId != null && widget.childId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadIfEditMode();
  }

  Future<void> _loadIfEditMode() async {
    if (!_isEditMode) return;
    final child = await LocalAppStorage.instance.getChildById(widget.childId!);
    if (child == null || !mounted) return;
    setState(() {
      _nameController.text = child.name;
      _selectedDob = child.dateOfBirth;
      _selectedGender = child.gender == 'girl' ? 'girl' : 'boy';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseSelectDateOfBirth)),
      );
      return;
    }

    setState(() => _isSaving = true);
    final child = ChildEntity(
      id: _isEditMode
          ? widget.childId!
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dateOfBirth: _selectedDob!,
      gender: _selectedGender,
      totalVaccines: 14,
      completedVaccines: 0,
      nextVaccineDate: _selectedDob!.add(const Duration(days: 60)),
      nextVaccineName: 'DTP Dose 1',
    );
    if (_isEditMode) {
      await LocalAppStorage.instance.updateChild(child);
    } else {
      await LocalAppStorage.instance.addChild(child);
    }
    await LocalNotificationService.instance.resyncVaccineReminders();
    if (!mounted) return;
    setState(() => _isSaving = false);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          _isEditMode
              ? context.l10n.editChildProfileTitle
              : context.l10n.addChildProfileTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.familyProfiles,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: AppSizes.fontXl,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      context.l10n.addYourChildProfileToGenerateVaccineSchedule,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      label: context.l10n.childFullName,
                      hint: context.l10n.childNameExample,
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.child_care_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.enterChildName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: context.l10n.dateOfBirth,
                      hint: _selectedDob == null
                          ? context.l10n.selectDate
                          : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
                      readOnly: true,
                      onTap: _pickDate,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    const SizedBox(height: AppSizes.md),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: InputDecoration(
                        labelText: context.l10n.childGender,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'boy',
                          child: Text(context.l10n.genderBoy),
                        ),
                        DropdownMenuItem(
                          value: 'girl',
                          child: Text(context.l10n.genderGirl),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedGender = value);
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: context.l10n.notesOptional,
                      hint: context.l10n.childNotesHint,
                      controller: _notesController,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppButton(
                      label: _isEditMode
                          ? context.l10n.updateChildProfile
                          : context.l10n.saveChildProfile,
                      onPressed: _saveChild,
                      isLoading: _isSaving,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
