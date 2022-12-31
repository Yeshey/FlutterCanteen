import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'constants.dart' as constants;
import 'main.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:camera/camera.dart';

class MealDetails extends StatefulWidget {
  const MealDetails({Key? key}) : super(key : key);

  static const String routname = '/SecondScreeen';

  @override
  State<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails> {

  bool _isEditable = false; //_isEnable is the boolean variable and set it false, so we have to make it true when user tap on text
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

  late Meal meal;



  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? imageCamera; //for captured image
  bool firstTime = true;

  @override
  void initState() {
    //loadCamera();
    super.initState();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if(cameras != null){
      controller = CameraController(cameras![0], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
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
          weekDay: meal.weekDay,
          originalSoup: meal.originalSoup,
          originalFish: meal.originalFish,
          originalMeat: meal.originalMeat,
          originalVegetarian: meal.originalVegetarian,
          originalDessert: meal.originalDessert,
          updatedSoup: _soupController.text,
          updatedFish: _fishController.text,
          updatedMeat: _meatController.text,
          updatedVegetarian: _vegetarianController.text,
          updatedDessert: _dessertController.text,
          img: meal.img,
          submitted: false,
        );
      } else {
        updatedMeal = Meal(
          thereIsAnUpdatedMeal: true,
          weekDay: meal.weekDay,
          originalSoup: meal.originalSoup,
          originalFish: meal.originalFish,
          originalMeat: meal.originalMeat,
          originalVegetarian: meal.originalVegetarian,
          originalDessert: meal.originalDessert,
          updatedSoup: "",
          updatedFish: "",
          updatedMeat: "",
          updatedVegetarian: "",
          updatedDessert: "",
          img: "",
          submitted: false,
        );
      }

      // Read the image file from the local file system
      final imageBytes = await rootBundle.load('images/cafeteria_meal.jpg');
// Decode the image as an Image object
      final img = image.decodeImage(imageBytes.buffer.asUint8List());
// Encode the image as a Base64 string
      final imgBase64 = base64Encode(image.encodeJpg(img));

      // Load the image file from the local file system
      //image.Image img = image.decodeImage(Image.asset('images/cafeteria_meal.jpg'));
      // Encode the image as a Base64 string
      //String imgBase64 = base64Encode(image.encodeJpg(img));

      final uri = Uri.parse('${constants.SERVER_URL}/menu');
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            {
              //"img": imgBase64,
              "img": null,
              "weekDay": updatedMeal.weekDay,
              "soup": updatedMeal.updatedSoup,
              "fish": updatedMeal.updatedFish,
              "meat": updatedMeal.updatedMeat,
              "vegetarian": updatedMeal.updatedVegetarian,
              "desert": updatedMeal.updatedDessert,
            }),
      );



      if (response.statusCode == HttpStatus.ok) {
        setState(() {
          _submitting = false;
          _submitSuccess = true;
          _submitErrorMessage = utf8.decode(response.bodyBytes);
        });
        Navigator.of(context).pop();

      } else {
        setState(() {
          _submitting = false;
          _submitErrorMessage = utf8.decode(response.bodyBytes);
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

    final path = 'path/to/save/image.jpg';

    meal = ModalRoute.of(context)!.settings.arguments as Meal;
    _soupController.text = meal.updatedSoup;
    _fishController.text = meal.updatedFish;
    _meatController.text = meal.updatedMeat;
    _vegetarianController.text = meal.updatedVegetarian;
    _dessertController.text = meal.updatedDessert;
    // final int? counter = ModalRoute.of(context).settings.arguments;
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
        //child: Stack(
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
                          if (firstTime){
                            await loadCamera();
                            firstTime = false;
                          }
                          if(controller != null){ //check if controller is not null
                            if(controller!.value.isInitialized){ //check if controller is initialized
                              imageCamera = await controller!.takePicture(); //capture image
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

                    //CameraPreview(cameraController),
                    //Image.file(File(path)),
                    Hero(
                      tag: 'AmovTag1',
                      child: Text('Change Meal Image'),
                    ),
                  ],
                ),
              ),

              if (imageCamera == null)...[
                if (meal.img.isEmpty)...[
                  SizedBox(
                    height: 200,
                    child: Image.asset('images/DefaultMeal-evie-s-unsplash.jpg'),
                  ),
                ]else...[
                  SizedBox(
                    height: 200,
                    child: Image.network('${constants.SERVER_URL}/images/${meal.img}'),
                  ),
                ],
              ]else...[
                Container( //show captured image
                  padding: EdgeInsets.all(30),
                  child: Image.file(File(imageCamera!.path), height: 300,),
                  //display captured image
                ),
              ],

            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Add code to handle "Repor" button press
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

                if(_isVisible && (meal.thereIsAnUpdatedMeal || _isEditable))...[
                  if(meal.originalSoup != meal.updatedSoup ||
                      meal.originalFish != meal.updatedFish ||
                      meal.originalMeat != meal.updatedMeat ||
                      meal.originalVegetarian != meal.updatedVegetarian ||
                      meal.originalDessert != meal.updatedDessert ||
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
                              children: <Widget> [
                                Expanded(
                                  child: Text(
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

                        if (meal.originalSoup != meal.updatedSoup || _isEditable)...[
                          const Text('Sopa: '),
                          TextFormField(
                            controller: _soupController,
                            //initialValue: '${meal.updatedSoup}',
                            //controller: _controller,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (meal.originalFish != meal.updatedFish || _isEditable)...[
                          const Text('Prato Peixe: '),
                          TextFormField(
                            controller: _fishController,
                            //initialValue: '${meal.updatedFish}',
                            //controller: _controller,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (meal.originalMeat != meal.updatedMeat || _isEditable)...[
                          const Text('Prato Carne: '),
                          TextFormField(
                            controller: _meatController,
                            //initialValue: '${meal.updatedMeat}',
                            //controller: _controller,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (meal.originalVegetarian != meal.updatedVegetarian || _isEditable)...[
                          const Text('Prato Vegetariano: '),
                          TextFormField(
                            controller: _vegetarianController,
                            //initialValue: '${meal.updatedVegetarian}',
                            //controller: _controller,
                            enabled: _isEditable,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ],

                        if (meal.originalDessert != meal.updatedDessert || _isEditable)...[
                          const Text('\nSobremesa: '),
                          TextFormField(
                            controller: _dessertController,
                            //initialValue: '${meal.updatedDessert}',
                            //controller: _controller,
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


                          Text('Sopa: ${meal.originalSoup}\n'),
                          Text('Prato Peixe: ${meal.originalFish}\n'),
                          Text('Prato Carne: ${meal.originalMeat}\n'),
                          Text('Prato Vegetariano: ${meal.originalVegetarian}\n'),
                          Text('Sobremesa: ${meal.originalDessert}\n'),
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
          ElevatedButton(
              onPressed: _submitting ? null : _submitChanges,
              child: const Text('Submit Changes'),
            ),
            /*{
              // TODO: Add code to handle "Submeter" button press
              // meal.thereIsAnUpdatedMeal = true;
              // if (_revertToOriginal{ }
            },
            child: const Text('Submeter'),
          ),*/
        ],
        )
      ),
      //),
    );
  }

}