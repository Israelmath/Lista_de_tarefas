import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lista_tarefas/dao/dao_json.dart';


void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _newToDo = TextEditingController();
  final TaskDAO _dao = TaskDAO();
  List<Map<String, dynamic>> _toDoList = List();

  Map<String, dynamic> _lastRemoved = Map();
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _dao.readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de tarefas'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding:
                EdgeInsets.only(left: 17.0, top: 1.0, right: 7.0, bottom: 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _newToDo,
                    decoration: InputDecoration(
                      labelText: 'Nova tarefa',
                      labelStyle: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: RaisedButton(
                    child: Text('Adicionar'),
                    onPressed: () {
                      _addToDo(_newToDo);
                      _newToDo.text = '';
                      _dao.saveData(_toDoList);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _toDoList.length,
                itemBuilder: buildItems,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItems(BuildContext context, int index) {
    return Dismissible(
      key: Key(Random().nextInt(1000).toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _dao.saveData(_toDoList);
        });
        final snack = SnackBar(
          duration: Duration(seconds: 5),
          content: Text('A tarefa ${_lastRemoved['title']} for removida'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () {
              setState(() {
                _toDoList.insert(_lastRemovedPos, _lastRemoved);
                _dao.saveData(_toDoList);
              });
            },
          ),
        );
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
      },
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: CheckboxListTile(
        value: _toDoList[index]['ok'],
        title: Text(
          _toDoList[index]['title'],
          style: TextStyle(
            color: !_toDoList[index]['ok'] ? Colors.black : Colors.grey[500],
          ),
        ),
        secondary: CircleAvatar(
          foregroundColor:
              _toDoList[index]['ok'] ? Colors.blue : Colors.blue[300],
          child: Icon(
            _toDoList[index]['ok'] ? Icons.check : Icons.error,
            color: Colors.white,
          ),
        ),
        onChanged: (check) {
          setState(() {
            _toDoList[index]['ok'] = check;
            _refresh();
            _dao.saveData(_toDoList);
          });
        },
      ),
    );
  }

  Future<Null> _refresh() async {
//    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((map1, map2) {
        if (map1['ok'] && !map2['ok']) {
          return 1;
        } else if (map1['ok'] && map2['ok']) {
          return 0;
        } else
          return -1;
      });
    });
    return null;
  }

  void _addToDo(TextEditingController _new) {
    setState(() {
      Map<String, dynamic> _newMap = Map();
      _newMap['title'] = _new.text;
      _newMap['ok'] = false;
      _toDoList.add(_newMap);
    });
  }
}

