import 'package:chungyak_box/domain/entities/content_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for opening videos

class VideoListItem extends StatelessWidget {
  final ContentEntity item;

  const VideoListItem({super.key, required this.item});

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
      await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
      ); // Changed to inAppWebView
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('영상을 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => _launchURL(context, item.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.thumbnailUrl ?? '',
                    width: 120.w,
                    height: 70.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120.w,
                      height: 70.w,
                      color: colors.secondaryContainer,
                      child: Icon(
                        Icons.image_not_supported,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                // Play Icon
                Icon(
                  Icons.play_circle_fill,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 30.sp,
                ),
                // Duration
                if (item.videoMetadata?.duration != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(item.videoMetadata!.duration),
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
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
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (item.videoMetadata!.viewCount != null)
                      Text(
                        item.videoMetadata!.viewCount!,
                        style: textTheme.bodySmall?.copyWith(
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
