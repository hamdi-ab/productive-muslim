import 'platform_timezone_stub.dart'
    if (dart.library.js_interop) 'platform_timezone_web.dart';

String? getPlatformTimeZone() => getBrowserTimeZone();
