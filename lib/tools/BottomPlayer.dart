import 'package:flutter/material.dart';
import 'package:music/provider/Music_Provider.dart';
import 'package:provider/provider.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(146, 33, 33, 33),
      height: 60,
      //padding: const EdgeInsets.only(),
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
              size: 35,
              color: Color.fromARGB(255, 140, 121, 167),
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
                    color: Color.fromARGB(255, 140, 121, 167),
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
                    color: Color.fromARGB(255, 140, 121, 167),
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
              size: 35,
              color: Color.fromARGB(255, 140, 121, 167),
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
    );
  }
}
