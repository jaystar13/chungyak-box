import '../../domain/entities/news_item.dart';
import '../../domain/entities/video_item.dart';

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
