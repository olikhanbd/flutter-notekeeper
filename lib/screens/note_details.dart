import 'package:flutter/material.dart';
import 'package:flutter_notekeeper/models/note.dart';
import 'package:flutter_notekeeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  var appBarTitle;
  var note;

  NoteDetails(this.appBarTitle, this.note);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailsState(this.appBarTitle, this.note);
  }
}

class NoteDetailsState extends State<NoteDetails> {
  var _priorities = ["High", "Low"];
  var selectedPriority = "Low";
  var selectedPriorityInt = 2;
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  DatabaseHelper databaseHelper = DatabaseHelper();

  var appBarTitle;
  var note;

  NoteDetailsState(this.appBarTitle, this.note);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    if (note != null) {
      titleController.text = note.title;
      descController.text = note.description;
      getPriorityFromInt(note.priority);
    }

    return WillPopScope(
        onWillPop: () {
          exitScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                exitScreen();
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownItem,
                          child: Text(dropDownItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: selectedPriority,
                      onChanged: (itemSelected) {
                        setState(() {
                          selectedPriority = itemSelected;
                          updatePriorityAsInt(selectedPriority);
                        });
                      }),
                ),

                /////////////////////////TITLE TEXTFIELD////////////////////////////
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("editing title");
                    },
                    decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                /////////////////Description TEXTFIELD////////////////////////////
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("editing desc");
                    },
                    decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                //////////////////////BUTTONS///////////////////////////////////////
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Colors.white,
                              child: Text(
                                "Save",
                              ),
                              onPressed: () {
                                setState(() {
                                  _save();
                                });
                              }),
                        ),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                          child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Colors.white,
                              child: Text(
                                "Delete",
                              ),
                              onPressed: () {
                                setState(() {
                                  _delete();
                                });
                              }),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ));
  }

  void exitScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String priority) {
    switch (priority) {
      case "High":
        selectedPriorityInt = 1;
        break;
      case "Low":
        selectedPriorityInt = 2;
        break;
      default:
        selectedPriorityInt = 2;
    }
  }

  void getPriorityFromInt(int value) {
    switch (value) {
      case 1:
        selectedPriority = "High";
        break;
      case 2:
        selectedPriority = "Low";
        break;
      default:
        selectedPriority = "Low";
    }
  }

  void _save() async {
    String dateNow = DateFormat.yMMMd().format(DateTime.now());

    if (note == null) {
      String title = titleController.text;
      String description = titleController.text;
      String date = dateNow;
      int priority = selectedPriorityInt;
      Note newNote = Note(title, date, priority, description);

      int result = await databaseHelper.insertNote(newNote);

      if (result != 0) {
        _showAlert(context, "Successfully inserted");
        exitScreen();
      } else {
        _showAlert(context, "Insert failed");
      }
    } else {
      note.title = titleController.text;
      note.description = titleController.text;
      note.date = dateNow;
      note.priority = selectedPriorityInt;

      int result = await databaseHelper.updateNote(note);

      if (result != 0) {
        _showAlert(context, "Successfully updated");
        exitScreen();
      } else {
        _showAlert(context, "Update failed");
      }
    }
  }

  void _delete() async {
    if (note != null) {
      int result = await databaseHelper.deleteNote(note.id);

      if (result != 0) {
        _showAlert(context, "Successfully deleted");
        exitScreen();
      } else {
        _showAlert(context, "Deletion failed");
      }
    }
  }

  void _showAlert(BuildContext context, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text("Note"),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
