import '../entities/child_entity.dart';
import '../entities/vaccine_entity.dart';
import '../repositories/repositories.dart';

// ─── Child Use Cases ──────────────────────────────────────────

class GetChildrenUseCase {
  final ChildRepository repository;
  GetChildrenUseCase(this.repository);

  Future<List<ChildEntity>> call() => repository.getChildren();
}

class GetChildByIdUseCase {
  final ChildRepository repository;
  GetChildByIdUseCase(this.repository);

  Future<ChildEntity?> call(String id) => repository.getChildById(id);
}

class AddChildUseCase {
  final ChildRepository repository;
  AddChildUseCase(this.repository);

  Future<ChildEntity> call(ChildEntity child) => repository.addChild(child);
}

// ─── Vaccine Use Cases ────────────────────────────────────────

class GetVaccineScheduleUseCase {
  final VaccineRepository repository;
  GetVaccineScheduleUseCase(this.repository);

  Future<List<VaccineScheduleGroup>> call(String childId) =>
      repository.getVaccineSchedule(childId);
}

class RecordVaccineUseCase {
  final VaccineRepository repository;
  RecordVaccineUseCase(this.repository);

  Future<VaccineEntity> call(VaccineEntity vaccine) =>
      repository.recordVaccine(vaccine);
}

// ─── User Use Cases ───────────────────────────────────────────

class LogoutUseCase {
  final UserRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}
