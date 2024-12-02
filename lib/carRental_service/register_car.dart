import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:carretera/carRental_service/car_list.dart';
import 'package:carretera/core/services/rental_car_service.dart';
import 'package:flutter/material.dart';

class RentalCarForm extends StatefulWidget {
  @override
  _RentalCarFormState createState() => _RentalCarFormState();
}

class _RentalCarFormState extends State<RentalCarForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<html.File>? _carImages = [];
  bool _isDragOver = false;
  bool _isAvailable = true;
  bool _isLoading = false;

  final RentalCarService _rentalCarService = RentalCarService();

  Future<void> _pickImagesFromFilePicker() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.multiple = true; // Permitir múltiples archivos
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) return;

      setState(() {
        _carImages = List.from(files!);
      });
    });
  }

  Future<void> _handleImageDrop(List<html.File> files) async {
    setState(() {
      _carImages = files;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final model = _modelController.text;
      final brand = _brandController.text;
      final price = double.tryParse(_priceController.text) ?? 0;
      final description = _descriptionController.text;

      if (_carImages != null && _carImages!.isNotEmpty) {
        try {
          // Llamamos al servicio para registrar el auto con múltiples imágenes
          await _rentalCarService.registerCar(
            model: model,
            brand: brand,
            price: price,
            carImages: _carImages!,
            description: description,
            isAvailable: _isAvailable,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CarListScreen()), 
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Auto registrado correctamente')),
          );
        } catch (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar el auto: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona al menos una imagen')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Auto para Renta'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Información del Auto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildTextFormField('Modelo', _modelController),
              _buildTextFormField('Marca', _brandController),
              _buildTextFormField('Precio por día', _priceController, isNumeric: true),
              _buildTextFormField('Descripción', _descriptionController),
              SizedBox(height: 20),
              Text('Disponibilidad', style: TextStyle(fontSize: 18)),
              SwitchListTile(
                title: Text('¿Disponible?'),
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Imagenes del Auto', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              _buildImagePicker(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Registrar Auto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el $label';
        }
        if (isNumeric && double.tryParse(value) == null) {
          return 'Por favor ingresa un número válido';
        }
        return null;
      },
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildImagePicker() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isDragOver = true),
      onExit: (_) => setState(() => _isDragOver = false),
      child: GestureDetector(
        onTap: _pickImagesFromFilePicker,
        child: DragTarget<html.File>( // Cambiar para recibir múltiples imágenes
          onWillAccept: (_) => true,
         
          builder: (context, candidateData, rejectedData) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: _isDragOver ? Colors.green : Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: _isDragOver ? Colors.green[50] : Colors.transparent,
              ),
              child: _carImages == null || _carImages!.isEmpty
                  ? Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.blueGrey))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _carImages!.length,
                      itemBuilder: (context, index) {
                        final file = _carImages![index];
                        return FutureBuilder<Uint8List>(
                          future: _loadImageBytes(file),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error al cargar la imagen'));
                            }
                            if (snapshot.hasData) {
                              return Image.memory(snapshot.data!, fit: BoxFit.cover);
                            }
                            return Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.blueGrey));
                          },
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<Uint8List> _loadImageBytes(html.File file) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as Uint8List);
    });

    reader.onError.listen((event) {
      completer.completeError('Error al cargar la imagen');
    });

    return completer.future;
  }
}
