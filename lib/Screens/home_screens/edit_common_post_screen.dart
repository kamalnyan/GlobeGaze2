import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../components/isDarkMode.dart';

class EditCommonPostScreen extends StatefulWidget {
  final String postId;

  const EditCommonPostScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<EditCommonPostScreen> createState() => _EditCommonPostScreenState();
}

class _EditCommonPostScreenState extends State<EditCommonPostScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> mediaUrls = [];
  List<File> newImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('CommanPosts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        final data = postDoc.data()!;
        setState(() {
          _textController.text = data['text'] ?? '';
          mediaUrls = List<String>.from(data['mediaUrls'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Post not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading post: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          newImages.addAll(pickedFiles.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<List<String>> _uploadNewImages() async {
    List<String> uploadedUrls = [];
    try {
      for (File imageFile in newImages) {
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${widget.postId}_$fileName.jpg');

        await ref.putFile(imageFile);
        final String downloadUrl = await ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading images: $e')),
      );
    }
    return uploadedUrls;
  }

  Future<void> _updatePost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new images if any
      List<String> newUrls = await _uploadNewImages();
      
      // Combine existing and new URLs
      List<String> allMediaUrls = [...mediaUrls, ...newUrls];

      await FirebaseFirestore.instance
          .collection('CommanPosts')
          .doc(widget.postId)
          .update({
        'text': _textController.text,
        'mediaUrls': allMediaUrls,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating post: $e';
        _isLoading = false;
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      mediaUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      newImages.removeAt(index);
    });
  }

  Widget _buildImageGrid() {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context) 
            ? primaryDarkBlue.withOpacity(0.1)
            : neutralLightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Images',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor(context),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: mediaUrls.length + newImages.length + 1,
            itemBuilder: (context, index) {
              if (index == mediaUrls.length + newImages.length) {
                // Add button
                return InkWell(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode(context)
                          ? primaryDarkBlue.withOpacity(0.2)
                          : neutralLightGrey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode(context)
                            ? primaryDarkBlue.withOpacity(0.3)
                            : neutralLightGrey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 32,
                          color: isDarkMode(context)
                              ? primaryDarkBlue
                              : neutralLightGrey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode(context)
                                ? primaryDarkBlue
                                : neutralLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (index < mediaUrls.length) {
                // Existing images
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: mediaUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: isDarkMode(context)
                              ? primaryDarkBlue.withOpacity(0.1)
                              : neutralLightGrey.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDarkMode(context)
                              ? primaryDarkBlue.withOpacity(0.1)
                              : neutralLightGrey.withOpacity(0.1),
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // New images
                final newImageIndex = index - mediaUrls.length;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        newImages[newImageIndex],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(newImageIndex),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? primaryDarkBlue : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode(context) ? primaryDarkBlue : Colors.white,
        elevation: 0,
        title: Text(
          'Edit Post',
          style: TextStyle(
            color: textColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                Icons.check_circle,
                color: isDarkMode(context) ? Colors.white : primaryDarkBlue,
              ),
              onPressed: _updatePost,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDarkMode(context) ? Colors.white : primaryDarkBlue,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: textColor(context),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode(context)
                              ? primaryDarkBlue.withOpacity(0.1)
                              : neutralLightGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _textController,
                          style: TextStyle(
                            color: textColor(context),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write your post...',
                            hintStyle: TextStyle(
                              color: hintColor(context),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildImageGrid(),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
} 