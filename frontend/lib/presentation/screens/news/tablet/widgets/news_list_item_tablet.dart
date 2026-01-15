import 'package:chungyak_box/domain/entities/content_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import

class NewsListItemTablet extends StatelessWidget {
  final ContentEntity item;

  const NewsListItemTablet({super.key, required this.item});

  // Add this helper method
  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView); // Changed to inAppWebView
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    String parseHtmlString(String htmlString) {
      return parse(htmlString).body?.text ?? '';
    }

    return GestureDetector( // Wrap with GestureDetector
      onTap: () => _launchURL(context, item.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20), // Increased vertical padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.press != null) ...[
                        Flexible(
                          child: Text(
                            item.press!,
                            style: textTheme.bodyMedium?.copyWith( // Increased font size
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6), // Increased horizontal padding
                          child: Text(
                            "|",
                            style: textTheme.bodyMedium?.copyWith( // Increased font size
                              color: colors.outline,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        DateFormat('yyyy.MM.dd').format(item.publishedAt),
                        style: textTheme.bodyMedium?.copyWith( // Increased font size
                          color: colors.onSurface.withValues(alpha: 0.6), // Corrected
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // Increased spacing
                  Text(
                    parseHtmlString(item.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith( // Increased font size
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6), // Increased spacing
                    Text(
                      parseHtmlString(item.subtitle!),
                      maxLines: 2, // Allow more lines for subtitle
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith( // Increased font size
                        color: colors.onSurface.withValues(alpha: 0.6), // Corrected
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.thumbnailUrl != null) ...[
              const SizedBox(width: 16), // Adjusted spacing
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // Adjusted border radius
                child: Image.network(
                  item.thumbnailUrl!,
                  width: 100.w, // Reduced thumbnail size
                  height: 100.w, // Reduced thumbnail size
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 100.w,
                      height: 100.w,
                      color: colors.secondaryContainer,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100.w, // Match new size
                    height: 100.w, // Match new size
                    color: colors.secondaryContainer,
                    child: Icon(
                      Icons.image_not_supported,
                      color: colors.onSecondaryContainer,
                      size: 40.sp, // Adjusted icon size
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
