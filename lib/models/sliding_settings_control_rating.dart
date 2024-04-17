
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seegle/screens/auth/auth_wrapper.dart';

class CustomSliderRating extends StatefulWidget {
  final String category;
  final String title;
  final String uid;
  final String username;

  const CustomSliderRating(
      {Key? key,
      required this.category,
      required this.title,
      required this.uid,
      required this.username})
      : super(key: key);

  @override
  State<CustomSliderRating> createState() => _CustomSliderRatingState();
}

class _CustomSliderRatingState extends State<CustomSliderRating> {
  late DocumentReference ratingsRef;
  int _currentSliderValue = 0;
  checkCategory() async {
    return setState(() {
      ratingsRef =
          FirebaseFirestore.instance.collection('ratings').doc(widget.category);
    });
  }


  @override
  void initState() {
    checkCategory();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  addRating(value) async {
    await usersRef.doc(currentUser!.id).update(
      {'${widget.category}SelfRating': value},
    );
  }

  addBeginner(value) async {
    await ratingsRef.collection('beginner').doc(widget.uid).set(
        {'uid': widget.uid, "username": widget.username, "self-rating": value});
    await ratingsRef.collection('advanced').doc(widget.uid).delete();
    await ratingsRef.collection('expert').doc(widget.uid).delete();
  }

  addAdvanced(value) async {
    await ratingsRef.collection('advanced').doc(widget.uid).set(
        {'uid': widget.uid, "username": widget.username, "self-rating": value});
    await ratingsRef.collection('beginner').doc(widget.uid).delete();
    await ratingsRef.collection('expert').doc(widget.uid).delete();
  }

  addExpert(value) async {
    await ratingsRef.collection('expert').doc(widget.uid).set(
        {'uid': widget.uid, "username": widget.username, "self-rating": value});
    await ratingsRef.collection('advanced').doc(widget.uid).delete();
    await ratingsRef.collection('beginner').doc(widget.uid).delete();
  }

  removeAll() async {
    await ratingsRef.collection('beginner').doc(widget.uid).delete();
    await ratingsRef.collection('advanced').doc(widget.uid).delete();
    await ratingsRef.collection('beginner').doc(widget.uid).delete();
  }

  _onValueChanged(double value) async {
    await addRating(value);
    value < 1
        ? await removeAll()
        : value > 1 && value <= 33
            ? await addBeginner(value)
            : value > 33 && value < 66.6
                ? await addAdvanced(value)
                : await addExpert(value);
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(currentUser!.id).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            _currentSliderValue = data['${widget.category}SelfRating'].toInt();

            return Column(
              children: [
                Text(
                    "${widget.title} - ${_currentSliderValue.round()}",
                    style: const TextStyle(fontSize: 16)),
                Slider(
                  value: _currentSliderValue.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _currentSliderValue.round() < 1
                      ? 'None'
                      : _currentSliderValue.round() > 1 &&
                              _currentSliderValue.round() <= 33
                          ? 'Beginner ${_currentSliderValue.round().toString()}'
                          : _currentSliderValue.round() > 34 &&
                                  _currentSliderValue.round() <= 66.6
                              ? 'Advanced ${_currentSliderValue.round().toString()}'
                              : 'Expert ${_currentSliderValue.round().toString()}',
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value.toInt();
                    });
                  },
                  onChangeEnd: (double value) {
                    _onValueChanged(value);
                  },
                ),
              ],
            );
          }

          return Column(
              children: [
                Text(
                    "${widget.title} - ${_currentSliderValue.round()}",
                    style: const TextStyle(fontSize: 16)),
                Slider(
                  value: _currentSliderValue.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _currentSliderValue.round() < 1
                      ? 'None'
                      : _currentSliderValue.round() > 1 &&
                              _currentSliderValue.round() <= 33
                          ? 'Beginner ${_currentSliderValue.round().toString()}'
                          : _currentSliderValue.round() > 34 &&
                                  _currentSliderValue.round() <= 66.6
                              ? 'Advanced ${_currentSliderValue.round().toString()}'
                              : 'Expert ${_currentSliderValue.round().toString()}',
                  onChanged: (double value) {
                    
                  },
                  onChangeEnd: (double value) {
                    _onValueChanged(value);
                  },
                ),
              ],
            );
        });
  }
}


// Text("Full Name: ${data[widget.category+'SelfRating']} ")