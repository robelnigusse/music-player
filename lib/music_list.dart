import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/pages/Player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import 'const/text_style.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songs = [];
  bool isLoading = true;
  String error = '';
  bool _storagePermissionGranted = false;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _setupAudioPlayerListener();
  }

  Future<void> _requestPermission() async {
    final build = await DeviceInfoPlugin().androidInfo;
    late final Map<Permission, PermissionStatus> statusess;
    if (build.version.sdkInt <= 32) {
      statusess = await [Permission.storage].request();
    } else {
      statusess = await [Permission.audio].request();
    }

    var allAccepted = true;
    statusess.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        allAccepted = false;
      }
    });

    if (allAccepted) {
      setState(() {
        _storagePermissionGranted = true;
      });
      await querySongs();
    } else {
      setState(() {
        error = 'Storage permission is required to access music files.';
        isLoading = false;
      });
    }
  }

  Future<void> querySongs() async {
    try {
      List<SongModel> fetchedSongs = await audioQuery.querySongs(
        ignoreCase: true,
        sortType: null,
        uriType: UriType.EXTERNAL,
        orderType: OrderType.ASC_OR_SMALLER,
      );

      setState(() {
        songs = fetchedSongs;
        isLoading = false;
      });

      if (fetchedSongs.isEmpty) {
        setState(() {
          error = 'No songs found on the device.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to query songs: $e';
        isLoading = false;
      });
    }
  }

  Future<void> playSong(String? uri) async {
    await audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(uri!),
      ),
    );
    audioPlayer.play();
  }

  Future<void> playNextSong() async {
    final currentAudioSource = audioPlayer.audioSource;
    String? currentUri;
    if (currentAudioSource is UriAudioSource) {
      currentUri = currentAudioSource.uri.toString();
    }
    int currentIndex = songs.indexWhere((song) => song.uri == currentUri);
    int nextIndex = currentIndex + 1;
    if (nextIndex < songs.length) {
      playSong(songs[nextIndex].uri);
    } else {
      playSong(songs[0].uri);
    }
  }

  void _setupAudioPlayerListener() {
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        playNextSong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_storagePermissionGranted) {
      return Center(
        child: Text(
          error,
          style: our_style(),
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(
          error,
          style: our_style(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: songs.length,
        itemBuilder: (BuildContext context, int index) {
          var song = songs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
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
              onTap: () {
                playSong(song.uri);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Player(
                      song: song,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
