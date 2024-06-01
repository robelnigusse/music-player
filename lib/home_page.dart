import 'package:flutter/material.dart';
import 'music_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 72, 53, 99),
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text(
          "M-Player",
          style: TextStyle(color: Colors.white70),
        ),
      ),
      body: const Center(
        child: MusicList(),
      ),
    );
  }
}
