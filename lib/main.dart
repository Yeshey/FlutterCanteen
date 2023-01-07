import 'dart:convert';
import 'dart:io';
import 'constants.dart' as constants;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'meal_details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root Widget of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: MealChooserScreen.routename,
      routes: {

        MealChooserScreen.routename : (context) => MealChooserScreen(),
        MealDetails.routname : (context) => MealDetails(),
      },
      debugShowCheckedModeBanner: false, // no longer debugging flag in the app!!
    );
  }
}

class Meal {

  Meal({
    required this.thereIsAnUpdatedMeal,
    required this.weekDay,
    required this.originalSoup,
    required this.originalFish,
    required this.originalMeat,
    required this.originalVegetarian,
    required this.originalDessert,
    required this.updatedSoup,
    required this.updatedFish,
    required this.updatedMeat,
    required this.updatedVegetarian,
    required this.updatedDessert,
    required this.submitted,
    required this.img
  });

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
        img = json['update']?['img'] ?? '',
        submitted = json['submitted'] ?? false,
        thereIsAnUpdatedMeal = recUpdatedMeal;

  bool thereIsAnUpdatedMeal;
  final String img;
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

  static const String _catFactsUrl = '${constants.SERVER_URL}/menu'; // 'http://amov.servehttp.com:8080/menu'; //'http://0.0.0.0:8080/menu'; // 'https://catfact.ninja/facts';

  List<Meal>? _meals = [];
  bool _anyMealsToShow = true;
  bool _fetchingData = true;
  // final meals = <Meal>[];
  Future<void> _fetchMeals() async {
    try {
      setState(() => _fetchingData = true);
      setState(() => _anyMealsToShow = true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      http.Response response = await http.get(Uri.parse(_catFactsUrl));

      if (response.statusCode == HttpStatus.ok) {
        debugPrint(response.body);

        saveMeals(response.bodyBytes);

        final meals = <Meal>[];
        bool updatedMeal = true;


        json.decode(utf8.decode(response.bodyBytes)).forEach((weekDay, data) {
          if (data['update'] == null) {
            updatedMeal = false;
          }
          final meal = Meal.fromJson(data,updatedMeal);
          meals.add(meal);
        });
        setState(() => _meals = orderMeals(meals));

      }
    } catch (e) {
      debugPrint('Something went wrong: $e');
    } finally {
      setState(() => _fetchingData = false);
    }
  }

  List<Meal> orderMeals(List<Meal> meals) {

    meals.sort((a, b) => _customWeekdayCompare(a.weekDay, b.weekDay));
    return meals;
  }

  int _customWeekdayCompare(String weekday1, String weekday2) {

    final currentWeekday = getCurrentWeekday();
    final weekdays = ['WEDNESDAY', 'THURSDAY', 'FRIDAY', 'MONDAY', 'TUESDAY'];
    final currentWeekdayIndex = weekdays.indexOf(currentWeekday);
    final sortedWeekdays = weekdays.sublist(currentWeekdayIndex)
        + weekdays.sublist(0, currentWeekdayIndex);

    final index1 = sortedWeekdays.indexOf(weekday1);
    final index2 = sortedWeekdays.indexOf(weekday2);
    return index1.compareTo(index2);
  }

  String getCurrentWeekday() {
    final now = DateTime.now();
    final weekday = now.weekday;
    switch (weekday) {
      case 1:
        return 'MONDAY';
      case 2:
        return 'TUESDAY';
      case 3:
        return 'WEDNESDAY';
      case 4:
        return 'THURSDAY';
      case 5:
        return 'FRIDAY';
      case 6:
        return 'MONDAY';
      case 7:
        return 'MONDAY';
      default:
        return 'Unknown';
    }
  }

  int getMaxIntValue() {
    return (pow(2, 31) - 1).toInt();
  }

  Future<void> _fetchLocalMeals() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {

        setState(() => _fetchingData = true);

        if (prefs.containsKey('storedMeals') == true){
            // Extract the local data

          _anyMealsToShow = true;

          final Uint8List responseBodyBytes = await getMeals();

          final meals = <Meal>[];
          bool updatedMeal = true;
          json.decode(utf8.decode(responseBodyBytes)).forEach((weekDay, data) { //utf8?
            if (data['update'] == null) {
              updatedMeal = false;
            }
            final meal = Meal.fromJson(data,updatedMeal);
            meals.add(meal);
          });
          setState(() => _meals = orderMeals(meals));

        } else {
          // Show, No meals screen
          setState(() => _anyMealsToShow = false);
        }

      } catch (e) {
        debugPrint('Something went wrong: $e');
      } finally {
        setState(() => _fetchingData = false);
      }
  }

  static Future<bool> saveMeals(Uint8List mealzz) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String base64Image = base64Encode(mealzz);
    return prefs.setString("storedMeals", base64Image);
  }

  static Future<Uint8List> getMeals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Uint8List bytes = base64Decode(prefs.getString("storedMeals"));
    return bytes;
  }

  @override
  void initState() {
    super.initState();
    _fetchLocalMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _fetchMeals();
          },
        ),
        title: const Text('Canteen Meals'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),

              if (_fetchingData) const CircularProgressIndicator(),

              if (_anyMealsToShow && !_fetchingData && _meals != null && _meals!.isNotEmpty)...[
                Flexible(
                  child: ListView.builder(
                    itemCount: getMaxIntValue(),
                    //itemCount: _meals!.length,
                    itemBuilder: (BuildContext context, int index) {
                      //final Meal meal = _meals![index];
                      final Meal meal = _meals![index % _meals!.length];
                      final children = <Widget>[];

                      if (index % 5 == 0) {
                        children.add(
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Weekday: ${(index ~/ 5) + 1 }',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      children.add(
                      Card(
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

                              Hero(
                                tag: 'mealdetails${meal.weekDay}$index',
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      MealDetails.routname,
                                      arguments: meal,
                                    );

                                    if (result != null && result == true){
                                      _fetchMeals();
                                    }
                                  },
                                  child: const Text('Meal Details'),
                                ),
                              )

                            ],
                          ),
                        ),
                      ),
                      );
                      return Column(children: children);
                    },
                  ),
                ),

              ]else...[
                if (!_fetchingData)
                  const Text( //mudei aqui
                    "No meals to show",
                    textScaleFactor: 2,
                  ),
              ],

            ],
          )
      ),
    );
  }

}
