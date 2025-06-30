import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(XFile image, String path) async {
    try {
      final ref = _storage.ref(path).child(image.name);
      final uploadTask = await ref.putFile(File(image.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir imagen: $e");
      throw Exception('No se pudo subir la imagen.');
    }
  }
}
