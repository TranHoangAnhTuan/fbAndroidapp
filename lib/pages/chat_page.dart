import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';  // Add Firebase Auth package

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "Tuan");
  ChatUser severUser = ChatUser(id: "1", firstName: "Facebook Scraper");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Facebook Scrape"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(currentUser: currentUser, onSend: _sendMessage, messages: messages);
  }
Future<String?> _getFirebaseAuthToken() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Retrieve the Firebase ID Token (it can be null, hence nullable)
      String? idToken = await user.getIdToken();
      return idToken;
    } else {
      throw Exception("User not authenticated");
    }
  } catch (e) {
    throw Exception("Failed to get Firebase token: $e");
  }
}
void _sendMessage(ChatMessage chatMessage) async {
  setState(() {
    messages = [chatMessage, ...messages];
  });

  try {
    String apiUrl = "http://10.0.2.2:5000/chat_message"; // Use for Android Emulator

    // Get the Firebase authentication token
    String? authToken = await _getFirebaseAuthToken();  // Declared as nullable String?

    if (authToken == null) {
      throw Exception("No valid authentication token found.");
    }

    Map<String, dynamic> payload = {
      "id": DateTime.now().millisecondsSinceEpoch, // Unique ID
      "username": chatMessage.user.firstName,
      "text": chatMessage.text,
      "datetime": DateTime.now().toIso8601String(),
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",  // Send the auth token here
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

      // Extract AI response
      String aiResponse = responseData["ai_response"] ?? "No response from AI.";

      ChatMessage replyMessage = ChatMessage(
        user: severUser,
        createdAt: DateTime.now(),
        text: aiResponse,
      );

      setState(() {
        messages = [replyMessage, ...messages];
      });

      print("Message sent and AI responded: $aiResponse");
    } else {
      print("Failed to send message: ${response.body}");
    }
  } catch (e) {
    print("Error sending message: $e");
  }
}

}
