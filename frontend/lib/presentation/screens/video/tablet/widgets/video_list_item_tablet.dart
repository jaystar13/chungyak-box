import 'package:chungyak_box/domain/entities/content_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for opening videos

class VideoListItemTablet extends StatelessWidget {
  final ContentEntity item;

  const VideoListItemTablet({super.key, required this.item});

  // Helper to format duration from ISO 8601 format (PTxMxS)
  String _formatDuration(String? isoDuration) {
    if (isoDuration == null) return '';

    final regex = RegExp(r'PT(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return '';

    final minutes = match.group(1) ?? '0';
    final seconds = match.group(2) ?? '0';

    final paddedSeconds = seconds.padLeft(2, '0');

    return '$minutes:$paddedSeconds';
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView); // Changed to inAppWebView
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영상을 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => _launchURL(context, item.url),
      child: Card( // Wrap with Card for better elevation and boundary
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column( // Changed from Row to Column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              alignment: Alignment.center,
              children: [
                // AspectRatio ensures the image keeps its shape
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    item.thumbnailUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colors.secondaryContainer,
                      child: Icon(
                        Icons.image_not_supported,
                        color: colors.onSecondaryContainer,
                        size: 40.sp,
                      ),
                    ),
                  ),
                ),
                // Play Icon
                Icon(
                  Icons.play_circle_fill,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 40.sp,
                ),
                // Duration
                if (item.videoMetadata?.duration != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(item.videoMetadata!.duration),
                        style: textTheme.labelMedium?.copyWith(color: Colors.white, fontSize: 12.sp),
                      ),
                    ),
                  ),
              ],
            ),
            // Text content
            Padding(
              padding: EdgeInsets.all(8.w), // Add padding for text content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith( // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.videoMetadata != null) ...[
                    Text(
                      item.videoMetadata!.channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith( // Adjusted font size
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (item.videoMetadata!.viewCount != null)
                      Text(
                        item.videoMetadata!.viewCount!,
                        style: textTheme.bodyMedium?.copyWith( // Adjusted font size
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
