import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialRoute: CatFactsScreen.routename,
      routes: {
        // '/': (context) => MyHomePage(title: 'Flutter Demo Home Page'),

        CatFactsScreen.routename : (context) => CatFactsScreen(),
      },
      debugShowCheckedModeBanner: false, // no longuer ddebugging flag in the app!!
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



class CatFactsScreen extends StatefulWidget {
  const CatFactsScreen({Key? key}) : super(key: key);

  static const String routename = '/CatFactsScreen';

  @override
  State<CatFactsScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CatFactsScreen> {

  static const String _catFactsUrl = 'http://amov.servehttp.com:8080/menu'; // 'http://amov.servehttp.com:8080/menu'; //'http://0.0.0.0:8080/menu'; // 'https://catfact.ninja/facts';

  Future<String> _fetchAnAsyncString() async {
    // Simula um pedido de 5 segundos
    await Future.delayed(const Duration(seconds: 5));
    return Future.value('Hello world, from an aysnc call!');
  }


  List<Meal>? _meals = [];
  bool _fetchingData = false;
  Future<void> _fetchCatFacts() async {
    try {
      setState(() => _fetchingData = true);
      http.Response response = await http.get(Uri.parse(_catFactsUrl));
      if (response.statusCode == HttpStatus.ok) {
        debugPrint(response.body);
        // final Map<String, dynamic> decodedData = json.decode(response.body);

        /*
        final Map<String, dynamic> mealsData = json.decode(response.body);
        setState(() => _meals = mealsData.entries
            .map((mealData) => Meal.fromJson(mealData.value)).toList());
         */

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeteria Meals'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Cafeteria Meals'),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: _fetchCatFacts,
                child: const Text('Fetch cat facts'),
              ),
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
