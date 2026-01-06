import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// Constants & Theme
// -----------------------------------------------------------------------------
const Color kThemeGreen = Color(0xFFB2E4B2); // Header light green
const Color kButtonGreen = Color(0xFF3F6F44); // Button dark green
const Color kGreen700 = Color(0xFF15803D); // Text green (Tailwind green-700)
const Color kGray50 = Color(0xFFF9FAFB);
const Color kGray100 = Color(0xFFF3F4F6);
const Color kGray200 = Color(0xFFE5E7EB);
const Color kGray400 = Color(0xFF9CA3AF);
const Color kGray500 = Color(0xFF6B7280);
const Color kGray900 = Color(0xFF111827);

// -----------------------------------------------------------------------------
// Models & Mock Data
// -----------------------------------------------------------------------------
class NewsItem {
  final int id;
  final String title;
  final String summary;
  final String source;
  final String date;
  final String imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.date,
    required this.imageUrl,
  });
}

class VideoItem {
  final int id;
  final String title;
  final String channel;
  final String views;
  final String thumbnailUrl;
  final String duration;
  final String date;

  VideoItem({
    required this.id,
    required this.title,
    required this.channel,
    required this.views,
    required this.thumbnailUrl,
    required this.duration,
    required this.date,
  });
}

// Mock Data
final List<NewsItem> kNewsItems = [
  NewsItem(
    id: 1,
    title: "공공분양 '뉴홈' 4차 사전청약 1만호 공급",
    summary: "서울 대방, 마곡, 화성 동탄 등 알짜 입지 대거 포함... 나눔형 80% 공급",
    source: "부동산뉴스",
    date: "2025.12.31",
    imageUrl:
        "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&q=80",
  ),
  NewsItem(
    id: 2,
    title: "청약통장 월 납입 인정액 25만원으로 상향",
    summary: "공공분양 당첨 커트라인 변동 예상... 전략 수정 필수",
    source: "청약인사이트",
    date: "2025.12.28",
    imageUrl:
        "https://images.unsplash.com/photo-1554224155-98406856d03a?w=800&q=80",
  ),
  NewsItem(
    id: 3,
    title: "3기 신도시 본청약 지연, 사전청약 당첨자 대책은?",
    summary: "본청약 지연에 따른 희망고문 논란... 국토부 대응 방안 발표",
    source: "데일리부동산",
    date: "2025.12.20",
    imageUrl:
        "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80",
  ),
  NewsItem(
    id: 4,
    title: "서울 아파트 분양가 계속 상승, '지금이 기회'?",
    summary: "건축비 상승으로 인한 분양가 인상 불가피... 청약 대기자들의 고민 깊어져",
    source: "경제투데이",
    date: "2025.12.29",
    imageUrl:
        "https://images.unsplash.com/photo-1591189327425-978d52361141?w=800&q=80",
  ),
  NewsItem(
    id: 5,
    title: "신생아 특례대출 금리 인하, 내 집 마련 기회 확대",
    summary: "정부, 출산 장려를 위한 파격적인 금리 혜택 제공... 소득 요건 완화",
    source: "주택금융뉴스",
    date: "2025.12.15",
    imageUrl:
        "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=800&q=80",
  ),
];

final List<VideoItem> kVideoItems = [
  VideoItem(
    id: 1,
    title: "2026년 공공분양 당첨 전략 총정리",
    channel: "청약의신",
    views: "15만회",
    thumbnailUrl:
        "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800&q=80",
    duration: "10:25",
    date: "2025.12.30",
  ),
  VideoItem(
    id: 2,
    title: "일반공급 vs 특별공급, 나에게 유리한 유형은?",
    channel: "부동산읽어주는남자",
    views: "8.2만회",
    thumbnailUrl:
        "https://images.unsplash.com/photo-1593672741392-72a7d506d30b?w=800&q=80",
    duration: "08:15",
    date: "2025.12.25",
  ),
  VideoItem(
    id: 3,
    title: "청약 가점 계산법, 실수하면 부적격 당첨 취소!",
    channel: "재테크TV",
    views: "5만회",
    thumbnailUrl:
        "https://images.unsplash.com/photo-1611974765270-ca1258634369?w=800&q=80",
    duration: "12:30",
    date: "2025.12.10",
  ),
];

// Date Utility
final DateTime kToday = DateTime(2026, 1, 1);

bool isRecent(String dateString) {
  final dateParts = dateString.split('.');
  final date = DateTime(
    int.parse(dateParts[0]),
    int.parse(dateParts[1]),
    int.parse(dateParts[2]),
  );
  final diff = kToday.difference(date).inDays.abs();
  return diff <= 7;
}

// -----------------------------------------------------------------------------
// App Entry & Main Layout
// -----------------------------------------------------------------------------
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Global State for Navigation and Viewed Items
  String _currentPage = 'home';
  final Set<String> _viewedItems = {};

  void _navigateTo(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _markAsViewed(String id) {
    setState(() {
      _viewedItems.add(id);
    });
  }

  int get _unreadCount {
    int count = 0;
    for (var item in kNewsItems) {
      if (isRecent(item.date) && !_viewedItems.contains('news-${item.id}')) {
        count++;
      }
    }
    for (var item in kVideoItems) {
      if (isRecent(item.date) && !_viewedItems.contains('video-${item.id}')) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '청약계산소',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard', // Assuming a Korean font is used
        useMaterial3: true,
      ),
      home: AppLayout(
        title: _currentPage == 'home' ? '' : '부동산 뉴스',
        showBack: _currentPage != 'home',
        onBack: () => _navigateTo('home'),
        currentTab: _currentPage,
        child: _currentPage == 'home'
            ? HomeScreen(onNavigate: _navigateTo, unreadCount: _unreadCount)
            : NewsScreen(viewedItems: _viewedItems, onItemView: _markAsViewed),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Components
// -----------------------------------------------------------------------------

class AppLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showBack;
  final VoidCallback onBack;
  final String currentTab;

  const AppLayout({
    super.key,
    required this.child,
    required this.title,
    required this.showBack,
    required this.onBack,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kThemeGreen,
        elevation: 0,
        leadingWidth: showBack ? 80 : 0,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: kGray900),
                onPressed: onBack,
              )
            : const SizedBox(),
        title: Row(
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  color: kGray900,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: kGray900),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kGray200)),
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTabItem(
                icon: Icons.home,
                label: "홈",
                isActive: currentTab == 'home',
                onTap: showBack ? onBack : () {},
              ),
              _buildTabItem(
                icon: Icons.newspaper,
                label: "뉴스/큐레이션",
                isActive: currentTab == 'news',
                onTap: () {}, // Already highlighting current or can nav
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isActive ? kGreen700 : kGray400),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? kGreen700 : kGray400,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Function(String) onNavigate;
  final int unreadCount;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Calculator Card
          Card(
            color: const Color(0xFFF2F5F0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Calc Representation
                  SizedBox(
                    width: 96,
                    child: Column(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: kGray400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 1.5,
                              ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: index == 11
                                    ? Colors.orangeAccent
                                    : kGray500,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "청약 인정금액",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kGray900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "공공분양 당첨 전략의 필수 조건, 나의 청약 인정 금액을 미리 확인해보세요.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kButtonGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "계산기로 이동",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // News Entry Card
          GestureDetector(
            onTap: () => onNavigate('news'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGray100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green[50], // green-100 equivalent
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.newspaper, color: kGreen700),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "부동산 청약 뉴스",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kGray900,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unreadCount > 0
                              ? "최근 1주일간 $unreadCount개의 새 소식이 있어요!"
                              : "공공분양 소식과 영상 콘텐츠를 확인하세요",
                          style: const TextStyle(fontSize: 12, color: kGray500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: kGray400,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kGray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                "광고 영역",
                style: TextStyle(fontSize: 12, color: kGray400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  final Set<String> viewedItems;
  final Function(String) onItemView;

  const NewsScreen({
    super.key,
    required this.viewedItems,
    required this.onItemView,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "청약 큐레이션",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kGray900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "공공분양 특화",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kGreen700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Custom Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: kGray100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            labelColor: kGray900,
            unselectedLabelColor: kGray500,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: "뉴스"),
              Tab(text: "영상"),
            ],
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // News Tab (Compact List)
              ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: kNewsItems.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: kGray100),
                itemBuilder: (context, index) {
                  final item = kNewsItems[index];
                  final isViewed = widget.viewedItems.contains(
                    'news-${item.id}',
                  );
                  final isRecentItem = isRecent(item.date);

                  return InkWell(
                    onTap: () => widget.onItemView('news-${item.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Opacity(
                        opacity: isViewed ? 0.7 : 1.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.source,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isViewed
                                              ? kGray500
                                              : kGreen700,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          "|",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.date,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: kGray400,
                                        ),
                                      ),
                                      if (isRecentItem && !isViewed) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                          child: const Text(
                                            "NEW",
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (isViewed) ...[
                                        const SizedBox(width: 4),
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              size: 12,
                                              color: kGray400,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              "읽음",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: kGray400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isViewed ? kGray500 : kGray900,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.summary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: kGray500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Thumbnail
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: kGray200,
                                image: DecorationImage(
                                  image: NetworkImage(item.imageUrl),
                                  fit: BoxFit.cover,
                                  colorFilter: isViewed
                                      ? const ColorFilter.mode(
                                          Colors.grey,
                                          BlendMode.saturation,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Video Tab
              ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: kVideoItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = kVideoItems[index];
                  final isViewed = widget.viewedItems.contains(
                    'video-${item.id}',
                  );
                  final isRecentItem = isRecent(item.date);

                  return InkWell(
                    onTap: () => widget.onItemView('video-${item.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isViewed ? kGray50 : Colors.white,
                        border: Border.all(color: kGray100),
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
                                    child: ColorFiltered(
                                      colorFilter: isViewed
                                          ? const ColorFilter.mode(
                                              Colors.grey,
                                              BlendMode.saturation,
                                            )
                                          : const ColorFilter.mode(
                                              Colors.transparent,
                                              BlendMode.multiply,
                                            ),
                                      child: Image.network(
                                        item.thumbnailUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isViewed
                                          ? Colors.black38
                                          : Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                if (isViewed)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.green.withOpacity(0.8),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "시청함",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else ...[
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.duration,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isRecentItem)
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                        child: const Text(
                                          "N",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isViewed ? kGray500 : kGray900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.channel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kGray500,
                                  ),
                                ),
                                Text(
                                  "조회수 ${item.views}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kGray400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
