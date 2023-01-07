import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'constants.dart' as constants;
import 'main.dart';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class MealDetails extends StatefulWidget {
  const MealDetails({Key? key}) : super(key : key);

  static const String routname = '/SecondScreeen';

  @override
  State<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails> {

  bool _isEditable = false;
  bool _isVisible = true;
  bool _revertToOriginal = false;

  final TextEditingController _soupController = TextEditingController();
  final TextEditingController _fishController = TextEditingController();
  final TextEditingController _meatController = TextEditingController();
  final TextEditingController _vegetarianController = TextEditingController();
  final TextEditingController _dessertController = TextEditingController();
  bool _submitting = false;
  bool _submitSuccess = false;
  String _submitErrorMessage = '';

  late Meal _meal;
  
  List<CameraDescription>? _cameras; // list out the camera available
  CameraController? _controller; // controller for camera
  XFile? _imageCamera; // for captured image

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  late LocationData _locationData;
  Location _location = Location();

  double _latitude = 0.0, _longitude = 0.0;
  Future<void> _getCoordinates() async {
    _locationData = await _location.getLocation();
    _latitude = _locationData.latitude ?? 0.0;
    _longitude = _locationData.longitude ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadCamera();
    _initLocation();
  }

  Future<void> _initLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      // update screen
    });
  }

  _loadCamera() async {
    _cameras = await availableCameras();
    if(_cameras != null){
      _controller = CameraController(_cameras![0], ResolutionPreset.max); //cameras[0] = first camera, change to 1 to another camera

      _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }else{
      debugPrint("No camera found");
    }
  }


  Future<void> _submitChanges() async {
    setState(() {
      _submitting = true;
      _submitSuccess = false;
      _submitErrorMessage = '';
    });
    try {
      Meal updatedMeal;
      if (!_revertToOriginal){
        updatedMeal = Meal(
          thereIsAnUpdatedMeal: true,
          weekDay: _meal.weekDay,
          originalSoup: _meal.originalSoup,
          originalFish: _meal.originalFish,
          originalMeat: _meal.originalMeat,
          originalVegetarian: _meal.originalVegetarian,
          originalDessert: _meal.originalDessert,
          updatedSoup: _soupController.text,
          updatedFish: _fishController.text,
          updatedMeat: _meatController.text,
          updatedVegetarian: _vegetarianController.text,
          updatedDessert: _dessertController.text,
          updatedImg: _meal.updatedImg,
          originalImg: _meal.originalImg,
          submitted: false,
        );
      } else {
        updatedMeal = Meal(
          thereIsAnUpdatedMeal: true,
          weekDay: _meal.weekDay,
          originalSoup: _meal.originalSoup,
          originalFish: _meal.originalFish,
          originalMeat: _meal.originalMeat,
          originalVegetarian: _meal.originalVegetarian,
          originalDessert: _meal.originalDessert,
          originalImg: _meal.originalImg,
          updatedSoup: "",
          updatedFish: "",
          updatedMeat: "",
          updatedVegetarian: "",
          updatedDessert: "",
          updatedImg: "",
          submitted: false,
        );
      }
      var imgBase64new = null;

      if (_imageCamera != null) {
        // Read the content of the XFile object into a Uint8List
        Uint8List imageBytes = await _imageCamera?.readAsBytes() as Uint8List;
        // Encode the Uint8List into a base64 String
        imgBase64new = imageBytes != null ? base64Encode(imageBytes) : null;
      }

      final uri = Uri.parse('${constants.SERVER_URL}/menu');
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            {
              "img": imgBase64new,
              "weekDay": updatedMeal.weekDay,
              "soup": updatedMeal.updatedSoup,
              "fish": updatedMeal.updatedFish,
              "meat": updatedMeal.updatedMeat,
              "vegetarian": updatedMeal.updatedVegetarian,
              "desert": updatedMeal.updatedDessert,
            }),
      );

      bool locationSuccess = false;
      String locationError = '';
      //var targetLatitude = 40.192833; var targetLongitude = -8.412939;
      final targetCoordinates = new LatLng(40.192833, -8.412939); // coordinates of cafeteria
      await _getCoordinates(); // updates variables _latitude & _longitude
      if (_permissionGranted == PermissionStatus.denied){
        locationError = "Location Permission Denied, can't submit";
      } else if (_latitude == 0.0 && _longitude == 0.0){
        locationError = "Location Error (coordinates 0.0 0.0?)";
      } else {

        final Distance distance = new Distance();
        final currentCoordinates = new LatLng(_latitude, _longitude);

        final double distanceInMeters = distance.as(LengthUnit.Meter, currentCoordinates, targetCoordinates);

        if (distanceInMeters >= 1000) { // more than 3Km away from cafeteria
          locationError = "More than 1Km away from cafeteria, currently ${distanceInMeters}Km away, not submitting";
        } else {
          locationSuccess = true;
        }
      }

      if (response.statusCode == 201) { // seems like it works when its 201 and not HttpStatus.ok

        if (locationSuccess){
          setState(() {
            _submitting = false;
            _submitSuccess = true;
            _submitErrorMessage = '';
          });
          Navigator.of(context).pop(_submitSuccess);

        } else {
          setState(() {
            _submitting = false;
            _submitErrorMessage = locationError;
          });
        }

      } else {
        setState(() {
          _submitting = false;
          _submitErrorMessage = '${utf8.decode(response.bodyBytes)} response.statusCode: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _submitting = false;
        _submitErrorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    _meal = ModalRoute.of(context)!.settings.arguments as Meal;
    _soupController.text = _meal.updatedSoup;
    _fishController.text = _meal.updatedFish;
    _meatController.text = _meal.updatedMeat;
    _vegetarianController.text = _meal.updatedVegetarian;
    _dessertController.text = _meal.updatedDessert;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Meal Details',
          style: TextStyle(
            color: Colors.indigo,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async{
                        try {
                          _revertToOriginal = false;
                          if(_controller != null){ //check if controller is not null
                            if(_controller!.value.isInitialized){ //check if controller is initialized
                              _controller?.setFlashMode(FlashMode.off);
                              _imageCamera = await _controller!.takePicture(); //capture image
                              setState(() {
                                //update UI
                              });
                            }
                          }
                        } catch (e) {
                          print(e); //show error
                        }
                      },
                    ),

                     Text('Change Meal Image'),
                  ],
                ),
              ),

              if (_imageCamera == null || _revertToOriginal==true)...[
                if (_meal.updatedImg.isEmpty || _revertToOriginal==true)...[

                  if (_meal.originalImg == null || _meal.originalImg.isEmpty)...[
                    SizedBox(
                      height: 200,
                      child: Image.asset('images/DefaultMeal-evie-s-unsplash.jpg'),
                    ),
                  ]else...[
                    SizedBox(
                      height: 200,
                      child: Image.network('${constants.SERVER_URL}/images/${_meal.originalImg}'),
                    ),
                  ]
                ]else...[
                  SizedBox(
                    height: 200,
                    child: Image.network('${constants.SERVER_URL}/images/${_meal.updatedImg}'),
                  ),
                ],
              ]else...[
                Container( //show captured image
                  padding: EdgeInsets.all(30),
                  child: Image.file(File(_imageCamera!.path), height: 300,), //display captured image
                ),
              ],

            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState (() {
                    _isVisible = false;
                    _revertToOriginal = true;
                  });
                },
                child: const Text('Repor'),
              ),
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState (() {
                      _isEditable = true;
                      _isVisible = true;
                    });
                  }),
            ],
          ),


          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(

              children: [

                if(_isVisible && (_meal.thereIsAnUpdatedMeal || _isEditable))...[
                  if(_meal.originalSoup != _meal.updatedSoup ||
                      _meal.originalFish != _meal.updatedFish ||
                      _meal.originalMeat != _meal.updatedMeat ||
                      _meal.originalVegetarian != _meal.updatedVegetarian ||
                      _meal.originalDessert != _meal.updatedDessert ||
                      _isEditable
                  )...[


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const <Widget> [
                                Expanded(
                                  child:Text(
                                    'Ementa Atualizada',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        if (_meal.originalSoup != _meal.updatedSoup || _isEditable)...[
                          const Text('Sopa: '),
                          TextFormField(
                            controller: _soupController,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (_meal.originalFish != _meal.updatedFish || _isEditable)...[
                          const Text('Prato Peixe: '),
                          TextFormField(
                            controller: _fishController,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (_meal.originalMeat != _meal.updatedMeat || _isEditable)...[
                          const Text('Prato Carne: '),
                          TextFormField(
                            controller: _meatController,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (_meal.originalVegetarian != _meal.updatedVegetarian || _isEditable)...[
                          const Text('Prato Vegetariano: '),
                          TextFormField(
                            controller: _vegetarianController,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (_meal.originalDessert != _meal.updatedDessert || _isEditable)...[
                          const Text('\nSobremesa: '),
                          TextFormField(
                            controller: _dessertController,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                      ],
                    ),
                  ),
                ],
                ],
              ],
            ),
          ),

          Container(
              padding: const EdgeInsets.all(8.0),

              child: Row(
                  children:[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: <Widget> [
                                  Expanded(
                                    child: Text(
                                      'Ementa Original',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),


                          Text('Sopa: ${_meal.originalSoup}\n'),
                          Text('Prato Peixe: ${_meal.originalFish}\n'),
                          Text('Prato Carne: ${_meal.originalMeat}\n'),
                          Text('Prato Vegetariano: ${_meal.originalVegetarian}\n'),
                          Text('Sobremesa: ${_meal.originalDessert}\n'),
                        ],
                      ),
                    ),

                  ]
              )
          ),

          SizedBox(height: 8.0),
          const SizedBox(height: 16.0),
          if (_submitting)
            const CircularProgressIndicator()
          else if (_submitSuccess)
            Text('Changes submitted successfully')
          else if (_submitErrorMessage.isNotEmpty)
              Text(_submitErrorMessage),
          const SizedBox(height: 16.0),
          Hero(
            tag: 'backToMain',
            child: ElevatedButton(
                onPressed: _submitting ? null : _submitChanges,
                child: const Text('Submit Changes'),
              ),
          )
        ],
        )
      ),
      //),
    );
  }
}