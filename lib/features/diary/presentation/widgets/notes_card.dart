import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotesCard extends StatefulWidget {
  final String? initialNote;
  final Function(String) onSave;

  const NotesCard({super.key, this.initialNote, required this.onSave});

  @override
  State<NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<NotesCard> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late String _baselineNote;
  bool _isExpanded = false;
  bool _isDirty = false;

  void _toggleExpanded() {
    final shouldExpand = !_isExpanded;

    setState(() {
      _isExpanded = shouldExpand;
      if (!shouldExpand) {
        _focusNode.unfocus();
      }
    });

    if (shouldExpand) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        () async {
          await Scrollable.ensureVisible(
            context,
            alignment: 0.2,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
          if (!mounted) return;
          _focusNode.requestFocus();
        }();
      });
    }
  }

  void _saveNote() {
    if (!_isDirty) return;

    widget.onSave(_controller.text);
    setState(() {
      _baselineNote = _controller.text;
      _isDirty = false;
    });
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota salva.')),
    );
  }

  @override
  void initState() {
    super.initState();
    _baselineNote = widget.initialNote ?? '';
    _controller = TextEditingController(text: _baselineNote);
    _controller.addListener(() {
      setState(() {
        _isDirty = _controller.text != _baselineNote;
      });
    });
  }

  @override
  void didUpdateWidget(covariant NotesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNote != oldWidget.initialNote && !_isDirty) {
      _baselineNote = widget.initialNote ?? '';
      _controller.text = _baselineNote;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _baselineNote.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _toggleExpanded,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF9C4), // Light yellow
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: Color(0xFFFBC02D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Diário do dia',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (!_isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    preview.isNotEmpty
                                        ? preview
                                        : 'Sem nota hoje. Toque para adicionar.',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isExpanded)
                TextButton.icon(
                  onPressed: _isDirty ? _saveNote : null,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Salvar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    disabledForegroundColor:
                        AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              IconButton(
                onPressed: _toggleExpanded,
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                ),
                tooltip: _isExpanded ? 'Recolher' : 'Expandir',
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                focusNode: _focusNode,
                controller: _controller,
                maxLines: 5,
                minLines: 2,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  _saveNote();
                },
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'Escreva sobre seu dia, humor, fome, sintomas...',
                  hintStyle:
                      const TextStyle(fontSize: 15, color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
