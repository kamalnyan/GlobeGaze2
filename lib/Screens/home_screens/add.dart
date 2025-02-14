import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../Providers/postProviders/imageMediaProviders.dart';
import '../../Providers/postProviders/locationProvider.dart';
import '../../apis/APIs.dart';
import '../../apis/addPost.dart';
import '../../components/isDarkMode.dart';
import '../../components/postComponents/groupExplorer.dart';
import '../../components/postComponents/standrdPost.dart';
import '../../themes/colors.dart';
import 'package:path_provider/path_provider.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});
  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _travelersCountController = TextEditingController();
  List<Map<String, dynamic>> _savedDrafts = [];
  late MediaProvider mediaProvider;
  late LocationProvider locationProvider;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
    _loadDrafts(Apis.uid);
  }

  bool _isToggled = false;
  DateTime? _startDate;
  DateTime? _endDate;
  final ValueNotifier<double> _uploadProgress = ValueNotifier(0.0);
  bool _isUploading = false;
  bool _isDraftSaved = false;

  @override
  void dispose() {
    _postController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _travelersCountController.dispose();
    _uploadProgress.dispose();
    super.dispose();
  }
  void deleteDraftWrapper(Map<String, dynamic> draft) {
    _deleteDraft(draft, Apis.uid);
  }

  void _showDraftListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Drafts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedDrafts.length,
            itemBuilder: (context, index) {
              final draft = _savedDrafts[index];
              final mediaFiles = draft['mediaFiles'] != null
                  ? draft['mediaFiles'] as List<File>
                  : [];
              final mediaCount = mediaFiles.length;
              final displayCount = mediaCount > 4 ? 4 : mediaCount;

              return GestureDetector(
                onTap: () {
                  _handleDraftSelection(draft);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(draft['text'] ?? 'No content'),
                      subtitle: Text(draft['location'] ?? 'No location'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteDraft(draft, Apis.uid),
                      ),
                    ),
                    if (mediaFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: displayCount,
                          itemBuilder: (context, i) {
                            return FutureBuilder<Uint8List?>(
                              future: mediaFiles[i]
                                  .readAsBytes(), // Load the file data as Uint8List
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: Image.memory(snapshot.data!,
                                            fit: BoxFit.cover),
                                      ),
                                      if (i == 3 && mediaCount > 4)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '+${mediaCount - 4}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }
                                return const CupertinoActivityIndicator(
                                    radius: 15.0);
                              },
                            );
                          },
                        ),
                      ),
                    const Divider(), // Add divider between drafts
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleDraftSelection(Map<String, dynamic> draft) {
    setState(() {
      _postController.text = draft['text'] ?? '';
      locationProvider.setSelectedLocation(draft['location']);
      mediaProvider.addNewMedia(draft['mediaPaths']
          .map<File>((path) => File(path as String))
          .toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    void callSett() {
      setState(() {});
    }
     locationProvider = Provider.of<LocationProvider>(context);
    return ChangeNotifierProvider(
      create: (_) => MediaProvider(),
      child: WillPopScope(
        onWillPop: () async {
          if (_isUploading) return false;
          return _showSaveDraftDialog();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: isDarkMode(context)?darkBackground:Colors.white,
            title:  Text('Create Post',style: TextStyle(color: textColor(context)),),
            actions: [
              TextButton(
                onPressed: _handlePost,
                child: const Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: PrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          body: Consumer<MediaProvider>(
            builder: (context, provider, child) {
              mediaProvider = provider; // Access MediaProvider
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileRow(),
                        if (_isToggled)
                          buildCreatePostForm(context, _selectDate, _endDate, _startDate)
                        else
                          buildStandardPost(
                            context,
                            _postController,
                            () => _pickAssets(mediaProvider),
                            _showDraftListDialog,
                          ),
                      ],
                    ),
                  ),
                  if (_isUploading) _buildCenteredProgressIndicator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _saveDraft(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationDocumentsDirectory();
    List<String> mediaPaths = [];

    for (var media in mediaProvider.selectedMedia) {
      final mediaFile = await media.file;
      if (mediaFile != null) {
        final fileName = '${media.id}.jpg';
        final filePath = '${appDir.path}/$fileName';

        // Copy the file and add the path to mediaPaths
        await mediaFile.copy(filePath);
        mediaPaths.add(filePath); // Adding file path as a String
      } else {
        print("File not found for media: ${media.id}");
      }
    }

    print("Final mediaPaths: $mediaPaths");

    // Create the draft map with mediaPaths as List<String> (paths only, not File objects)
    Map<String, dynamic> draft = {
      'uid': uid,
      'text': _postController.text.trim(),
      'mediaPaths': mediaPaths,
      'location': locationProvider.selectedLocation??"Unknown",
    };

    print("Draft object: $draft");

    // Ensure _savedDrafts contains only JSON-encodable data
    _savedDrafts = _savedDrafts.map((d) {
      return {
        'uid': d['uid'],
        'text': d['text'],
        'mediaPaths': List<String>.from(d['mediaPaths'] ?? []),
        'location': d['location']?.toString(),
      };
    }).toList();

    // Update UI state and clear inputs
    setState(() {
      _isDraftSaved = true;
      _savedDrafts.add(draft);
      _postController.clear();
      locationProvider.setSelectedLocation("");
    });

    // Convert each draft to a JSON string and save in SharedPreferences
    List<String> drafts = _savedDrafts.map((d) => json.encode(d)).toList();
    bool success = await prefs.setStringList('savedDrafts', drafts);

    return success;
  }

  Future<bool> _showSaveDraftDialog() async {
    if (_postController.text.isEmpty && mediaProvider.selectedMedia.isEmpty)
      return true;
    bool saveAsDraft = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save Draft'),
            content: const Text('Do you want to save this post as a draft?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Discard'),
              ),
              TextButton(
                onPressed: () async {
                  bool saved = await _saveDraft(
                      Apis.uid); // Await and check the save result
                  Navigator.pop(context, saved);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
    if (!saveAsDraft) {
      setState(() => _isDraftSaved = false);
    }
    return saveAsDraft;
  }

  Future<List<Map<String, dynamic>>> _compressMedia(
      MediaProvider mediaProvider) async {
    List<Map<String, dynamic>> mediaFiles = [];
    // Compress and add AssetEntity images
    for (var media in mediaProvider.selectedMedia) {
      if (media.type == AssetType.image) {
        Uint8List? imageData = await media.originBytes;
        if (imageData != null) {
          Uint8List compressedImage =
              await _compressImage(imageData, 1024 * 1024); // compress to 1MB
          mediaFiles.add({'type': 'image', 'data': compressedImage});
        }
      } else if (media.type == AssetType.video) {
      }
    }
    // Compress and add File images
    for (var mediaFile in mediaProvider.newSelectedMedia) {
      if (mediaFile.existsSync()) {
        Uint8List imageData = await mediaFile.readAsBytes();
        Uint8List compressedImage =
            await _compressImage(imageData, 1024 * 1024);
        mediaFiles.add({'type': 'image', 'data': compressedImage});
      }
    }
    return mediaFiles;
  }
  Future<void> _loadDrafts(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? drafts = prefs.getStringList('savedDrafts');
    if (drafts != null) {
      setState(() {
        _savedDrafts = drafts
            .map((d) {
              final draft = json.decode(d) as Map<String, dynamic>;
              if (draft['uid'] != uid) return null;
              draft['mediaFiles'] = (draft['mediaPaths'] as List<dynamic>)
                  .map((path) => File(path as String))
                  .toList();
              return draft;
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      });
    }
  }
  Future<void> _deleteDraft(Map<String, dynamic> draft, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (draft['uid'] != uid) return;
    for (var path in draft['mediaPaths']) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    setState(() {
      _savedDrafts.remove(draft);
    });
    List<String> drafts = _savedDrafts.map((d) => json.encode(d)).toList();
    await prefs.setStringList('savedDrafts', drafts);
  }
  Widget _buildProfileRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: Apis.me.image,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CupertinoActivityIndicator()),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/png_jpeg_images/user.png'),
              ),
            ),
          ),
          Column(
            children: [
              CupertinoSwitch(
                value: _isToggled,
                onChanged: (bool value) {
                  setState(() => _isToggled = value);
                },
              ),
               Text(
                'Group Explorer',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: hintColor(context)),
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildCenteredProgressIndicator() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black54, // Semi-transparent background covering full screen
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<double>(
            valueListenable: _uploadProgress,
            builder: (context, progress, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progress,
                      color:
                          CupertinoColors.activeBlue, // Cupertino-style color
                      backgroundColor: Colors.white70,
                      strokeWidth: 3.0, // Adjust thickness for Cupertino look
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%", // Show progress percentage
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  Future<void> _handlePost() async {
    setState(() => _isUploading = true);
    _uploadProgress.value = 0.0;
    List<Map<String, dynamic>> compressedMedia =
        await _compressMedia(mediaProvider);
    String postText = _postController.text.trim();
    try {
      await addPost.uploadPostToFirebase(
        postText,
        compressedMedia,
        locationProvider.selectedLocation ,
        onProgress: (progress) {
          _uploadProgress.value = progress;
        },
      );
      _showSuccessDialog();
    } catch (error) {
      print("Error uploading post: $error");
    } finally {
      setState(() => _isUploading = false);
    }
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Successful'),
        content: const Text('Your post has been uploaded successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: PrimaryColor)),
          ),
        ],
      ),
    );
  }
  Future<Uint8List> _compressImage(Uint8List imageData, int maxSize) async {
    img.Image? image = img.decodeImage(imageData);
    if (image == null) return imageData;
    img.Image resizedImage = img.copyResize(image, width: 1024);
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 80));
  }
  Future<void> _pickAssets(MediaProvider mediaProvider) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: 5,
      ),
    );
    if (result != null) {
      for (var media in result) {
        mediaProvider.addSelectedMedia(media);
      }
    }
  }
  Future<void> _requestStoragePermission() async {
    await Permission.storage.request();
  }
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }
}
