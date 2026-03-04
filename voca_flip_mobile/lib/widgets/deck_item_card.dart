import 'package:flutter/material.dart';
import 'package:voca_flip_mobile/models/card_model.dart';

class DeckItemCard extends StatelessWidget {
  final String title;
  final int cards;
  final double progress; // 0..1
  final String? imageUrl;
  final VoidCallback onTap;

  const DeckItemCard({
    super.key,
    required this.title,
    required this.cards,
    required this.progress,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _DeckThumbnail(imageUrl: imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '$cards Cards',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    progress <= 0 ? 'NOT STARTED' : '$percent% LEARNED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: progress <= 0 ? Colors.black38 : const Color(0xFF1E5EFF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress <= 0 ? 0.02 : progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE6E9F2),
                      valueColor: AlwaysStoppedAnimation(
                        progress <= 0 ? Colors.black26 : const Color(0xFF1E5EFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _DeckThumbnail extends StatelessWidget {
  final String? imageUrl;
  const _DeckThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 52,
        height: 52,
        child: hasUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.blue.shade100,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, color: Colors.white),
                  );
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.blue.shade100,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.blue.shade100,
                alignment: Alignment.center,
                child: const Icon(Icons.layers_outlined, color: Colors.white),
              ),
      ),
    );
  }
 Widget _cardTile(CardModel card) {
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
              Text(
                card.front, // ✅ đổi
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                card.back, // ✅ đổi
                style: const TextStyle(
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),

              // (tuỳ chọn) show phonetic + exampleSentence
              if ((card.phonetic ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(card.phonetic!, style: const TextStyle(color: Colors.black45)),
              ],
              if ((card.exampleSentence ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(card.exampleSentence!, style: const TextStyle(color: Colors.black54)),
              ],
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Color(0xFF1E5EFF)),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline, color: Color(0xFF1E5EFF)),
            ),
          ],
        ),
      ],
    ),
  );
}

}
class DeleteDeckDialog extends StatelessWidget {
  final String title;
  const DeleteDeckDialog({super.key, required this.title});

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
                color: Colors.red.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete Deck',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

