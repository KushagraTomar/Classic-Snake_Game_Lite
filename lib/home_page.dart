import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart ';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/high_score.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/snake_pixel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snakeDirection {UP, DOWN, LEFT, RIGHT}

class _HomePageState extends State<HomePage> {
  // Grid Dimensions
  int rowSize = 10;
  int totalNoOfSquares = 100;

  // Has the Game Started?
  bool gameHasStarted = false;

  // Initial Snake Position
  List<int> snakePos = [
    0, 1, 2,
  ];

  // Initial Snake Direction is Set Right
  var currDirection = snakeDirection.RIGHT;

  // Initial Food Position
  int foodPos = Random().nextInt(100);

  // Users Current Score
  int currScore = 0;

  // HighScores List
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  //  Name Controller
  late TextEditingController controller;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(1)
        .get()
        .then((value) => value.docs.forEach((element) {
          highscore_DocIds.add(element.reference.id);
    }));
  }

  // start the Game!
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        // Keep the Snake Moving!
        moveSnake();
        // Check if the Game is Over
        if (gameOver()) {
          timer.cancel();
          // Display a Dialog Message
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(),
                title: Text(
                  'GAME OVER',
                  style: GoogleFonts.righteous(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  children: [
                    Text(
                      'USER SCORE: ' + currScore.toString(),
                      style: GoogleFonts.righteous(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter Your Name'),
                      controller: controller,
                    ),
                  ],
                ),
                actions: [
                  Container(
                    child: MaterialButton(
                      child: const Text('SUBMIT'),
                      color: Colors.pinkAccent,
                      onPressed: () {
                        submitScore();
                        newGame() ;
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  void submitScore() {
    // Get access to the collection
    var database = FirebaseFirestore.instance;

    // Add data to Firebase
    database.collection('highscores').add({
      "name": controller.text,
      "score": currScore,
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0, 1, 2,
      ];
      currScore = 0;
      foodPos = Random().nextInt(100);
      currDirection = snakeDirection.RIGHT;
      gameHasStarted = false;
    });
  }

  void eatTheFood() {
    currScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNoOfSquares);
    }
  }

  void moveSnake() {
    switch(currDirection) {
      case snakeDirection.RIGHT:
        {
          // add a new head
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case snakeDirection.LEFT:
        {
          // add a new head
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snakeDirection.UP:
        {
          // add a new head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNoOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snakeDirection.DOWN:
        {
          // add a new head
          if (snakePos.last + rowSize > totalNoOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNoOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }
    // Snake is Eating Food!
    if (snakePos.last == foodPos) {
      // do not remove the tail
      eatTheFood();
    } else {
      // remove the tail
      snakePos.removeAt(0);
    }
  }

  // Game Over
  bool gameOver() {
    // List is the Snake Body (no head)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length-1);
    if(bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Color
      backgroundColor: Colors.blueGrey[400],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // High Scores, top 1
                  Expanded(
                    child: gameHasStarted ? Container()
                        : FutureBuilder(
                          future: letsGetDocIds,
                          builder: (context, snapshot) {
                            return ListView.builder(
                              itemCount: highscore_DocIds.length,
                              itemBuilder: ((context, index) {
                                return HighScore(
                                    documentId: highscore_DocIds[index]);
                            }),
                          );
                        }),
                  ),

                  // User Current Score
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'USER SCORE: ',
                          style: GoogleFonts.righteous(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          currScore.toString(),
                          style: GoogleFonts.righteous(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ),

          //Game Grid
          Expanded(
            flex: 4,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currDirection != snakeDirection.UP) {
                    currDirection = snakeDirection.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currDirection != snakeDirection.DOWN) {
                    currDirection = snakeDirection.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currDirection != snakeDirection.LEFT) {
                    currDirection = snakeDirection.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currDirection != snakeDirection.RIGHT) {
                    currDirection = snakeDirection.LEFT;
                  }
                },
                child: GridView.builder(
                  itemCount: totalNoOfSquares,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize,
                  ),
                  itemBuilder: (context,index) {
                    if (snakePos.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  }),
              ),
          ),

          // Play Button
          // End Credits
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: MaterialButton(
                      elevation: 0,
                      shape: RoundedRectangleBorder(),
                      color: gameHasStarted? Colors.grey: Colors.pink,
                      onPressed: gameHasStarted? (){}: startGame,
                      child: Text(
                        "PLAY",
                        style: GoogleFonts.righteous(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CREDITS: KUSHAGRA TOMAR',
                    style: GoogleFonts.amaticSc(
                      fontSize: 24,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
