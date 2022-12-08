import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snake_game_flutter/highscore_tile.dart';

import 'package:snake_game_flutter/snake_pixel.dart';

import 'blank_pixel.dart';
import 'food_pixel.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // grid dimensions

  int rowSize = 10;
  int totalNumbersOfSquares = 100;

  //user score
  int currentScore = 0;
  bool gamehasStarted = false;

  final _nameController = TextEditingController();

  //snake position
  List<int> snakepos = [
    0,
    1,
    2,
  ];

  //snake  direcdtion is initialilly to the right
  var currentDirection = snake_Direction.RIGHT;

  //food position
  int foodPos = 55;

  //high scores list
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  //start the game
  void startGame() {
    gamehasStarted = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();

        //check if the game is over
        if (gameOver()) {
          timer.cancel();
          //display a message to user
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Game over'),
                  content: Column(
                    children: [
                      Text('Your score is: ' + currentScore.toString()),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: 'Enter name'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        submitScore();
                        newGame();
                      },
                      child: Text('Subimit'),
                      color: Colors.pink,
                    )
                  ],
                );
              });
        }
      });
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakepos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = snake_Direction.RIGHT;
      gamehasStarted = false;
      currentScore = 0;
    });
  }

  void submitScore() {
    //get access to the collection
    var database = FirebaseFirestore.instance;

    //add data to firebase
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  void eatFood() {
    currentScore++;
    while (snakepos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumbersOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //if snake is at the right wall, need to re-adjust
          if (snakepos.last % rowSize == 9) {
            snakepos.add(snakepos.last + 1 - rowSize);
          } else {
            snakepos.add(snakepos.last + 1);
          }
          // add a head

          // remove tail
        }
        break;
      case snake_Direction.LEFT:
        {
          // add a head
          if (snakepos.last % rowSize == 0) {
            snakepos.add(snakepos.last - 1 + rowSize);
          } else {
            //remove tail
            snakepos.add(snakepos.last - 1);
          }
          // remove tail
        }
        break;
      case snake_Direction.UP:
        {
          // add a head
          if (snakepos.last < rowSize) {
            snakepos.add(snakepos.last - rowSize + totalNumbersOfSquares);
          } else {
            snakepos.add(snakepos.last - rowSize);
          }
          // remove tail
        }
        break;
      case snake_Direction.DOWN:
        {
          if (snakepos.last + rowSize > totalNumbersOfSquares) {
            snakepos.add(snakepos.last + rowSize - totalNumbersOfSquares);
          } else {
            snakepos.add(snakepos.last + rowSize);
          }
          // remove tail
        }
        break;
      default:
    }
    //snake is eating the food
    if (snakepos.last == foodPos) {
      eatFood();
    } else {
      snakepos.removeAt(0);
    }
  }

  //game over
  bool gameOver() {
    //the game is over when the snake rubns into itself
    //this occurs when there is a duplicate position in the snake position list

    //this list is the body of the snake (no head)
    List<int> bodySnake = snakepos.sublist(0, snakepos.length - 1);
    if (bodySnake.contains(snakepos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    //get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 428 ? 428 : screenWidth,
        child: Column(children: [
          //high scores
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //user current score
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Current score'),
                    Text(
                      currentScore.toString(),
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
              ),

              //high scores top 5 or 10
              Expanded(
                child: gamehasStarted
                    ? Container()
                    : FutureBuilder(
                        future: letsGetDocIds,
                        builder: (context, snapshot) {
                          return ListView.builder(
                              itemCount: highscore_DocIds.length,
                              itemBuilder: ((context, index) {
                                return HighScoreTile(
                                    documentId: highscore_DocIds[index]);
                              }));
                        }),
              ),
            ],
          )),

          // games grid

          Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snake_Direction.UP) {
                    currentDirection = snake_Direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snake_Direction.DOWN) {
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snake_Direction.LEFT) {
                    currentDirection = snake_Direction.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snake_Direction.RIGHT) {
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                  itemCount: totalNumbersOfSquares,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize),
                  itemBuilder: (context, index) {
                    if (snakepos.contains(index)) {
                      return const SnakePixel();
                    } else if (foodPos == index) {
                      return const FoodPixel();
                    } else {
                      return const BlankPixel();
                    }
                  },
                ),
              )),
          // play button
          Expanded(
              child: Container(
            child: Center(
                child: MaterialButton(
              onPressed: gamehasStarted ? () {} : startGame,
              child: Text('PLAY'),
              color: gamehasStarted ? Colors.grey : Colors.pink,
            )),
          )),
        ]),
      ),
    );
  }
}
