import 'package:flutter/material.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:provider/provider.dart';
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
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              //
            },
            decoration: InputDecoration(
              hintText: 'Search for a music...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color.fromARGB(203, 113, 86, 151),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const Expanded(
            child: MusicList(),
          ),
          if (context.watch<musicprovider>().currentsong != null)
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(8.0),
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
      ),
    );
  }
}
