import '../../domain/models/generate_request.dart';
import '../../domain/models/generate_response.dart';

abstract class AIProvider {
  String get name;
  Future<GenerateResponse> generate(GenerateRequest request);
  Stream<GenerateResponse> generateStream(GenerateRequest request);
}
