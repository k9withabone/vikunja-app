import 'dart:ffi';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vikunja_app/global.dart';
import 'package:vikunja_app/models/list.dart';
import 'package:vikunja_app/theme/button.dart';
import 'package:vikunja_app/theme/buttonText.dart';

class ListEditPage extends StatefulWidget {
  final TaskList list;

  ListEditPage({required this.list}) : super(key: Key(list.toString()));

  @override
  State<StatefulWidget> createState() => _ListEditPageState();
}

class _ListEditPageState extends State<ListEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _title = '', _description = '';
  bool? displayDoneTasks;
  late int listId;

  @override
  void initState(){
    listId = widget.list.id;
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    if(displayDoneTasks == null)
      VikunjaGlobal.of(context).listService.getDisplayDoneTasks(listId).then(
              (value) => setState(() => displayDoneTasks = value == "1"));
    else
      log("Display done tasks: " + displayDoneTasks.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit List'),
      ),
      body: Builder(
        builder: (BuildContext context) => SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      initialValue: widget.list.title,
                      onSaved: (title) => _title = title ?? '',
                      validator: (title) {
                        //if (title?.length < 3 || title.length > 250) {
                        //  return 'The title needs to have between 3 and 250 characters.';
                        //}
                        return null;
                      },
                      decoration: new InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      initialValue: widget.list.description,
                      onSaved: (description) => _description = description ?? '',
                      validator: (description) {
                        if(description == null)
                          return null;
                        if (description.length > 1000) {
                          return 'The description can have a maximum of 1000 characters.';
                        }
                        return null;
                      },
                      decoration: new InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: CheckboxListTile(
                      value: displayDoneTasks ?? false,
                      title: Text("Show done tasks"),
                      onChanged: (value) {
                        value ??= false;
                        VikunjaGlobal.of(context).listService.setDisplayDoneTasks(listId, value ? "1" : "0");
                        setState(() => displayDoneTasks = value);
                      },
                    ),
                  ),
                  Builder(
                      builder: (context) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: FancyButton(
                            onPressed: !_loading
                                ? () {
                                    if (_formKey.currentState!.validate()) {
                                      Form.of(context)?.save();
                                      _saveList(context);
                                    }
                                  }
                                : () {},
                            child: _loading
                                ? CircularProgressIndicator()
                                : VikunjaButtonText('Save'),
                          ))),
                ]),
          ),
        ),
      ),
    );
  }

  _saveList(BuildContext context) async {
    setState(() => _loading = true);
    // FIXME: is there a way we can update the list without creating a new list object?
    //  aka updating the existing list we got from context (setters?)
    widget.list.title = _title;
    widget.list.description = _description;
    VikunjaGlobal.of(context).listService.update(widget.list).then((_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('The list was updated successfully!'),
      ));
    }).catchError((err) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: ' + err.toString()),
          action: SnackBarAction(
              label: 'CLOSE',
              onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar),
        ),
      );
    });
  }
}
