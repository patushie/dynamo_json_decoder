import 'package:dynamo_json_decoder/dynamo/project/commons/system/handlers/app_logger.dart';
import 'package:dynamo_json_decoder/dynamo/project/commons/system/handlers/dynamo_decoder.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static AppLogger logger = AppLogger.getInstance();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    logger.log('+++++++++++++++++++++++++++++++++ [0] point-blank...');
    String userAccountJson = '{"userAccountID":27,"userName":"john.doe","userNameFQN":"john.doe@company.com","password":"password1"}';

    Map<String, dynamic>? jsonObject = DynamoDecoder.decode(userAccountJson, debugMode: false, reviver: (k, v) {
      logger.log('+++++++++++++++++++++++++++++ k, v ==>> $k, $v');
      return v;
    });

    logger.log('+++++++++++++++++++++++++++++++ [1] jsonObject ==>> $jsonObject');

    return MaterialApp(
      title: 'Dynamo Decoder Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Container(),
    );
  }
}
