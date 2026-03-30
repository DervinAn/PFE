import '../../domain/entities/child_entity.dart';
import '../../domain/entities/vaccine_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/local_datasource.dart';

class ChildRepositoryImpl implements ChildRepository {
  final LocalDataSource _dataSource;
  ChildRepositoryImpl(this._dataSource);

  @override
  Future<List<ChildEntity>> getChildren() => _dataSource.getChildren();

  @override
  Future<ChildEntity?> getChildById(String id) => _dataSource.getChildById(id);

  @override
  Future<ChildEntity> addChild(ChildEntity child) async {
    // TODO: persist to local DB / remote API
    return child;
  }

  @override
  Future<ChildEntity> updateChild(ChildEntity child) async {
    // TODO: update in local DB / remote API
    return child;
  }

  @override
  Future<void> deleteChild(String id) async {
    // TODO: delete from local DB / remote API
  }
}

class VaccineRepositoryImpl implements VaccineRepository {
  final LocalDataSource _dataSource;
  VaccineRepositoryImpl(this._dataSource);

  @override
  Future<List<VaccineScheduleGroup>> getVaccineSchedule(String childId) =>
      _dataSource.getVaccineSchedule(childId);

  @override
  Future<List<VaccineEntity>> getVaccinesByChild(String childId) async {
    final groups = await _dataSource.getVaccineSchedule(childId);
    return groups.expand((g) => g.vaccines).toList();
  }

  @override
  Future<VaccineEntity> recordVaccine(VaccineEntity vaccine) async {
    // TODO: persist to local DB / remote API
    return vaccine;
  }

  @override
  Future<VaccineEntity> updateVaccine(VaccineEntity vaccine) async {
    // TODO: update in local DB / remote API
    return vaccine;
  }
}

class UserRepositoryImpl implements UserRepository {
  final LocalDataSource _dataSource;
  UserRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity?> getCurrentUser() => _dataSource.getCurrentUser();

  @override
  Future<UserEntity> updateUser(UserEntity user) async => user;

  @override
  Future<void> logout() async {
    // TODO: clear local storage / invalidate token
  }
}

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications() async {
    // TODO: load from local DB / remote API
    return [];
  }

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> dismissNotification(String id) async {}
}

class RecordRepositoryImpl implements RecordRepository {
  @override
  Future<List<VaccinationRecordEntity>> getRecords({String? childId}) async {
    // TODO: query from local DB
    return [];
  }

  @override
  Future<VaccinationRecordEntity> addRecord(
    VaccinationRecordEntity record,
  ) async => record;

  @override
  Future<void> deleteRecord(String id) async {}
}
