import 'package:yayscribbl/models/point_model.dart';

sealed class BatchProcessingEvents {}

final class BatchTimerFinished extends BatchProcessingEvents {
  final List<PointModel?> processedPoints;

  BatchTimerFinished({required this.processedPoints});
}
