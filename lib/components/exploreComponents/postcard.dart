import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../apis/addPost.dart';
import '../../firebase/usermodel/usermodel.dart';
import '../mydate.dart';

Future<Widget> PostCard(BuildContext context, Map<String, dynamic> postData) async {
  UserModel? user = await  addPost.fetchUserInformation( postData['userId']);
  final PageController _pageController = PageController();
  final mediaUrls = postData['mediaUrls'] ?? [];
  return Padding(
    padding: EdgeInsets.all(20.05),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Unknown User', // User ID
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            Text(
                              postData['location'] ??'',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                       Row(
                         children: [
                           Text(
                             MyDateUtil.timeAgo(postData['createdAt']),
                             style: const TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.w400,
                                 color: Colors.black38),
                           ),
                           IconButton(
                             onPressed: () {},
                             icon: const Icon(
                               Icons.more_vert_outlined,
                               color: Colors.black,
                             ),
                           )
                         ],
                       )
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0.5,
                    thickness: 2.0,
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0)),
                    child: mediaUrls.length > 1
                        ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          height: 320,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: mediaUrls.length,
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: mediaUrls[index],
                                width: double.infinity,
                                height: 320,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                const Center(
                                    child:
                                    CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      'assets/png_jpeg_images/kamal.JPG',
                                      fit: BoxFit.cover,
                                    ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 16, // Positioning the indicator above the bottom edge
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: mediaUrls.length,
                            effect: WormEffect(
                              dotWidth: 8,
                              dotHeight: 8,
                              activeDotColor: Colors.blueAccent,
                              dotColor: Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    )
                        : CachedNetworkImage(
                      imageUrl: mediaUrls.isNotEmpty
                          ? mediaUrls[0]
                          : '', // Display the first media URL
                      width: double.infinity,
                      height: 320,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/png_jpeg_images/kamal.JPG',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -25,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: user!.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(child: CupertinoActivityIndicator()),
                      errorWidget: (context, url, error) => Image.asset('assets/png_jpeg_images/user.png'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Row(
                children: const [
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 5),
                  Text(
                    '8.5K',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: const [
                  Icon(Icons.comment),
                  SizedBox(width: 5),
                  Text(
                    '321',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: const [
                  Icon(Icons.share),
                  SizedBox(width: 5),
                  Text(
                    '13',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.bookmark_border),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            postData['text'] ?? '', // Display the post text
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
