import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: true, 
                onChanged: (bool value) {} , 
                inactiveTrackColor: const Color.fromARGB(255, 181, 230, 181), 
                inactiveThumbColor: const Color.fromARGB(255, 120, 218, 118),
                activeTrackColor: const Color.fromARGB(255, 200, 99, 71),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.add)),
            ],
          )
        ],
      ));
  }
}