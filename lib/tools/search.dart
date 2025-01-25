import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music/const/text_style.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:provider/provider.dart';

class Search extends SearchDelegate {
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        systemOverlayStyle: colorScheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? const Color.fromARGB(255, 72, 53, 99)
            : const Color.fromARGB(255, 96, 73, 127),
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        titleTextStyle: theme.textTheme.titleLarge,
        toolbarTextStyle: theme.textTheme.bodyMedium,
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          const InputDecorationTheme(
            hintStyle: TextStyle(
              color: const Color.fromARGB(100, 150, 147, 147),
              fontSize: 18,
            ),
            border: InputBorder.none,
          ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        // IconButton(
        //     onPressed: () {
        //       if (query.isEmpty) close(context, null);
        //       query = '';
        //     },
        //     icon: Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded));

  @override
  Widget buildResults(BuildContext context) {
    return Placeholder();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var filteredSongs = context
        .read<musicprovider>()
        .songs
        .where((song) => song.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: filteredSongs.length,
            itemBuilder: (BuildContext context, int index) {
              var song = filteredSongs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: ListTile(
                  onTap: () {
                    //some issue here
                    context.read<musicprovider>().currentsong = song;
                    context.read<musicprovider>().play(song.uri);
                  },
                  leading: const Icon(
                    Icons.music_note_outlined,
                    color: Colors.white,
                  ),
                  title: Text(
                    song.title.length > 30
                        ? '${song.title.substring(0, 27)}...'
                        : song.title,
                    style: our_style(),
                  ),
                ),
              );
            },
          ),
        ),
        if (context.watch<musicprovider>().currentsong != null)
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.music_note_outlined,
                  color: Colors.white70,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.watch<musicprovider>().currentsong!.title,
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  //previous button
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () async {
                    context.read<musicprovider>().savedPosition = null;
                    context.read<musicprovider>().currentsong =
                        await context.read<musicprovider>().playPervious();
                    context.read<musicprovider>().fetchmusicimage();
                  },
                ),
                context.watch<musicprovider>().isplaying
                    ? IconButton(
                        icon: const Icon(
                          Icons.pause,
                          color: Color.fromARGB(255, 214, 201, 201),
                        ),
                        onPressed: () {
                          context.read<musicprovider>().pauseSong(
                              context.read<musicprovider>().currentsong!.uri);

                          context.read<musicprovider>().isplaying = false;
                        },
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Color.fromARGB(255, 214, 201, 201),
                        ),
                        onPressed: () {
                          context.read<musicprovider>().playSong(
                              context.read<musicprovider>().currentsong!.uri);
                          context.read<musicprovider>().isplaying = true;
                          context.read<musicprovider>().savedPosition = null;
                        },
                      ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: Color.fromARGB(255, 214, 201, 201),
                  ),
                  onPressed: () async {
                    context.read<musicprovider>().savedPosition = null;
                    context.read<musicprovider>().currentsong =
                        await context.read<musicprovider>().playNext();
                    context.read<musicprovider>().fetchmusicimage();
                  },
                ),
                //next button
              ],
            ),
          ),
      ],
    );
  }
}
