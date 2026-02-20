import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../articles/domain/use_cases/create_article_params.dart';
import '../../../articles/domain/use_cases/update_article_params.dart';
import '../models/article_model.dart';
import 'article_firebase_data_source.dart';

/// Implementación concreta del [ArticleFirebaseDataSource].
/// Interactúa directamente con Firebase Firestore.
class ArticleFirebaseDataSourceImpl implements ArticleFirebaseDataSource {
  final FirebaseFirestore _firestore;

  const ArticleFirebaseDataSourceImpl(this._firestore);

  CollectionReference get _articlesRef =>
      _firestore.collection(FirebaseConstants.articlesCollection);

  @override
  Future<List<ArticleModel>> getArticles() async {
    final snapshot =
        await _articlesRef.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
  }

  @override
  Future<ArticleModel> getArticleById(String id) async {
    final doc = await _articlesRef.doc(id).get();

    if (!doc.exists) {
      throw Exception('Artículo no encontrado');
    }

    return ArticleModel.fromFirestore(doc);
  }

  @override
  Future<ArticleModel> createArticle(CreateArticleParams params) async {
    final articleModel = ArticleModel(
      title: params.title,
      content: params.content,
      thumbnailURL: params.thumbnailURL,
      category: params.category,
      createdAt: DateTime.now(),
    );

    final docRef = await _articlesRef.add(articleModel.toFirestore());
    final createdDoc = await docRef.get();

    return ArticleModel.fromFirestore(createdDoc);
  }

  @override
  Future<ArticleModel> updateArticle(UpdateArticleParams params) async {
    final updateData = <String, dynamic>{
      'title': params.title,
      'content': params.content,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (params.thumbnailURL != null) {
      updateData['thumbnailURL'] = params.thumbnailURL;
    }
    if (params.category != null) {
      updateData['category'] = params.category;
    }

    await _articlesRef.doc(params.id).update(updateData);
    final updatedDoc = await _articlesRef.doc(params.id).get();

    return ArticleModel.fromFirestore(updatedDoc);
  }

  @override
  Future<void> deleteArticle(String id) async {
    await _articlesRef.doc(id).delete();
  }
}
