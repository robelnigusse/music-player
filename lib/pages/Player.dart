// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/music_list.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatefulWidget {
  Player(
      {super.key,
      required currentsong,
      required this.isplaying,
      required this.pause,
      required this.play}) {
    song = currentsong;
  }
  static SongModel? song;
  bool isplaying;
  Future<void> Function(String?) pause;
  Future<void> Function(String?) play;
  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  Uint8List? _artwork;

  @override
  void initState() {
    super.initState();
    _fetchArtwork();
  }

  Future<SongModel> playNext() async {
    final currentAudioSource = MusicList.audioPlayer.audioSource;
    String? currentUri;
    if (currentAudioSource is UriAudioSource) {
      currentUri = currentAudioSource.uri.toString();
    }
    int currentIndex =
        MusicList.songs.indexWhere((song) => song.uri == currentUri);
    int nextIndex = currentIndex + 1;
    if (nextIndex < MusicList.songs.length) {
      setState(() {
        Player.song = MusicList.songs[nextIndex];
        MusicList.playSong(MusicList.songs[nextIndex].uri);
      });

      return MusicList.songs[nextIndex];
    } else {
      setState(() {
        Player.song = MusicList.songs[0];
        MusicList.playSong(MusicList.songs[0].uri);
      });

      return MusicList.songs[0];
    }
  }

  Future<SongModel> playPervious() async {
    final currentAudioSource = MusicList.audioPlayer.audioSource;
    String? currentUri;
    if (currentAudioSource is UriAudioSource) {
      currentUri = currentAudioSource.uri.toString();
    }
    int currentIndex =
        MusicList.songs.indexWhere((song) => song.uri == currentUri);
    int PerviousIndex = currentIndex - 1;
    if (PerviousIndex > 0) {
      setState(() {
        Player.song = MusicList.songs[PerviousIndex];
        MusicList.playSong(MusicList.songs[PerviousIndex].uri);
      });

      return MusicList.songs[PerviousIndex];
    } else {
      setState(() {
        Player.song = MusicList.songs[0];
        MusicList.playSong(MusicList.songs[MusicList.songs.length - 1].uri);
      });

      return MusicList.songs[MusicList.songs.length - 1];
    }
  }

  Future<void> _fetchArtwork() async {
    var artwork =
        await _audioQuery.queryArtwork(Player.song!.id, ArtworkType.AUDIO);
    setState(() {
      _artwork = artwork;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 72, 53, 99),
        title: const Text('Now Playing'),
        centerTitle: true,
        elevation: 0,
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
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  image: _artwork != null
                      ? DecorationImage(
                          image: MemoryImage(
                              _artwork!), // Use MemoryImage to provide an ImageProvider
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: const AssetImage('assets/spotify.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            const Color.fromARGB(255, 72, 53, 99)
                                .withOpacity(0.9),
                            BlendMode
                                .dstATop, // This blend mode keeps the original image but applies the color filter
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Player.song!.title.length > 50
                  ? '${Player.song!.title.substring(0, 47)}...'
                  : Player.song!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              Player.song!.artist ?? "Unknown Artist",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Slider(
              value: 1.03,
              min: 0,
              max: 4.12,
              onChanged: (value) {},
              activeColor: const Color.fromARGB(255, 88, 64, 121),
              inactiveColor: const Color.fromARGB(255, 219, 216, 216),
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
                    Player.song = await playPervious();
                  },
                ),
                widget.isplaying
                    ? IconButton(
                        icon: const Icon(
                          Icons.pause,
                          size: 60,
                          color: Color.fromARGB(255, 214, 201, 201),
                        ),
                        onPressed: () {
                          widget.pause(Player.song!.uri);
                          setState(() {
                            widget.isplaying = false;
                          });
                        },
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 60,
                          color: Color.fromARGB(255, 214, 201, 201),
                        ),
                        onPressed: () {
                          widget.play(Player.song!.uri);
                          setState(() {
                            widget.isplaying = true;
                          });
                        },
                      ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    size: 50,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () async {
                    Player.song = await playNext();
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
