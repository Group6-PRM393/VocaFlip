import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voca_flip_mobile/core/providers/data_refresh_notifier.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';
import 'package:voca_flip_mobile/features/category/models/category_model.dart';
import 'package:voca_flip_mobile/features/category/providers/category_provider.dart';

class CreateDeckScreen extends ConsumerStatefulWidget {
  const CreateDeckScreen({super.key});

  @override
  ConsumerState<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends ConsumerState<CreateDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _submitting = false;
  CategoryModel? _selectedCategory;

  /// Dùng XFile + bytes thay vì dart:io File để tương thích Flutter Web
  XFile? _coverXFile;
  Uint8List? _coverBytes;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final XFile? x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;

    final bytes = await x.readAsBytes();
    setState(() {
      _coverXFile = x;
      _coverBytes = bytes;
    });
  }

  void _clearCover() {
    setState(() {
      _coverXFile = null;
      _coverBytes = null;
    });
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = await ref.read(deckRepositoryProvider.future);

      // Dùng createDeckFromBytes cho cả Web lẫn Mobile (XFile.readAsBytes hoạt động trên mọi nền tảng)
      await repo.createDeckFromBytes(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        categoryId: _selectedCategory!.id,
        coverBytes: _coverBytes,
        coverFileName: _coverXFile?.name,
      );

      // ✅ refresh danh sách deck
      ref.invalidate(deckListProvider);
      dataRefreshNotifier.bump();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E5EFF),
            elevation: 0,
            title: const Text(
              'Create New Deck',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            leading: const BackButton(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel('DECK TITLE'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g., Advanced Verbs 101',
                      suffixIcon: const Icon(Icons.edit_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Title is required';
                      if (s.length < 3) return 'Title is too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const _FieldLabel('DESCRIPTION'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'What is this deck about?',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Description is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const _FieldLabel('CATEGORY'),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    loading: () => Container(
                      height: 56,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (e, _) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Load categories failed')),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(categoryListProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (cats) {
                      return DropdownButtonFormField<CategoryModel>(
                        initialValue: _selectedCategory,
                        items: cats
                            .map(
                              (c) => DropdownMenuItem<CategoryModel>(
                                value: c,
                                child: Text(c.categoryName),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: InputDecoration(
                          hintText: 'Select a category',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (v) =>
                            v == null ? 'Please select a category' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(child: _FieldLabel('COVER PHOTO')),
                      TextButton(
                        onPressed: _coverBytes == null ? null : _clearCover,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _CoverUploadBox(imageBytes: _coverBytes, onTap: _pickCover),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5EFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Create Deck',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_submitting)
          Positioned.fill(
            child: Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Widget hiển thị ảnh bìa — dùng Image.memory (bytes) thay vì Image.file
class _CoverUploadBox extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  const _CoverUploadBox({required this.imageBytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E5EFF), width: 1.2),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: Color(0xFF1E5EFF),
                    size: 28,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap to upload cover image',
                    style: TextStyle(
                      color: Color(0xFF1E5EFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'PNG, JPG up to 5MB',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
