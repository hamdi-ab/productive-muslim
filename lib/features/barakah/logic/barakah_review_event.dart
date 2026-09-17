import 'package:productive_muslim/domain/models/barakah_daily_response.dart';

sealed class BarakahReviewEvent {
  const BarakahReviewEvent();
}

class BarakahReviewWeekSelected extends BarakahReviewEvent {
  const BarakahReviewWeekSelected(this.offset);

  final int offset;
}

class BarakahReviewResponsesReceived extends BarakahReviewEvent {
  const BarakahReviewResponsesReceived(this.generation, this.responses);

  final int generation;
  final List<BarakahDailyResponse> responses;
}

class BarakahReviewFailed extends BarakahReviewEvent {
  const BarakahReviewFailed(this.generation);

  final int generation;
}
