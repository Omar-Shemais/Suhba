import 'package:dartz/dartz.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

/// Use case for creating a new post
class CreatePostUseCase {
  final CommunityRepository repository;

  CreatePostUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, PostEntity>> call({
    required String userId,
    String? title,
    required String content,
    List<String>? mediaPaths,
  }) async {
    // Validate content
    if (content.trim().isEmpty) {
      return Left(ValidationFailure('المحتوى لا يمكن أن يكون فارغاً'));
    }

    if (content.length > SupabaseConstants.maxPostContentLength) {
      return Left(
        ValidationFailure(
          'المحتوى طويل جداً (حد أقصى ${SupabaseConstants.maxPostContentLength} حرف)',
        ),
      );
    }

    // Validate title if provided
    if (title != null && title.length > SupabaseConstants.maxTitleLength) {
      return Left(
        ValidationFailure(
          'العنوان طويل جداً (حد أقصى ${SupabaseConstants.maxTitleLength} حرف)',
        ),
      );
    }

    return await repository.createPost(
      userId: userId,
      title: title,
      content: content,
      mediaPaths: mediaPaths,
    );
  }
}
