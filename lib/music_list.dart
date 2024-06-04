import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/pages/Player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import 'const/text_style.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});
  static List<SongModel> songs = [];
  static final AudioPlayer audioPlayer = AudioPlayer();
  static Duration? _savedPosition;
  static bool isplaying = false;

  static Future<void> playSong(String? uri) async {
    MusicList.isplaying = true;
    if (_savedPosition != null) {
      await audioPlayer.seek(_savedPosition);
    } else {
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
    }
    audioPlayer.play();
  }

  static Future<void> pauseSong(String? uri) async {
    MusicList.isplaying = false;
    _savedPosition = await audioPlayer.positionStream.first;
    await audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(uri!),
      ),
    );
    audioPlayer.pause();
  }

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  final OnAudioQuery audioQuery = OnAudioQuery();

  bool isLoading = true;
  String error = '';
  bool _storagePermissionGranted = false;

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
        MusicList.songs = fetchedSongs;
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

  Future<void> play(String? uri) async {
    final currentSource = MusicList.audioPlayer.audioSource;
    final currentUri =
        (currentSource is UriAudioSource) ? currentSource.uri.toString() : null;
    if (currentUri == uri) {
    } else {
      MusicList.isplaying = true;
      await MusicList.audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
      MusicList.audioPlayer.play();
    }
  }

  Future<void> playNextSong() async {
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
      });
      MusicList.playSong(MusicList.songs[nextIndex].uri);
    } else {
      setState(() {
        Player.song = MusicList.songs[0];
      });
      MusicList.playSong(MusicList.songs[0].uri);
    }
  }

  void _setupAudioPlayerListener() {
    MusicList.audioPlayer.playerStateStream.listen((playerState) {
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
        itemCount: MusicList.songs.length,
        itemBuilder: (BuildContext context, int index) {
          var song = MusicList.songs[index];
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
                play(song.uri);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Player(
                      currentsong: song,
                      isplaying: MusicList.isplaying,
                      pause: MusicList.pauseSong,
                      play: MusicList.playSong,
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
