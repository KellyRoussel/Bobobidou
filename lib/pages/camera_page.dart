import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bobobidou/l10n/app_localizations.dart';
import 'package:bobobidou/services/food_recognition_service.dart';

class CameraPage extends StatefulWidget {
  final Function(List<String>) onIngredientsDetected;

  const CameraPage({
    Key? key,
    required this.onIngredientsDetected,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  final FoodImageRecognitionService _recognitionService = FoodImageRecognitionService();
  File? _imageFile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Start the image picker automatically when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return;

    final XFile? image;
    try {
      image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Camera error: $e');
      if (!mounted) return;
      _showError();
      if (_imageFile == null) Navigator.of(context).pop();
      return;
    }
    if (!mounted) return;

    if (image == null) {
      // User canceled the picker: leave only if there is no previous photo
      if (_imageFile == null) Navigator.of(context).pop();
      return;
    }

    final imageFile = File(image.path);
    setState(() {
      _imageFile = imageFile;
    });

    await _analyzePicture();
  }

  /// Sends the current picture to the backend and returns the detected
  /// ingredients to the caller. On error, stays on the page so the user can
  /// retry or retake the picture.
  Future<void> _analyzePicture() async {
    if (_isProcessing || _imageFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Show processing indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).translate('analyzing_image')),
          ],
        ),
      ),
    );

    try {
      final language = AppLocalizations.of(context).locale.languageCode;
      final ingredients = await _recognitionService.recognizeIngredientsFromImage(
        _imageFile!,
        language: language,
      );
      if (!mounted) return;

      // Close the processing dialog
      Navigator.of(context).pop();

      // Return the detected ingredients and go back to the previous screen
      widget.onIngredientsDetected(ingredients);
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Ingredient recognition error: $e');
      if (!mounted) return;

      // Close the processing dialog
      Navigator.of(context).pop();
      _showError();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).translate('ingredient_detection_error'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _retakePicture() async {
    await _takePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('take_photo')),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _imageFile == null
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      )
          : Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                _imageFile!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).translate('retake')),
                  onPressed: _isProcessing ? null : _retakePicture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(AppLocalizations.of(context).translate('use_photo')),
                  onPressed: _isProcessing ? null : _analyzePicture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}