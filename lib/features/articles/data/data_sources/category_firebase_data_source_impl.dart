import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/category_model.dart';
import 'category_firebase_data_source.dart';

/// Implementación concreta del [CategoryFirebaseDataSource].
/// Interactúa directamente con Firebase Firestore.
class CategoryFirebaseDataSourceImpl implements CategoryFirebaseDataSource {
  final FirebaseFirestore _firestore;

  const CategoryFirebaseDataSourceImpl(this._firestore);

  CollectionReference get _categoriesRef =>
      _firestore.collection(FirebaseConstants.categoriesCollection);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _categoriesRef.orderBy('name').get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<CategoryModel> addCategory(String name) async {
    // Verificar si ya existe una categoría con ese nombre (case-insensitive)
    final existing = await _categoriesRef
        .where('nameLower', isEqualTo: name.toLowerCase().trim())
        .get();

    if (existing.docs.isNotEmpty) {
      return CategoryModel.fromFirestore(existing.docs.first);
    }

    final docRef = await _categoriesRef.add({
      'name': name.trim(),
      'nameLower': name.toLowerCase().trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    final createdDoc = await docRef.get();
    return CategoryModel.fromFirestore(createdDoc);
  }
}
