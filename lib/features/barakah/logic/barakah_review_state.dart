import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productive_muslim/domain/models/barakah_weekly_review.dart';

part 'barakah_review_state.freezed.dart';

@freezed
sealed class BarakahReviewState with _$BarakahReviewState {
  const factory BarakahReviewState.loading(BarakahReviewWeek week) =
      BarakahReviewLoading;
  const factory BarakahReviewState.loaded(
    BarakahReviewWeek week,
    BarakahWeeklyReview review,
  ) = BarakahReviewLoaded;
  const factory BarakahReviewState.failure(BarakahReviewWeek week) =
      BarakahReviewFailure;
}
