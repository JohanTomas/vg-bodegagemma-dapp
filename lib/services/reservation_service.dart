import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/models/reservation_model.dart'; // Asegúrate de tener este archivo

class ReservationService {
  static const String baseUrl = '${Config.baseUrl}/sistventas/api/reservations';

  static Future<List<Reservation>> getActiveReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/status/A'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Reservation>.from(data.map((model) => Reservation.fromJson(model)));
    } else {
      throw Exception('Failed to load active reservations');
    }
  }

  static Future<List<Reservation>> getInactiveReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/status/I'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(utf8.decode(response.bodyBytes));
      return List<Reservation>.from(data.map((model) => Reservation.fromJson(model)));
    } else {
      throw Exception('Failed to load inactive reservations');
    }
  }

  static Future<Reservation> getReservationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Reservation.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load reservation');
    }
  }

  static Future<void> createReservation(Reservation reservation) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(reservation.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create reservation: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateReservation(int id, Reservation reservation) async {
    final url = Uri.parse('$baseUrl/$id');
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode(reservation.toJson());

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Handle success case
      } else {
        throw Exception(
            'Failed to update reservation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update reservation: $e');
    }
  }

  static Future<void> logicalDeleteReservation(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/delete/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to logically delete reservation');
    }
  }

  static Future<void> activateReservation(int id) async {
    final response = await http.put(Uri.parse('$baseUrl/activate/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to activate reservation');
    }
  }
}