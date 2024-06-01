import 'package:flutter/material.dart';
import '../music_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "M-Player",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        elevation: 20,
      ),
      body: const Center(
        child: MusicList(),
      ),
    );
  }
}
