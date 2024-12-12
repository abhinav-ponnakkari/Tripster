import 'dart:io';

import 'package:Tripster/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:translator/translator.dart';
import 'package:image_picker/image_picker.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  String _capturedText = "";
  String _selectedLanguage = "en";
  final List<String> _availableLanguages = [
    "en", // English
    "es", // Spanish
    "fr", // French
    "ar", // arabic
    "zh-cn", // chinese
    "hi", // hindi
    "ml", // malayalam
  ];
  bool _isLoading = false; // Add loading state variable

  Future<void> _captureAndTranslate() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Center(
          child: Text(
            'Select Image Source',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        actions: [
          _buildDialogButton(
            text: 'Cancel',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          _buildDialogButton(
            text: 'Gallery',
            onPressed: () => _getImage(picker, ImageSource.gallery),
          ),
          _buildDialogButton(
            text: 'Camera',
            onPressed: () => _getImage(picker, ImageSource.camera),
          ),
        ],
      ),
    );

    if (image == null) return;

    final imageCropper = ImageCropper();
    final croppedImageFile = await imageCropper.cropImage(
      sourcePath: image.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
// Adjust aspect ratio as needed
      compressQuality: 100,
      cropStyle: CropStyle.rectangle,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: AppColors.White,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );
    setState(() {
      _isLoading = true; // Set loading state to true after image selection
    });
    final inputImage = InputImage.fromFilePath(croppedImageFile!.path);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    String recognizedText = "";
    final RecognizedText recogText =
        await textRecognizer.processImage(inputImage);
    for (TextBlock block in recogText.blocks) {
      recognizedText += block.text;
    }

    final translator = GoogleTranslator();
    final translation =
        await translator.translate(recognizedText, to: _selectedLanguage);

    if (mounted) {
      setState(() {
        _capturedText = translation.text;
        _isLoading = false; // Set loading state to false after translation
      });
    }
  }

  Widget _buildCaptureButton() {
    return ElevatedButton(
      onPressed: _captureAndTranslate,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
      ),
      child: const Text(
        "Capture Text",
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w700,
          fontSize: 14.0,
          color: AppColors.White,
        ),
      ),
    );
  }

  void _getImage(ImagePicker picker, ImageSource source) async {
    final XFile? capturedImage = await picker.pickImage(source: source);
    if (capturedImage != null) {
      Navigator.of(context).pop(capturedImage);
    }
  }

  Widget _buildDialogButton(
      {required String text, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.White,
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Text Capture and Translation",
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildCaptureButton(),
            const SizedBox(height: 20.0),
            _buildLanguageDropdown(),
            const SizedBox(height: 20.0),
            _buildCapturedTextContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonFormField(
      value: _selectedLanguage,
      items: _availableLanguages
          .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang.toUpperCase()),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedLanguage = value as String),
      decoration: InputDecoration(
        labelText: "Target Language",
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        suffixIcon: const Icon(Icons.language_outlined),
      ),
    );
  }

  Widget _buildCapturedTextContainer() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.Grey),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _capturedText
                      .split('\n') // Split the text by new line
                      .map((line) => Text(
                            line,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ))
                      .toList(),
                ),
              ),
      ),
    );
  }
}
