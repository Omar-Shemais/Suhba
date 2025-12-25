import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/network/supabase_client.dart';
import '../../../../../core/services/supabase_auth_sync_service.dart';
import '../../../../../core/services/supabase_storage_service.dart';
import 'data/datasources/community_remote_datasource.dart';
import 'data/repositories/community_repository_impl.dart';
import 'domain/repositories/community_repository.dart';
import 'domain/usecases/add_comment_usecase.dart';
import 'domain/usecases/create_post_usecase.dart';
import 'domain/usecases/delete_post_usecase.dart';
import 'domain/usecases/get_comments_usecase.dart';
import 'domain/usecases/get_posts_usecase.dart';
import 'domain/usecases/toggle_like_usecase.dart';
import 'presentation/cubits/community/community_cubit.dart';

final sl = GetIt.instance;

/// Setup dependency injection for Community feature
/// Call this in main.dart after initializing Supabase
void setupCommunityInjector() {
  // ==================== Services ====================

  // Supabase Storage Service
  sl.registerLazySingleton<SupabaseStorageService>(
    () => SupabaseStorageService(SupabaseClientWrapper.client),
  );

  // Auth Sync Service
  sl.registerLazySingleton<SupabaseAuthSyncService>(
    () => SupabaseAuthSyncService(
      supabase: SupabaseClientWrapper.client,
      firebaseAuth: FirebaseAuth.instance,
    ),
  );

  // ==================== Data Sources ====================

  sl.registerLazySingleton<CommunityRemoteDataSource>(
    () => CommunityRemoteDataSourceImpl(
      storageService: sl<SupabaseStorageService>(),
    ),
  );

  // ==================== Repositories ====================

  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(sl<CommunityRemoteDataSource>()),
  );

  // ==================== Use Cases ====================

  sl.registerLazySingleton(() => GetPostsUseCase(sl<CommunityRepository>()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl<CommunityRepository>()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl<CommunityRepository>()));
  sl.registerLazySingleton(() => GetCommentsUseCase(sl<CommunityRepository>()));
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl<CommunityRepository>()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl<CommunityRepository>()));

  // ==================== Cubits ====================

  // Register as Singleton (one instance shared across app for caching)
  sl.registerLazySingleton(
    () => CommunityCubit(
      getPostsUseCase: sl<GetPostsUseCase>(),
      createPostUseCase: sl<CreatePostUseCase>(),
      toggleLikeUseCase: sl<ToggleLikeUseCase>(),
      deletePostUseCase: sl<DeletePostUseCase>(),
      getCommentsUseCase: sl<GetCommentsUseCase>(),
      addCommentUseCase: sl<AddCommentUseCase>(),
    ),
  );
}
