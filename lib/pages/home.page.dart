import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children:[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(children: [
                  Row(
                    children: [
                      Container(
                        child: Icon(Icons.download, color: Colors.white,),
                        ),
                      SizedBox(width: 16,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, User!'),
                          Text('Welcome Back'),
                        ],
                      )
                  ]
                  ),
              ]),

              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(16),
              ),
            )
          ),],
        )),
    );
  }
}