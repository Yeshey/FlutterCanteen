import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MealDetails extends StatefulWidget {
  const MealDetails({Key? key}) : super(key : key);

  static const String routname = '/SecondScreeen';

  @override
  State<MealDetails> createState() => _MealDetailsState();
}

const String isec_url =
    'https://www.isec.pt/assets_isec/logo-isec-transparente.png';

class _MealDetailsState extends State<MealDetails> {

  late final int _counter = ModalRoute.of(context)!.settings.arguments as int;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text(
            'Second Screen',
            style: TextStyle(
                color: Colors.indigo
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 200, child: Image.asset('images/ahh.jpg')),
              SizedBox(height: 50, child: Image.network(isec_url),), // internet
              SizedBox(height: 200, child: Image.asset('images/15b.gif'),), // gif
              Hero(
                  tag: 'AmovTag1',
                  child: Text('Valor = $_counter')
              ),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_counter*2),
                  child: const Text('Return')
              )
            ],
          ),
        )
    );
    throw UnimplementedError();
  }
}