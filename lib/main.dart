import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'generator.dart';

import 'package:backdrop/backdrop.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passphrase generator',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
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
    // Just rerender
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      title: Text(widget.title),
      backLayer: buildBackdrop(),
      iconPosition: BackdropIconPosition.action,
      frontLayer: Container(
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

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildBackdrop() {
    return Container(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: ListView(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,//
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context, "About"),
                  Text(
                    "A simple passphrase generator inspired by the XKCD comic strip and built using Flutter.",
                    style: Theme.of(context).textTheme.body1,
                  ),
                  _buildHeader(context, "Dictionaries"),
                  Text(
                    "Small dictionary contains ~7000 common English words. This dictionary is used by Keepass. Large dictionary contains over over 60,000 words, but they're hard to remember.",
                    style: Theme.of(context).textTheme.body1,
                  ),
                  _buildHeader(context, "Security"),
                  Text(
                    "Generator uses secure number generator provided by the Android system. The app itself also doesn't have permission to use the Internet so all the generated passphrases remain on your device.",
                    style: Theme.of(context).textTheme.body1,
                  ),
                  _buildHeader(context, "Copying passphrases"),
                  Text(
                    "Tap on the passphrase to copy it to the clipboard. Note that the system clipboard is available for all applications on the device, so it is recommended to write your new passphrase on a piece of paper.",
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              )),
          ListTile(
            title: Text("View source code"),
            subtitle: Text("Avaliable on Github under WTFPL licence"),
            onTap: () =>
                _launchURL("https://github.com/holykol/passphrase-generator"),
          ),
          ListTile(
            title: Text("Feedback"),
            subtitle: Text("Suggest new feature or report a bug"),
            onTap: () => _launchURL(
                "https://github.com/holykol/passphrase-generator/issues/new"),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 12.0),
      child: Text(text, style: Theme.of(context).textTheme.subtitle),
    );
  }
}
