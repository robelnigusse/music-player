import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/pages/Player.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../const/text_style.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});
  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  bool _storagePermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _setupAudioPlayerListener();
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
      await context.read<musicprovider>().querySongs();
    } else {
      context.read<musicprovider>().error =
          'Storage permission is required to access music files.';
      context.read<musicprovider>().isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_storagePermissionGranted) {
      return Center(
        child: Text(
          context.read<musicprovider>().error,
          style: our_style(),
        ),
      );
    }

    if (context.watch<musicprovider>().isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (context.watch<musicprovider>().error.isNotEmpty) {
      return Center(
        child: Text(
          context.read<musicprovider>().error,
          style: our_style(),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: context.read<musicprovider>().songs.length,
      itemBuilder: (BuildContext context, int index) {
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
    );
  }
}
