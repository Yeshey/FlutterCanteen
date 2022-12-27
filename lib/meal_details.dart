import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_canteen/main.dart';

class MealDetails extends StatefulWidget {
  const MealDetails({Key? key}) : super(key : key);

  static const String routname = '/SecondScreeen';

  @override
  State<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails> {

  bool _isEnable = false; //_isEnable is the boolean variable and set it false, so we have to make it true when user tap on text
  TextEditingController _controller = TextEditingController(text: 'Wong Yuk Hei');
  bool isReadOnly = true;

  late final Meal meal = ModalRoute.of(context)!.settings.arguments as Meal;

  @override
  Widget build(BuildContext context) {
    // final int? counter = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Second Screen',
          style: TextStyle(
            color: Colors.indigo,
          ),
        ),
      ),
      body: Column(
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
                      onPressed: () {
                        // TODO: Add code to handle camera button press
                      },
                    ),
                    Hero(
                      tag: 'AmovTag1',
                      child: Text('Change Meal Image'),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 200,
                child: Image.asset('images/DefaultMeal-evie-s-unsplash.jpg'),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row( //  todo need to make them be in a Column not a row now
              children: [

                if(meal.thereIsAnUpdatedMeal)...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ementa Atualizada',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

/*
                        Text('Sopa: ${meal.updatedSoup}\n'),
                        Text('Prato Peixe: ${meal.updatedFish}\n'),
                        Text('Prato Carne: ${meal.updatedMeat}\n'),
                        Text('Prato Vegetariano: ${meal.updatedVegetarian}\n'),
                        Text('Sobremesa: ${meal.updatedDessert}\n'),
 */

                        const Text('Sopa: '),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget> [
                                Expanded(
                                    child: TextFormField(
                                        initialValue: '${meal.updatedSoup}',
                                        //controller: _controller,
                                        enabled: _isEnable,
                                        minLines: 1,
                                        maxLines: 5,
                                    )
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState (() {
                                        _isEnable = true;
                                      });
                                    }),
                              ],
                            )
                          ],
                        ),

                        const Text('Prato Peixe: '),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget> [
                                Expanded(
                                    child: TextFormField(
                                      initialValue: '${meal.updatedFish}',
                                      //controller: _controller,
                                      enabled: _isEnable,
                                      minLines: 1,
                                      maxLines: 5,
                                    )
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState (() {
                                        _isEnable = true;
                                      });
                                    }),
                              ],
                            )
                          ],
                        ),

                        const Text('Prato Carne: '),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget> [
                                Expanded(
                                    child: TextFormField(
                                      initialValue: '${meal.updatedMeat}',
                                      //controller: _controller,
                                      enabled: _isEnable,
                                      minLines: 1,
                                      maxLines: 5,
                                    )
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState (() {
                                        _isEnable = true;
                                      });
                                    }),
                              ],
                            )
                          ],
                        ),

                        const Text('Prato Vegetariano: '),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget> [
                                Expanded(
                                    child: TextFormField(
                                      initialValue: '${meal.updatedVegetarian}',
                                      //controller: _controller,
                                      enabled: _isEnable,
                                      minLines: 1,
                                      maxLines: 5,
                                    )
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState (() {
                                        _isEnable = true;
                                      });
                                    }),
                              ],
                            )
                          ],
                        ),

                        const Text('Sobremesa: '),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget> [
                                Expanded(
                                    child: TextFormField(
                                      initialValue: '${meal.updatedDessert}',
                                      //controller: _controller,
                                      enabled: _isEnable,
                                      minLines: 1,
                                      maxLines: 5,
                                    )
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState (() {
                                        _isEnable = true;
                                      });
                                    }),
                              ],
                            )
                          ],
                        ),


                      ],
                    ),
                  ),
                ],


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ementa Original',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Sopa: ${meal.originalSoup}\n'),
                      Text('Prato Peixe: ${meal.originalFish}\n'),
                      Text('Prato Carne: ${meal.originalMeat}\n'),
                      Text('Prato Vegetariano: ${meal.originalVegetarian}\n'),
                      Text('Sobremesa: ${meal.originalDessert}\n'),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Add code to handle "Repor" button press
                },
                child: const Text('Repor'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Add code to handle "Editar" button press
                },
                child: const Text('Editar'),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              // TODO: Add code to handle "Submeter" button press
            },
            child: const Text('Submeter'),
          ),
        ],
      ),
    );
  }

}