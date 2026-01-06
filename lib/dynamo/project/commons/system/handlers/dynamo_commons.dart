import 'dart:io';
import 'dart:typed_data';

import 'package:dynamo_json_decoder/dynamo/project/commons/system/entities/log_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//
import 'dart:ui' as ui;

import 'package:dynamo_json_decoder/dynamo/project/commons/constants/pad_direction_type.dart';

import 'app_logger.dart';

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

  /// Replaces special characters with their unicode values.
  static String encodeSpecialCharacters(String inputString) {
    String encodedString = inputString;

    DynamoCommons.specialCharUnicodeMap.forEach((key, value) {
      if (value != "-") {
        encodedString = encodedString.replaceAll(value, key);
      }
    });

    return encodedString;
  }

  /// strips off the nase URL leaving only the simple file name.
  static String showSimpleFileName(String fileName) {
    String simpleFileName = "";

    if (fileName.toLowerCase().startsWith("http://") ||
        fileName.toLowerCase().startsWith("https://")) {
      simpleFileName = fileName.substring(fileName.lastIndexOf("/") + 1);
    }

    return simpleFileName;
  }

  /// checks if a screen size is mobile.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  /// tablet >= 650
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650;

  ///desktop >= 1100
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// Replaces unicode characters with their corresponding special characters.
  static String decodeUnicodeCharacters(String messageText) {
    specialCharUnicodeMap.forEach((key, value) {
      messageText = messageText.replaceAll(key, value);
    });

    return messageText;
  }

  /// returns 'Person' if [personCount] is 1 otherwise it returns 'People'.
  static String getPersonSet(int personCount) {
    if (personCount == 1) {
      return "Person";
    } else {
      return "People";
    }
  }

  /// strips off the domain name part of an email'.
  static String getUnqualifiedEmailName(String emailAddress) {
    return emailAddress.contains("@")
        ? emailAddress.substring(0, emailAddress.indexOf("@"))
        : emailAddress;
  }

  /// checks if an email address is correctly formatted.
  static bool isEmailFormat(String? emailAddress) {
    bool? emailValidated =
        emailAddress != null && emailAddress.trim().isNotEmpty;

    if (emailValidated) {
      List<String> emailPart = emailAddress.split("@");
      if (emailPart.length == 2) {
        emailValidated = isAlphaNumericWithNonB2BDots(emailPart.first) &&
            isAlphaNumericWithNonB2BDots(emailPart.last);
      }
    }

    return emailValidated;
  }

  /// does a calculation to determine a Text widget height.
  static int calculateCharactersThatFit(
      String text, double containerWidth, TextStyle textStyle) {
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

  /// pads the input text [inputStr] with the pad string [padString],
  /// in the direction provided by [directionType], until the padded string equals [padLength].
  static String padString(String inputStr, String padString, int padLength,
      PadDirectionType directionType) {
    if (inputStr.length < padLength) {
      if (directionType == PadDirectionType.left) {
        for (int i = 0; i <= padLength - inputStr.length - 1; i++) {
          inputStr = padString + inputStr;
        }
      } else if (directionType == PadDirectionType.right) {
        for (int i = 0; i <= padLength - inputStr.length - 1; i++) {
          inputStr = inputStr + padString;
        }
      }
    }

    return inputStr;
  }

  /// get enum field simple name
  static String getEnumStringValue(String enumStr) {
    String enumNameValue = "";

    if (enumStr.contains(".")) {
      enumNameValue = enumStr.substring(enumStr.indexOf(".") + 1);
    } else {
      enumNameValue = enumStr;
    }

    return enumNameValue;
  }

  static bool isSessionLostMessage(String errorMessage) {
    return errorMessage == "Exception: <<SESSION-LOST>>";
  }

  /// remove money-type formatting from a string before converting it to a number
  static String unformatMoneyValue(String moneyStr) {
    moneyStr = moneyStr.replaceAll(",", "");
    moneyStr = moneyStr.replaceAll(" ", "");

    if ((moneyStr.startsWith("(")) && (moneyStr.endsWith(")"))) {
      moneyStr = '-${moneyStr.substring(1, moneyStr.length - 1)}';
    }

    return moneyStr;
  }

  /// 17500 =>> 17,500
  static String getIntegerFormatted(double amount) {
    String moneyStr = amount.toString();

    if (moneyStr.contains(".")) {
      String decimalPortion = moneyStr.substring(0, moneyStr.indexOf("."));
      return getFormattedAmount(decimalPortion);
    } else {
      return getFormattedAmount(moneyStr);
    }
  }

  /// 17500 =>> 17,500.00
  static String getMoneyFormat(double amount,
      {bool removeZeroFraction = false}) {
    bool? isNegativeAmt = amount < 0;

    String? moneyStr = amount.abs().toString();

    moneyStr = moneyStr.replaceAll(",", "");
    moneyStr = moneyStr.replaceAll(" ", "");

    if (moneyStr.contains(".")) {
      String? decimalPortion = moneyStr.substring(0, moneyStr.indexOf("."));
      String? fractionalPortion =
          moneyStr.substring(moneyStr.indexOf(".") + 1, moneyStr.length);

      if (fractionalPortion.length == 2) {
        moneyStr = '${getFormattedAmount(decimalPortion)}.$fractionalPortion';
      } else if (fractionalPortion.length > 2) {
        moneyStr =
            '${getFormattedAmount(decimalPortion)}.${fractionalPortion.substring(0, 2)}';
      } else {
        moneyStr =
            '${getFormattedAmount(decimalPortion)} . ${fractionalPortion}0';
      }
    } else {
      moneyStr = '${getFormattedAmount(moneyStr)} .00';
    }

    if (removeZeroFraction) {
      if (moneyStr.substring(moneyStr.lastIndexOf(".")) == ".00") {
        moneyStr = moneyStr.substring(0, moneyStr.lastIndexOf("."));
      }
    }

    return isNegativeAmt ? "($moneyStr)" : moneyStr;
  }

  /// formats the decimal part of a floating point number
  static String getFormattedAmount(String moneyStr) {
    String formattedAmt = "";

    String threesTerm = "";
    int threesCount = 0;

    for (int i = moneyStr.length - 1; i >= 0; i--) {
      if (threesCount < 3) {
        threesTerm = moneyStr[i] + threesTerm;
      } else {
        if (formattedAmt.isNotEmpty) {
          formattedAmt = '$threesTerm,$formattedAmt';
        } else {
          formattedAmt = threesTerm;
        }

        threesCount = 0;
        threesTerm = moneyStr[i];
      }

      threesCount++;
    }

    if (threesTerm.isNotEmpty) {
      if (formattedAmt.isNotEmpty) {
        formattedAmt = '$threesTerm,$formattedAmt';
      } else {
        formattedAmt = threesTerm;
      }
    }

    return formattedAmt;
  }

  /// Get string as bool
  static bool getAsBool(String boolStr) {
    return boolStr.toLowerCase() == "true";
  }

  /// check if character matches carriage return
  static bool isEnterKey(String char) {
    return char.codeUnitAt(0) == 13 ||
        char == '\n' ||
        char == '\r' ||
        char == '\r\n';
  }

  /// check if character is an alphabet
  static bool isAlpha(String char) {
    int? asciiCode = char.codeUnitAt(0);

    return (asciiCode >= 65 && asciiCode <= 90) ||
        (asciiCode >= 97 && asciiCode <= 122);
  }

  /// check if String has a capital letter
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

  /// check if character is a capital letter
  static bool isCapitalLetter(String char) {
    int? asciiCode = char.codeUnitAt(0);
    return (asciiCode >= 65 && asciiCode <= 90);
  }

  /// check if character is a number
  static bool isDigit(String char) {
    int asciiCode = char.codeUnitAt(0);
    return (asciiCode >= 48 && asciiCode <= 57);
  }

  /// check if character is an alphabet or number
  static bool isAlphaNum(String char) {
    return isAlpha(char) || isDigit(char);
  }

  /// get the ASCII value of a character
  static int asciiTag(String ch) {
    return ch.codeUnitAt(0);
  }

  /// check if the string has a non-zero digit
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

  /// check if character is a whaite space
  static bool isSpace(String char) {
    return char.codeUnitAt(0) == 32;
  }

  /// skip whitespace character in a character sequence.
  static int skipSpace(String inputString, int index) {
    if (index <= inputString.length - 1) {
      while (
          (isSpace(inputString[index])) && (index <= inputString.length - 1)) {
        index++;
      }
    }

    return index;
  }

  /// continuously remove the first character of the string [inputString]
  /// if it starts with the character held by [leading].
  static String removeLeading(String inputString, String leading) {
    if (inputString.startsWith(leading)) {
      inputString = inputString.substring(1);
      inputString = removeLeading(inputString, leading);
    }

    return inputString;
  }

  /// A simple parser method that returns a specific definition of a map object:
  /// `inputString = {key1=value1, key2=value2, ..., keyN=valueN}`
  static Map<String, dynamic> parseStringToMap(String inputString) {
    Map<String, dynamic> nameValueMap = {};

    if (inputString[0] == "{") {
      inputString = inputString.substring(1);
    }

    if (inputString[inputString.length - 1] == "}") {
      inputString = inputString.substring(0, inputString.length - 1);
    }

    List<String> nameValuePairList = inputString.split(",");

    for (var element in nameValuePairList) {
      List<String> nameValueArray = element.split("=");
      if (nameValueArray.length == 2) {
        nameValueMap.putIfAbsent(
            nameValueArray[0].trim(), () => nameValueArray[1]);
      }
    }

    return nameValueMap;
  }

  /// read the byte array of the file with path [filePath].
  static Future<Uint8List> readFileByte(String filePath) async {
    AppLogger logger = AppLogger.getInstance();

    Uri myUri = Uri.parse(filePath);
    File fileHandle = File.fromUri(myUri);

    late Uint8List bytes;

    await fileHandle.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      logger.log('reading of bytes is completed');
    }).catchError((onError) {
      logger.log(
          'Exception Error while reading audio from path: ${onError.toString()}',
          logLevel: LogLevel.error);
    });

    return bytes;
  }

  /// delete file with path [filePath].
  static Future<void> deleteFile(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File fileHandle = File.fromUri(myUri);

    await fileHandle.delete();
  }

  /// trim [inputText] from the right to fit the length of [limitLength].
  static String getTextByLimitedLength(String? inputText,
      {int limitLength = 0}) {
    inputText ??= "";

    if (inputText.trim().isNotEmpty) {
      if (limitLength > 0 && inputText.length > limitLength) {
        return "${inputText.substring(0, limitLength - 3)}...";
      }
    }

    return inputText;
  }

  /// check if the [inputStr] is alpha-numeric
  static bool isAlphaNumeric(String inputStr) {
    bool isAlNumSeq = true;
    int index = 0;

    if (inputStr.trim().isEmpty) {
      isAlNumSeq = false;
      return isAlNumSeq;
    }

    if (isAlpha(inputStr[0])) {
      while ((index <= inputStr.length - 1) && (isAlNumSeq)) {
        isAlNumSeq = isAlNumSeq &&
            (isDigit(inputStr[index]) || isAlpha(inputStr[index]));
        if (!isAlNumSeq) {
          break;
        }

        index++;
      }
    }

    return isAlNumSeq;
  }

  /// check if the [inputStr] is alpha-numeric with a single dot occurence
  static bool isAlphaNumericWithADot(String inputStr) {
    bool isAlNumSeq = true;
    int index = 0;
    int dotCount = 0;

    if (inputStr.trim().isEmpty) {
      isAlNumSeq = false;
      return isAlNumSeq;
    }

    if (isAlpha(inputStr[0])) {
      while ((index <= inputStr.length - 1) && (isAlNumSeq)) {
        isAlNumSeq = isAlNumSeq &&
            (isDigit(inputStr[index]) ||
                isAlpha(inputStr[index]) ||
                (inputStr[index] == '.'));
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

  /// is alpha-numeric String? with Non-back-to-back dot sequence
  /// example: lenon..traxo
  static bool isAlphaNumericWithNonB2BDots(String inputStr) {
    bool isAlNumSeq = true;
    int index = 0;
    int dotCount = 0;

    if (inputStr.trim().isEmpty) {
      isAlNumSeq = false;
      return isAlNumSeq;
    }

    if (isAlpha(inputStr[0])) {
      while ((index <= inputStr.length - 1) && (isAlNumSeq)) {
        isAlNumSeq = isAlNumSeq &&
            (isDigit(inputStr[index]) ||
                isAlpha(inputStr[index]) ||
                (inputStr[index] == '.'));
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

  /// check if the [inputStr] is a digit sequence
  static bool isDigitSequence(String inputStr) {
    bool isDigSeq = true;
    int index = 0;

    if (inputStr.trim().isEmpty) {
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

  /// check if the [inputStr] is a digit sequence with a single dot
  static bool isDigitSequenceWithADot(String inputStr) {
    bool isDigSeq = true;
    int index = 0;
    int dotCount = 0;

    if (inputStr.trim().isEmpty) {
      isDigSeq = false;
      return isDigSeq;
    }

    if (inputStr.startsWith("-")) {
      index++;
    }

    while ((index <= inputStr.length - 1) && (isDigSeq)) {
      isDigSeq =
          isDigSeq && (isDigit(inputStr[index]) || (inputStr[index] == '.'));
      if (inputStr[index] == '.') {
        dotCount++;
      }
      index++;
    }

    isDigSeq = isDigSeq && (dotCount == 1);

    return isDigSeq;
  }

  /// check if the [inputStr] is a digit sequence with more than one dot
  static bool isDigitSequenceWithDots(String inputStr) {
    bool isDigSeq = true;
    int index = 0;

    if (inputStr.trim().isEmpty) {
      isDigSeq = false;
      return isDigSeq;
    }

    if (inputStr.startsWith("-")) {
      index++;
    }

    while ((index <= inputStr.length - 1) && (isDigSeq)) {
      isDigSeq =
          isDigSeq && (isDigit(inputStr[index]) || (inputStr[index] == '.'));
      index++;
    }

    return isDigSeq;
  }

  /// check if the [inputStr] is a number
  static bool isNumber(String inputStr) {
    return isDigitSequence(inputStr) || isDigitSequenceWithADot(inputStr);
  }

  /// calculate the similarity between the two strings [a] and [b]
  static double getSimilarity(String a, String b) {
    double similarity = 0;

    a = a.toUpperCase();
    b = b.toUpperCase();
    similarity = 1 - levenshtein(a, b) / (max(a.length, b.length));
    return (similarity);
  }

  static int levenshtein(String a, String b) {
    a = a.toUpperCase();
    b = b.toUpperCase();
    int sa = a.length;
    int sb = b.length;
    int i, j, cost, min1, min2, min3;
    int levenshtein;
    List<List<int>> d = List.generate(
        sa + 1, (int? i) => List<int>.filled(sb + 1, 0, growable: true));

    if (a.isEmpty) {
      levenshtein = b.length;
      return (levenshtein);
    }

    if (b.isEmpty) {
      levenshtein = a.length;
      return (levenshtein);
    }

    for (i = 0; i <= sa; i++) {
      d[i][0] = i;
    }

    for (j = 0; j <= sb; j++) {
      d[0][j] = j;
    }

    for (i = 1; i <= a.length; i++) {
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
