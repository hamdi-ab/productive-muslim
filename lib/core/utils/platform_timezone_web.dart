import 'dart:js_interop';

String? getBrowserTimeZone() {
  try {
    final format = _createDateTimeFormat();
    final options = _resolvedOptions(format);
    return _getTimeZone(options);
  } catch (_) {
    return null;
  }
}

@JS('Intl.DateTimeFormat')
external JSObject _createDateTimeFormat();

extension type _DateTimeFormat(JSObject _) implements JSObject {
  external _ResolvedOptions resolvedOptions();
}

extension type _ResolvedOptions(JSObject _) implements JSObject {
  external String? get timeZone;
}

String? _getTimeZone(JSObject options) {
  try {
    final opts = _ResolvedOptions(options);
    return opts.timeZone;
  } catch (_) {
    return null;
  }
}

JSObject _resolvedOptions(JSObject format) {
  final dtf = _DateTimeFormat(format);
  return dtf.resolvedOptions();
}
