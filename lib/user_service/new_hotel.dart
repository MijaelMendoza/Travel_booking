import 'package:carretera/apis/countries_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HotelFormPage extends StatefulWidget {
  @override
  _HotelFormPageState createState() => _HotelFormPageState();
}

class _HotelFormPageState extends State<HotelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? selectedCountry;
  String? selectedCity;
  List<String> amenities = [];
  List<String> roomTypes = [];
  int rating = 0;
  String? imagePath;

  List<String> countries = [];
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final fetchedCountries = await CountriesApi.fetchCountries();
      setState(() {
        countries = fetchedCountries;
      });
    } catch (e) {
      print('Error al cargar países: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar países: $e")),
      );
    }
  }

  Future<void> _loadCities(String country) async {
    try {
      final fetchedCities = await CountriesApi.fetchCities(country);
      setState(() {
        cities = fetchedCities;
        selectedCity = null; // Restablece la ciudad al cambiar de país
      });
    } catch (e) {
      print('Error al cargar ciudades: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar ciudades: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          imagePath = pickedImage.path;
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _saveHotelToFirestore() async {
    if (selectedCountry == null || selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona un país y una ciudad.")),
      );
      return;
    }

    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona una imagen.")),
      );
      return;
    }

    try {
      final CollectionReference hotelsCollection =
          FirebaseFirestore.instance.collection('hotels');

      // Validar y convertir el precio
      double? pricePerNight;
      try {
        pricePerNight = double.parse(priceController.text);
      } catch (e) {
        throw Exception("El precio ingresado no es válido.");
      }

      await hotelsCollection.add({
        "name": nameController.text.trim(),
        "rating": rating,
        "description": descriptionController.text.trim(),
        "address": addressController.text.trim(),
        "country": selectedCountry ?? '',
        "city": selectedCity ?? '',
        "price": pricePerNight,
        "amenities": amenities,
        "roomTypes": roomTypes,
        "imagePath": imagePath,
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hotel guardado correctamente.")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error al guardar el hotel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el hotel: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añadir Hotel"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nombre del Hotel"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, ingresa un nombre.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text("Calificación:"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Descripción"),
                maxLines: 3,
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Dirección"),
              ),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                hint: Text("Selecciona un país"),
                items: countries.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCountry = value;
                      selectedCity = null;
                      _loadCities(value);
                    });
                  }
                },
              ),
              if (selectedCountry != null)
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  hint: Text("Selecciona una ciudad"),
                  items: cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                ),
              SizedBox(height: 16),
              Text("Amenidades:"),
              Wrap(
                spacing: 8.0,
                children: [
                  "Wi-Fi",
                  "Piscina",
                  "Desayuno Incluido",
                  "Estacionamiento",
                  "Gimnasio"
                ].map((amenity) {
                  return FilterChip(
                    label: Text(amenity),
                    selected: amenities.contains(amenity),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          amenities.add(amenity);
                        } else {
                          amenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text("Tipos de Habitación:"),
              Wrap(
                spacing: 8.0,
                children: ["Individual", "Doble", "Suite", "Familiar"]
                    .map((roomType) {
                  return FilterChip(
                    label: Text(roomType),
                    selected: roomTypes.contains(roomType),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          roomTypes.add(roomType);
                        } else {
                          roomTypes.remove(roomType);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Precio por noche"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, ingresa un precio.";
                  }
                  if (double.tryParse(value) == null) {
                    return "Por favor, ingresa un número válido.";
                  }
                  if (double.parse(value) <= 0) {
                    return "El precio debe ser mayor a 0.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Subir Imagen"),
                  ),
                  SizedBox(width: 8),
                  if (imagePath != null)
                    Text(
                      "Imagen seleccionada",
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveHotelToFirestore();
                  }
                },
                child: Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
