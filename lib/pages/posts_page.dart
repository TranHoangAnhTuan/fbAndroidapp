  import 'dart:async';
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:uuid/uuid.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:shared_preferences/shared_preferences.dart';

class Post {
  final String uuid;
  final String groupId;
  final String postId;
  final String createTime;
  final String text;

  Post({
    required this.uuid,
    required this.groupId,
    required this.postId,
    required this.createTime,
    required this.text,
  });

  // Generate the link dynamically
  String get link => "facebook.com/$groupId/$postId";

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "group_id": groupId,
        "post_id": postId,
        "create_time": createTime,
        "text": text,
      };

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      uuid: json["uuid"] ?? "", // Provide default value
      groupId: json["group_id"] ?? "",
      postId: json["post_id"] ?? "",
      createTime: json["create_time"] ?? "",
      text: json["text"] ?? "",
    );
  }
}
  class Topic {
  final String uuid;
  final String note;
  final List<String> groupUrls;
  final String? authToken;
  List<Post> posts; // Add this field

  Topic({
    required this.uuid,
    required this.note,
    required this.groupUrls,
    required this.authToken,
    this.posts = const [], // Initialize as empty
  });

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "note": note,
        "groupUrls": groupUrls,
        "authToken": authToken,
        "posts": posts.map((post) => post.toJson()).toList(), // Include posts in JSON
      };

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      uuid: json["uuid"],
      note: json["note"],
      groupUrls: List<String>.from(json["groupUrls"]),
      authToken: json["authToken"],
      posts: List<Post>.from(
          json["posts"]?.map((post) => Post.fromJson(post)) ?? []), // Parse posts
    );
  }
}
  class PostsPage extends StatefulWidget {
    const PostsPage({super.key});

    @override
    State<PostsPage> createState() => _PostsPageState();
  }

  class _PostsPageState extends State<PostsPage> with SingleTickerProviderStateMixin {
    final List<Topic> _topics = [];
    final List<String> _groupUrls = [];
    final _uuid = Uuid();
    final User? user = FirebaseAuth.instance.currentUser;
    late TabController _tabController;
    final TextEditingController _noteController = TextEditingController();
    final TextEditingController _urlController = TextEditingController();
    final String _prefsKeyTopic = "saved_topics";
    final String _prefsKeyPost = "saved_posts";
  // State variable to track the selected topic
    Topic? _selectedTopic;
    StreamSubscription? _sseSubscription;
void _connectToSSE() async {
  final String? token = await user?.getIdToken();
  if (token == null) return;

  final sseUrl = Uri.parse("http://10.0.2.2:5000/sse");
  final request = http.Request("GET", sseUrl)
    ..headers["Authorization"] = "Bearer $token";

  final client = http.Client();
  final stream = client.send(request).asStream().asyncExpand((response) {
    return response.stream.transform(utf8.decoder).transform(LineSplitter());
  });

  _sseSubscription = stream.listen((data) {
    debugPrint("Received SSE data: $data"); // Log the raw data

    // Skip empty lines or comments
    if (data.isEmpty || data.startsWith(":")) {
      return;
    }

    try {
      // Remove the "data: " prefix (if present) and parse the JSON
      final jsonString = data.replaceFirst("data: ", "");
      final jsonData = jsonDecode(jsonString);

      // Extract the UUID and post data
      final String uuid = jsonData["uuid"] ?? "";
      final String groupId = jsonData["group_id"] ?? "";
      final String postId = jsonData["post_id"] ?? "";
      final int createTime = int.tryParse(jsonData["create_time"] ?? "0") ?? 0;
      final String text = jsonData["text"] ?? "";

      // Create a Post object
      final Post post = Post(
        uuid: uuid,
        groupId: groupId,
        postId: postId,
        createTime: createTime.toString(),
        text: text,
      );

      if (uuid.isNotEmpty) {
        _savePost(post);
        debugPrint("Saved post: ${post.postId}");
        setState(() {
          final topicIndex = _topics.indexWhere((topic) => topic.uuid == uuid);
          if (topicIndex != -1) {
            _topics[topicIndex].posts.add(post); // Add the new post to the topic
          }
        });
      } else {
        debugPrint("Received post with null or empty UUID: $jsonData");
      }
    } catch (e) {
      debugPrint("Error parsing SSE data: $e");
    }
  }, onError: (error) {
    debugPrint("SSE error: $error");
  });
}


          Future<List<Post>> loadPostsByUuid(String uuid) async {
  final prefs = await SharedPreferences.getInstance();
  final Set<String> keys = prefs.getKeys();
  
  // Filter keys that start with the given uuid
  final List<Post> posts = [];
  
  for (String key in keys) {
    if (key.startsWith('${uuid}_')) {
      final String? encodedPost = prefs.getString(key);
      if (encodedPost != null) {
        final Map<String, dynamic> postMap = jsonDecode(encodedPost);
        final Post post = Post.fromJson(postMap);
        posts.add(post);
      }
    }
  }
  
  return posts;
}
    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 1, vsync: this);
      _connectToSSE(); // Load saved topics when the app starts

      _loadTopics(); 
    }

    // Load topics from local storage
    Future<void> _loadTopics() async {
      final prefs = await SharedPreferences.getInstance();
      final String? savedTopics = prefs.getString(_prefsKeyTopic);
      if (savedTopics != null) {
        final List<dynamic> decodedTopics = jsonDecode(savedTopics);
        setState(() {
          _topics.addAll(decodedTopics.map((topic) => Topic.fromJson(topic)).toList());
        });
      }
    }

    // Save topics to local storage
    Future<void> _saveTopics() async {
      final prefs = await SharedPreferences.getInstance();
      final String encodedTopics = jsonEncode(_topics.map((topic) => topic.toJson()).toList());
      await prefs.setString(_prefsKeyTopic, encodedTopics);
    }

    void _createTopic() async {
      if (_noteController.text.isEmpty || _groupUrls.isEmpty) {
        debugPrint("Validation failed: Note or URLs are empty");
        return;
      }

      final String? token = await user?.getIdToken();
      final topic = Topic(
        uuid: _uuid.v4(),
        note: _noteController.text,
        groupUrls: _groupUrls,
        authToken: token,
      );

      try {
        final response = await http.post(
          Uri.parse("http://10.0.2.2:5000/create_topic"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(topic.toJson()),
        );

        if (response.statusCode == 200) {
          setState(() {
            _topics.add(topic);
          });
          await _saveTopics(); // Save topics after adding a new one
          debugPrint("Topic added successfully!");
        } else {
          debugPrint("Error: ${response.body}");
        }
      } catch (e) {
        debugPrint("Request failed: $e");
      }

      _noteController.clear();
      _groupUrls.clear();
    }

    void _updateTopic(int index, String newNote, List<String> newGroupUrls) async {
    final String? token = await user?.getIdToken();
    final updatedTopic = Topic(
      uuid: _topics[index].uuid,
      note: newNote,
      groupUrls: newGroupUrls,
      authToken: token,
    );

    try {
      final response = await http.put(
        Uri.parse("http://10.0.2.2:5000/update_topic/${_topics[index].uuid}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode(updatedTopic.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          _topics[index] = updatedTopic; // Update the local state
        });
        await _saveTopics(); // Save the updated topics to local storage
        debugPrint("Topic updated successfully!");
      } else {
        debugPrint("Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("Request failed: $e");
    }
  }

    void _deleteTopic(int index) async {
      final String? token = await user?.getIdToken();
      try {
        final response = await http.delete(
          Uri.parse("http://10.0.2.2:5000/delete_topic/${_topics[index].uuid}"),
          headers: {
            "Authorization": "Bearer $token"
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _topics.removeAt(index);
          });
          await _saveTopics(); // Save topics after deletion
          debugPrint("Topic deleted successfully!");
        } else {
          debugPrint("Error: ${response.body}");
        }
      } catch (e) {
        debugPrint("Request failed: $e");
      }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Topics")),
      body: Column(
        children: [
          // Topic Input Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: "Enter topic note",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: "Enter Group URL",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (_urlController.text.isNotEmpty) {
                            _groupUrls.add(_urlController.text);
                            _urlController.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
                Wrap(
                  children: _groupUrls.map((url) => Chip(label: Text(url))).toList(),
                ),
                ElevatedButton(
                  onPressed: _createTopic,
                  child: const Text("Create Topic"),
                ),
              ],
            ),
          ),

          // Topic Cards Section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _topics.map((topic) {
                    return GestureDetector(
                      onTap: () => _onTopicCardClicked(topic),
                      child: SizedBox(
                        width: 170.0,
                        child: Card(
                          margin: const EdgeInsets.all(4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.note.isNotEmpty ? topic.note : "No Title",
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18.0),
                                      onPressed: () {
                                        _showUpdateDialog(_topics.indexOf(topic));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18.0),
                                      onPressed: () {
                                        _deleteTopic(_topics.indexOf(topic));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Posts Section for Selected Topic
          if (_selectedTopic != null)
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Posts",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedTopic!.posts.length,
                      itemBuilder: (context, index) {
                        final post = _selectedTopic!.posts[index];
                        return ListTile(
                          title: Text(post.postId),
                          subtitle: Text(post.createTime.toString()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


     Future<void> _savePost(Post post) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedPost = jsonEncode(post.toJson());

    // Save the post under the topic's UUID
    final String topicKey = 'posts_${post.uuid}';
    final List<String>? existingPosts = prefs.getStringList(topicKey);
    final List<String> updatedPosts = [...existingPosts ?? [], encodedPost];

    await prefs.setStringList(topicKey, updatedPosts);
    debugPrint("Post saved for topic: ${post.uuid}");
  }

  Future<List<Post>> _loadPostsForTopic(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final String topicKey = 'posts_$uuid';
    final List<String>? encodedPosts = prefs.getStringList(topicKey);

    if (encodedPosts == null || encodedPosts.isEmpty) {
      debugPrint("No posts found for topic: $uuid");
      return [];
    }

    // Decode the posts
    final List<Post> posts = encodedPosts.map((encodedPost) {
      final Map<String, dynamic> postMap = jsonDecode(encodedPost);
      return Post.fromJson(postMap);
    }).toList();

    debugPrint("Loaded ${posts.length} posts for topic: $uuid");
    return posts;
  }

  void _onTopicCardClicked(Topic topic) async {
    // Load posts for the selected topic
    final List<Post> posts = await _loadPostsForTopic(topic.uuid);

    // Update the selected topic and its posts
    setState(() {
      _selectedTopic = topic;
      _selectedTopic!.posts = posts; // Assign the loaded posts to the topic
    });
  }



    void _showPostsDialog(int index) {
  final topic = _topics[index];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Posts for ${topic.note}"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: topic.posts.length,
            itemBuilder: (context, postIndex) {
              final post = topic.posts[postIndex];
              return ListTile(
                title: Text(post.text),
                subtitle: Text(post.link),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      topic.posts.removeAt(postIndex); // Remove the post locally
                    });
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

    void _showUpdateDialog(int index) {
    final topic = _topics[index];
    final TextEditingController updateNoteController = TextEditingController(text: topic.note);
    final TextEditingController updateUrlController = TextEditingController();
    List<String> updatedGroupUrls = List.from(topic.groupUrls);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Update Topic"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: updateNoteController,
                    decoration: const InputDecoration(
                      labelText: "Update topic note",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: updateUrlController,
                    decoration: InputDecoration(
                      labelText: "Add/Update Group URL",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (updateUrlController.text.isNotEmpty) {
                            setState(() {
                              updatedGroupUrls.add(updateUrlController.text);
                            });
                            updateUrlController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  Wrap(
                    children: updatedGroupUrls.map((url) {
                      return Chip(
                        label: Text(url),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            updatedGroupUrls.remove(url); // Remove the URL from the list
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog without saving
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    // Update the topic with the new note and group URLs
                    _updateTopic(index, updateNoteController.text, updatedGroupUrls);
                    Navigator.pop   (context); // Close the dialog after updating
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  }