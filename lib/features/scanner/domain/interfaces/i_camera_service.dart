import 'dart:typed_data';

abstract class ICameraService {
  void setCameraState(dynamic state);
  Future<Uint8List?> takePicture();
}
