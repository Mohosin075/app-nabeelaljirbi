import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/view/patient_popular_doctor_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/widget/video_banner_item.dart';

class BannerSlider extends StatefulWidget {
  final List<String> mediaUrls;
  const BannerSlider({super.key, required this.mediaUrls});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  Timer? _timer;

  bool _isVideo(String url) {
    return url.endsWith('.mp4') || url.contains('video');
  }

  @override
  void initState() {
    super.initState();
    // Start timer for the first item if it's not a video
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    final currentUrl = widget.mediaUrls[_currentIndex];

    if (!_isVideo(currentUrl)) {
      // It's an image, wait 5 seconds then swap
      _timer = Timer(const Duration(seconds: 5), () {
        _carouselController.nextPage();
      });
    }
    // If it's a video, VideoBannerItem will trigger onCompleted to call nextPage
  }

  void _onVideoCompleted() {
    _carouselController.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 175,
            viewportFraction: 1.0,
            autoPlay: false, // Convert to manual control
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              _startAutoPlay();
            },
          ),
          items: widget.mediaUrls.asMap().entries.map((entry) {
            final int index = entry.key;
            final String url = entry.value;
            final bool isCurrent = index == _currentIndex;

            return Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _isVideo(url)
                              ? VideoBannerItem(
                                  videoUrl: url,
                                  shouldPlay: isCurrent,
                                  onCompleted: _onVideoCompleted,
                                )
                              : CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff137CCF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => PatientPopularDoctorScreen());
                              },
                              child: Text(
                                'book_now'.tr,
                                style: globalTextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.mediaUrls.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.blue)
                        .withValues(
                          alpha: _currentIndex == entry.key ? 0.9 : 0.4,
                        ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
