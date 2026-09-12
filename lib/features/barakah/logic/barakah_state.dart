import 'package:productive_muslim/domain/models/barakah_entry.dart';

sealed class BarakahState {
  const BarakahState();

  const factory BarakahState.initial() = Initial;
  const factory BarakahState.loading() = Loading;
  const factory BarakahState.loaded(List<BarakahEntry> entries) = Loaded;
  const factory BarakahState.error(String message) = Error;
}

class Initial extends BarakahState {
  const Initial();
}

class Loading extends BarakahState {
  const Loading();
}

class Loaded extends BarakahState {
  final List<BarakahEntry> entries;
  const Loaded(this.entries);
}

class Error extends BarakahState {
  final String message;
  const Error(this.message);
}