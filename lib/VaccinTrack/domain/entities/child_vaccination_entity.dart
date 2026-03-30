class ChildVaccinationEntity {
  final String id;
  final String childId;
  final String plannedDoseId;
  final DateTime administeredDate;
  final String status; // administered | skipped
  final String? remark;
  final String? clinicName;
  final String? lotNumber;

  const ChildVaccinationEntity({
    required this.id,
    required this.childId,
    required this.plannedDoseId,
    required this.administeredDate,
    required this.status,
    this.remark,
    this.clinicName,
    this.lotNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'plannedDoseId': plannedDoseId,
      'administeredDate': administeredDate.toIso8601String(),
      'status': status,
      'remark': remark,
      'clinicName': clinicName,
      'lotNumber': lotNumber,
    };
  }

  factory ChildVaccinationEntity.fromJson(Map<String, dynamic> json) {
    return ChildVaccinationEntity(
      id: (json['id'] ?? '').toString(),
      childId: (json['childId'] ?? '').toString(),
      plannedDoseId: (json['plannedDoseId'] ?? '').toString(),
      administeredDate:
          DateTime.tryParse((json['administeredDate'] ?? '').toString()) ??
          DateTime.now(),
      status: (json['status'] ?? 'administered').toString(),
      remark: json['remark'] as String?,
      clinicName: json['clinicName'] as String?,
      lotNumber: json['lotNumber'] as String?,
    );
  }
}
