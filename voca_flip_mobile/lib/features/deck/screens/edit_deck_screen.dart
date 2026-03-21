import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:voca_flip_mobile/features/deck/models/deck_model.dart';
import 'package:voca_flip_mobile/features/category/models/category_model.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';
import 'package:voca_flip_mobile/features/category/providers/category_provider.dart';

class EditDeckScreen extends ConsumerStatefulWidget {
  final DeckModel deck;
  const EditDeckScreen({super.key, required this.deck});

  @override
  ConsumerState<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends ConsumerState<EditDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  bool _saving = false;

  CategoryModel? _selectedCategory;
  Uint8List? _newCoverBytes;
  String? _newCoverFileName;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.deck.title);
    _descCtrl = TextEditingController(text: widget.deck.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    setState(() {
      _newCoverBytes = bytes;
      _newCoverFileName = x.name;
    });
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select category')));
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = await ref.read(deckRepositoryProvider.future);

      await repo.updateDeckFromBytes(
        deckId: widget.deck.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        categoryId: _selectedCategory!.id,
        coverImageBytes: _newCoverBytes,
        coverFileName: _newCoverFileName,
      );

      // refresh
      ref.invalidate(deckDetailProvider(widget.deck.id));
      ref.invalidate(deckListProvider);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteDeck() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _DeleteDeckDialog(title: widget.deck.title),
    );

    if (confirmed != true) return;

    setState(() => _saving = true);

    try {
      final repo = await ref.read(deckRepositoryProvider.future);
      await repo.deleteDeck(widget.deck.id);

     ref.invalidate(deckListProvider);
      await repo.deleteDeck(widget.deck.id);

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pop(context, widget.deck.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = widget.deck.coverImageUrl;
    final categoriesAsync = ref.watch(categoryListProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black87),
            centerTitle: true,
            title: const Text(
              'Edit Deck',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover
                  InkWell(
                    onTap: _pickCover,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black12,
                        image: _newCoverBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_newCoverBytes!),
                                fit: BoxFit.cover,
                              )
                            : (coverUrl != null && coverUrl.trim().isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(coverUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Change Cover',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _Label('Deck Title'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: _inputDeco(),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Title is required';
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  const _Label('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 5,
                    decoration: _inputDeco(),
                  ),

                  const SizedBox(height: 14),

                  const _Label('Category'),
                  const SizedBox(height: 8),

                  categoriesAsync.when(
                    loading: () => Container(
                      height: 56,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (e, _) => Row(
                      children: [
                        Expanded(child: Text('Load categories failed: $e')),
                        TextButton(
                          onPressed: () => ref.invalidate(categoryListProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                    data: (cats) {
                      // ✅ set default theo tên category hiện tại của deck (1 lần)
                      _selectedCategory ??= cats.firstWhere(
                        (c) => c.name == (widget.deck.category ?? ''),
                        orElse: () => cats.isNotEmpty
                            ? cats.first
                            : CategoryModel(id: '', name: ''),
                      );
                      if (_selectedCategory?.id == '') _selectedCategory = null;

                      return DropdownButtonFormField<CategoryModel>(
                        initialValue: _selectedCategory,
                        items: cats
                            .map(
                              (c) => DropdownMenuItem<CategoryModel>(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: _inputDeco(),
                        validator: (v) =>
                            v == null ? 'Please select category' : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5EFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saving ? null : _submit,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Update Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _saving ? null : _deleteDeck,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Delete Deck',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_saving)
          Positioned.fill(
            child: Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E5EFF)),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }
}

class _DeleteDeckDialog extends StatelessWidget {
  final String title;
  const _DeleteDeckDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Delete Deck?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to delete the deck "$title"? '
              'This action will permanently remove all cards within it and cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete Deck',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
