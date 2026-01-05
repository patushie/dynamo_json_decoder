import 'dart:io';
import 'dart:typed_data';

import 'package:dynamo_json_decoder/dynamo/project/commons/system/entities/LogLevel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//
import 'dart:ui' as ui;

import 'package:dynamo_json_decoder/dynamo/project/commons/constants/PadDirectionType.dart';

import 'AppLogger.dart';

class DynamoCommons {

  static Map<String, String> specialCharUnicodeMap = {
    "\\u003c": "<",
    "\\u003e": ">",
    "\\u0027": "'",
    "\\u0025": "%",
    "\\u0023": "#",
    "\\u0022": "\"",
    "\\u00E6": "\\\"",
    "\\u0021": "!",
    "\\u0026": "&",
    "\\u0028": "(",
    "\\u0029": ")",
    "\\u002A": "*",
    "\\u002B": "+",
    "\\u002D": "-",
    "\\u0040": "@",
    "\\u003F": "?",
    "\\u003A": ":",
    "\\u003B": ";",
    "\\u003D": "=",
    "\\u003d": "=",
    "\\u005F": "_",
    "\\u007B": "{",
    "\\u007C": "|",
    "\\u007D": "}",
    "\\u007E": "~",
    "\\u002F": "/",
    "\\u005C": "\\",
    "\\u005B": "[",
    "\\u005D": "]",
    "\\u005E": "^",
  };

  static String encodeSpecialCharacters(String inputString) {
    String encodedString = inputString;

    DynamoCommons.specialCharUnicodeMap.forEach((key, value) {
      if (value != "-") {
        encodedString = encodedString.replaceAll(value, key);
      }
    });

    return encodedString;
  }

  static String showSimpleFileName(String fileName) {
    String simpleFileName = "";

    if (fileName.toLowerCase().startsWith("http://")
        || fileName.toLowerCase().startsWith("https://")) {
      simpleFileName = fileName.substring(fileName.lastIndexOf("/") + 1);
    }

    return simpleFileName;
  }

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 650;

  /// tablet >= 650
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 650;

  ///desktop >= 1100
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  static String decodeUnicodeCharacters(String messageText) {
    specialCharUnicodeMap.forEach((key, value) {
      messageText = messageText.replaceAll(key, value);
    });

    return messageText;
  }

  static String getPersonSet(int personCount) {
    if (personCount == 1) {
      return "Person";
    } else {
      return "People";
    }
  }

  static String getUnqualifiedEmailName(String emailAddress) {
    return emailAddress.contains("@") ? emailAddress.substring(0, emailAddress.indexOf("@")) : emailAddress;
  }

  static bool isEmailFormat(String? emailAddress) {
    bool? emailValidated = emailAddress != null && emailAddress.trim().length > 0;

    if (emailValidated) {
      List<String> emailPart = emailAddress.split("@");
      if (emailPart.length == 2) {
        emailValidated = isAlphaNumericWithNonB2BDots(emailPart.first) && isAlphaNumericWithNonB2BDots(emailPart.last);
      }
    }

    return emailValidated;
  }

  static int calculateCharactersThatFit(String text, double containerWidth, TextStyle textStyle) {
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );

    // Iterate over the text, character by character
    for (int i = 1; i <= text.length; i++) {
      String currentText = text.substring(0, i);
      textPainter.text = TextSpan(text: currentText, style: textStyle);
      textPainter.layout();

      // Check if the current text width exceeds the container width
      if (textPainter.width > containerWidth) {
        return i - 1; // Return the number of characters that fit
      }
    }

    return text.length; // If all characters fit, return the total length
  }

  static String padString(String inputStr, String padString, int padLength, PadDirectionType directionType) {
    if (inputStr.length < padLength) {
      if (directionType == PadDirectionType.LEFT) {
        for (int i = 0; i <= padLength - inputStr.length - 1; i++) {
          inputStr = padString + inputStr;
        }
      } else if (directionType == PadDirectionType.RIGHT) {
        for (int i = 0; i <= padLength - inputStr.length - 1; i++) {
          inputStr = inputStr + padString;
        }
      }
    }

    return inputStr;
  }

  static String getEnumStringValue(String enumStr) {
    String enumNameValue = "";

    if (enumStr != null) {
      if (enumStr.indexOf(".") > -1) {
        enumNameValue = enumStr.substring(enumStr.indexOf(".") + 1);
      } else {
        enumNameValue = enumStr;
      }
    }

    return enumNameValue;
  }

  static bool isSessionLostMessage(String errorMessage) {
    return errorMessage == "Exception: <<SESSION-LOST>>";
  }

  static String unformatMoneyValue(String moneyStr) {
    moneyStr = moneyStr.replaceAll(",", "");
    moneyStr = moneyStr.replaceAll(" ", "");

    if((moneyStr.startsWith("(")) && (moneyStr.endsWith(")"))) {
      moneyStr = "-"+moneyStr.substring(1, moneyStr.length-1);
    }

    return moneyStr;
  }

  static String getIntegerFormatted(double amount) {
    String moneyStr = amount.toString();

    if (moneyStr.contains(".")) {
      String decimalPortion = moneyStr.substring(0, moneyStr.indexOf("."));
      return getFormattedAmount(decimalPortion);
    } else {
      return getFormattedAmount(moneyStr);
    }
  }

  static String getMoneyFormat(double amount, {bool removeZeroFraction = false}) {
    bool? isNegativeAmt = amount < 0;

    String? moneyStr = amount.abs().toString();

    moneyStr = moneyStr.replaceAll(",", "");
    moneyStr = moneyStr.replaceAll(" ", "");

    if (moneyStr.contains(".")) {
      String? decimalPortion = moneyStr.substring(0, moneyStr.indexOf("."));
      String? fractionalPortion = moneyStr.substring(moneyStr.indexOf(".") + 1, moneyStr.length);

      if (fractionalPortion.length == 2) {
        moneyStr = getFormattedAmount(decimalPortion) + "." + fractionalPortion;
      } else if (fractionalPortion.length > 2) {
        moneyStr = getFormattedAmount(decimalPortion) + "." + fractionalPortion.substring(0, 2);
      } else {
        moneyStr = getFormattedAmount(decimalPortion) + "." + fractionalPortion + "0";
      }
    } else {
      moneyStr = getFormattedAmount(moneyStr) + ".00";
    }

    if (removeZeroFraction) {
      if (moneyStr.substring(moneyStr.lastIndexOf(".")) == ".00") {
        moneyStr = moneyStr.substring(0, moneyStr.lastIndexOf("."));
      }
    }

    return isNegativeAmt ? "($moneyStr)" : moneyStr;
  }

  static String getFormattedAmount(String moneyStr) {
    String formattedAmt = "";

    String threesTerm = "";
    int threesCount = 0;

    for (int i = moneyStr.length - 1; i >= 0; i--) {
      if (threesCount < 3) {
        threesTerm = moneyStr[i] + threesTerm;
      } else {
        if (formattedAmt.length > 0) {
          formattedAmt = threesTerm + "," + formattedAmt;
        } else {
          formattedAmt = threesTerm;
        }

        threesCount = 0;
        threesTerm = moneyStr[i];
      }

      threesCount++;
    }

    if (threesTerm.length > 0) {
      if (formattedAmt.length > 0) {
        formattedAmt = threesTerm + "," + formattedAmt;
      } else {
        formattedAmt = threesTerm;
      }
    }

    return formattedAmt;
  }

  static bool getAsBool(String boolStr) {
    return boolStr.toLowerCase() == "true";
  }

  static bool isEnterKey(String char) {
    return char.codeUnitAt(0) == 13 || char == '\n' || char == '\r' || char == '\r\n';
  }

  static bool isAlpha(String char) {
    int? asciiCode = char.codeUnitAt(0);

    return (asciiCode >= 65 && asciiCode <= 90) || (asciiCode >= 97 && asciiCode <= 122);
  }

  static bool hasCapitalLetter(String inputString) {
    bool hasCapLetter = false;
    int index = 0;

    while (index <= inputString.length - 1) {
      if (isCapitalLetter(inputString[index])) {
        hasCapLetter = true;
        break;
      }

      index++;
    }

    return hasCapLetter;
  }

  static bool isCapitalLetter(String char) {
    int? asciiCode = char.codeUnitAt(0);
    return (asciiCode >= 65 && asciiCode <= 90);
  }

  static bool isDigit(String char) {
    int asciiCode = char.codeUnitAt(0);
    return (asciiCode >= 48 && asciiCode <= 57);
  }

  static bool isAlphaNum(String char) {
    return isAlpha(char) || isDigit(char);
  }

  static int asciiTag(String ch) {
    return ch!.codeUnitAt(0);
  }

  static bool hasNonZeroDigit(String digitSequence) {
    bool foundNonZero = false;

    for (int i = 0; i <= digitSequence.length - 1; i++) {
      foundNonZero = digitSequence[i].codeUnitAt(0) != 48;

      if (foundNonZero) {
        break;
      }
    }

    return foundNonZero;
  }

  static bool isSpace(String char) {
    return char.codeUnitAt(0) == 32;
  }

  static int skipSpace(String inputString, int index) {
    if (index <= inputString.length - 1) {
      while ((isSpace(inputString[index])) && (index <= inputString.length - 1)) {
        index++;
      }
    }

    return index;
  }

  static String removeLeading(String inputString, String leading) {
    if (inputString.startsWith(leading)) {
      inputString = inputString.substring(1);
      inputString = removeLeading(inputString, leading);
    }

    return inputString;
  }

  static Map<String, dynamic> parseStringToMap(String inputString) {
    Map<String, dynamic> nameValueMap = new Map<String, dynamic>();

    if (inputString[0] == "{") {
      inputString = inputString.substring(1);
    }

    if (inputString[inputString.length - 1] == "}") {
      inputString = inputString.substring(0, inputString.length - 1);
    }

    List<String> nameValuePairList = inputString.split(",");

    nameValuePairList.forEach((element) {
      List<String> nameValueArray = element.split("=");
      if (nameValueArray.length == 2) {
        nameValueMap.putIfAbsent(nameValueArray[0].trim(), () => nameValueArray[1]);
      }
    });

    return nameValueMap;
  }

  static Future<Uint8List> readFileByte(String filePath) async {
    AppLogger logger = AppLogger.getInstance();

    Uri myUri = Uri.parse(filePath);
    File fileHandle = new File.fromUri(myUri);

    late Uint8List bytes;

    await fileHandle.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      logger.log('reading of bytes is completed');
    }).catchError((onError) {
      logger.log('Exception Error while reading audio from path:' + onError.toString(), logLevel: LogLevel.ERROR);
    });

    return bytes;
  }

  static Future<void> deleteFile(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File fileHandle = new File.fromUri(myUri);

    await fileHandle.delete();
  }

  static String getTextByLimitedLength(String? inputText, {int? limitLength = 0}) {
    if (inputText == null) {
      inputText = "";
    }

    if (inputText.trim().length > 0) {
      if ((limitLength! > 0) && (inputText.length > limitLength!)) {
        inputText = inputText.substring(0, limitLength - 3) + "...";
      }
    }

    return inputText;
  }

  static bool isAlphaNumeric(String inputStr) {
    bool isAlNumSeq = true;
    int index = 0;
    int dotCount = 0;

    if (inputStr.trim().length == 0) {
      isAlNumSeq = false;
      return isAlNumSeq;
    }

    if (isAlpha(inputStr[0])) {
      while ((index <= inputStr.length - 1) && (isAlNumSeq)) {
        isAlNumSeq = isAlNumSeq && (isDigit(inputStr[index]) || isAlpha(inputStr[index]));
        if (!isAlNumSeq) {
          break;
        }

        index++;
      }
    }

    return isAlNumSeq;
  }

  static bool isAlphaNumericWithADot(String inputStr) {
    bool isAlNumSeq = true;
    int index = 0;
    int dotCount = 0;

    if (inputStr.trim().length == 0) {
      isAlNumSeq = false;
      return isAlNumSeq;
    }

    if (isAlpha(inputStr[0])) {
      while ((index <= inputStr.length - 1) && (isAlNumSeq)) {
        isAlNumSeq = isAlNumSeq && (isDigit(inputStr[index]) || isAlpha(inputStr[index]) || (inputStr[index] == '.'));
        if (inputStr[index] == '.') {
          dotCount++;
        }

        if (!isAlNumSeq) {
          break;
        }

        index++;
      }
    }

    isAlNumSeq = isAlNumSeq && (dotCount == 1);

    return isAlNumSeq;
  }

  /**
   * is alpha-numeric String? with Non-back-to-back dot sequence
   * example: lenon..traxo
   */
  static bool isAlphaNumericWithNonB2BDots(String inputStr) {
    bool isAlNumSeq = true;
    int index = 0;
    int dotCount = 0;

    if (inputStr.trim().length == 0) {
      isAlNumSeq = false;
      return isAlNumSeq;
    }

    if (isAlpha(inputStr[0])) {
      while ((index <= inputStr.length - 1) && (isAlNumSeq)) {
        isAlNumSeq = isAlNumSeq && (isDigit(inputStr[index]) || isAlpha(inputStr[index]) || (inputStr[index] == '.'));
        if (inputStr[index] == '.') {
          dotCount++;
        } else {
          dotCount = 0;
        }

        if (dotCount > 1) {
          isAlNumSeq = false;
        }

        if (!isAlNumSeq) {
          break;
        }

        index++;
      }
    }

    return isAlNumSeq;
  }

  static bool isDigitSequence(String inputStr) {
    bool isDigSeq = true;
    int index = 0;

    if (inputStr.trim().length == 0) {
      isDigSeq = false;
      return isDigSeq;
    }

    if (inputStr.startsWith("-")) {
      index++;
    }

    while ((index <= inputStr.length - 1) && (isDigSeq)) {
      isDigSeq = isDigSeq && isDigit(inputStr[index++]);
    }

    return isDigSeq;
  }

  static bool isDigitSequenceWithADot(String inputStr) {
    bool isDigSeq = true;
    int index = 0;
    int dotCount = 0;

    if (inputStr.trim().length == 0) {
      isDigSeq = false;
      return isDigSeq;
    }

    if (inputStr.startsWith("-")) {
      index++;
    }

    while ((index <= inputStr.length - 1) && (isDigSeq)) {
      isDigSeq = isDigSeq && (isDigit(inputStr[index]) || (inputStr[index] == '.'));
      if (inputStr[index] == '.') {
        dotCount++;
      }
      index++;
    }

    isDigSeq = isDigSeq && (dotCount == 1);

    return isDigSeq;
  }

  static bool isDigitSequenceWithDots(String inputStr) {
    bool isDigSeq = true;
    int index = 0;

    if (inputStr.trim().length == 0) {
      isDigSeq = false;
      return isDigSeq;
    }

    if (inputStr.startsWith("-")) {
      index++;
    }

    while ((index <= inputStr.length - 1) && (isDigSeq)) {
      isDigSeq = isDigSeq && (isDigit(inputStr[index]) || (inputStr[index] == '.'));
      index++;
    }

    return isDigSeq;
  }

  static bool isNumber(String inputStr) {
    return isDigitSequence(inputStr) || isDigitSequenceWithADot(inputStr);
  }

  static double getSimilarity(String a, String b) {
    double _similarity = 0;

    a = a.toUpperCase();
    b = b.toUpperCase();
    _similarity = 1 - levenshtein(a, b) / (max(a.length, b.length));
    return (_similarity);
  }

  static int levenshtein(String a, String b) {
    a = a.toUpperCase();
    b = b.toUpperCase();
    int sa = a.length;
    int sb = b.length;
    int i, j, cost, min1, min2, min3;
    int levenshtein;
    List<List<int>> d = new List.generate(sa + 1, (int? i) => List<int>.filled(sb + 1, 0, growable: true));

    if (a.length == 0) {
      levenshtein = b.length;
      return (levenshtein);
    }

    if (b.length == 0) {
      levenshtein = a.length;
      return (levenshtein);
    }

    for (i = 0; i <= sa; i++) {
      d[i][0] = i;
    }

    for (j = 0; j <= sb; j++) {
      d[0][j] = j;
    }

    for (i = 1; i <= a.length; i++)
      for (j = 1; j <= b.length; j++) {
        if (a[i - 1] == b[j - 1]) {
          cost = 0;
        } else {
          cost = 1;
        }

        min1 = (d[i - 1][j] + 1);
        min2 = (d[i][j - 1] + 1);
        min3 = (d[i - 1][j - 1] + cost);
        d[i][j] = min(min1, min(min2, min3));
      }

    levenshtein = d[a.length][b.length];

    return (levenshtein);
  }

  static int min(int x, int y) {
    if (x <= y) {
      return x;
    } else {
      return y;
    }
  }

  static int max(int x, int y) {
    if (x >= y) {
      return x;
    } else {
      return y;
    }
  }
}
