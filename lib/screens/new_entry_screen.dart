import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../models/landmark.dart';
import '../services/api_service.dart';

class NewEntryScreen extends StatefulWidget {
  final Landmark? existing;

  const NewEntryScreen({super.key, this.existing});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  File? _imageFile;
  bool _isSubmitting = false;

  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final lm = widget.existing!;
      _titleController.text = lm.title;
      _latController.text = lm.lat.toString();
      _lonController.text = lm.lon.toString();
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _latController.text = pos.latitude.toString();
        _lonController.text = pos.longitude.toString();
      });
    } catch (_) {
      // Could show a snackbar that GPS failed
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final resized = await _resizeImage(file, picked.name);

    setState(() {
      _imageFile = resized;
    });
  }

  Future<File> _resizeImage(File file, String originalFileName) async {
    final bytes = await file.readAsBytes();
    final img.Image? original = img.decodeImage(bytes);
    if (original == null) return file;

    final img.Image resized = img.copyResize(
      original,
      width: 800,
      height: 600,
    );

    // Determine format from original filename
    final isPng = originalFileName.toLowerCase().endsWith('.png');
    final isGif = originalFileName.toLowerCase().endsWith('.gif');
    
    Uint8List encoded;
    
    if (isPng) {
      encoded = Uint8List.fromList(img.encodePng(resized));
    } else if (isGif) {
      encoded = Uint8List.fromList(img.encodeGif(resized));
    } else {
      // Default to JPEG (supports .jpg, .jpeg, or others)
      encoded = Uint8List.fromList(img.encodeJpg(resized, quality: 90));
    }

    await file.writeAsBytes(encoded);
    return file;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());

    if (lat == null || lon == null) {
      _showError('Invalid latitude or longitude');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.existing == null) {
        // New entry: image is required
        if (_imageFile == null) {
          _showError('Please select an image');
          setState(() => _isSubmitting = false);
          return;
        }

        await _api.createLandmark(
          title: title,
          lat: lat,
          lon: lon,
          imageFile: _imageFile!,
        );
        _showSnack('Landmark created');
      } else {
        // Update: image optional
        await _api.updateLandmark(
          id: widget.existing!.id,
          title: title,
          lat: lat,
          lon: lon,
          imageFile: _imageFile,
        );
        _showSnack('Landmark updated');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Landmark' : 'New Landmark'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lonController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _imageFile == null
                          ? (isEdit
                              ? 'Using existing image (optional to change)'
                              : 'No image selected')
                          : 'Image selected (800×600)',
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isEdit &&
                  _imageFile == null &&
                  widget.existing!.imageUrl.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current image:'),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.existing!.imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isEdit ? 'Update' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
