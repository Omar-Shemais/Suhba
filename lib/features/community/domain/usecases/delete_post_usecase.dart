import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/community_repository.dart';

/// Use case for deleting a post
class DeletePostUseCase {
  final CommunityRepository repository;

  DeletePostUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, void>> call({
    required String postId,
    required String userId,
  }) async {
    return await repository.deletePost(postId: postId, userId: userId);
  }
}
