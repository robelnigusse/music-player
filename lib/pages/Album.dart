import 'package:flutter/material.dart';
import 'package:music/pages/AlbumSongs.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:music/tools/BottomPlayer.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class Album extends StatefulWidget {
  const Album({super.key});

  @override
  State<Album> createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: context.read<musicprovider>().audioQuery.queryAlbums(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                context.read<musicprovider>().albums =
                    snapshot.data as List<AlbumModel>;
                return ListView.builder(
                  itemCount: context.read<musicprovider>().albums.length,
                  itemBuilder: (context, index) {
                    var album = context.read<musicprovider>().albums[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 1),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(62, 92, 69, 96),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListTile(
                        title: Text(
                          album.album.length > 30
                              ? '${album.album.substring(0, 27)}...'
                              : album.album,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          album.numOfSongs.toString() +
                              ' songs  • ' +
                              album.artist!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        leading: QueryArtworkWidget(
                          id: album.id,
                          type: ArtworkType.ALBUM,
                          nullArtworkWidget: const Icon(
                            Icons.album,
                            color: Color.fromARGB(255, 140, 121, 167),
                            size: 34,
                          ),
                        ),
                        onTap: () async {
                          context.read<musicprovider>().songs = await context
                              .read<musicprovider>()
                              .audioQuery
                              .queryAudiosFrom(
                                  AudiosFromType.ALBUM_ID, album.id);

                          context.read<musicprovider>().currentalbum = album;

                          context.read<musicprovider>().currentsong =
                              context.read<musicprovider>().songs[0];

                          context
                              .read<musicprovider>()
                              .play(context.read<musicprovider>().songs[0].uri);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Albumsongs(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        if (context.watch<musicprovider>().currentsong != null) BottomPlayer()
      ],
    );
  }
}
