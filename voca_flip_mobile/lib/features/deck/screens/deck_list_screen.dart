import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';
import 'package:voca_flip_mobile/features/deck/widgets/deck_item_card.dart';
import 'package:voca_flip_mobile/features/deck/screens/create_deck_screen.dart';
import 'package:voca_flip_mobile/features/deck/screens/deck_detail_screen.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDecks = ref.watch(deckListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5EFF),
        elevation: 0,
        title: const Text(
          'My Decks',
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
            ref.invalidate(deckListProvider);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: asyncDecks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          text: e.toString(),
          onRetry: () => ref.invalidate(deckListProvider),
        ),
        data: (decks) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(deckListProvider);
            await ref.read(deckListProvider.future);
          },
          child: decks.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: decks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final d = decks[i];
                    return DeckItemCard(
                      title: d.title,
                      cards: d.totalCards,
                      progress: d.progress,
                      imageUrl: d.coverImageUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeckDetailScreen(deckId: d.id),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
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
