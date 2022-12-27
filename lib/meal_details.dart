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
            child: Row(
              children: [
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
                      Text('Sopa: ${meal.soup}'),
                      Text('Prato Peixe: ${meal.fish}'),
                      Text('Prato Carne: ${meal.meat}'),
                      Text('Prato Vegetariano: ${meal.vegetarian}'),
                      Text('Sobremesa: ${meal.desert}'),
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