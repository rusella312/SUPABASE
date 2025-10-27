import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:buildausermanagement/main.dart';

class Avatar extends StatefulWidget {
  const Avatar({super.key, required this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    print('🖼️ Avatar build - imageUrl: ${widget.imageUrl}');
    print('🔍 imageUrl is null: ${widget.imageUrl == null}');
    print('🔍 imageUrl is empty: ${widget.imageUrl?.isEmpty ?? 'null'}');
    
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.network(
                    widget.imageUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    headers: const {
                      'User-Agent': 'Mozilla/5.0 (Android 10; Mobile; rv:81.0) Gecko/81.0 Firefox/81.0',
                      'Accept': 'image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(75),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ Error loading image: $error');
                      print('📍 Image URL: ${widget.imageUrl}');
                      print('🔍 Stack trace: $stackTrace');
                      return Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(75),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image, color: Colors.red, size: 40),
                              SizedBox(height: 4),
                              Text(
                                'Error\ncargando',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(75),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.grey, size: 70),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _isLoading ? null : _upload,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;

      print('📤 Uploading file: $filePath');
      print('📁 File size: ${bytes.length} bytes');

      // Subir archivo
      await supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: imageFile.mimeType),
          );

      print('✅ File uploaded successfully');

      // Obtener URL pública
      final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      
      print('🔗 Public URL generated: $imageUrl');

      // Verificar que la URL sea válida
      if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        widget.onUpload(imageUrl);
        print('✅ URL passed to onUpload callback');
      } else {
        throw Exception('Invalid URL generated: $imageUrl');
      }

      if (mounted) {
        context.showSnackBar('¡Imagen subida exitosamente! 🎉');
      }
    } on StorageException catch (error) {
      print('❌ Storage error: ${error.message}');
      if (mounted) {
        context.showSnackBar(
          'Error al subir imagen: ${error.message}',
          isError: true,
        );
      }
    } catch (error) {
      print('❌ Unexpected error: $error');
      if (mounted) {
        context.showSnackBar('Error inesperado al subir imagen', isError: true);
      }
    }
    setState(() => _isLoading = false);
  }
}
