import '../../domain/entities/child_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/entities/user_entity.dart';

/// Local data source placeholder for legacy repository wiring.
/// VaccinTrack screens now use LocalAppStorage for real local persistence.
class LocalDataSource {
  static final LocalDataSource _instance = LocalDataSource._internal();
  factory LocalDataSource() => _instance;
  LocalDataSource._internal();

  final List<ChildEntity> _children = [];
  UserEntity? _currentUser;

  Future<List<ChildEntity>> getChildren() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _children;
  }

  Future<ChildEntity?> getChildById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _children.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  Future<List<VaccineScheduleGroup>> getVaccineSchedule(String childId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }
}
