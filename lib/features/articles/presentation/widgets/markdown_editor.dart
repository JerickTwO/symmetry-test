import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget de editor de Markdown con toolbar de formato y preview.
/// Permite al usuario escribir contenido con negritas, cursivas,
/// listas, encabezados, etc.
class MarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String labelText;
  final String hintText;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.validator,
    this.labelText = 'Contenido',
    this.hintText = 'Escribe el contenido...',
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_showPreview) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con label y toggle preview
        Row(
          children: [
            Text(
              widget.labelText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _buildPreviewToggle(),
          ],
        ),
        const SizedBox(height: 8),

        // Toolbar de formato (solo en modo edición)
        if (!_showPreview) ...[
          _buildToolbar(),
          const SizedBox(height: 8),
        ],

        // Editor o Preview
        if (_showPreview) _buildPreview() else _buildEditor(),
      ],
    );
  }

  Widget _buildPreviewToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          icon: Icon(Icons.edit, size: 16),
          label: Text('Editar', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(Icons.visibility, size: 16),
          label: Text('Preview', style: TextStyle(fontSize: 12)),
        ),
      ],
      selected: {_showPreview},
      onSelectionChanged: (selected) {
        setState(() => _showPreview = selected.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Negrita',
              onPressed: () => _wrapSelection('**', '**'),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Cursiva',
              onPressed: () => _wrapSelection('_', '_'),
            ),
            _ToolbarButton(
              icon: Icons.strikethrough_s,
              tooltip: 'Tachado',
              onPressed: () => _wrapSelection('~~', '~~'),
            ),
            _buildToolbarDivider(),
            _ToolbarButton(
              icon: Icons.title,
              tooltip: 'Encabezado',
              onPressed: () => _insertAtLineStart('## '),
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Lista con viñetas',
              onPressed: () => _insertAtLineStart('- '),
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Lista numerada',
              onPressed: () => _insertAtLineStart('1. '),
            ),
            _ToolbarButton(
              icon: Icons.check_box_outlined,
              tooltip: 'Checkbox',
              onPressed: () => _insertAtLineStart('- [ ] '),
            ),
            _buildToolbarDivider(),
            _ToolbarButton(
              icon: Icons.format_quote,
              tooltip: 'Cita',
              onPressed: () => _insertAtLineStart('> '),
            ),
            _ToolbarButton(
              icon: Icons.code,
              tooltip: 'Código inline',
              onPressed: () => _wrapSelection('`', '`'),
            ),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Enlace',
              onPressed: () => _insertLink(),
            ),
            _ToolbarButton(
              icon: Icons.horizontal_rule,
              tooltip: 'Línea divisoria',
              onPressed: () => _insertText('\n---\n'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.grey[400],
    );
  }

  Widget _buildEditor() {
    return TextFormField(
      controller: widget.controller,
      maxLines: 12,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
        helperText: 'Soporta formato Markdown',
        helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
      ),
      validator: widget.validator,
    );
  }

  Widget _buildPreview() {
    final content = widget.controller.text;
    if (content.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Nada que previsualizar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MarkdownBody(
        data: content,
        selectable: true,
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrl(Uri.parse(href));
          }
        },
      ),
    );
  }

  // ──────────────────── Métodos de inserción ────────────────────

  /// Envuelve el texto seleccionado con prefijo y sufijo.
  /// Si no hay selección, inserta el placeholder entre los marcadores.
  void _wrapSelection(String prefix, String suffix) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid) return;

    final selectedText = selection.textInside(text);
    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);

    if (selectedText.isEmpty) {
      final placeholder = _getPlaceholderFor(prefix);
      widget.controller.text = '$before$prefix$placeholder$suffix$after';
      widget.controller.selection = TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + placeholder.length,
      );
    } else {
      widget.controller.text = '$before$prefix$selectedText$suffix$after';
      widget.controller.selection = TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      );
    }
  }

  /// Inserta un prefijo al inicio de la línea actual.
  void _insertAtLineStart(String prefix) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid) return;

    // Encontrar el inicio de la línea actual
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final before = text.substring(0, lineStart);
    final after = text.substring(lineStart);

    widget.controller.text = '$before$prefix$after';
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length,
    );
  }

  /// Inserta texto en la posición actual del cursor.
  void _insertText(String insertion) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid) return;

    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);

    widget.controller.text = '$before$insertion$after';
    widget.controller.selection = TextSelection.collapsed(
      offset: selection.start + insertion.length,
    );
  }

  /// Inserta un enlace Markdown.
  void _insertLink() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid) return;

    final selectedText = selection.textInside(text);
    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);

    final linkText = selectedText.isEmpty ? 'texto del enlace' : selectedText;
    final link = '[$linkText](https://)';

    widget.controller.text = '$before$link$after';

    // Posicionar cursor en la URL
    final urlStart = selection.start + linkText.length + 3; // [text](
    widget.controller.selection = TextSelection(
      baseOffset: urlStart,
      extentOffset: urlStart + 8, // https://
    );
  }

  String _getPlaceholderFor(String prefix) {
    switch (prefix) {
      case '**':
        return 'negrita';
      case '_':
        return 'cursiva';
      case '~~':
        return 'tachado';
      case '`':
        return 'código';
      default:
        return 'texto';
    }
  }
}

/// Botón individual de la toolbar.
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(6),
      splashRadius: 18,
    );
  }
}
