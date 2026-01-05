# dynamo_json_decoder

A lightweight, high-performance Flutter project for decoding serialized JSON text into Flutter 
objects - particularly Map<String, dynamic> and List<dynamic>.

## 🌟 Features

* **Decode A Serialized JSON String:** Take a raw JSON string and convert it into a Map<String, dynamic> 
* or List<dynamic> depending on the object structure.
* **Run In Debug Mode:** Switch to debug mode to receive and print error logs from the API.

## 🛠️ Tech Stack
* **Dependencies:** [Dart](https://dart.dev/) (v3.x), [Flutter](https://flutter.dev) (v3.x)

### Prerequisites
* Flutter SDK Installed

## Installation
* **Run this command:**
* flutter pub add dynamo_json_decoder
* 
* **Or add  the following line under the dependencies section of your project's pubspec.yml file:**
* dependencies:
* dynamo_json_decoder: ^1.0.0

## Import It
* Now in your Flutter code, you can use:
* import 'package:dynamo/projects/commons/system/handlers/DynamoDecoder.dart';

## Getting Started
* static AppLogger logger = AppLogger.getInstance();
* 
* String serviceURL = "your.service.url"; //example: http://localhost:8080/api/calculateQuote
* var response = await http.get(Uri.parse(serviceURL));
* 
* if (response.statusCode == 200) {
*   return DynamoDecoder.decode(response.body);
* }
* 

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
