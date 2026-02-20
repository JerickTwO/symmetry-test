import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import '../bloc/category_cubit.dart';
import '../bloc/category_state.dart';
import '../widgets/category_search_field.dart';
import '../widgets/markdown_editor.dart';

/// Wrapper que carga el artículo por ID para edición.
class ArticleFormScreenWrapper extends StatelessWidget {
  final String articleId;

  const ArticleFormScreenWrapper({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ArticleDetailLoaded) {
          return ArticleFormScreen(article: state.article);
        } else if (state is ArticleError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

/// Pantalla para crear o editar un artículo.
/// Si recibe un [article], es modo edición; si no, es modo creación.
class ArticleFormScreen extends StatefulWidget {
  final ArticleEntity? article;

  const ArticleFormScreen({super.key, this.article});

  bool get isEditing => article != null;

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final TextEditingController _categorySearchController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController =
        TextEditingController(text: widget.article?.content ?? '');
    _selectedCategory = widget.article?.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Artículo' : 'Nuevo Artículo'),
      ),
      body: BlocListener<ArticleBloc, ArticleState>(
        listener: (context, state) {
          if (state is ArticleCreated) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Artículo creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is ArticleUpdated) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Artículo actualizado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is ArticleError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildCategoryField(),
                const SizedBox(height: 16),
                _buildThumbnailField(),
                const SizedBox(height: 16),
                _buildContentField(),
                const SizedBox(height: 24),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      maxLength: 100,
      decoration: const InputDecoration(
        labelText: 'Título',
        hintText: 'Escribe el título del artículo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El título es obligatorio';
        }
        if (value.trim().length < 3) {
          return 'El título debe tener al menos 3 caracteres';
        }
        if (value.trim().length > 100) {
          return 'El título no puede superar los 100 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return BlocConsumer<CategoryCubit, CategoryState>(
      listener: (context, state) {
        if (state is CategoryAdded) {
          setState(() {
            _selectedCategory = state.addedCategory.name;
            _categorySearchController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Categoría "${state.addedCategory.name}" agregada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        final List<CategoryEntity> allCategories = state is CategoriesLoaded
            ? state.categories
            : state is CategoryAdded
                ? state.categories
                : [];

        return CategorySearchField(
          categories: allCategories,
          selectedCategory: _selectedCategory,
          searchController: _categorySearchController,
          isLoading: state is CategoryLoading,
          onSelected: (name) {
            setState(() => _selectedCategory = name);
          },
          onClear: () {
            setState(() => _selectedCategory = null);
          },
          onAdd: (name) {
            context.read<CategoryCubit>().addCategory(name);
          },
        );
      },
    );
  }

  Widget _buildThumbnailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen del artículo (opcional)',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        // Preview de imagen seleccionada o existente
        if (_selectedImageBytes != null)
          _buildSelectedImagePreview()
        else if (widget.isEditing &&
            widget.article?.thumbnailURL != null &&
            widget.article!.thumbnailURL!.isNotEmpty)
          _buildExistingImagePreview()
        else
          _buildImagePlaceholder(),

        const SizedBox(height: 12),

        // Botones para seleccionar imagen
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galería'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
            ),
          ],
        ),

        // Botón para eliminar imagen seleccionada
        if (_selectedImageBytes != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => setState(() {
                _selectedImageBytes = null;
                _selectedImageName = null;
              }),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text(
                'Quitar imagen',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        _selectedImageBytes!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildExistingImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        widget.article!.thumbnailURL!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Selecciona una imagen',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildContentField() {
    return MarkdownEditor(
      controller: _contentController,
      labelText: 'Contenido',
      hintText: 'Escribe el contenido del artículo usando Markdown...',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El contenido es obligatorio';
        }
        if (value.trim().length < 10) {
          return 'El contenido debe tener al menos 10 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : () => _onSubmit(context),
      icon: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.isEditing ? Icons.save : Icons.publish),
      label: Text(widget.isEditing ? 'Guardar Cambios' : 'Publicar Artículo'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _selectedCategory;

    if (widget.isEditing) {
      context.read<ArticleBloc>().add(
            UpdateArticleRequested(
              id: widget.article!.id!,
              title: title,
              content: content,
              imageData: _selectedImageBytes,
              imageFileName: _selectedImageName,
              category: category,
            ),
          );
    } else {
      context.read<ArticleBloc>().add(
            CreateArticleRequested(
              title: title,
              content: content,
              imageData: _selectedImageBytes,
              imageFileName: _selectedImageName,
              category: category,
            ),
          );
    }
  }
}
