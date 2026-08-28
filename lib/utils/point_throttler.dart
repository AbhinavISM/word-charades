import 'dart:async';

import 'package:yayscribbl/models/batch_processing_events.dart';
import 'package:yayscribbl/models/point_model.dart';

class PointThrottler {
  // drawing throttling
  Timer? _batchTimer;
  List<PointModel?> _pointBuffer = [];
  List<PointModel?> _processingBuffer = [];
  bool _isProcessing = false;

  final batchProcessingEventStreamController =
      StreamController<BatchProcessingEvents>();
  Sink<BatchProcessingEvents> get _batchProcessingEventSink =>
      batchProcessingEventStreamController.sink;
  Stream<BatchProcessingEvents> get batchProcessingEventStream =>
      batchProcessingEventStreamController.stream;

  void addPoint(PointModel? point) {
    _pointBuffer.add(point);
    _startBatchTimer();
  }

  void cancel() {
    _batchTimer?.cancel();
  }

  void _processPoints() {
    if (_pointBuffer.isEmpty || _isProcessing) return;

    try {
      _isProcessing = true;

      _processingBuffer = _pointBuffer;
      _pointBuffer = [];

      _batchProcessingEventSink
          .add(BatchTimerFinished(processedPoints: _processingBuffer));

      _processingBuffer.clear();
    } catch (e) {
      // print('Error preparing points for sending: $e');
      // Recover points if preparation failed
      _pointBuffer.insertAll(0, _processingBuffer);
    } finally {
      _isProcessing = false;
      // If there are new points that arrived during processing,
      // start a new batch timer
      if (_pointBuffer.isNotEmpty) {
        _startBatchTimer();
      }
    }
  }

  void _startBatchTimer() {
    // Only start a new timer if one isn't already running
    if (_batchTimer == null || !_batchTimer!.isActive) {
      _batchTimer = Timer(const Duration(milliseconds: 16), () {
        _processPoints();
      });
    }
  }
}
