import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;

import 'package:news_views/card.dart';
import 'package:news_views/user.dart';
import 'package:provider/provider.dart';
import 'cardProvider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
             color: Colors.grey[300],

              alignment: Alignment.center,
      padding: EdgeInsets.all(16),
      child: buildCards(),
    )));
  }

  Widget buildCards() {
    final provider = Provider.of<CardProvider>(context, listen: true);

    final urlImages = provider.urlimage;
    return urlImages.isEmpty
        ? Center(
            child: CircularProgressIndicator())
        : Stack(
            children: urlImages
                .map((urlimage) =>
                NewsCard(
                    user: User(image: urlimage),
                    isFront: urlImages.last == urlimage)
            )
                .toList(),
          );
  }
}
