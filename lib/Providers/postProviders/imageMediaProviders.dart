import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaProvider extends ChangeNotifier {
  List<AssetEntity> _selectedMedia = [];
  List<File> _newSelectedMedia = [];

  List<AssetEntity> get selectedMedia => _selectedMedia;
  List<File> get newSelectedMedia => _newSelectedMedia;

  void addSelectedMedia(AssetEntity media) {
    _selectedMedia.add(media);
    notifyListeners();
  }

  void addNewMedia(List<File> mediaList) {
    _newSelectedMedia.addAll(mediaList);
    print("New media added: ${mediaList.map((file) => file.path)}");
    notifyListeners();
  }

  void removeSelectedMedia(AssetEntity media) {
    _selectedMedia.remove(media);
    notifyListeners();
  }

  void removeNewMedia(File media) {
    _newSelectedMedia.remove(media);
    notifyListeners();
  }

  void clearAllMedia() {
    _selectedMedia.clear();
    _newSelectedMedia.clear();
    notifyListeners();
  }
}