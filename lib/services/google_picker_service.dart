// Facade which conditionally imports the correct implementation for web vs other platforms.
import 'google_picker_service_stub.dart'
    if (dart.library.html) 'google_picker_service_web.dart';

export 'google_picker_service_stub.dart'
    if (dart.library.html) 'google_picker_service_web.dart';
