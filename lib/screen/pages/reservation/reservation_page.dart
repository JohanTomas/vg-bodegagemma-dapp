// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:myapp/models/reservation_model.dart';
import 'package:myapp/services/reservation_service.dart';
import 'package:myapp/screen/pages/reservation/reservation_modal_page.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  late List<Reservation> _reservationList;
  late List<Reservation> _filteredReservationList;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _reservationList = [];
    _filteredReservationList = [];
    _searchController = TextEditingController();
    _searchController.addListener(_filterReservations);
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      List<Reservation> activeReservations =
          await ReservationService.getActiveReservations();
      List<Reservation> inactiveReservations =
          await ReservationService.getInactiveReservations();
      setState(() {
        _reservationList = [...activeReservations, ...inactiveReservations];
        _filteredReservationList = _reservationList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las reservas: $e')),
      );
    }
  }

  void _filterReservations() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReservationList = _reservationList.where((reservation) {
        bool matchesClientName =
            reservation.clientNames?.toLowerCase().contains(query) ?? false;
        bool matchesSellerName =
            reservation.sellerNames?.toLowerCase().contains(query) ?? false;
        bool matchesTotal =
            reservation.totalReservation?.toString().contains(query) ?? false;
        bool matchesDateTime = reservation.formattedReservationDate
                ?.toLowerCase()
                .contains(query) ??
            false;
        return matchesClientName ||
            matchesSellerName ||
            matchesTotal ||
            matchesDateTime;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const SizedBox(height: 16.0),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar Reserva',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black, size: 28),
                    onPressed: () {
                      _navigateToReservationDetail(Reservation.empty());
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                  child:
                      Text('Activas', style: TextStyle(color: Colors.black))),
              Tab(
                  child:
                      Text('Inactivas', style: TextStyle(color: Colors.black))),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildReservationList(true),
                  _buildReservationList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationList(bool showActive) {
    List<Reservation> filteredReservations = _filteredReservationList
        .where((reservation) => reservation.active == (showActive ? 'A' : 'I'))
        .toList();

    if (filteredReservations.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay reservas activas'
            : 'No hay reservas inactivas'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredReservations.length,
      itemBuilder: (context, index) {
        Reservation reservation = filteredReservations[index];
        bool isActive = reservation.active == 'A';
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'N° de reserva: ${reservation.id}\nCliente: ${reservation.clientNames}\nVendedor: ${reservation.sellerNames}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${reservation.formattedReservationDate}'),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: S/.${reservation.totalReservation?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(fontSize: 15, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isActive ? Icons.delete : Icons.restore,
                    color: isActive ? Colors.red : Colors.blue,
                    size: 24,
                  ),
                  onPressed: () {
                    _showConfirmationDialog(context, reservation);
                  },
                ),
              ],
            ),
            onTap: () {
              if (isActive) {
                _navigateToReservationDetail(reservation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'No se puede abrir el formulario para reservas inactivas.'),
                  ),
                );
              }
            },
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }

  void _showConfirmationDialog(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reservation.active == 'A'
              ? "Eliminar Reserva"
              : "Restaurar Reserva"),
          content: Text(reservation.active == 'A'
              ? "¿Estás seguro de eliminar esta reserva?"
              : "¿Estás seguro de restaurar esta reserva?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (reservation.active == 'A') {
                  _deleteReservation(context, reservation.id!);
                } else {
                  _restoreReservation(context, reservation.id!);
                }
              },
              child: Text(
                  reservation.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteReservation(BuildContext context, int reservationId) async {
    try {
      await ReservationService.logicalDeleteReservation(reservationId);
      _loadReservations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva eliminada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la reserva: $e')),
      );
    }
  }

  void _restoreReservation(BuildContext context, int reservationId) async {
    try {
      await ReservationService.activateReservation(reservationId);
      _loadReservations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva restaurada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar la reserva: $e')),
      );
    }
  }

  void _handleReservationSaved(Reservation reservation, bool isNewReservation) {
    _loadReservations();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewReservation
              ? 'Reserva insertada exitosamente'
              : 'Reserva editada exitosamente',
        ),
      ),
    );
  }

  void _navigateToReservationDetail(Reservation reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationModalPage(
          reservation: reservation,
          onReservationSaved: _handleReservationSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterReservations);
    _searchController.dispose();
    super.dispose();
  }
}
