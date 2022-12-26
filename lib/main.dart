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
  Meal.fromJson(Map<String, dynamic> json)
      : weekDay = json['weekDay'] ?? '',
        soup = json['soup'] ?? '',
        fish = json['fish'] ?? '',
        meat = json['meat'] ?? '',
        vegetarian = json['vegetarian'] ?? '',
        desert = json['desert'] ?? '';

  final String weekDay;
  final String soup;
  final String fish;
  final String meat;
  final String vegetarian;
  final String desert;
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

        final mealsData = json.decode(response.body);
        final meals = <Meal>[];
        mealsData.forEach((weekDay, data) {
          final meal = Meal.fromJson(data['original']);
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
                              Text('Soup: ${meal.soup}'),
                              Text('Fish: ${meal.fish}'),
                              Text('Meat: ${meal.meat}'),
                              Text('Vegetarian: ${meal.vegetarian}'),
                              Text('Dessert: ${meal.desert}'),
                              ElevatedButton(
                                  onPressed: () => Navigator.pushNamed( // You could call a function, with () => you are defining the function in place
                                    context,
                                    MealDetails.routname,
                                    arguments: 5,
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
