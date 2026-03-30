import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
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
        const SnackBar(content: Text('Please select date of birth')),
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
        title: Text(_isEditMode ? 'Edit Child Profile' : 'Child Profile'),
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
                    const Text(
                      'Family Profiles',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: AppSizes.fontXl,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    const Text(
                      'Add your child profile to generate vaccine schedule.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      label: 'Child Full Name',
                      hint: 'Example: Leo Johnson',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.child_care_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter child name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: 'Date Of Birth',
                      hint: _selectedDob == null
                          ? 'Select date'
                          : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
                      readOnly: true,
                      onTap: _pickDate,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: 'Notes (optional)',
                      hint: 'Allergies, previous doses, clinic preferences...',
                      controller: _notesController,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppButton(
                      label: _isEditMode
                          ? 'Update Child Profile'
                          : 'Save Child Profile',
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
