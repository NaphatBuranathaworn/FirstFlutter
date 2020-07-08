import 'package:FirstFlutter/app.dart';
import 'package:FirstFlutter/page2.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void main() => runApp(MyApp());

final logger = Logger();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        theme: ThemeData(
          primaryColor: Colors.pink[0],
        ),
        home: RandomWords());
  }
}

class RandomWords extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RandomWordsState();
  }
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Startup Name Generator'), actions: [
        IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        IconButton(icon: Icon(Icons.add_to_photos), onPressed: _routeToPage2),
        IconButton(icon: Icon(Icons.apps), onPressed: _routeToApps),
      ]),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
        title: Text(pair.asPascalCase, style: _biggerFont),
        trailing: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () {
          logger.d('onTap : ' + alreadySaved.toString());
          setState(() {
            if (alreadySaved) {
              _saved.remove(pair);
            } else {
              _saved.add(pair);
            }
          });
        });
  }

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        final tiles = _saved.map((WordPair pair) {
          return ListTile(
              title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ));
        });
        final divided = ListTile.divideTiles(
          context: context,
          tiles: tiles,
        ).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('Save Suggestions'),
          ),
          body: ListView(children: divided),
        );
      },
    ));
  }

  void _routeToApps() {
    logger.d('route ja');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => App()));
    Navigator.of(context).push(_createRoute(App()));
  }

  void _routeToPage2() {
    Navigator.of(context).push(_createRoute(Page2()));
  }

  Route _createRoute(StatelessWidget target) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => target,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
    // return MaterialPageRoute(builder: (context) => target);
  }
}
