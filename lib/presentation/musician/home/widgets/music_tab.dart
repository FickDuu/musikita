import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'music_player_card.dart';

//show music with player controls
class MusicTab extends StatelessWidget{
  final String userId;

  const MusicTab({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context){
    //Todo: Fetch music from Firebase
    final demoMusic = List.generate(
      7,
      (index) => {
        'artistName': 'artist Name',
        'songName': 'song Name',
        'audioUrl': null, //add audio ltr
      },
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: demoMusic.length,
      itemBuilder: (context, index){
        final music = demoMusic[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MusicPlayerCard(
            artistName: music['artistName'] as String,
            songName: music['songName'] as String,
            audioUrl: music['audioUrl'],
          ),
        );
      },
    );
  }
}