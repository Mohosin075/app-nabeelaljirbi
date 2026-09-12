import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_photos_controller.dart';

class ClinicPhotosScreen extends StatelessWidget {
  const ClinicPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClinicPhotosController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'photos'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D2D2D),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(IconsPath.backArrow),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchGallery(isRefresh: true),
                  color: AppColors.primaryColor,
                  child: Obx(() {
                    if (controller.isGalleryLoading.value &&
                        controller.galleryList.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (controller.galleryList.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'no_photos_yet'.tr,
                                    style: globalTextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return GridView.builder(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                      itemCount:
                          controller.galleryList.length +
                          (controller.hasMoreData.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.galleryList.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        final item = controller.galleryList[index];

                        return Obx(() {
                          final isSelected = controller.isSelected(item.id);

                          return GestureDetector(
                            onTap: () => controller.toggleSelection(item.id),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade100,
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.red,
                                            width: 2.5,
                                          )
                                        : null,
                                    image: item.image != null
                                        ? DecorationImage(
                                            image: NetworkImage(item.image!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.white.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.red
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isSelected ? Icons.check : Icons.close,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() {
                  final selectedCount = controller.selectedGalleryIds.length;
                  final isDeleteMode = selectedCount > 0;

                  return ElevatedButton(
                    onPressed: isDeleteMode
                        ? (controller.isDeleting.value
                              ? null
                              : controller.deleteSelectedPhotos)
                        : (controller.isUploading.value
                              ? null
                              : controller.pickAndUploadImages),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDeleteMode
                          ? Colors.red
                          : AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        (isDeleteMode
                            ? controller.isDeleting.value
                            : controller.isUploading.value)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isDeleteMode
                                ? '${'delete_photos'.tr} ($selectedCount)'
                                : 'add_photos'.tr,
                            style: globalTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
