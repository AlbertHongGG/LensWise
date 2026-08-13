import 'dart:io';
import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:lens_wise/features/scanner/domain/interfaces/i_camera_service.dart';

class CamerawesomeService implements ICameraService {
  CameraState? _currentState;

  @override
  void setCameraState(dynamic state) {
    if (state is CameraState) {
      _currentState = state;
    }
  }

  @override
  Future<Uint8List?> takePicture() async {
    if (_currentState == null) return null;

    if (_currentState is PhotoCameraState) {
      final photoState = _currentState as PhotoCameraState;
      final request = await photoState.takePhoto();
      final path = request.when(
        single: (single) => single.file?.path,
        multiple: (multiple) => multiple.fileBySensor.values.first?.path,
      );
      
      if (path != null) {
        return await File(path).readAsBytes();
      }
    }
    return null;
  }
}
