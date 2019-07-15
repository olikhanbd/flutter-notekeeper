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

  var _formKey = GlobalKey<FormState>();
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
            body: Form(
              key: _formKey,
              child: Padding(
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

                    /////////////////////////TITLE TEXTFIELD////////////////////////
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: titleController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter a valid title";
                          }
                        },
                        style: textStyle,
                        decoration: InputDecoration(
                            labelText: "Title",
                            labelStyle: textStyle,
                            errorStyle:
                                TextStyle(color: Colors.red, fontSize: 15.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    /////////////////DESCRIPTION TEXTFIELD//////////////////////////
                    Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        controller: descController,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter a valid description";
                          }
                        },
                        style: textStyle,
                        decoration: InputDecoration(
                            labelText: "Description",
                            errorStyle:
                                TextStyle(color: Colors.red, fontSize: 15.0),
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),

                    //////////////////////BUTTONS///////////////////////////////////
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
                                      if (_formKey.currentState.validate())
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
                                      if (note != null)
                                        _delete();
                                      else
                                        _showAlert(
                                            "Error", "No note to delete");
                                    });
                                  }),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            )));
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
    exitScreen();

    String dateNow = DateFormat.yMMMd().format(DateTime.now());

    if (note == null) {
      String title = titleController.text;
      String description = descController.text;
      String date = dateNow;
      int priority = selectedPriorityInt;
      Note newNote = Note(title, date, priority, description);

      int result = await databaseHelper.insertNote(newNote);

      if (result != 0) {
        _showAlert("Success", "Successfully inserted");
      } else {
        _showAlert("Failure", "Insert failed");
      }
    } else {
      note.title = titleController.text;
      note.description = descController.text;
      note.date = dateNow;
      note.priority = selectedPriorityInt;

      int result = await databaseHelper.updateNote(note);

      if (result != 0) {
        _showAlert("Success", "Successfully updated");
      } else {
        _showAlert("Failure", "Update failed");
      }
    }
  }

  void _delete() async {
    exitScreen();

    if (note != null) {
      int result = await databaseHelper.deleteNote(note.id);

      if (result != 0) {
        _showAlert("Success", "Successfully deleted");
      } else {
        _showAlert("Failure", "Deletion failed");
      }
    }
  }

  void _showAlert(String title, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
