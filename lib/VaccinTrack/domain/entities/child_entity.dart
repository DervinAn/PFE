// child_entity.dart
class ChildEntity {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String? photoUrl;
  final int totalVaccines;
  final int completedVaccines;
  final DateTime? nextVaccineDate;
  final String? nextVaccineName;
  final bool isFullyProtected;

  const ChildEntity({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.photoUrl,
    required this.totalVaccines,
    required this.completedVaccines,
    this.nextVaccineDate,
    this.nextVaccineName,
    this.isFullyProtected = false,
  });

  String get ageDisplay {
    final now = DateTime.now();
    final diff = now.difference(dateOfBirth);
    final months = (diff.inDays / 30.44).floor();
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    final remainMonths = months % 12;
    if (remainMonths == 0) return '$years year${years > 1 ? 's' : ''}';
    return '$years year${years > 1 ? 's' : ''} $remainMonths month${remainMonths > 1 ? 's' : ''}';
  }

  double get progressPercent =>
      totalVaccines > 0 ? completedVaccines / totalVaccines : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'photoUrl': photoUrl,
      'totalVaccines': totalVaccines,
      'completedVaccines': completedVaccines,
      'nextVaccineDate': nextVaccineDate?.toIso8601String(),
      'nextVaccineName': nextVaccineName,
      'isFullyProtected': isFullyProtected,
    };
  }

  factory ChildEntity.fromJson(Map<String, dynamic> json) {
    return ChildEntity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      dateOfBirth:
          DateTime.tryParse((json['dateOfBirth'] ?? '').toString()) ??
          DateTime.now(),
      photoUrl: json['photoUrl'] as String?,
      totalVaccines: (json['totalVaccines'] as num?)?.toInt() ?? 0,
      completedVaccines: (json['completedVaccines'] as num?)?.toInt() ?? 0,
      nextVaccineDate: json['nextVaccineDate'] != null
          ? DateTime.tryParse(json['nextVaccineDate'].toString())
          : null,
      nextVaccineName: json['nextVaccineName'] as String?,
      isFullyProtected: json['isFullyProtected'] as bool? ?? false,
    );
  }
}
