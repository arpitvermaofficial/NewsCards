import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/News_Model.dart';
import '../View_Model/cardProvider.dart';
import 'Widgets/card.dart';

class NewsView extends StatefulWidget {
  const NewsView({
    super.key,
  });

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/11.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),
                child: Container(child: buildCards()))));
  }

  Widget buildCards() {
    final provider = Provider.of<CardProvider>(context, listen: true);

    final urlImages = provider.urlimage;
    return urlImages.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: urlImages
                .map((urlimage) => NewsCard(
                    user: User(image: urlimage),
                    isFront: urlImages.last == urlimage))
                .toList(),
          );
  }
}
