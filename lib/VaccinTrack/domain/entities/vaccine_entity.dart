enum VaccineStatus { done, overdue, dueSoon, upcoming, pending }

class VaccineEntity {
  final String id;
  final String? plannedDoseId;
  final String name;
  final String disease;
  final int doseNumber;
  final int totalDoses;
  final DateTime? scheduledDate;
  final DateTime? administeredDate;
  final VaccineStatus status;
  final String? lotNumber;
  final String? clinicName;
  final String? notes;
  final String ageGroup; // e.g., "AT BIRTH", "12 MONTHS"
  final String category; // mandatory | optional | travel
  final int recommendedAgeMonths;
  final bool canAdminister;
  final bool windowMissed;

  const VaccineEntity({
    required this.id,
    this.plannedDoseId,
    required this.name,
    required this.disease,
    required this.doseNumber,
    required this.totalDoses,
    this.scheduledDate,
    this.administeredDate,
    required this.status,
    this.lotNumber,
    this.clinicName,
    this.notes,
    required this.ageGroup,
    this.category = 'mandatory',
    this.recommendedAgeMonths = 0,
    this.canAdminister = false,
    this.windowMissed = false,
  });

  String get doseLabel => 'Dose $doseNumber of $totalDoses';
  bool get isCompleted => status == VaccineStatus.done;
  bool get isOverdue => status == VaccineStatus.overdue;
  bool get isDueSoon => status == VaccineStatus.dueSoon;
}

class VaccineScheduleGroup {
  final String ageGroup;
  final String dateLabel;
  final List<VaccineEntity> vaccines;
  final VaccineStatus groupStatus;

  const VaccineScheduleGroup({
    required this.ageGroup,
    required this.dateLabel,
    required this.vaccines,
    required this.groupStatus,
  });
}
