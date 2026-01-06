import 'package:chungyak_box/domain/entities/video_item.dart';
import 'package:flutter/material.dart';

class VideoListItem extends StatelessWidget {
  final VideoItem item;
  final bool isViewed;
  final bool isRecent;

  const VideoListItem({
    super.key,
    required this.item,
    this.isViewed = false,
    this.isRecent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isViewed ? colors.secondaryContainer.withOpacity(0.2) : colors.surface,
        border: Border.all(color: colors.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          SizedBox(
            width: 120,
            height: 68,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.thumbnailUrl,
                      fit: BoxFit.cover,
                      color: isViewed ? Colors.grey : null,
                      colorBlendMode: isViewed ? BlendMode.saturation : null,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: colors.secondaryContainer,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: colors.secondaryContainer,
                        child: Icon(Icons.videocam_off, color: colors.onSecondaryContainer),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isViewed ? Colors.black38 : Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                  ),
                ),
                if (isViewed)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "시청함",
                            style: textTheme.labelSmall?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isViewed) ...[
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.duration,
                        style: textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  if (isRecent)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "NEW",
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isViewed ? colors.onSurface.withOpacity(0.6) : colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.channel,
                  style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(0.7)),
                ),
                Text(
                  "조회수 ${item.views}",
                  style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
