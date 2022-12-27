import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'meal_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: MealChooserScreen.routename,
      routes: {
        // '/': (context) => MyHomePage(title: 'Flutter Demo Home Page'),

        MealChooserScreen.routename : (context) => MealChooserScreen(),
        MealDetails.routname : (context) => MealDetails(),
      },
      debugShowCheckedModeBanner: false, // no longuer debugging flag in the app!!
    );
  }
}

class Meal {

  Meal.fromJson(Map<String, dynamic> json, bool recUpdatedMeal)
      : weekDay = json['original']?['weekDay'] ?? '',
        originalSoup = json['original']?['soup'] ?? '',
        originalFish = json['original']?['fish'] ?? '',
        originalMeat = json['original']?['meat'] ?? '',
        originalVegetarian = json['original']?['vegetarian'] ?? '',
        originalDessert = json['original']?['desert'] ?? '',
        updatedSoup = json['update']?['soup'] ?? '',
        updatedFish = json['update']?['fish'] ?? '',
        updatedMeat = json['update']?['meat'] ?? '',
        updatedVegetarian = json['update']?['vegetarian'] ?? '',
        updatedDessert = json['update']?['desert'] ?? '',
        submitted = json['submitted'] ?? false,
        thereIsAnUpdatedMeal = recUpdatedMeal;

  final bool thereIsAnUpdatedMeal;
  final String weekDay;
  final String originalSoup;
  final String originalFish;
  final String originalMeat;
  final String originalVegetarian;
  final String originalDessert;
  final String updatedSoup;
  final String updatedFish;
  final String updatedMeat;
  final String updatedVegetarian;
  final String updatedDessert;
  final bool submitted;
}

class MealChooserScreen extends StatefulWidget {
  const MealChooserScreen({Key? key}) : super(key: key);

  static const String routename = '/CatFactsScreen';

  @override
  State<MealChooserScreen> createState() => _MealChooserScreenState();
}

class _MealChooserScreenState extends State<MealChooserScreen> {

  static const String _catFactsUrl = 'http://amov.servehttp.com:8080/menu'; // 'http://amov.servehttp.com:8080/menu'; //'http://0.0.0.0:8080/menu'; // 'https://catfact.ninja/facts';

  List<Meal>? _meals = [];
  bool _fetchingData = false;
  Future<void> _fetchMeals() async {
    try {
      setState(() => _fetchingData = true);
      http.Response response = await http.get(Uri.parse(_catFactsUrl));
      if (response.statusCode == HttpStatus.ok) {
        debugPrint(response.body);

        final meals = <Meal>[];
        bool updatedMeal = true;
        json.decode(response.body).forEach((weekDay, data) {
          if (data['update'] == null) {
            updatedMeal = false;
          }
          final meal = Meal.fromJson(data,updatedMeal);
          meals.add(meal);
        });
        setState(() => _meals = meals);

      }
    } catch (e) {
      debugPrint('Something went wrong: $e');
    } finally {
      setState(() => _fetchingData = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Meals'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Canteen Meals'),
              const SizedBox(height: 20.0),

              if (_fetchingData) const CircularProgressIndicator(),
              if (!_fetchingData && _meals != null && _meals!.isNotEmpty)
                Flexible(
                  child: ListView.builder(

                    //itemCount: json.keys.length,
                    itemCount: _meals!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Meal meal = _meals![index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(meal.weekDay),

                              Column(
                                children: [
                                  if(meal.thereIsAnUpdatedMeal)...[
                                    Text('Soup: ${meal.updatedSoup}'),
                                    Text('Fish: ${meal.updatedFish}'),
                                    Text('Meat: ${meal.updatedMeat}'),
                                    Text('Vegetarian: ${meal.updatedVegetarian}'),
                                    Text('Dessert: ${meal.updatedDessert}'),
                                  ]else...[
                                    Text('Soup: ${meal.originalSoup}'),
                                    Text('Fish: ${meal.originalFish}'),
                                    Text('Meat: ${meal.originalMeat}'),
                                    Text('Vegetarian: ${meal.originalVegetarian}'),
                                    Text('Dessert: ${meal.originalDessert}'),
                                  ]
                                ]),


                              /*Text('Soup: ${meal.updatedSoup}'),
                              Text('Fish: ${meal.updatedFish}'),
                              Text('Meat: ${meal.updatedMeat}'),
                              Text('Vegetarian: ${meal.updatedVegetarian}'),
                              Text('Dessert: ${meal.updatedDessert}'),
                              */


                              ElevatedButton(
                                  onPressed: () => Navigator.pushNamed( // if you could call a function with () => you are defining the function in place
                                    context,
                                    MealDetails.routname,
                                    arguments: meal,
                                  ),
                                  child: Text('Meal Details')
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          )
      ),
    );
  }

}
