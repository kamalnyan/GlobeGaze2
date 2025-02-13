import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  int currentIndex = 0;
  final List<String> imageUrls = [
    'assets/png_jpeg_images/Rashi.jpg',
    'assets/png_jpeg_images/Rashi.jpg',
    'assets/png_jpeg_images/Rashi.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0, left: 7, right: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                    'assets/png_jpeg_images/Rashi.jpg'), // Change to network image if needed
              ),
              title: Text(
                'anny_wilson',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Marketing Coordinator'),
              trailing: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Icon(FontAwesomeIcons.ellipsis, color: Colors.black, size: 13),
              ) ,
            ),

            // Image Section with PageView
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(
                          imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: MediaQuery.of(context).size.width / 2.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imageUrls.length,
                          (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        width: currentIndex == index ? 8 : 6,
                        height: currentIndex == index ? 8 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentIndex == index ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(width: 5),
                      Text('44,389'),
                      SizedBox(width: 20), // Added space between favorite and comment icons
                      Icon(Icons.comment, color: Colors.grey),
                      SizedBox(width: 5),
                      Text('26,376'),
                    ],
                  ),
                  Spacer(), // Pushes the bookmark icon to the right
                  Icon(Icons.bookmark_border, color: Colors.black),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
