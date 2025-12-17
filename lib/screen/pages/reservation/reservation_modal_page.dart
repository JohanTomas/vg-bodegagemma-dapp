import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/models/client_model.dart';
import 'package:myapp/models/paymentMethod_model.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/models/reservation_detail_model.dart';
import 'package:myapp/models/reservation_model.dart';
import 'package:myapp/models/seller_model.dart';
import 'package:myapp/screen/pages/reservation/client_selection_screen.dart';
import 'package:myapp/screen/pages/reservation/payment_selection_screen.dart';
import 'package:myapp/screen/pages/reservation/seller_selection_screen.dart';
import 'package:myapp/services/reservation_service.dart';
import 'package:myapp/screen/pages/reservation/product_selection_screen.dart';

class ReservationModalPage extends StatefulWidget {
  final Reservation reservation;
  final Function(Reservation, bool) onReservationSaved;

  const ReservationModalPage({
    Key? key,
    required this.reservation,
    required this.onReservationSaved,
  }) : super(key: key);

  @override
  _ReservationModalPageState createState() => _ReservationModalPageState();
}

class _ReservationModalPageState extends State<ReservationModalPage> {
  late TextEditingController _clientController;
  late TextEditingController _sellerController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _reservationDateController;
  List<ReservationDetail> _reservationDetails = [];

  @override
  void initState() {
    super.initState();
    _clientController =
        TextEditingController(text: widget.reservation.clientNames);
    _sellerController =
        TextEditingController(text: widget.reservation.sellerNames);
    _paymentMethodController =
        TextEditingController(text: widget.reservation.paymentMethod.name);
    _reservationDateController =
        TextEditingController(text: widget.reservation.reservationDate);
    _reservationDetails.addAll(widget.reservation.reservationDetails);
  }

  void _saveReservation() async {
    if (_clientController.text.isEmpty ||
        _sellerController.text.isEmpty ||
        _paymentMethodController.text.isEmpty ||
        _reservationDateController.text.isEmpty ||
        _reservationDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
        ),
      );
      return;
    }

    try {
      final reservation = Reservation(
        id: widget.reservation.id,
        client: widget.reservation.client,
        seller: widget.reservation.seller,
        paymentMethod: widget.reservation.paymentMethod,
        reservationDate: _reservationDateController.text.isNotEmpty
            ? _reservationDateController.text
            : DateTime.now().toIso8601String(),
        reservationDetails: _reservationDetails,
      );

      if (widget.reservation.id == null) {
        await ReservationService.createReservation(reservation);
      } else {
        await ReservationService.updateReservation(
            reservation.id!, reservation);
      }

      widget.onReservationSaved(reservation, widget.reservation.id == null);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la reserva: $e')),
      );
    }
  }

  void _selectClient() async {
    final selectedClient = await Navigator.push<Client?>(
      context,
      MaterialPageRoute(
        builder: (context) => const ClientListScreen(),
      ),
    );

    if (selectedClient != null) {
      setState(() {
        widget.reservation.client = selectedClient;
        _clientController.text =
            '${selectedClient.names} ${selectedClient.lastName}';
      });
    }
  }

  void _selectSeller() async {
    final selectedSeller = await Navigator.push<Seller?>(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerListScreen(),
      ),
    );

    if (selectedSeller != null) {
      setState(() {
        widget.reservation.seller = selectedSeller;
        _sellerController.text =
            '${selectedSeller.names} ${selectedSeller.lastName}';
      });
    }
  }

  void _selectPaymentMethod() async {
    final selectedMethod = await Navigator.push<PaymentMethod?>(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentMethodListScreen(),
      ),
    );

    if (selectedMethod != null) {
      setState(() {
        widget.reservation.paymentMethod = selectedMethod;
        _paymentMethodController.text = selectedMethod.name;
      });
    }
  }

  void _selectReservationDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          DateTime finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _reservationDateController.text = finalDateTime.toIso8601String();
        });
      }
    }
  }

  void _addProduct() async {
    final Product? selectedProduct = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProductListScreen()),
    );

    if (selectedProduct != null) {
      _showProductDetails(selectedProduct);
    }
  }

  void _showProductDetails(Product product) {
    double quantity = 1;
    TextEditingController quantityController = TextEditingController(
      text: quantity.toStringAsFixed(product.unitSale == 'Kilo' ? 2 : 0),
    );

    bool allowDecimals = product.unitSale == 'Kilo';

    ReservationDetail? existingDetail;
    for (var detail in _reservationDetails) {
      if (detail.product.id == product.id) {
        existingDetail = detail;
        break;
      }
    }

    if (existingDetail != null) {
      quantity = existingDetail.amount;
      quantityController.text = quantity.toStringAsFixed(allowDecimals ? 2 : 0);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Precio de Venta: S/.${product.priceUnit.toStringAsFixed(2)}\n Unidad de Venta: ${product.unitSale}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Stock: ${product.stock}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 0) {
                            if (allowDecimals) {
                              quantity -= 0.1;
                            } else {
                              quantity--;
                            }
                            quantity = _roundToDecimals(
                                quantity, allowDecimals ? 2 : 0);
                            quantityController.text =
                                quantity.toStringAsFixed(allowDecimals ? 2 : 0);
                          }
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ingrese la cantidad'),
                            content: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: allowDecimals),
                              decoration: const InputDecoration(
                                hintText: 'Cantidad',
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    quantity = double.parse(value);
                                    quantity = _roundToDecimals(
                                        quantity, allowDecimals ? 2 : 0);
                                  });
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 30,
                        child: Text(
                          quantity.toStringAsFixed(allowDecimals ? 2 : 0),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (allowDecimals) {
                            quantity += 0.1;
                          } else {
                            quantity++;
                          }
                          quantity =
                              _roundToDecimals(quantity, allowDecimals ? 2 : 0);
                          quantityController.text =
                              quantity.toStringAsFixed(allowDecimals ? 2 : 0);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Total: S/.${(product.priceUnit * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (existingDetail != null) {
                          setState(() {
                            existingDetail!.amount = quantity;
                          });
                        } else {
                          setState(() {
                            _reservationDetails.add(ReservationDetail(
                              product: product,
                              amount: quantity,
                            ));
                          });
                        }
                        Navigator.pop(context);
                        _updateForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        existingDetail != null
                            ? 'Actualizar cantidad'
                            : 'Agregar a la reserva',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _roundToDecimals(double number, int decimals) {
    num fac = pow(10, decimals);
    return (number * fac).round() / fac;
  }

  Widget _buildProductList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _reservationDetails.length,
        itemBuilder: (context, index) {
          final reservationDetail = _reservationDetails[index];
          final product = reservationDetail.product;
          final totalPrice = reservationDetail.amount * product.priceUnit;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              onTap: () {
                _showProductDetails(product);
              },
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reservationDetail.amount} x S/.${product.priceUnit.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: S/.${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _reservationDetails.removeAt(index);
                    _updateForm();
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  double _calculateTotalAmount() {
    double totalAmount = 0;
    for (var reservationDetail in _reservationDetails) {
      totalAmount +=
          reservationDetail.amount * reservationDetail.product.priceUnit;
    }
    return totalAmount;
  }

  void _updateForm() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.reservation.id == null ? 'Nueva Reserva' : 'Editar Reserva',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _selectClient,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.person),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _clientController.text.isNotEmpty
                      ? _clientController.text
                      : 'Selecciona un cliente',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectSeller,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Vendedor',
                  prefixIcon: Icon(Icons.person_outline),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _sellerController.text.isNotEmpty
                      ? _sellerController.text
                      : 'Selecciona un vendedor',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectPaymentMethod,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: Icon(Icons.payment),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _paymentMethodController.text.isNotEmpty
                      ? _paymentMethodController.text
                      : 'Selecciona un método de pago',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectReservationDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Reserva',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.navigate_next),
                ),
                child: Text(
                  _reservationDateController.text.isNotEmpty
                      ? _reservationDateController.text
                      : 'Selecciona una fecha y hora',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Añadir Producto'),
            ),
            const SizedBox(height: 16),
            _buildProductList(),
            const SizedBox(height: 16),
            Text(
              'Monto a pagar: S/.${_calculateTotalAmount().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveReservation,
              child: Text(widget.reservation.id == null
                  ? 'Guardar Reserva'
                  : 'Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
