import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/const/text_style.dart';
import 'package:music/pages/Player.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:music/tools/BottomPlayer.dart';
import 'package:music/tools/fav_methods.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  void initState() {
    _setupAudioPlayerListener();
    super.initState();
  }

  void _setupAudioPlayerListener() {
    //change to the next song if currentsong ended
    context
        .read<musicprovider>()
        .audioPlayer
        .playerStateStream
        .listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        context.read<musicprovider>().playNextSong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<String>>(
            future: getFavorites(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                ); // Show error if any
              } else if (snapshot.hasData) {
                List<String> favorites = snapshot.data!;

                List<SongModel> favoritesongs = context
                    .read<musicprovider>()
                    .songs
                    .where((song) => favorites.contains(song.uri))
                    .toList();

                if (favoritesongs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: favoritesongs.length,
                    itemBuilder: (context, index) {
                      var song = favoritesongs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(62, 92, 69, 96),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListTile(
                          title: Text(
                            song.title.length > 30
                                ? '${song.title.substring(0, 27)}...'
                                : song.title,
                            style: our_style(),
                          ),
                          subtitle: Text(
                            song.artist ?? "Unknown Artist",
                            style: our_style(size: 10),
                          ),
                          leading: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(
                              Icons.music_note_outlined,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          onTap: () async {
                            context.read<musicprovider>().songs = favoritesongs;
                            context.read<musicprovider>().currentsong = song;
                            context.read<musicprovider>().play(song.uri);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Player(),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                        ),
                      );
                    },
                  );
                }
              }
              return const Center(
                child: Text('No favorites yet.'),
              );
            },
          ),
        ),
        if (context.watch<musicprovider>().currentsong != null) BottomPlayer()
      ],
    );
  }
}
