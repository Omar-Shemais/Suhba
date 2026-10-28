import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/community_repository.dart';

/// Use case for toggling like on a post
class ToggleLikeUseCase {
  final CommunityRepository repository;

  ToggleLikeUseCase(this.repository);

  /// Execute the use case
  /// Returns true if post was liked, false if unliked
  Future<Either<Failure, bool>> call({
    required String postId,
    required String userId,
  }) async {
    return await repository.toggleLike(postId: postId, userId: userId);
  }
}
