import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/features/deck/models/deck_model.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';
import 'package:voca_flip_mobile/features/deck/widgets/deck_item_card.dart';
import 'package:voca_flip_mobile/features/deck/screens/create_deck_screen.dart';
import 'package:voca_flip_mobile/features/deck/screens/deck_detail_screen.dart';

class DeckListScreen extends ConsumerStatefulWidget {
  final String? filterCategoryId;
  final String? filterCategoryName;

  const DeckListScreen({
    super.key,
    this.filterCategoryId,
    this.filterCategoryName,
  });

  @override
  ConsumerState<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends ConsumerState<DeckListScreen> {
  List<DeckModel>? _localDecks;

  String get _screenTitle {
    final categoryName = widget.filterCategoryName?.trim();
    if (categoryName == null || categoryName.isEmpty) return 'My Decks';
    return categoryName;
  }

  bool get _hasCategoryFilter {
    final categoryId = widget.filterCategoryId?.trim();
    return categoryId != null && categoryId.isNotEmpty;
  }

  Future<List<DeckModel>> _readCurrentDecks() {
    if (_hasCategoryFilter) {
      return ref.read(
        deckListByCategoryProvider(widget.filterCategoryId!.trim()).future,
      );
    }
    return ref.read(deckListProvider.future);
  }

  void _invalidateCurrentDecks() {
    ref.invalidate(deckListProvider);
    if (_hasCategoryFilter) {
      ref.invalidate(
        deckListByCategoryProvider(widget.filterCategoryId!.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDecks = _hasCategoryFilter
        ? ref.watch(deckListByCategoryProvider(widget.filterCategoryId!.trim()))
        : ref.watch(deckListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5EFF),
        elevation: 0,
        title: Text(
          _screenTitle,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E5EFF),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateDeckScreen()),
          );

          if (created == true) {
            _invalidateCurrentDecks();
            final refreshed = await _readCurrentDecks();

            if (!mounted) return;
            setState(() {
              _localDecks = List<DeckModel>.from(refreshed);
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: asyncDecks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            _ErrorState(text: e.toString(), onRetry: _invalidateCurrentDecks),
        data: (decks) {
          final visibleDecks = _localDecks ?? decks;

          if (_localDecks == null) {
            _localDecks = List<DeckModel>.from(decks);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _invalidateCurrentDecks();
              final refreshed = await _readCurrentDecks();

              if (!mounted) return;
              setState(() {
                _localDecks = List<DeckModel>.from(refreshed);
              });
            },
            child: visibleDecks.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleDecks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final d = visibleDecks[i];
                      return DeckItemCard(
                        title: d.title,
                        cards: d.totalCards,
                        progress: d.progress,
                        imageUrl: d.coverImageUrl,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeckDetailScreen(deckId: d.id),
                            ),
                          );

                          if (result is String) {
                            setState(() {
                              _localDecks = (_localDecks ?? [])
                                  .where((deck) => deck.id != result)
                                  .toList();
                            });
                            return;
                          }

                          if (result == true) {
                            _invalidateCurrentDecks();
                            final refreshed = await _readCurrentDecks();

                            if (!mounted) return;
                            setState(() {
                              _localDecks = List<DeckModel>.from(refreshed);
                            });
                          }
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: Text(
            'No decks yet.\nTap + to create your first deck.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _ErrorState({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
