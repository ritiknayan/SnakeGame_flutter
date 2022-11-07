import 'dart:async';

import 'package:flutter/material.dart';

import 'package:snake_game_flutter/snake_pixel.dart';

import 'blank_pixel.dart';
import 'food_pixel.dart';

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

  //start the game
  void startGame() {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        //keep the snake moving
        moveSnake();
      });
    });
  }

  void eatFood() {}

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
          snakepos.removeAt(0);
        }
        break;
      case snake_Direction.LEFT:
        {
          // add a head
          if (snakepos.last % rowSize == 0) {
            snakepos.add(snakepos.last - 1 + rowSize);
          } else {
            snakepos.add(snakepos.last - 1);
          }
          // remove tail
          snakepos.removeAt(0);
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
          snakepos.removeAt(0);
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
          snakepos.removeAt(0);
        }
        break;
      default:
    }

    if (snakepos.last == foodPos) {
      eatFood();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        //high scores
        Expanded(child: Container()),

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
            onPressed: startGame,
            child: Text('PLAY'),
            color: Colors.pink,
          )),
        )),
      ]),
    );
  }
}
