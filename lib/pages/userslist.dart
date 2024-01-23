import 'dart:convert';

import 'package:participants/models/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

SnackBar _snackBar(String message) => SnackBar(
      content: Text(message),
    );

class UserScreen extends StatelessWidget {
  final Users users;
  const UserScreen({required this.users, super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
        ),
        body: usersname(users: users),
      );
}

late TextEditingController _titleInputController;
late TextEditingController _bodyInputController;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class usersname extends StatefulWidget {
  final Users users;
  const usersname({required this.users, super.key});

  @override
  State<usersname> createState() => _UserNameState();
}

class _UserNameState extends State<usersname> {
  Future<Users>? futureUsers;

  @override
  void initState() {
    super.initState();
    _titleInputController = TextEditingController();
    _bodyInputController = TextEditingController();
    futureUsers = fetchPost();
  }

  @override
  void dispose() {
    _titleInputController.dispose();
    super.dispose();
  }

  Future<Users> fetchPost() async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/users/${widget.users.id}'));

    if (response.statusCode == 200) {
      return Users.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<Users> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load users');
    }
  }

  // UpdatePost
  // make a http request to server
  // pass the title and body ke dalam body section of http request.
  // check the status code == 200
  // return Post();
  // else
  // Throw error.

  // http.post() <- create new data.
  Future<Users> updatePost(int id) async {
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/users/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _titleInputController.text,
        'name': _bodyInputController.text,
      }),
    );

    if (response.statusCode == 200) {
      return Users.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update post');
    }
  }

  // Update Post
  // http.put() <-- Update a resource.
  // http
  // - Header
  // - 'Content-Type': 'application/json; charset=UTF-8',
  // - Body
  // - title
  // - body
  // - url = 'https://jsonplaceholder.typicode.com/posts/$id

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: FutureBuilder<Users>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _titleInputController.value =
                TextEditingValue(text: snapshot.data?.username ?? '');
            _bodyInputController.value =
                TextEditingValue(text: snapshot.data?.name ?? '');
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _titleInputController,
                          decoration: const InputDecoration(
                            hintText: 'List Users',
                            label: Text('Participants'),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _bodyInputController,
                          decoration: const InputDecoration(
                            hintText: 'Username Here',
                            label: Text('Participants'),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate will return true if the form is valid, or false if
                              // the form is invalid.
                              if (_formKey.currentState!.validate()) {
                                // Process data.
                                // UpdatePost
                                // Display update message in snackbar
                                setState(() {
                                  futureUsers = updatePost(snapshot.data!.id);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(_snackBar('updated'));
                                });
                              }
                            },
                            child: const Text('Update'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              futureUsers = deletePost(snapshot.data!.id);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(_snackBar('Deleted'));
                            });
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(
              child: SizedBox(child: CircularProgressIndicator()));
        },
      )),
    ]);
  }
}
