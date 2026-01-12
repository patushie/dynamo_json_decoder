import 'dart:math';

import 'package:dynamo_json_decoder/dynamo/project/commons/system/entities/log_level.dart';

import 'app_logger.dart';
import 'dynamo_commons.dart';
import 'token_expected_exception.dart';

/// The main class for performing the JSON object decoding
class DynamoDecoder {
  static int index = 0;
  static String look = "";
  static String inputString = "";
  //
  static AppLogger logger = AppLogger.getInstance();

  /// the decoder entrypoint: this method handles the decoding
  static dynamic decode(String inputExprString,
      {Object? Function(Object?, Object?)? reviver, bool debugMode = false}) {
    inputString = inputExprString;

    inputString = inputString.replaceAll("\\\"", "\\u00E6");
    inputString = inputString.replaceAll("\\u003d", "=");

    index = 0;
    look = "";

    dynamic jsonObject = parseJSONStructure(0, debugMode, reviver: reviver);

    return jsonObject;
  }

  /// The parser method: uses lexical and syntactical analysis
  /// to traverse the string and construct the JSON object graph.
  static dynamic parseJSONStructure(int depth, bool debugMode,
      {Object? Function(Object?, Object?)? reviver}) {
    depth++;

    dynamic jsonObject;

    skipSpace();

    if (index == 0) {
      read();
    }

    if (debugMode) {
      logger.log(
        '+++++++++++++++++++++++++++++ [0] index, look ==>> '
        '$index, $look, ${showConttext(depth)}',
        logLevel: LogLevel.debug,
      );
    }

    if (look == "{") {
      jsonObject = Map<String, dynamic>();

      while (look != "}") {
        if (debugMode) {
          logger.log(
            '+++++++++++++++++++++++++++++ [0] index, look ==>> $index, $look, ${showConttext(depth)}',
            logLevel: LogLevel.debug,
          );
        }

        read();

        if (debugMode) {
          logger.log(
            '+++++++++++++++++-++++++++++++ [0.1] index, look ==>> $index, $look, ${showConttext(depth)}',
            logLevel: LogLevel.debug,
          );
        }

        skipSpace();

        if (look != '}') {
          if (look != '"') {
            read(indexPos: index++);
          }

          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ [0.2] index, look ==>> $index, $look, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }

          match('"');
          read();

          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ [1] index, look ==>> $index, $look, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }

          String expressionKey = getExpressionKey();

          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ [2] expressionKey, index, look ==>> $expressionKey, $index, $look, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }

          match('"');
          read();

          index = DynamoCommons.skipSpace(inputString, index);
          read(indexPos: index++);

          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ [3] index, look ==>> $index, $look, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }

          match(':');
          read();
          skipSpace();

          bool isStringValue = false;

          if (!DynamoCommons.isDigit(look) &&
              look != "-" &&
              look != "{" &&
              look != "[") {
            if (look == '"') {
              isStringValue = true;
            }

            if (!DynamoCommons.isAlpha(look)) {
              read(indexPos: index);
            }
          }

          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ [4] index, look, inputString[index] ==>> $index, $look, ${inputString[index]}, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }

          if ((DynamoCommons.isDigit(look) || look == "-") &&
              (!isStringValue)) {
            String expressionValue = getExpressionValue(true);

            if (DynamoCommons.isDigitSequence(expressionValue)) {
              jsonObject.putIfAbsent(
                  expressionKey, () => int.parse(expressionValue));
            } else if (DynamoCommons.isDigitSequenceWithADot(expressionValue)) {
              jsonObject.putIfAbsent(
                  expressionKey, () => double.parse(expressionValue));
            }

            if ((look == ']') || (look == '}')) {
              index++;
            }

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            if (reviver != null) {
              reviver(expressionKey, expressionValue);
            }

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [6] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }
          } else if ((DynamoCommons.isAlpha(look)) && (!isStringValue)) {
            String expressionValue = getNonStrExpressionValue();
            jsonObject.putIfAbsent(expressionKey, () => expressionValue);

            skipSpace();

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5a.1] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            if (reviver != null) {
              reviver(expressionKey, expressionValue);
            }
          } else if ((look != '{') && (look != '[')) {
            String expressionValue = getExpressionValue(false);
            jsonObject.putIfAbsent(expressionKey, () => expressionValue);

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5b.1] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            match('"');
            read();

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5b.2] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            if (look == '"') {
              read();
            }

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5b.3] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            skipSpace();

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5b.4] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            if (reviver != null) {
              reviver(expressionKey, expressionValue);
            }
          } else if ((look == '{') || (look == '[')) {
            dynamic expressionValue =
                parseJSONStructure(depth, debugMode, reviver: reviver);

            jsonObject.putIfAbsent(expressionKey, () => expressionValue);

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5c.1] expressionKey, index, look ==>> $expressionKey, $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            read();
            skipSpace();

            if ((look == '}') &&
                (depth == 1) &&
                (index < inputString.length - 1)) {
              read();
              skipSpace();
            }

            if (debugMode) {
              logger.log(
                '++++++++++++++++-+++++++++++++ [5c.2] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            if (reviver != null) {
              reviver(expressionKey, expressionValue);
            }
          }
        }
      }
    } else if (look == "[") {
      jsonObject = <dynamic>[];

      if (debugMode) {
        logger.log(
          '+++++++++++++++++++++++++++++ <T>[00] index, look ==>> $index, $look, ${showConttext(depth)}',
          logLevel: LogLevel.debug,
        );
      }

      while (look != "]") {
        read();
        skipSpace();
        if (debugMode) {
          logger.log(
            '+++++++++++++++++++++++++++++ <T>[001] index, look ==>> $index, $look, ${showConttext(depth)}',
            logLevel: LogLevel.debug,
          );
        }

        if (look == "]") {
          skipSpace();
          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ <T>[002] index, look ==>> $index, $look, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }
        } else if (look == "{") {
          Map<String, dynamic> childJsonObject = {};

          while (look != "}") {
            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ <T>[0] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            read();

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ <T>[0.1] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            skipSpace();
            if (look != "}") {
              while (look != '"') {
                read(indexPos: index++);
              }

              if (debugMode) {
                logger.log(
                  '+++++++++++++++++++++++++++++ <T>[0.2] index, look ==>> $index, $look, ${showConttext(depth)}',
                  logLevel: LogLevel.debug,
                );
              }

              match('"');
              read();

              if (debugMode) {
                logger.log(
                  '+++++++++++++++++++++++++++++ <T>[1] index, look, context ==>> $index, $look, ${showConttext(depth)}',
                  logLevel: LogLevel.debug,
                );
              }

              String expressionKey = getExpressionKey();

              if (debugMode) {
                logger.log(
                  '+++++++++++++++++++++++++++++ <T>[2] expressionKey, index, look ==>> $expressionKey, $index, $look, ${showConttext(depth)}',
                  logLevel: LogLevel.debug,
                );
              }

              match('"');
              read();
              //skipSpace();
              index = DynamoCommons.skipSpace(inputString, index);
              read(indexPos: index++);

              if (debugMode) {
                logger.log(
                  '+++++++++++++++++++++++++++++ <T>[3] index, look ==>> $index, $look, ${showConttext(depth)}',
                  logLevel: LogLevel.debug,
                );
              }

              match(':');
              read();
              skipSpace();

              bool isStringValue = false;

              if (!DynamoCommons.isDigit(look) &&
                  look != "-" &&
                  look != "{" &&
                  look != "[") {
                if (look == '"') {
                  isStringValue = true;
                  read(indexPos: index);
                }
              }

              if (debugMode) {
                logger.log(
                  '+++++++++++++++++++++++++++++ <T>[4] index, look, inputString[index] ==>> $index, $look, ${inputString[index]}, ${showConttext(depth)}',
                  logLevel: LogLevel.debug,
                );
              }

              if ((DynamoCommons.isDigit(look) || look == "-") &&
                  (!isStringValue)) {
                String expressionValue = getExpressionValue(true);

                if (DynamoCommons.isDigitSequence(expressionValue)) {
                  childJsonObject.putIfAbsent(
                      expressionKey, () => int.parse(expressionValue));
                } else if (DynamoCommons.isDigitSequenceWithADot(
                    expressionValue)) {
                  childJsonObject.putIfAbsent(
                      expressionKey, () => double.parse(expressionValue));
                }

                if ((look == ']') || (look == '}')) {
                  index++;
                }

                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[5] index, look ==>> $index, $look, ${showConttext(depth)}',
                    logLevel: LogLevel.debug,
                  );
                }

                if (reviver != null) {
                  reviver(expressionKey, expressionValue);
                }
              } else if ((DynamoCommons.isAlpha(look)) && (!isStringValue)) {
                String expressionValue = getNonStrExpressionValue();

                childJsonObject.putIfAbsent(
                    expressionKey, () => expressionValue);

                skipSpace();

                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ [5a.2] index, look ==>> $index, $look, ${showConttext(depth)}',
                    logLevel: LogLevel.debug,
                  );
                }

                if (reviver != null) {
                  reviver(expressionKey, expressionValue);
                }
              } else if ((look != '{') && (look != '[')) {
                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[4b] index, look, expressionKey ==>> $index, $look, $expressionKey',
                    logLevel: LogLevel.debug,
                  );
                }
                String expressionValue = getExpressionValue(false);

                childJsonObject.putIfAbsent(
                    expressionKey, () => expressionValue);

                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[5b] index, look, expressionValue ==>> $index, $look, $expressionValue',
                    logLevel: LogLevel.debug,
                  );
                }

                match('"');

                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[6b] index, look, expressionValue ==>> $index, $look, $expressionValue',
                    logLevel: LogLevel.debug,
                  );
                }

                read();

                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[6c] index, look, expressionValue ==>> $index, $look, $expressionValue',
                    logLevel: LogLevel.debug,
                  );
                }

                skipSpace();
                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[6d] index, look, expressionValue ==>> $index, $look, $expressionValue',
                    logLevel: LogLevel.debug,
                  );
                }

                if (look == '"') {
                  read();
                  skipSpace();
                }

                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[7a] index, look, expressionValue ==>> $index, $look, $expressionValue',
                    logLevel: LogLevel.debug,
                  );
                }

                if (reviver != null) {
                  reviver(expressionKey, expressionValue);
                }
              } else if ((look == '{') || (look == '[')) {
                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[7b.0] index, look, expressionKey ==>> $index, $look, $expressionKey, ${showConttext(depth)}',
                    logLevel: LogLevel.debug,
                  );
                }

                dynamic expressionValue =
                    parseJSONStructure(depth, debugMode, reviver: reviver);

                childJsonObject.putIfAbsent(
                    expressionKey, () => expressionValue);

                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[7b.1] index, look ==>> $index, $look, ${showConttext(depth)}',
                    logLevel: LogLevel.debug,
                  );
                }

                read();
                skipSpace();
                if (debugMode) {
                  logger.log(
                    '+++++++++++++++++++++++++++++ <T>[7b.2] index, look ==>> $index, $look, ${showConttext(depth)}',
                    logLevel: LogLevel.debug,
                  );
                }

                if (reviver != null) {
                  reviver(expressionKey, expressionValue);
                }
              }
            }
          }

          jsonObject.add(childJsonObject);

          read();
          skipSpace();
          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ <T>[6] index, look ==>> $index, $look, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }
          if (look == '}') {
            read();
            skipSpace();
            //index = DynamoCommons.skipSpace(inputString, index);
            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ <T>[7] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }
          }
        } else if (look == '[') {
          dynamic expressionValue =
              parseJSONStructure(depth, debugMode, reviver: reviver);

          jsonObject.add(expressionValue);

          read();
          skipSpace();

          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ <TT>[5c.2] index, look ==>> $index, $look, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }
        } else {
          bool isStringValue = false;

          if (!DynamoCommons.isDigit(look) &&
              look != "-" &&
              look != "{" &&
              look != "[") {
            if (look == '"') {
              isStringValue = true;
              read(indexPos: index);
            }

            if (DynamoCommons.isDigit(look) || look == "-") {
              if (index < inputString.length - 1) {
                index++;
              }
            }
          }

          if (debugMode) {
            logger.log(
              '+++++++++++++++++++++++++++++ <S>[4] index, look, inputString[index] ==>> $index, $look, ${inputString[index]}, ${showConttext(depth)}',
              logLevel: LogLevel.debug,
            );
          }

          if ((DynamoCommons.isDigit(look) || look == "-") &&
              (!isStringValue)) {
            String expressionValue = getExpressionValue(true);

            if (DynamoCommons.isDigitSequence(expressionValue)) {
              jsonObject.add(int.parse(expressionValue));
            } else if (DynamoCommons.isDigitSequenceWithADot(expressionValue)) {
              jsonObject.add(double.parse(expressionValue));
            }

            if ((look == ']') || (look == '}')) {
              index++;
            }

            skipSpace();

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ <S>[5] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }
          } else if ((DynamoCommons.isAlpha(look)) && (!isStringValue)) {
            String expressionValue = getNonStrExpressionValue();
            jsonObject.add(expressionValue);

            skipSpace();

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ [5a.1] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }
          } else if (isStringValue) {
            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ <S>[1] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            String expressionValue = getExpressionValue(false);

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ <S>[2] index, look, expressionValue ==>> $index, $look, $expressionValue, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }

            read();
            skipSpace();

            jsonObject.add(expressionValue);

            if (debugMode) {
              logger.log(
                '+++++++++++++++++++++++++++++ <S>[3] index, look ==>> $index, $look, ${showConttext(depth)}',
                logLevel: LogLevel.debug,
              );
            }
          }
        }
      }
    }

    return jsonObject;
  }

  static void skipSpace() {
    if ((index <= inputString.length - 1) &&
        (index > 0) &&
        (DynamoCommons.isSpace(inputString[index - 1]))) {
      index = DynamoCommons.skipSpace(inputString, index);
      read();
    }
  }

  static String showConttext(int depth) {
    String contextText = "";

    if (index + 100 <= inputString.length - 1) {
      contextText = inputString.substring(index, index + 100);
    } else {
      contextText = inputString.substring(index);
    }

    return '<<$depth> <$contextText>>';
  }

  static String getExpressionKey() {
    String exprValue = "";

    exprValue = look;

    while ((index <= inputString.length - 1) && (inputString[index] != '"')) {
      exprValue += inputString[index++];
    }

    read(indexPos: index);

    return exprValue;
  }

  static String getNonStrExpressionValue() {
    String exprValue = "";

    if (DynamoCommons.isAlpha(look)) {
      exprValue = look;

      while ((index <= inputString.length - 1) &&
          (DynamoCommons.isAlphaNum(inputString[index])) &&
          (inputString[index] != ',')) {
        exprValue += inputString[index++];
      }
    }

    read(indexPos: index);

    return exprValue;
  }

  static String getExpressionValue(bool isNumber) {
    String exprValue = "";
    String exponentValue = "";
    bool foundExponent = false;

    if (!isNumber) {
      if (inputString[index] != '"') {
        exprValue = look;
        index++;
      }

      int contentLength = inputString.indexOf('"', index);
      exprValue += inputString.substring(index, contentLength);
      index = contentLength;

      exprValue = DynamoCommons.decodeUnicodeCharacters(exprValue);
    } else {
      if (DynamoCommons.isDigit(look) || look == "-") {
        exprValue = look;

        while ((index <= inputString.length - 1) &&
            (DynamoCommons.isDigit(inputString[index]) ||
                inputString[index] == '.' ||
                inputString[index] == 'E')) {
          if (inputString[index] == 'E') {
            foundExponent = true;
            index++;
          }

          if (foundExponent) {
            exponentValue += inputString[index++];
          } else {
            exprValue += inputString[index++];
          }
        }
      }

      if ((foundExponent) && (DynamoCommons.isDigitSequence(exponentValue))) {
        exprValue =
            (double.parse(exprValue) * pow(10, double.parse(exponentValue)))
                .toString();
      }
    }

    read(indexPos: index);

    return exprValue;
  }

  static void match(String cc) {
    if (cc != look) {
      expected(cc);
    }
  }

  static void read({int indexPos = -1}) {
    if (indexPos > 0) {
      if (indexPos <= inputString.length - 1) {
        look = inputString[indexPos];
      }
    } else if (index <= inputString.length - 1) {
      look = inputString[index++];
    }
  }

  static void expected(String token) {
    if (index > 0) {
      int indexPos = index;
      int contextUpperPos = 256;

      if (inputString.substring(index).length < contextUpperPos) {
        contextUpperPos = inputString.substring(index).length;
      }

      index = inputString.length + 1;

      throw TokenExpectedException(
          "'$token' Expected Near: ${inputString.substring(indexPos, indexPos + contextUpperPos)}... <<index, look ==>> $indexPos, $look>>");
    }
  }
}
