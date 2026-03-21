import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_flip_mobile/features/deck/providers/deck_provider.dart';
import 'package:voca_flip_mobile/features/card/providers/card_provider.dart';
import 'package:voca_flip_mobile/features/card/models/card_model.dart';
import 'package:voca_flip_mobile/features/deck/screens/edit_deck_screen.dart';
import 'package:voca_flip_mobile/features/study/study_screen.dart';
import 'package:voca_flip_mobile/features/card/screens/create_card_screen.dart';
import 'package:voca_flip_mobile/features/card/screens/edit_card_screen.dart';

class DeckDetailScreen extends ConsumerWidget {
  final String deckId;
  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDeck = ref.watch(deckDetailProvider(deckId));
    final asyncCards = ref.watch(cardListProvider(deckId));

    return asyncDeck.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Deck Details'),
          leading: const BackButton(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Load deck failed: $e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(deckDetailProvider(deckId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (deck) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              'Deck Details',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                 final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EditDeckScreen(deck: deck),
  ),
);

if (result is String) {
  if (!context.mounted) return;
  Navigator.pop(context, result); 
  return;
}

if (result == true) {
  final id = deck.id;

  ref.invalidate(deckDetailProvider(id));
  ref.invalidate(deckListProvider);

  await ref.read(deckDetailProvider(id).future);
}
                },

                child: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(deckDetailProvider(deckId));
                    ref.invalidate(cardListProvider(deckId));
                    await ref.read(deckDetailProvider(deckId).future);
                    await ref.read(cardListProvider(deckId).future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    children: [
                      // Category pill
                      if ((deck.category ?? '').trim().isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EEFF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              deck.category!,
                              style: const TextStyle(
                                color: Color(0xFF1E5EFF),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Title
                      Text(
                        deck.title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),

                      // Description
                      if ((deck.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          deck.description!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Meta row
                      Row(
                        children: [
                          const Icon(
                            Icons.style_outlined,
                            size: 18,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${deck.totalCards} Cards',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(deck.createdAt),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const Divider(height: 1),

                      // FLASHCARDS header
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text(
                            'FLASHCARDS',
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: sort
                            },
                            icon: const Icon(Icons.sort, size: 18),
                            label: const Text('Sort by'),
                          ),
                        ],
                      ),

                      // Cards list (REAL)
                      asyncCards.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.red.shade200),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Load cards failed: $e',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    ref.invalidate(cardListProvider(deckId)),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                        data: (cards) {
                          if (cards.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                'No flashcards yet.',
                                style: TextStyle(color: Colors.black45),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              for (final c in cards) ...[
                                _flashcardTile(context, ref, c),
                                const SizedBox(height: 12),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Floating +
                Positioned(
                  right: 18,
                  bottom: 98,
                  child: FloatingActionButton(
  backgroundColor: const Color(0xFF1E5EFF),
  onPressed: () async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCardScreen(deckId: deckId),
      ),
    );

    if (created == true) {
      ref.invalidate(cardListProvider(deckId));
      ref.invalidate(deckDetailProvider(deckId));

      await ref.read(cardListProvider(deckId).future);
      await ref.read(deckDetailProvider(deckId).future);
    }
  },
  child: const Icon(Icons.add, color: Colors.white),
),
                ),

                // Bottom actions
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E5EFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudyScreen(deckId: deckId),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Study Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF1E5EFF),
                                    width: 1.5,
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Test
                                },
                                icon: const Icon(
                                  Icons.school,
                                  color: Color(0xFF1E5EFF),
                                ),
                                label: const Text(
                                  'Test',
                                  style: TextStyle(
                                    color: Color(0xFF1E5EFF),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _flashcardTile(BuildContext context, WidgetRef ref, CardModel card) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.front,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if ((card.phonetic ?? '').trim().isNotEmpty)
                      Text(
                        card.phonetic!,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  card.back,
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((card.exampleSentence ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    card.exampleSentence!,
                    style: const TextStyle(color: Colors.black54, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              IconButton(
  onPressed: () async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCardScreen(card: card),
      ),
    );

    /// Nếu sửa thành công → reload lại list
    if (updated == true) {
      ref.invalidate(cardListProvider(card.deckId));
    }
  },
  icon: const Icon(Icons.edit, color: Color(0xFF1E5EFF)),
),
              IconButton(
  onPressed: () {
    _showDeleteCardDialog(context, ref, card);
  },
  icon: const Icon(
    Icons.delete_outline,
    color: Color(0xFF1E5EFF),
  ),
),
            ],
          ),
        ],
      ),
    );
  }
}
Future<void> _showDeleteCardDialog(
  BuildContext context,
  WidgetRef ref,
  CardModel card,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9ECFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete,
                  color: Color(0xFF4C63FF),
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Delete this word?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Roboto',
                  ),
                  children: [
                    const TextSpan(text: 'Are you sure you want to delete '),
                    TextSpan(
                      text: '"${card.front}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const TextSpan(
                      text:
                          '? This action cannot be undone and the card will be permanently removed.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4A4A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirmed != true) return;

  try {
    final repo = await ref.read(cardRepositoryProvider.future);
    await repo.deleteCard(card.id);

    ref.invalidate(cardListProvider(card.deckId));
    ref.invalidate(deckDetailProvider(card.deckId));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card deleted successfully')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete card failed: $e')),
    );
  }
}
