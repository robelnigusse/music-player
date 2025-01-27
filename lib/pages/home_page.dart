import 'package:flutter/material.dart';
import 'package:music/pages/Album.dart';
import 'package:music/pages/favorite.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:music/tools/BottomPlayer.dart';
import 'package:music/tools/search.dart';
import 'package:provider/provider.dart';
import '../tools/music_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> page = [Homepage(), Album(), Favorite()];
  int _selectedindex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: Search(),
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
        title: const Text(
          "PlayWave",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        elevation: 20,
      ),
      body: page[_selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 172, 151, 201),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.music_note,
            ),
            label: "Music",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: "Album",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
        ],
        currentIndex: _selectedindex,
        onTap: _navigateBottomBar,
      ),
    );
  }
}

class Homepage extends StatelessWidget {
  const Homepage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: MusicList(),
        ),
        if (context.watch<musicprovider>().currentsong != null) BottomPlayer(),
      ],
    );
  }
}
