import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

/// Use case for getting comments on a post
class GetCommentsUseCase {
  final CommunityRepository repository;

  GetCommentsUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, List<CommentEntity>>> call({
    required String postId,
    int page = 0,
  }) async {
    return await repository.getComments(postId: postId, page: page);
  }
}
