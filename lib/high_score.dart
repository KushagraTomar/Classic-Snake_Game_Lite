import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class HighScore extends StatelessWidget {
  final String documentId;
  const HighScore({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference highscores =
        FirebaseFirestore.instance.collection('highscores');
    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'HIGHSCORE: ',
                style: GoogleFonts.righteous(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
                // style: TextStyle(
                //     fontSize: 18,
                //     color: Colors.black,
                //     fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['score'].toString(),
                    style: GoogleFonts.righteous(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    data['name'].toUpperCase(),
                    style: GoogleFonts.righteous(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return const Text('LOADING..');
        }
      },
    );
  }
}
