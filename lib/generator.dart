import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

Future<String> generatePassphrase({wordsCount = 4, separator = " ", dictionaryPath = "../assets/small.txt" }) async {

  var rand = Random.secure();
  var dictText = await rootBundle.loadString(dictionaryPath);
  var dict = dictText.split("\n").toList();

  var len = dict.length;

  List<String> result;

  for (var i = 0; i < wordsCount  ; i++) {
    var word = dict[rand.nextInt(len)].toLowerCase();
    result.add(word);
  }

  return result.join(separator);
}
