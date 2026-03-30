class PlannedVaccineDoseEntity {
  final String id;
  final String vaccineCode;
  final String vaccineName;
  final String disease;
  final int doseNumber;
  final int totalDoses;
  final int recommendedAgeMonths;
  final String category; // mandatory | optional | travel

  const PlannedVaccineDoseEntity({
    required this.id,
    required this.vaccineCode,
    required this.vaccineName,
    required this.disease,
    required this.doseNumber,
    required this.totalDoses,
    required this.recommendedAgeMonths,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineCode': vaccineCode,
      'vaccineName': vaccineName,
      'disease': disease,
      'doseNumber': doseNumber,
      'totalDoses': totalDoses,
      'recommendedAgeMonths': recommendedAgeMonths,
      'category': category,
    };
  }

  factory PlannedVaccineDoseEntity.fromJson(Map<String, dynamic> json) {
    return PlannedVaccineDoseEntity(
      id: (json['id'] ?? '').toString(),
      vaccineCode: (json['vaccineCode'] ?? '').toString(),
      vaccineName: (json['vaccineName'] ?? '').toString(),
      disease: (json['disease'] ?? '').toString(),
      doseNumber: (json['doseNumber'] as num?)?.toInt() ?? 1,
      totalDoses: (json['totalDoses'] as num?)?.toInt() ?? 1,
      recommendedAgeMonths:
          (json['recommendedAgeMonths'] as num?)?.toInt() ?? 0,
      category: (json['category'] ?? 'mandatory').toString(),
    );
  }
}
