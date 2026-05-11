import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_state.dart';
import '../models/product.dart';
import 'admin_dashboard_screen.dart';
import '../app_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  
  File? _image;
  final _picker = ImagePicker();
  bool _isUploading = false;

  late AnimationController _animationController;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _tiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      // Simulate network delay
      Future.delayed(const Duration(seconds: 2), () {
        final newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          description: _descController.text,
          price: double.parse(_priceController.text),
          imageUrl: _image?.path ?? 'assets/images/flower.png', // Fallback to asset for demo
          category: _categoryController.text,
          tags: ['New', 'Admin'],
        );

        context.read<AppState>().addProduct(newProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PRODUCT ADDED SUCCESSFULLY!'),
            backgroundColor: AppTheme.pastelMint,
          ),
        );

        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDashboardScreen.darkBg,
      appBar: AppBar(
        title: Text(
          'ADD NEW PRODUCT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              Shadow(color: AppTheme.pastelLavender.withOpacity(0.45), blurRadius: 6),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Animation
          Positioned(
            left: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.5,
              child: SizedBox(
                width: 250,
                height: 250,
                child: Lottie.network(
                  'https://assets8.lottiefiles.com/packages/lf20_m6cuL6.json', // Rotating Flower
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _tiltAnimation,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_tiltAnimation.value),
                        alignment: FractionalOffset.center,
                        child: child,
                      );
                    },
                    child: _buildImagePicker(),
                  ),
                  const SizedBox(height: 30),
                  _buildNeonTextField(
                    controller: _nameController,
                    label: 'FLOWER NAME',
                    icon: Icons.local_florist,
                    color: AppTheme.pastelPink,
                  ),
                  const SizedBox(height: 20),
                  _buildNeonTextField(
                    controller: _descController,
                    label: 'DESCRIPTION',
                    icon: Icons.description,
                    color: AppTheme.pastelPeach,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNeonTextField(
                          controller: _priceController,
                          label: 'PRICE (\$)',
                          icon: Icons.attach_money,
                          color: AppTheme.pastelMint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildNeonTextField(
                          controller: _categoryController,
                          label: 'CATEGORY',
                          icon: Icons.category,
                          color: AppTheme.pastelPink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.network(
                      'https://assets3.lottiefiles.com/packages/lf20_at6p7rqi.json', // Loading animation
                      width: 150,
                    ),
                    const Text(
                      'UPLOADING TO BLOOMBASKET...',
                      style: TextStyle(color: Colors.black54, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
          decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.pastelLavender.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.pastelLavender.withOpacity(0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: AppTheme.pastelLavender, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'TAP TO ADD PICTURE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return InkWell(
      onTap: _submitForm,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [AppTheme.pastelLavender, AppTheme.pastelPink],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.pastelLavender.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'ADD PRODUCT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
