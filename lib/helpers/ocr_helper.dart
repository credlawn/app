
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrHelper {
  static Future<void> pickImage(ImageSource source, Function(String) onTextRecognized) async {
    print('[_pickImage] Picking image from $source');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      print('[_pickImage] Image picked: ${pickedFile.path}');
      _performOcr(pickedFile.path, onTextRecognized);
    } else {
      print('[_pickImage] No image picked.');
    }
  }

  static void _performOcr(String imagePath, Function(String) onTextRecognized) async {
    print('[_performOcr] Starting OCR for image: $imagePath');

    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
    await textRecognizer.close();

    String foundRefNumber = '';

    String _cleanArn(String text) {
      text = text.toUpperCase();
      text = text.replaceAll(']', 'J');
      text = text.replaceAll('[', 'I');
      text = text.replaceAll('|', 'I');
      text = text.replaceAll('(', 'C');
      text = text.replaceAll(')', '');
      text = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');

      if (text.length != 16) return text;

      if (text.startsWith('D')) {
        String part1_digits = text.substring(1, 3);
        String part2_alpha = text.substring(3, 4);
        String part3_digits = text.substring(4, 12);
        String part4_alpha = text.substring(12, 13);
        String part5_digit = text.substring(13, 14);
        String part6_alpha = text.substring(14, 15);
        String part7_last = text.substring(15, 16);

        String _fixDigits(String s) {
          return s
              .replaceAll('O', '0')
              .replaceAll('S', '5')
              .replaceAll('I', '1')
              .replaceAll('Z', '2')
              .replaceAll('B', '8');
        }

        String _fixAlpha(String s) {
          return s
              .replaceAll('5', 'S')
              .replaceAll('0', 'O')
              .replaceAll('1', 'I')
              .replaceAll('2', 'Z')
              .replaceAll('8', 'B');
        }

        String fixed_part1 = _fixDigits(part1_digits);
        String fixed_part2 = _fixAlpha(part2_alpha);
        String fixed_part3 = _fixDigits(part3_digits);
        String fixed_part4 = _fixAlpha(part4_alpha);
        String fixed_part5 = _fixDigits(part5_digit);
        String fixed_part6 = _fixAlpha(part6_alpha);

        text = 'D' + fixed_part1 + fixed_part2 + fixed_part3 + fixed_part4 + fixed_part5 + fixed_part6 + part7_last;
      }
      return text;
    }

    bool _isValidArn(String text) {
      if (text.length != 16) return false;

      if (text.startsWith('D')) {
        bool part1_isDigits = RegExp(r'^[0-9]{2}$').hasMatch(text.substring(1, 3));
        bool part2_isAlpha = RegExp(r'^[A-Z]$').hasMatch(text.substring(3, 4));
        bool part3_isDigits = RegExp(r'^[0-9]{8}$').hasMatch(text.substring(4, 12));
        bool part4_isAlpha = RegExp(r'^[A-Z]$').hasMatch(text.substring(12, 13));
        bool part5_isDigit = RegExp(r'^[0-9]{1}$').hasMatch(text.substring(13, 14));
        bool part6_isAlpha = RegExp(r'^[A-Z]$').hasMatch(text.substring(14, 15));
        return part1_isDigits && part2_isAlpha && part3_isDigits && part4_isAlpha && part5_isDigit && part6_isAlpha;
      }
      return false;
    }

    final RegExp arnRegExp = RegExp(r'[A-Z0-9]{16}');
    final allText = recognizedText.blocks.map((b) => b.text.replaceAll('\n', ' ')).join(' ');
    final matches = arnRegExp.allMatches(allText);

    for (final match in matches) {
      final potentialArn = match.group(0)!;
      print('[_performOcr] Potential ARN found: $potentialArn');
      
      final cleanedArn = _cleanArn(potentialArn);
      print('[_performOcr] Cleaned ARN: $cleanedArn');

      if (_isValidArn(cleanedArn)) {
        foundRefNumber = cleanedArn;
        print('[_performOcr] Valid ARN found after cleaning: $foundRefNumber');
        onTextRecognized(foundRefNumber);
        return; 
      }
    }

    if (foundRefNumber.isEmpty) {
      print('[_performOcr] No valid ARN found after checking all potential matches.');
    }
  }
}
