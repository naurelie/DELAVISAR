import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/question_model.dart'; // our question model
import '../widgets/question_widget.dart'; // the question widget
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/db_connect.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var db = DBconnect();
  late Future _questions;

  Future<List<Question>> getData() async {
    return db.fetchQuestions();
  }

  @override
  void initState() {
    _questions = getData();
    super.initState();
  }

  int index = 0;
  int score = 0;
  bool isPressed = false;
  bool isAlreadySelected = false;

  void nextQuestion(int questionLength) {
    if (index == questionLength - 1) {
      // End of quiz
      showDialog(
          context: context,
          builder: (ctx) => ResultBox(
                result: score, 
                questionLength: questionLength,
                onPressed: startOver,
              ));
    } else {
      if (isPressed) {
        setState(() {
          index++;
          isPressed = false;
          isAlreadySelected = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select an option'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(vertical: 20.0),
        ));
      }
    }
  }

  void checkAnswerAndUpdate(bool value) {
    if (isAlreadySelected) {
      return;
    } else {
      if (value) {
        score++;
      }
      setState(() {
        isPressed = true;
        isAlreadySelected = true;
      });
    }
  }

  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadySelected = false;
    });
    Navigator.pop(context);
  }

@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _questions,  // This already fetches questions from Firebase
    builder: (ctx, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (snapshot.hasData) {
          var extractedData = snapshot.data as List<Question>;

          if (extractedData.isEmpty) {
            return const Center(child: Text('No questions available'));
          }

          return Scaffold(
            backgroundColor: background,
            appBar: AppBar(
              title: const Text('Quiz App Sarah Cantik'),
              backgroundColor: background,
              shadowColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(18.00),
                  child: Text(
                    'Score: $score',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
            body: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  // Question widget
                  QuestionWidget(
                    indexAction: index,
                    question: extractedData[index].title,
                    totalQuestions: extractedData.length,
                  ),
                  const Divider(color: neutral),
                  const SizedBox(height: 25.0),
                  for (int i = 0; i < extractedData[index].options.length; i++)
                    GestureDetector(
                      onTap: () => checkAnswerAndUpdate(
                        extractedData[index].options.values.toList()[i],
                      ),
                      child: OptionCard(
                        option: extractedData[index].options.keys.toList()[i],
                        color: isPressed
                            ? extractedData[index].options.values
                                    .toList()[i] ==
                                true
                                ? correct
                                : incorrect
                            : neutral,
                      ),
                    ),
                ],
              ),
            ),
            floatingActionButton: GestureDetector(
              onTap: () => nextQuestion(extractedData.length),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: NextButton(),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else {
          return const Center(child: Text('No Data'));
        }
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    },
  );
}
}