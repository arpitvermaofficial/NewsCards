import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum CardStatus { Interested, NotInterested}

class CardProvider extends ChangeNotifier {

  int index = 2;
  String right = "";
  String curr = "";

  List<String> _urlimage = [];

  Offset _position = Offset.zero;
  bool _isDrag = false;
  double _angle = 0;
  Size _screenSize = Size.zero;
  List<String> get urlimage => _urlimage;
  Offset get position => _position;
  void intialize() {
    DocumentReference users =
        FirebaseFirestore.instance.collection('news').doc(index.toString());
    users.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        curr = data['current'];
        right = data['right'];
        index = data['index'];

        urlimage.add(curr);
        urlimage.add(right);
        urlimage.reversed.toList();
        notifyListeners();
      },
    );
  }

  Future fetch(int index1) async {
    DocumentReference users =
        FirebaseFirestore.instance.collection('news').doc(index1.toString());
    users.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        _urlimage.insert(0, data['right']);
        notifyListeners();
      },
    );
    return;
  }

  CardProvider() {
    intialize();
  }
  bool get isDrag => _isDrag;
  double get angle => _angle;

  void setScreenSize(Size size) {
    _screenSize = size;
  }

  void startPosition(DragStartDetails details) {
    _isDrag = true;
    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;
    notifyListeners();
  }

  void endPosition(DragEndDetails details) {
    _isDrag = false;
    notifyListeners();
    final status = getsatus();
    if (status != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: status.toString().split('.').last.toUpperCase(), fontSize: 16.0,textColor: status == CardStatus.Interested ? Colors.green : Colors.red);
    }

    switch (status) {
      case CardStatus.Interested:
        like();
        break;
      case CardStatus.NotInterested:
        dislike();
        break;
      default:
        resetPostion();
    }
  }

  CardStatus? getsatus() {
    final x = _position.dx;
    final y = _position.dy;
    final forceSuperLike = x.abs() < 20;
    final delta = 100;
    if (x >= delta) {
      return CardStatus.Interested;
    } else if (x <= -delta) {
      return CardStatus.NotInterested;
    }
  }

  void resetPostion() {
    _isDrag = false;
    _position = Offset.zero;
    _angle = 0;
    notifyListeners();
  }

  void like() {

    notifyListeners();
    _angle = 20;
    _position += Offset(2 * _screenSize.width / 2, 0);
    _nextCard();
    notifyListeners();
  }

  void dislike() {
    notifyListeners();
    _angle = -20;
    _position -= Offset(2 * _screenSize.width, 0);
    _nextCard();
    notifyListeners();
  }

  Future _nextCard() async {
    if (_urlimage.isEmpty) {
      return;
    }
    await Future.delayed(Duration(milliseconds: 200));
    _urlimage.removeLast();
    index = index + 1;
    fetch(index);

    resetPostion();
  }
}
