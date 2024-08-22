import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/screens/add_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<HomePage> {
  List items = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        enableFeedback: true,
        onPressed: () {
          goToAdd(context);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Center(
          child: Text(
            "To-Do App",
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: () => getData(),
          child: Visibility(

            visible: items.isNotEmpty,
            replacement: Center(child: Text("No To Do's Found.",style: GoogleFonts.roadRage(fontSize: 70,color: Colors.amber),)),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                var item = items[index] as Map;
                final id = item['_id'] as String;
          
                return Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: Text("Edit"),
                              onTap: () => goToEdit(item),
                            ),
                            PopupMenuItem(
                              child: Text("Delete"),
                              onTap: () => deleteById(id),
                            ),
                          ];
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.amber,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
    );
  }

  Future<void> goToAdd(BuildContext context) async {
    final route = MaterialPageRoute(
      builder: (context) => AddPage(),
    );
    await Navigator.push(
      context,
      route,
    );
    setState(() {
      isLoading = true;
    });
     getData();
  }

  Future<void> getData() async {
    final response = await http
        .get(Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10'));
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['items'] as List;
      setState(() {
        items = result;
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteById(String id) async {
    final response =
        await http.delete(Uri.parse("https://api.nstack.in/v1/todos/$id"));
    final newList = items.where((element) => element['_id'] != id).toList();
    if (response.statusCode == 200) {
      setState(() {
        getData();
        items = newList;
      });
    }
  }

  Future<void> goToEdit(Map item) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return AddPage(
          todo: item,
        );
      },
    ));
    setState(() {
      isLoading = true;
    });
     getData();
  }
}
