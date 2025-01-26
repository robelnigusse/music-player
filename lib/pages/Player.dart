// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:music/tools/fav_methods.dart';
import 'package:provider/provider.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  @override
  void initState() {
    context.read<musicprovider>().fetchmusicimage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 72, 53, 99),
        title: const Text('Now Playing'),
        centerTitle: true,
        elevation: 0,
        actions: [
          StatefulBuilder(
            builder: (context, setState) {
              return FutureBuilder<bool>(
                future:
                    isFavorite(context.watch<musicprovider>().currentsong!.uri),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                      ),
                      onPressed: null, // Disable while loading
                    );
                  }

                  bool isFavorite = snapshot.data ?? false;

                  return IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      String? songUri =
                          Provider.of<musicprovider>(context, listen: false)
                              .currentsong!
                              .uri;

                      if (isFavorite) {
                        await removeFavorite(songUri);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Center(
                              child: Text(
                                'Removed from favorites',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 210, 109, 109),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            duration: Duration(seconds: 2),
                            margin: const EdgeInsets.only(
                                bottom: 20, left: 100, right: 100),
                          ),
                        );
                      } else {
                        await addFavorite(songUri);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Center(
                              child: Text(
                                'Added to favorites',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 111, 201, 114),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            duration: Duration(seconds: 1),
                            margin: const EdgeInsets.only(
                                bottom: 20, left: 100, right: 100),
                          ),
                        );
                      }

                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                width: double.infinity,
                height: 370.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  image: context.watch<musicprovider>().musicimage != null
                      ? DecorationImage(
                          image: MemoryImage(context
                              .watch<musicprovider>()
                              .musicimage!), // Use MemoryImage to provide an ImageProvider
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: const AssetImage('assets/spotify.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            const Color.fromARGB(255, 72, 53, 99)
                                .withOpacity(0.9),
                            BlendMode.dstATop,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.watch<musicprovider>().currentsong!.title.length > 50
                  ? '${context.watch<musicprovider>().currentsong!.title.substring(0, 47)}...'
                  : context.watch<musicprovider>().currentsong!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              context.watch<musicprovider>().currentsong!.artist ??
                  "Unknown Artist",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            //to get the current position of the song
            StreamBuilder<Duration>(
              stream: context
                  .read<musicprovider>()
                  .audioPlayer
                  .positionStream, //gives the current position of the song as duration object
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  // This gives you the current position of the song
                  Duration currentPosition = snapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString()}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          const Spacer(),
                          Text(
                            '${context.watch<musicprovider>().audioPlayer.duration?.inMinutes}:${((context.watch<musicprovider>().audioPlayer.duration?.inSeconds ?? 0 % 60) / 10).floor().toString()}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      Slider(
                        value: currentPosition.inSeconds.toDouble(),
                        min: 0,
                        max: context
                                .watch<musicprovider>()
                                .audioPlayer
                                .duration
                                ?.inSeconds
                                .toDouble() ??
                            1.0, //some render overflow error when the music ends so i added 1.0
                        onChanged: (value) {
                          context
                              .read<musicprovider>()
                              .audioPlayer
                              .seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: const Color.fromARGB(255, 88, 64, 121),
                        inactiveColor: const Color.fromARGB(255, 219, 216, 216),
                      ),
                    ],
                  );
                }
                return const Text('Loading...');
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    size: 50,
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
                          size: 60,
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
                          size: 60,
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
                    size: 50,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () async {
                    context.read<musicprovider>().savedPosition = null;
                    context.read<musicprovider>().currentsong =
                        await context.read<musicprovider>().playNext();
                    context.read<musicprovider>().fetchmusicimage();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
