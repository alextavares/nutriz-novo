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
  bool _isExpanded = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _controller.addListener(() {
      setState(() {
        _isDirty = _controller.text != (widget.initialNote ?? '');
      });
    });
  }

  @override
  void didUpdateWidget(covariant NotesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNote != oldWidget.initialNote && !_isDirty) {
      _controller.text = widget.initialNote ?? '';
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  // Request focus after a short delay to allow animation to start
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      _focusNode.requestFocus();
                    }
                  });
                } else {
                  _focusNode.unfocus();
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9C4), // Light yellow
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: Color(0xFFFBC02D),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Journal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                        if (!_isExpanded &&
                            (widget.initialNote?.isNotEmpty ?? false))
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.initialNote!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: TextField(
                focusNode: _focusNode,
                controller: _controller,
                maxLines: 6,
                minLines: 3,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFF2D3436),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'Write about your day, feelings, or symptoms...',
                  hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            if (_isDirty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onSave(_controller.text);
                    setState(() {
                      _isDirty = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    'Save Entry',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
