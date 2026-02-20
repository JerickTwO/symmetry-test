import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/use_cases/create_article_params.dart';
import '../../domain/use_cases/create_article_use_case.dart';
import '../../domain/use_cases/delete_article_use_case.dart';
import '../../domain/use_cases/get_article_by_id_use_case.dart';
import '../../domain/use_cases/get_articles_use_case.dart';
import '../../domain/use_cases/update_article_params.dart';
import '../../domain/use_cases/update_article_use_case.dart';
import '../../domain/use_cases/upload_article_image_use_case.dart';
import 'article_event.dart';
import 'article_state.dart';

/// BLoC de artículos.
/// Solo este componente importa los use_cases para satisfacer la lógica de UI.
class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetArticlesUseCase _getArticlesUseCase;
  final GetArticleByIdUseCase _getArticleByIdUseCase;
  final CreateArticleUseCase _createArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final UploadArticleImageUseCase _uploadArticleImageUseCase;

  ArticleBloc({
    required GetArticlesUseCase getArticlesUseCase,
    required GetArticleByIdUseCase getArticleByIdUseCase,
    required CreateArticleUseCase createArticleUseCase,
    required UpdateArticleUseCase updateArticleUseCase,
    required DeleteArticleUseCase deleteArticleUseCase,
    required UploadArticleImageUseCase uploadArticleImageUseCase,
  })  : _getArticlesUseCase = getArticlesUseCase,
        _getArticleByIdUseCase = getArticleByIdUseCase,
        _createArticleUseCase = createArticleUseCase,
        _updateArticleUseCase = updateArticleUseCase,
        _deleteArticleUseCase = deleteArticleUseCase,
        _uploadArticleImageUseCase = uploadArticleImageUseCase,
        super(const ArticleInitial()) {
    on<LoadArticles>(_onLoadArticles);
    on<LoadArticleDetail>(_onLoadArticleDetail);
    on<CreateArticleRequested>(_onCreateArticle);
    on<UpdateArticleRequested>(_onUpdateArticle);
    on<DeleteArticleRequested>(_onDeleteArticle);
  }

  Future<void> _onLoadArticles(
    LoadArticles event,
    Emitter<ArticleState> emit,
  ) async {
    emit(const ArticleLoading());

    final result = await _getArticlesUseCase(const NoParams());
    if (result.isSuccess) {
      emit(ArticlesLoaded(articles: result.data!));
    } else {
      emit(ArticleError(message: result.error!));
    }
  }

  Future<void> _onLoadArticleDetail(
    LoadArticleDetail event,
    Emitter<ArticleState> emit,
  ) async {
    emit(const ArticleLoading());

    final result = await _getArticleByIdUseCase(event.articleId);
    if (result.isSuccess) {
      emit(ArticleDetailLoaded(article: result.data!));
    } else {
      emit(ArticleError(message: result.error!));
    }
  }

  Future<void> _onCreateArticle(
    CreateArticleRequested event,
    Emitter<ArticleState> emit,
  ) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final thumbnailURL = await _uploadImageIfNeeded(
      imageData: event.imageData,
      imageFileName: event.imageFileName,
      articleId: tempId,
      emit: emit,
    );
    if (event.imageData != null && thumbnailURL == null) return;

    final result = await _createArticleUseCase(CreateArticleParams(
      title: event.title,
      content: event.content,
      thumbnailURL: thumbnailURL,
      category: event.category,
    ));

    if (result.isSuccess) {
      emit(const ArticleCreated());
    } else {
      emit(ArticleError(message: result.error!));
    }
  }

  Future<void> _onUpdateArticle(
    UpdateArticleRequested event,
    Emitter<ArticleState> emit,
  ) async {
    final thumbnailURL = await _uploadImageIfNeeded(
      imageData: event.imageData,
      imageFileName: event.imageFileName,
      articleId: event.id,
      emit: emit,
    );
    if (event.imageData != null && thumbnailURL == null) return;

    final result = await _updateArticleUseCase(UpdateArticleParams(
      id: event.id,
      title: event.title,
      content: event.content,
      thumbnailURL: thumbnailURL,
      category: event.category,
    ));

    if (result.isSuccess) {
      emit(const ArticleUpdated());
    } else {
      emit(ArticleError(message: result.error!));
    }
  }

  /// Sube una imagen a Storage si [imageData] no es null.
  /// Retorna la URL de la imagen subida, o null si no hay imagen o si falla.
  Future<String?> _uploadImageIfNeeded({
    required Uint8List? imageData,
    required String? imageFileName,
    required String articleId,
    required Emitter<ArticleState> emit,
  }) async {
    if (imageData == null) return null;

    final uploadResult = await _uploadArticleImageUseCase(
      UploadArticleImageParams(
        data: imageData,
        fileName: imageFileName ?? 'image.png',
        articleId: articleId,
      ),
    );

    if (uploadResult.isError) {
      emit(ArticleError(message: uploadResult.error!));
      return null;
    }

    return uploadResult.data;
  }

  Future<void> _onDeleteArticle(
    DeleteArticleRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(const ArticleLoading());

    try {
      await _deleteArticleUseCase(event.articleId);
      emit(const ArticleDeleted());
    } catch (e) {
      emit(ArticleError(message: e.toString()));
    }
  }
}
