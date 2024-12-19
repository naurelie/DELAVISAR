import 'package:http/http.dart' as http;
import './question_model.dart';
import 'dart:convert';

class DBconnect {
  // Firebase database URL
  final url = Uri.parse(
      'https://simplequizapp-b24a0-default-rtdb.firebaseio.com/questions.json');

  // Fetch data from the database
  Future<List<Question>> fetchQuestions() async {
    try {
      // Send a GET request to the database
      final response = await http.get(url);

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        // Decode the response body
        var data = json.decode(response.body);

        // If data is null, throw an exception
        if (data == null) {
          throw Exception('No data found');
        }

        // Cast the decoded data to a Map<String, dynamic>
        var questionMap = data as Map<String, dynamic>;

        // Initialize a list to store the questions
        List<Question> newQuestions = [];

        // Loop through each key-value pair in the map
        questionMap.forEach((key, value) {
          // Ensure 'options' exists and is a map
          if (value['options'] != null && value['options'] is Map) {
            // Create a new Question object
            var newQuestion = Question(
              id: key, // Use the key as the ID
              title: value['title'], // Extract the title
              options: Map<String, bool>.from(value['options']), // Cast options to Map<String, bool>
            );
            newQuestions.add(newQuestion); // Add the question to the list
          }
        });

        // Return the list of questions
        return newQuestions;
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load questions');
      }
    } catch (error) {
      // Catch any errors that occur and rethrow them
      throw Exception('Failed to fetch questions: $error');
    }
  }
}
