class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final bool notificationsEnabled;
  final String language;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.notificationsEnabled = true,
    this.language = 'English',
  });
}

enum NotificationPriority { urgent, dueSoon, info, success }

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final String? actionLabel;
  final String? vaccineName;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    this.actionLabel,
    this.vaccineName,
  });
}

class VaccinationRecordEntity {
  final String id;
  final String childId;
  final String childName;
  final String vaccineName;
  final String disease;
  final String doseLabel;
  final DateTime administeredDate;
  final String? clinicName;
  final String? lotNumber;
  final String status; // completed, pending
  final String? notes;

  const VaccinationRecordEntity({
    required this.id,
    required this.childId,
    required this.childName,
    required this.vaccineName,
    required this.disease,
    required this.doseLabel,
    required this.administeredDate,
    this.clinicName,
    this.lotNumber,
    required this.status,
    this.notes,
  });
}
