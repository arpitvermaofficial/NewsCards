import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'dart:math';
import 'package:news_views/user.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'cardProvider.dart';


class NewsCard extends StatefulWidget {
  final User user;
  final bool isFront;
  const NewsCard({super.key, required this.user, required this.isFront});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isElevated = true;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.user.image,
      ),
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Offset distance = isElevated ? const Offset(5, 5) : const Offset(10, 10);
    double blur = isElevated ? 15.0 : 20.0;
    final provider = Provider.of<CardProvider>(context,listen: true);

    return widget.isFront ? buildFrontCard(distance,blur) : buildCard(distance,blur);
  }

  Widget buildCard(Offset distance,double blur) => AnimatedContainer(  duration: const Duration(milliseconds: 200),
    height: 400,
    padding: const EdgeInsets.all(10),
    decoration:BoxDecoration(
      image: DecorationImage(

        image: AssetImage( "assets/1.jpg"),
        fit: BoxFit.fill,
      ),

      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.grey[500]!,
          offset: distance,
          blurRadius: blur,
          spreadRadius: 1,
          inset: isElevated,
        ),
        BoxShadow(
          color: Colors.black,
          offset: -distance,
          blurRadius: blur,
          spreadRadius: 1,
          inset: isElevated,
        )
      ],
    ),
    child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,

                  child: VideoPlayer(_controller),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
  );

  Widget buildFrontCard(Offset distance,double blur) => GestureDetector(
        onTap: () {

          setState(() { isElevated = !isElevated;
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: LayoutBuilder(builder: (context, constraints) {
          final provider = Provider.of<CardProvider>(context);
          final position = provider.position;
          final centre = constraints.smallest.center(Offset.zero);
          final miliiseconds = provider.isDrag ? 0 : 400;
          final angle = provider.angle * pi / 180;
          final rotateMatrix = Matrix4.identity()
            ..translate(centre.dx, centre.dy)
            ..rotateZ(angle)
            ..translate(-centre.dx, -centre.dy);
          return AnimatedContainer(
              transform: rotateMatrix..translate(position.dx, position.dy),
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: miliiseconds),
              child: buildCard(distance,blur));
        }),
        onPanStart: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.startPosition(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.updatePosition(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.endPosition(details);
        },
      );
}
