import 'package:flutter/material.dart';
import 'package:music/pages/Album.dart';
import 'package:music/pages/favorite.dart';
import 'package:music/provider/Music_Provider.dart';
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
          "M-Player",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        elevation: 20,
      ),
      body: page[_selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(220, 226, 222, 222),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
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
        if (context.watch<musicprovider>().currentsong != null)
          Container(
            color: const Color.fromARGB(146, 33, 33, 33),
            //padding: const EdgeInsets.only(),
            child: Row(
              children: [
                const Icon(
                  Icons.music_note_outlined,
                  color: Colors.white70,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.watch<musicprovider>().currentsong!.title,
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  //previous button
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () async {
                    context.read<musicprovider>().savedPosition = null;
                    context.read<musicprovider>().currentsong =
                        await context.read<musicprovider>().playPervious();
                    context.read<musicprovider>().fetchmusicimage();
                  },
                ),
                context.watch<musicprovider>().isplaying
                    ? IconButton(
                        icon: const Icon(
                          Icons.pause,
                          color: Color.fromARGB(255, 214, 201, 201),
                        ),
                        onPressed: () {
                          context.read<musicprovider>().pauseSong(
                              context.read<musicprovider>().currentsong!.uri);

                          context.read<musicprovider>().isplaying = false;
                        },
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Color.fromARGB(255, 214, 201, 201),
                        ),
                        onPressed: () {
                          context.read<musicprovider>().playSong(
                              context.read<musicprovider>().currentsong!.uri);
                          context.read<musicprovider>().isplaying = true;
                          context.read<musicprovider>().savedPosition = null;
                        },
                      ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () async {
                    context.read<musicprovider>().savedPosition = null;
                    context.read<musicprovider>().currentsong =
                        await context.read<musicprovider>().playNext();
                    context.read<musicprovider>().fetchmusicimage();
                  },
                ),
                //next button
              ],
            ),
          ),
      ],
    );
  }
}
