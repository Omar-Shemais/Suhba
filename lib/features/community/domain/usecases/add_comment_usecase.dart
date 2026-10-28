import 'package:dartz/dartz.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comment_entity.dart';
import '../repositories/community_repository.dart';

/// Use case for adding a comment to a post
class AddCommentUseCase {
  final CommunityRepository repository;

  AddCommentUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, CommentEntity>> call({
    required String postId,
    required String userId,
    required String content,
  }) async {
    // Validate content
    if (content.trim().isEmpty) {
      return Left(ValidationFailure('التعليق لا يمكن أن يكون فارغاً'));
    }

    if (content.length > SupabaseConstants.maxCommentContentLength) {
      return Left(
        ValidationFailure(
          'التعليق طويل جداً (حد أقصى ${SupabaseConstants.maxCommentContentLength} حرف)',
        ),
      );
    }

    return await repository.addComment(
      postId: postId,
      userId: userId,
      content: content,
    );
  }
}
