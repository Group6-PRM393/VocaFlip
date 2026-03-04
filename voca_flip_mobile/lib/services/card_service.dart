import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/card_model.dart';

class CardService {
  final Dio dio;
  CardService(this.dio);

  Future<List<CardModel>> getCardsByDeck(String deckId) async {
    final res = await dio.get('/api/cards/deck/$deckId');
    final body = res.data;

    if (body is List) {
      return body
          .whereType<Map<String, dynamic>>()
          .map(CardModel.fromJson)
          .toList();
    }

    throw Exception('Invalid cards response: ${body.runtimeType} - $body');
  }
}
