import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class musicprovider extends ChangeNotifier {
  bool isplaying = false;
  Duration? savedPosition;
  final AudioPlayer audioPlayer = AudioPlayer(); //to play song

  List<AlbumModel> albums = [];
  AlbumModel? currentalbum;

  List<SongModel> songs = [];
  bool isLoading = true;
  String error = '';
  final OnAudioQuery audioQuery = OnAudioQuery(); //to query album and music
  SongModel? currentsong;
  Uint8List? musicimage;

  Future<void> fetchmusicimage() async {
    var artwork =
        await audioQuery.queryArtwork(currentsong!.id, ArtworkType.AUDIO);

    musicimage = artwork;
  }

  Future<void> querySongs() async {
    try {
      List<SongModel> fetchedSongs = await audioQuery.querySongs(
        ignoreCase: true,
        sortType: null,
        uriType: UriType.EXTERNAL,
        orderType: OrderType.ASC_OR_SMALLER,
      );

      songs = fetchedSongs;
      isLoading = false;
      if (fetchedSongs.isEmpty) {
        error = 'No songs found on the device.';
      }
    } catch (e) {
      error = 'Failed to query songs: $e';
      isLoading = false;
    }
    notifyListeners();
  }

  Future<void> playSong(String? uri) async {
    isplaying = true;
    if (savedPosition != null) {
      await audioPlayer.seek(savedPosition);
    } else {
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
    }
    audioPlayer.play();
    notifyListeners();
  }

  Future<void> stopSong() async {
    await audioPlayer.stop();
  }

  Future<SongModel?> playNext() async {
    final currentAudioSource = audioPlayer.audioSource;
    String? currentUri;
    if (currentAudioSource is UriAudioSource) {
      currentUri = currentAudioSource.uri.toString();
    }
    int currentIndex = songs.indexWhere((song) => song.uri == currentUri);
    int nextIndex = currentIndex + 1;
    if (nextIndex < songs.length) {
      currentsong = songs[nextIndex];
      playSong(currentsong!.uri);
      notifyListeners();
      return currentsong;
    } else {
      currentsong = songs[0];
      playSong(currentsong!.uri);
      notifyListeners();
      return currentsong;
    }
  }

  Future<SongModel?> playPervious() async {
    final currentAudioSource = audioPlayer.audioSource;
    String? currentUri;
    if (currentAudioSource is UriAudioSource) {
      currentUri = currentAudioSource.uri.toString();
    }
    int currentIndex = songs.indexWhere((song) => song.uri == currentUri);
    int PerviousIndex = currentIndex - 1;
    if (PerviousIndex > 0) {
      currentsong = songs[PerviousIndex];
      playSong(currentsong!.uri);
      notifyListeners();
      return currentsong;
    } else {
      currentsong = songs[songs.length - 1];
      playSong(songs[songs.length - 1].uri);
      notifyListeners();
      return currentsong;
    }
  }

  Future<void> pauseSong(String? uri) async {
    isplaying = false;
    savedPosition = await audioPlayer.positionStream.first;
    audioPlayer.pause();
    notifyListeners();
  }

  Future<void> play(String? uri) async {
    //play song that is tapped
    final currentSource = audioPlayer.audioSource;
    final currentUri =
        (currentSource is UriAudioSource) ? currentSource.uri.toString() : null;
    if (currentUri == uri) {
    } else {
      isplaying = true;
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(uri!),
        ),
      );
      audioPlayer.play();
    }
    notifyListeners();
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
      currentsong = songs[nextIndex];

      playSong(currentsong!.uri);
    } else {
      currentsong = songs[0];

      playSong(currentsong!.uri);
    }
    notifyListeners();
  }
}
