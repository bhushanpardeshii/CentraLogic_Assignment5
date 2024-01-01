import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FeedbackChatbot extends StatefulWidget {
  const FeedbackChatbot({super.key});

  @override
  State<FeedbackChatbot> createState() => _ChatbotState();
}

String apiUrl =
    "https://sapdos-api-v2.azurewebsites.net/api/Credentials/FeedbackJoiningBot";
Uri uri = Uri.parse(apiUrl);

Future<String> generateText(String prompt) async {
  final response = await http.post(
    uri,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiUrl",
    },
    body: jsonEncode({
      "step": prompt,
    }),
  );

  if (response.statusCode == 200) {
    final responseJson = jsonDecode(response.body);
    String responseMessage = responseJson['message'];
    return responseMessage;
  } else {
    return "Invaid input";
  }
}

class _ChatbotState extends State<FeedbackChatbot> {
  final _textController = TextEditingController();
  final _messages = <String>[];
  @override
  void initState() {
    super.initState();
    // Add an initial bot message to the list
    _addBotMessage(
        "Hi Welcome to CentraLogic Feedback Agent! Thank You for your interest in CentraLogic!");
    _addBotMessage(
        "On a scale of 1 to 5,how would you rate the overall effectiveness of the Flutter training you received in the last month? ");
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _sendMessage() async {
    String message = _textController.text;
    setState(() {
      _messages.add(' $message');
      _textController.clear();
    });

    await _getResponse(message);
  }

  Future<String> _getResponse(String message) async {
    try {
      final response = await generateText(message);
      if (response.isEmpty) {
        return "Error generating response";
      }
      setState(() {
        _messages.add(response);
        _textController.clear(); // Add the API response
      });

      return response;
    } catch (e) {
      setState(() {
        //Error for invalid input
        _messages.add("Invalid Input");
      });
      return "error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to CentraLogic",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              "Hi Charles",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            Divider(),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const Image(
              image: AssetImage("assets/img.png"),
              width: 50,
            ),
            const Text(
              'CentraLogic Bot',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Hi! Im CentraLogic Bot,your onboarding agent",
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(
              height: 25,
            ),
            Flexible(
              child: ListView(
                children: _messages.map((message) {
                  if (message.startsWith(' ')) {
                    return _buildUserMessage(message, true);
                  } else {
                    return _buildBotMessage(message, context);
                  }
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type Your Message',
                        hintStyle: const TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Send',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildUserMessage(String message, bool isUser) {
  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(message.trimLeft()),
    ),
  );
}

Widget _buildBotMessage(String message, BuildContext context) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/img.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, overflow: TextOverflow.visible),
          ),
        ],
      ),
    ),
  );
}
