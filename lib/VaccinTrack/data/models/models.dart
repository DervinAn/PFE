import '../../domain/entities/child_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/entities/user_entity.dart';

// ─── Child Model ──────────────────────────────────────────────

class ChildModel extends ChildEntity {
  const ChildModel({
    required super.id,
    required super.name,
    required super.dateOfBirth,
    super.photoUrl,
    required super.totalVaccines,
    required super.completedVaccines,
    super.nextVaccineDate,
    super.nextVaccineName,
    super.isFullyProtected,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      photoUrl: json['photo_url'] as String?,
      totalVaccines: json['total_vaccines'] as int,
      completedVaccines: json['completed_vaccines'] as int,
      nextVaccineDate: json['next_vaccine_date'] != null
          ? DateTime.parse(json['next_vaccine_date'] as String)
          : null,
      nextVaccineName: json['next_vaccine_name'] as String?,
      isFullyProtected: json['is_fully_protected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'photo_url': photoUrl,
      'total_vaccines': totalVaccines,
      'completed_vaccines': completedVaccines,
      'next_vaccine_date': nextVaccineDate?.toIso8601String(),
      'next_vaccine_name': nextVaccineName,
      'is_fully_protected': isFullyProtected,
    };
  }
}

// ─── Vaccine Model ────────────────────────────────────────────

class VaccineModel extends VaccineEntity {
  const VaccineModel({
    required super.id,
    required super.name,
    required super.disease,
    required super.doseNumber,
    required super.totalDoses,
    super.scheduledDate,
    super.administeredDate,
    required super.status,
    super.lotNumber,
    super.clinicName,
    super.notes,
    required super.ageGroup,
  });

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['id'] as String,
      name: json['name'] as String,
      disease: json['disease'] as String,
      doseNumber: json['dose_number'] as int,
      totalDoses: json['total_doses'] as int,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      administeredDate: json['administered_date'] != null
          ? DateTime.parse(json['administered_date'] as String)
          : null,
      status: VaccineStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => VaccineStatus.upcoming,
      ),
      lotNumber: json['lot_number'] as String?,
      clinicName: json['clinic_name'] as String?,
      notes: json['notes'] as String?,
      ageGroup: json['age_group'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'disease': disease,
      'dose_number': doseNumber,
      'total_doses': totalDoses,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'administered_date': administeredDate?.toIso8601String(),
      'status': status.name,
      'lot_number': lotNumber,
      'clinic_name': clinicName,
      'notes': notes,
      'age_group': ageGroup,
    };
  }
}

// ─── User Model ───────────────────────────────────────────────

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.photoUrl,
    super.notificationsEnabled,
    super.language,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      photoUrl: json['photo_url'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'English',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'notifications_enabled': notificationsEnabled,
      'language': language,
    };
  }
}
