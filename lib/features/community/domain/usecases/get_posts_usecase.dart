import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

/// Use case for getting paginated posts
class GetPostsUseCase {
  final CommunityRepository repository;

  GetPostsUseCase(this.repository);

  /// Execute the use case
  /// [page] - Page number (0-indexed)
  /// [limit] - Number of posts per page
  Future<Either<Failure, List<PostEntity>>> call({
    int page = 0,
    int limit = 20,
  }) async {
    return await repository.getPosts(page: page, limit: limit);
  }
}
