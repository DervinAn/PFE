import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/usecases/usecases.dart';

// ─── Events ───────────────────────────────────────────────────

abstract class ChildEvent extends Equatable {
  const ChildEvent();
  @override
  List<Object?> get props => [];
}

class LoadChildrenEvent extends ChildEvent {
  const LoadChildrenEvent();
}

class LoadChildByIdEvent extends ChildEvent {
  final String id;
  const LoadChildByIdEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class AddChildEvent extends ChildEvent {
  final ChildEntity child;
  const AddChildEvent(this.child);
  @override
  List<Object?> get props => [child];
}

// ─── States ───────────────────────────────────────────────────

abstract class ChildState extends Equatable {
  const ChildState();
  @override
  List<Object?> get props => [];
}

class ChildInitial extends ChildState {}

class ChildLoading extends ChildState {}

class ChildrenLoaded extends ChildState {
  final List<ChildEntity> children;
  const ChildrenLoaded(this.children);
  @override
  List<Object?> get props => [children];
}

class ChildLoaded extends ChildState {
  final ChildEntity child;
  const ChildLoaded(this.child);
  @override
  List<Object?> get props => [child];
}

class ChildError extends ChildState {
  final String message;
  const ChildError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────

class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final GetChildrenUseCase _getChildren;
  final GetChildByIdUseCase _getChildById;
  final AddChildUseCase _addChild;

  ChildBloc({
    required GetChildrenUseCase getChildren,
    required GetChildByIdUseCase getChildById,
    required AddChildUseCase addChild,
  }) : _getChildren = getChildren,
       _getChildById = getChildById,
       _addChild = addChild,
       super(ChildInitial()) {
    on<LoadChildrenEvent>(_onLoadChildren);
    on<LoadChildByIdEvent>(_onLoadChildById);
    on<AddChildEvent>(_onAddChild);
  }

  Future<void> _onLoadChildren(
    LoadChildrenEvent event,
    Emitter<ChildState> emit,
  ) async {
    emit(ChildLoading());
    try {
      final children = await _getChildren();
      emit(ChildrenLoaded(children));
    } catch (e) {
      emit(ChildError(e.toString()));
    }
  }

  Future<void> _onLoadChildById(
    LoadChildByIdEvent event,
    Emitter<ChildState> emit,
  ) async {
    emit(ChildLoading());
    try {
      final child = await _getChildById(event.id);
      if (child != null) {
        emit(ChildLoaded(child));
      } else {
        emit(const ChildError('Child not found'));
      }
    } catch (e) {
      emit(ChildError(e.toString()));
    }
  }

  Future<void> _onAddChild(
    AddChildEvent event,
    Emitter<ChildState> emit,
  ) async {
    try {
      await _addChild(event.child);
      // Reload list after adding
      add(const LoadChildrenEvent());
    } catch (e) {
      emit(ChildError(e.toString()));
    }
  }
}
