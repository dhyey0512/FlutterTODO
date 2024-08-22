import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:todo/screens/home.dart';

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({super.key, this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
  @override
  void initState(todo) {}
}

class _AddPageState extends State<AddPage> {
  bool isEdit = false;

  @override
  void initState() {
    final todo = widget.todo;
    super.initState();
    if (todo != null) {
      isEdit = true;
      task.text = todo['title'];
      desc.text = todo['description'];
    }
  }

  TextEditingController task = TextEditingController();
  TextEditingController desc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Add To-Do",
          style: GoogleFonts.roboto(),
        )),
      ),
      body: ListView(
        padding: EdgeInsets.only(right: 20, left: 20, top: 12),
        children: [
          TextField(
            controller: task,
            decoration: InputDecoration(hintText: "Task"),
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
            controller: desc,
            decoration: InputDecoration(hintText: "Description"),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 5,
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              if (!isEdit) {
                submitData();
              } else {
                submitUpdate();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(!isEdit ? "Submit" : "Update"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitData() async {
    final tsk = task.text;
    final des = desc.text;
    var body = {'title': tsk, 'description': des, 'is_completed': false};
    final response = await http.post(
        Uri.parse("https://api.nstack.in/v1/todos"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 201) {
      task.text = "";
      desc.text = "";
      showMsg("Success");
    } else {
      showMsg("Failed");
    }
    
  }

  void showMsg(String input) {
    final Snackbar = SnackBar(
      content: Text(
        input,
      ),
      backgroundColor: Colors.blue,
    );
    ScaffoldMessenger.of(context).showSnackBar(Snackbar);
  }

  Future<void> submitUpdate() async {
    final text0 = task.text;
    final desc0 = desc.text;
    final todo1 = widget.todo;

    if (todo1 == null) {
      showMsg("Can't be Empty");
      return;
    }

    final id = todo1['_id'];

    final body = {"title": text0, "description": desc0, "is_completed": false};

    final response = await http.put(
        Uri.parse("https://api.nstack.in/v1/todos/$id"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      showMsg("Update Successful");
    }
  }
}
