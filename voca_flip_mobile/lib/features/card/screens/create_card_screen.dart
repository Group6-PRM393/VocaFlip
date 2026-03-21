import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voca_flip_mobile/features/card/providers/card_provider.dart';

class CreateCardScreen extends ConsumerStatefulWidget {
  final String deckId;

  const CreateCardScreen({
    super.key,
    required this.deckId,
  });

  @override
  ConsumerState<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends ConsumerState<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  late final TextEditingController _phoneticController;
  late final TextEditingController _exampleController;

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController();
    _backController = TextEditingController();
    _phoneticController = TextEditingController();
    _exampleController = TextEditingController();
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _phoneticController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
        _selectedImage = null;
      });
    } else {
      setState(() {
        _selectedImage = File(picked.path);
        _selectedImageBytes = null;
        _selectedImageName = picked.name;
      });
    }
  }

  Future<void> _saveCard() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    ref.read(cardActionLoadingProvider.notifier).state = true;

    try {
      final repo = await ref.read(cardRepositoryProvider.future);

      if (kIsWeb) {
        await repo.createCardFromBytes(
          deckId: widget.deckId,
          front: _frontController.text,
          back: _backController.text,
          phonetic: _phoneticController.text,
          exampleSentence: _exampleController.text,
          imageBytes: _selectedImageBytes,
          imageFileName: _selectedImageName,
        );
      } else {
        await repo.createCard(
          deckId: widget.deckId,
          front: _frontController.text,
          back: _backController.text,
          phonetic: _phoneticController.text,
          exampleSentence: _exampleController.text,
          imageFile: _selectedImage,
        );
      }

      ref.invalidate(cardListProvider(widget.deckId));
      ref.read(cardActionLoadingProvider.notifier).state = false;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card created successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ref.read(cardActionLoadingProvider.notifier).state = false;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create card failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(cardActionLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Front (Word/Phrase)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _frontController,
                        hintText: 'Type word here...',
                        maxLines: 1,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter word or phrase';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Back (Meaning)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _backController,
                        hintText: 'Type meaning here...',
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter meaning';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: const [
                          Text(
                            'Pronunciation',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '(Optional)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _phoneticController,
                        hintText: '/prəˌnʌnsiˈeɪʃ(ə)n/',
                        maxLines: 1,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Example Sentence'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _exampleController,
                        hintText: 'Type a sentence using the word...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Image (Optional)'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: (_selectedImage == null &&
                                  _selectedImageBytes == null)
                              ? const Center(
                                  child: Text(
                                    'Tap to upload image',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: kIsWeb
                                      ? Image.memory(
                                          _selectedImageBytes!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
            ),
          ),
          const Text(
            'Add New Card',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool isLoading) {
    return Container(
      color: const Color(0xFFF3F4F8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2146F3),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFB6BDC9),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines == 1 ? 16 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    );
  }
}