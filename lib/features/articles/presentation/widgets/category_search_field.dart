import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';

/// Widget reutilizable que muestra un campo de búsqueda de categorías
/// con dropdown filtrado y botón para agregar nuevas categorías.
class CategorySearchField extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategory;
  final TextEditingController searchController;
  final bool isLoading;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;
  final ValueChanged<String> onAdd;

  const CategorySearchField({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.searchController,
    required this.isLoading,
    required this.onSelected,
    required this.onClear,
    required this.onAdd,
  });

  @override
  State<CategorySearchField> createState() => _CategorySearchFieldState();
}

class _CategorySearchFieldState extends State<CategorySearchField> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<CategoryEntity> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
    _focusNode.addListener(_handleFocusChange);
    widget.searchController.addListener(_handleSearchChanged);
  }

  @override
  void didUpdateWidget(covariant CategorySearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _filterCategories(widget.searchController.text);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_handleFocusChange);
    widget.searchController.removeListener(_handleSearchChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _filterCategories(widget.searchController.text);
      _showOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _handleSearchChanged() {
    _filterCategories(widget.searchController.text);
    if (_focusNode.hasFocus) {
      _removeOverlay();
      _showOverlay();
    }
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories
            .where((c) =>
                c.name.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();
      }
    });
  }

  bool get _searchHasNoExactMatch {
    final query = widget.searchController.text.trim();
    if (query.isEmpty) return false;
    return !widget.categories
        .any((c) => c.name.toLowerCase() == query.toLowerCase());
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: _buildDropdownContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContent() {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final items = <Widget>[
      ..._buildCategoryItems(),
      ..._buildEmptyStateItems(),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: items,
    );
  }

  List<Widget> _buildCategoryItems() {
    return _filteredCategories.map((category) {
      return InkWell(
        onTap: () => _selectCategory(category.name),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.label_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (widget.selectedCategory == category.name)
                const Icon(Icons.check, size: 18, color: Colors.green),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildEmptyStateItems() {
    if (_filteredCategories.isEmpty && widget.searchController.text.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay categorías. Escribe para crear una.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ];
    }

    if (_filteredCategories.isEmpty &&
        widget.searchController.text.isNotEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'No se encontraron coincidencias',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ];
    }

    return [];
  }

  void _selectCategory(String name) {
    widget.onSelected(name);
    widget.searchController.clear();
    _focusNode.unfocus();
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedCategoryChip(),
        _buildSearchFieldWithAddButton(),
      ],
    );
  }

  Widget _buildSelectedCategoryChip() {
    if (widget.selectedCategory == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Chip(
            avatar: const Icon(Icons.category, size: 18),
            label: Text(widget.selectedCategory!),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: widget.onClear,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFieldWithAddButton() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Categoría (opcional)',
                hintText: widget.selectedCategory != null
                    ? 'Cambiar categoría...'
                    : 'Buscar o crear categoría...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          widget.searchController.clear();
                          _filterCategories('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_searchHasNoExactMatch) ...[
            const SizedBox(width: 8),
            _buildAddButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(top: 1),
      child: IconButton.filled(
        onPressed: () {
          final name = widget.searchController.text.trim();
          if (name.isNotEmpty) {
            widget.onAdd(name);
            _focusNode.unfocus();
            _removeOverlay();
          }
        },
        icon: const Icon(Icons.add),
        tooltip: 'Agregar categoría',
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
