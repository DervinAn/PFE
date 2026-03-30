import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/vaccine_entity.dart';
import '../../../domain/usecases/usecases.dart';

// ─── Events ───────────────────────────────────────────────────

abstract class VaccineEvent extends Equatable {
  const VaccineEvent();
  @override
  List<Object?> get props => [];
}

class LoadScheduleEvent extends VaccineEvent {
  final String childId;
  const LoadScheduleEvent(this.childId);
  @override
  List<Object?> get props => [childId];
}

class RecordVaccineEvent extends VaccineEvent {
  final VaccineEntity vaccine;
  const RecordVaccineEvent(this.vaccine);
  @override
  List<Object?> get props => [vaccine];
}

// ─── States ───────────────────────────────────────────────────

abstract class VaccineState extends Equatable {
  const VaccineState();
  @override
  List<Object?> get props => [];
}

class VaccineInitial extends VaccineState {}

class VaccineLoading extends VaccineState {}

class ScheduleLoaded extends VaccineState {
  final List<VaccineScheduleGroup> groups;
  const ScheduleLoaded(this.groups);
  @override
  List<Object?> get props => [groups];
}

class VaccineRecorded extends VaccineState {
  final VaccineEntity vaccine;
  const VaccineRecorded(this.vaccine);
  @override
  List<Object?> get props => [vaccine];
}

class VaccineError extends VaccineState {
  final String message;
  const VaccineError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────

class VaccineBloc extends Bloc<VaccineEvent, VaccineState> {
  final GetVaccineScheduleUseCase _getSchedule;
  final RecordVaccineUseCase _recordVaccine;

  VaccineBloc({
    required GetVaccineScheduleUseCase getSchedule,
    required RecordVaccineUseCase recordVaccine,
  }) : _getSchedule = getSchedule,
       _recordVaccine = recordVaccine,
       super(VaccineInitial()) {
    on<LoadScheduleEvent>(_onLoadSchedule);
    on<RecordVaccineEvent>(_onRecordVaccine);
  }

  Future<void> _onLoadSchedule(
    LoadScheduleEvent event,
    Emitter<VaccineState> emit,
  ) async {
    emit(VaccineLoading());
    try {
      final groups = await _getSchedule(event.childId);
      emit(ScheduleLoaded(groups));
    } catch (e) {
      emit(VaccineError(e.toString()));
    }
  }

  Future<void> _onRecordVaccine(
    RecordVaccineEvent event,
    Emitter<VaccineState> emit,
  ) async {
    try {
      final recorded = await _recordVaccine(event.vaccine);
      emit(VaccineRecorded(recorded));
    } catch (e) {
      emit(VaccineError(e.toString()));
    }
  }
}
