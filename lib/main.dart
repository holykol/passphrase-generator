import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'generator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Passphrase generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double _wordCount = 4.0;
  String _selectedDictionary = "small";

  void _handleDictionaryChange(String value) {
    setState(() {
      _selectedDictionary = value;
    });
  }

  void _handleWordCountChange(double value) {
    setState(() {
      _wordCount = value;
    });
  }

  void _generatePassphrase() async {
    // Just refresh the state
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: this._formKey,
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Dictionary"),
                  Radio(
                    value: "small",
                    groupValue: _selectedDictionary,
                    onChanged: _handleDictionaryChange,
                  ),
                  Text("Tiny"),
                  Radio(
                    value: "large",
                    groupValue: _selectedDictionary,
                    onChanged: _handleDictionaryChange,
                  ),
                  Text("Large"),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Words count"),
                  Expanded(
                    child: Slider(
                      value: _wordCount,
                      divisions: 10,
                      min: 2.0,
                      label: _wordCount.floor().toString() + " words",
                      max: 12.0,
                      onChanged: _handleWordCountChange,
                    ),
                  ),
                ],
              ),
              RaisedButton(
                onPressed: () => _generatePassphrase(),
                child: Text("Regenerate"),
              ),
              Container(
                color: Color(0xffeeeeee),
                padding: EdgeInsets.all(20.0),
                child: FutureBuilder(
                  future: generatePassphrase(
                    wordsCount: this._wordCount.floor(),
                    dictionaryPath:
                        "assets/dictionaries/${this._selectedDictionary}.txt",
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text('None');
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                        return Text('');
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text(
                            '${snapshot.error}',
                            style: TextStyle(color: Colors.red),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: snapshot.data),
                              );
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Copied to Clipboard"),
                                ),
                              );
                            },
                            child: Text(
                              snapshot.data,
                              style: TextStyle(fontFamily: "monospace"),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
