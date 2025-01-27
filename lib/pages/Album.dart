import 'package:flutter/material.dart';
import 'package:music/provider/Album_provider.dart';
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
    return Center(
        child: FutureBuilder(
      future: context.read<AlbumProvider>().albumQuery.queryAlbums(),
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
          context.read<AlbumProvider>().albums =
              snapshot.data as List<AlbumModel>;
          return ListView.builder(
            itemCount: context.read<AlbumProvider>().albums.length,
            itemBuilder: (context, index) {
              var album = context.read<AlbumProvider>().albums[index];
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
                    album.numOfSongs.toString() + ' songs  • ' + album.artist!,
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
                      color: Color.fromARGB(110, 48, 228, 51),
                      size: 34,
                    ),
                  ),
                  onTap: () async {
                    context.read<AlbumProvider>().albumSongs = await context
                        .read<AlbumProvider>()
                        .albumQuery
                        .queryAudiosFrom(AudiosFromType.ALBUM_ID, album.id);
                  },
                ),
              );
            },
          );
        }
      },
    ));
  }
}
