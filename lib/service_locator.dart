import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/data_sources/auth_firebase_data_source.dart';
import 'features/auth/data/data_sources/auth_firebase_data_source_impl.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'features/auth/domain/use_cases/sign_in_use_case.dart';
import 'features/auth/domain/use_cases/sign_out_use_case.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/articles/data/data_sources/article_firebase_data_source.dart';
import 'features/articles/data/data_sources/article_firebase_data_source_impl.dart';
import 'features/articles/data/data_sources/category_firebase_data_source.dart';
import 'features/articles/data/data_sources/category_firebase_data_source_impl.dart';
import 'features/articles/data/data_sources/storage_firebase_data_source.dart';
import 'features/articles/data/data_sources/storage_firebase_data_source_impl.dart';
import 'features/articles/data/repository/article_repository_impl.dart';
import 'features/articles/data/repository/category_repository_impl.dart';
import 'features/articles/data/repository/storage_repository_impl.dart';
import 'features/articles/domain/repository/article_repository.dart';
import 'features/articles/domain/repository/category_repository.dart';
import 'features/articles/domain/repository/storage_repository.dart';
import 'features/articles/domain/use_cases/add_category_use_case.dart';
import 'features/articles/domain/use_cases/create_article_use_case.dart';
import 'features/articles/domain/use_cases/delete_article_use_case.dart';
import 'features/articles/domain/use_cases/get_article_by_id_use_case.dart';
import 'features/articles/domain/use_cases/get_articles_use_case.dart';
import 'features/articles/domain/use_cases/get_categories_use_case.dart';
import 'features/articles/domain/use_cases/update_article_use_case.dart';
import 'features/articles/domain/use_cases/upload_article_image_use_case.dart';
import 'features/articles/presentation/bloc/article_bloc.dart';
import 'features/articles/presentation/bloc/category_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  _registerExternalServices();
  _registerAuthDependencies();
  _registerArticleDependencies();
  _registerStorageDependencies();
  _registerCategoryDependencies();
  _registerBlocs();
}

void _registerExternalServices() {
  serviceLocator.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  serviceLocator.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  serviceLocator.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );
}

void _registerAuthDependencies() {
  serviceLocator.registerLazySingleton<AuthFirebaseDataSource>(
    () => AuthFirebaseDataSourceImpl(
      serviceLocator<FirebaseAuth>(),
      serviceLocator<FirebaseFirestore>(),
    ),
  );

  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(serviceLocator<AuthFirebaseDataSource>()),
  );

  serviceLocator.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(serviceLocator<AuthRepository>()),
  );

  serviceLocator.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(serviceLocator<AuthRepository>()),
  );

  serviceLocator.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(serviceLocator<AuthRepository>()),
  );
}

void _registerArticleDependencies() {
  serviceLocator.registerLazySingleton<ArticleFirebaseDataSource>(
    () => ArticleFirebaseDataSourceImpl(
      serviceLocator<FirebaseFirestore>(),
    ),
  );

  serviceLocator.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(serviceLocator<ArticleFirebaseDataSource>()),
  );

  serviceLocator.registerLazySingleton<GetArticlesUseCase>(
    () => GetArticlesUseCase(serviceLocator<ArticleRepository>()),
  );

  serviceLocator.registerLazySingleton<GetArticleByIdUseCase>(
    () => GetArticleByIdUseCase(serviceLocator<ArticleRepository>()),
  );

  serviceLocator.registerLazySingleton<CreateArticleUseCase>(
    () => CreateArticleUseCase(serviceLocator<ArticleRepository>()),
  );

  serviceLocator.registerLazySingleton<UpdateArticleUseCase>(
    () => UpdateArticleUseCase(serviceLocator<ArticleRepository>()),
  );

  serviceLocator.registerLazySingleton<DeleteArticleUseCase>(
    () => DeleteArticleUseCase(serviceLocator<ArticleRepository>()),
  );
}

void _registerStorageDependencies() {
  serviceLocator.registerLazySingleton<StorageFirebaseDataSource>(
    () => StorageFirebaseDataSourceImpl(
      serviceLocator<FirebaseStorage>(),
    ),
  );

  serviceLocator.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(serviceLocator<StorageFirebaseDataSource>()),
  );

  serviceLocator.registerLazySingleton<UploadArticleImageUseCase>(
    () => UploadArticleImageUseCase(serviceLocator<StorageRepository>()),
  );
}

void _registerCategoryDependencies() {
  serviceLocator.registerLazySingleton<CategoryFirebaseDataSource>(
    () => CategoryFirebaseDataSourceImpl(
      serviceLocator<FirebaseFirestore>(),
    ),
  );

  serviceLocator.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(serviceLocator<CategoryFirebaseDataSource>()),
  );

  serviceLocator.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(serviceLocator<CategoryRepository>()),
  );

  serviceLocator.registerLazySingleton<AddCategoryUseCase>(
    () => AddCategoryUseCase(serviceLocator<CategoryRepository>()),
  );
}

void _registerBlocs() {
  serviceLocator.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInUseCase: serviceLocator<SignInUseCase>(),
      signOutUseCase: serviceLocator<SignOutUseCase>(),
      getCurrentUserUseCase: serviceLocator<GetCurrentUserUseCase>(),
    ),
  );

  serviceLocator.registerFactory<ArticleBloc>(
    () => ArticleBloc(
      getArticlesUseCase: serviceLocator<GetArticlesUseCase>(),
      getArticleByIdUseCase: serviceLocator<GetArticleByIdUseCase>(),
      createArticleUseCase: serviceLocator<CreateArticleUseCase>(),
      updateArticleUseCase: serviceLocator<UpdateArticleUseCase>(),
      deleteArticleUseCase: serviceLocator<DeleteArticleUseCase>(),
      uploadArticleImageUseCase: serviceLocator<UploadArticleImageUseCase>(),
    ),
  );

  serviceLocator.registerFactory<CategoryCubit>(
    () => CategoryCubit(
      getCategoriesUseCase: serviceLocator<GetCategoriesUseCase>(),
      addCategoryUseCase: serviceLocator<AddCategoryUseCase>(),
    ),
  );
}
