import 'package:equatable/equatable.dart';
import 'package:flutter_smart_genome/util/logger.dart';

abstract class RequestState extends Equatable {}

class RequestDefault extends RequestState {
  @override
  String toString() {
    return 'RequestDefault';
  }

  @override
  List<Object> get props => [];
}

class FetchingState extends RequestState {
  final DateTime time;

  FetchingState(this.time) {}

  @override
  List<Object> get props => [time];
}

class RequestError extends RequestState {
  final String error;
  final int mils;

  RequestError({required this.error, required this.mils});

  @override
  String toString() {
    return 'RequestError{$error}';
  }

  @override
  List<Object> get props => [error];
}

class DataLoaded<T> extends RequestState {
  final bool hasReachedMax;
  final T? data;
  final List<T>? list;
  DataLoaded({this.hasReachedMax = false, this.data, this.list});

  @override
  String toString() {
    return 'DataLoaded';
  }

  @override
  List<Object> get props => [data!, list!, hasReachedMax];
}

class DataEmptyState<T> extends RequestState {
  final String message;

  DataEmptyState(this.message);

  @override
  String toString() {
    return 'DataEmptyState';
  }

  @override
  List<Object> get props => [message];
}

class RequestSuccess<T> extends RequestState {
  final T data;

  RequestSuccess({required this.data}) {
    logger.i(data);
  }

  @override
  String toString() {
    return 'RequestSuccess';
  }

  @override
  List<Object> get props => [data!];
}

class CreateSuccess<T> extends RequestSuccess<T> {
  CreateSuccess({required T data}) : super(data: data);

  @override
  String toString() {
    return 'CreateSuccess';
  }
}

class UpdateSuccess<T> extends RequestSuccess<T> {
  UpdateSuccess({required T data}) : super(data: data);

  @override
  String toString() {
    return 'UpdateSuccess';
  }
}

class DeleteSuccess<T> extends RequestSuccess<T> {
  DeleteSuccess({required T data}) : super(data: data);

  @override
  String toString() {
    return 'DeleteSuccess';
  }
}