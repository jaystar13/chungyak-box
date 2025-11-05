from fastapi.testclient import TestClient

from app.core.config import settings
from app.main import app

client = TestClient(app)


def test_normal_schedule():
    """
    정상 납입내역 생성 API 테스트
    """
    payload = {"open_date": "2025-01-01", "due_day": 10, "end_date": "2025-06-30"}

    response = client.post(f"{settings.API_V1_STR}/payments/normal", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert data["total_installments"] == 6
    assert len(data["payments"]) == 6

    # 1번째 납입내역 검증
    first_payment = data["payments"][0]
    assert first_payment["installment_no"] == 1
    assert first_payment["due_date"] == "2025-01-10"
    assert first_payment["paid_date"] == "2025-01-10"
    assert first_payment["delay_days"] == 0
    assert first_payment["total_delay_days"] == 0
    assert first_payment["prepaid_days"] == 0
    assert first_payment["total_prepaid_days"] == 0
    assert first_payment["recognized_date"] == "2025-01-10"


def test_recalc_schedule_with_delays():
    """
    납입내역 재계산 API 테스트 - 지연 납입
    """
    payload = {
        "payments": [
            {
                "installment_no": 1,
                "due_date": "2025-01-01",
                "paid_date": "2025-01-01",
            },
            {
                "installment_no": 2,
                "due_date": "2025-02-01",
                "paid_date": "2025-02-10",  # 9일 연체
            },
        ]
    }

    response = client.post(f"{settings.API_V1_STR}/payments/recalc", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert data["total_installments"] == 2
    assert len(data["payments"]) == 2

    second = data["payments"][1]
    assert second["delay_days"] == 9
    assert second["total_delay_days"] == 9
    assert second["recognized_date"] > second["due_date"]  # 인정일이 뒤로 밀렸는지 확인
