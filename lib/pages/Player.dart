import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatefulWidget {
  Player({super.key, required this.song});
  final SongModel song;
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

  Future<void> _fetchArtwork() async {
    var artwork =
        await _audioQuery.queryArtwork(widget.song.id, ArtworkType.AUDIO);
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
                            const Color.fromARGB(255, 72, 53, 99).withOpacity(
                                0.9), // Adjust the opacity value as needed (0.0 to 1.0)
                            BlendMode
                                .dstATop, // This blend mode keeps the original image but applies the color filter
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.song.title.length > 50
                  ? '${widget.song.title.substring(0, 47)}...'
                  : widget.song.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.song.artist ?? "Unknown Artist",
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill,
                    size: 60,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    size: 50,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
