import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumProvider extends ChangeNotifier {
  final OnAudioQuery albumQuery = OnAudioQuery();
  List<AlbumModel> albums = [];
  List<SongModel> albumSongs = [];
}
