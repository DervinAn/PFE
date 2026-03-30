import '../entities/child_entity.dart';
import '../entities/vaccine_entity.dart';
import '../entities/user_entity.dart';

abstract class ChildRepository {
  Future<List<ChildEntity>> getChildren();
  Future<ChildEntity?> getChildById(String id);
  Future<ChildEntity> addChild(ChildEntity child);
  Future<ChildEntity> updateChild(ChildEntity child);
  Future<void> deleteChild(String id);
}

abstract class VaccineRepository {
  Future<List<VaccineScheduleGroup>> getVaccineSchedule(String childId);
  Future<List<VaccineEntity>> getVaccinesByChild(String childId);
  Future<VaccineEntity> recordVaccine(VaccineEntity vaccine);
  Future<VaccineEntity> updateVaccine(VaccineEntity vaccine);
}

abstract class UserRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updateUser(UserEntity user);
  Future<void> logout();
}

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> dismissNotification(String id);
}

abstract class RecordRepository {
  Future<List<VaccinationRecordEntity>> getRecords({String? childId});
  Future<VaccinationRecordEntity> addRecord(VaccinationRecordEntity record);
  Future<void> deleteRecord(String id);
}
