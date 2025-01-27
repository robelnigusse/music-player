import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/const/text_style.dart';
import 'package:music/pages/Player.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:music/tools/BottomPlayer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class Albumsongs extends StatefulWidget {
  const Albumsongs({super.key});

  @override
  State<Albumsongs> createState() => _AlbumsongsState();
}

class _AlbumsongsState extends State<Albumsongs> {
  @override
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
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text((context.read<musicprovider>().currentalbum!.album +
                  " - album songs")
              .toUpperCase()),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: context.read<musicprovider>().songs.length,
              itemBuilder: (context, index) {
                var song = context.read<musicprovider>().songs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(
                    color: Colors.black38,
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
                      context.read<musicprovider>().currentsong = song;
                      context.read<musicprovider>().play(song.uri);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Player(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (context.watch<musicprovider>().currentsong != null) BottomPlayer()
        ],
      ),
    );
  }
}
