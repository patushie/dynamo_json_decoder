# dynamo_json_decoder

A lightweight, high-performance utility for decoding serialized JSON text into Dart objects (`Map` or `List`). Designed for speed and ease of use in Flutter applications.

[![pub package](https://img.shields.io/pub/v/dynamo_json_decoder.svg)](https://pub.dev/packages/dynamo_json_decoder)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 🌟 Features

* **Type-Safe Decoding:** Easily convert raw JSON strings into `Map<String, dynamic>` or `List<dynamic>`.
* **Debug Logging:** Integrated support for error tracking during the decoding process.
* **Zero Boilerplate:** Static methods allow you to decode without instantiating complex classes.

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  dynamo_json_decoder: ^1.0.0
```
Or run:

```flutter pub add dynamo_json_decoder```

## 🚀 Usage

Import the library

```import 'package:dynamo_json_decoder/dynamo_json_decoder.dart';```

Simple Decoding Example

```
void fetchUser() async {
  String rawJson = '{"id": 1, "name": "John Doe"}';
  
  // Decode into a Map
  Map<String, dynamic> user = DynamoDecoder.decode(rawJson);
  
  print(user['name']); // Output: John Doe
}
```

Integration with HTTP

```
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getRemoteData() async {
  final response = await http.get(Uri.parse("[https://api.example.com/data](https://api.example.com/data)"));
  
  if (response.statusCode == 200) {
    // Automatically handles Maps
    return DynamoDecoder.decode(response.body);
  }
}


Future<List<dynamic>> getRemoteListData() async {
  final response = await http.get(
     Uri.parse("[https://api.example.com/data](https://api.example.com/data)"));
  
  if (response.statusCode == 200) {
    // Automatically handles Lists
    return DynamoDecoder.decode(response.body);
  }
}
```

## 🛠️ Debug Mode

You can pass a reviver function or enable debug logging to inspect the decoding process:

```
   Map<String, dynamic>? jsonObject = DynamoDecoder
      .decode(rawJson, debugMode: true, reviver: (k, v) {
      print('+++++++++++++++++++++++++++++ k, v ==>> ${k}, ${v}');
    });
```

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/patushie/dynamo_json_decoder/issues).