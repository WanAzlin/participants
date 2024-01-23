import 'package:participants/models/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:participants/pages/userslist.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List of Users')),
      body: const HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  Future<List<Users>>? futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchPost();
  }

  Future<List<Users>> fetchPost() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    // status code, 200,404,500
    if (response.statusCode == 200) {
      List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Users.fromJson(e)).toList();
    } else {
      throw Exception('failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureUsers,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                // Return ListTile();
                // snapshot.data[index].title
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserScreen(users: snapshot.data![index])));
                  },
                  title: Text(snapshot.data![index].username),
                  subtitle: Text(
                    snapshot.data![index].name,
                    maxLines: 2,
                  ),
                  leading: Text(snapshot.data![index].id
                      .toString()), //convert int to string
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
