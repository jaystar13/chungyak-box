# 애플리케이션 아키텍처 설명

이 애플리케이션은 **클린 아키텍처(Clean Architecture)** 원칙을 기반으로 설계 및 리팩토링되었습니다. 클린 아키텍처는 애플리케이션을 여러 계층으로 나누어 각 계층이 독립적인 역할을 수행하도록 하여, 코드의 유지보수성, 테스트 용이성, 그리고 유연성을 극대화하는 것을 목표로 합니다.

---

### **현재 애플리케이션 구조**

애플리케이션은 크게 다음의 계층들로 구성됩니다.

1.  **Domain Layer (비즈니스 로직의 핵심)**
2.  **Data Layer (데이터 처리)**
3.  **Presentation Layer (UI 및 사용자 상호작용)**
4.  **Core Layer (공통 유틸리티)**
5.  **Dependency Injection (의존성 주입)**
6.  **Routing (화면 이동)**

각 계층의 역할과 구성 요소는 다음과 같습니다.

---

#### **1. Domain Layer (`lib/domain`)**

*   **목적:** 애플리케이션의 핵심 비즈니스 로직을 담고 있으며, 어떤 프레임워크나 외부 요소에도 의존하지 않는 가장 순수한 계층입니다.
*   **구성 요소:**
    *   `entities/`:
        *   `PaymentEntity`, `PaymentScheduleEntity`: 비즈니스 로직에서 사용되는 핵심 데이터 객체입니다. `equatable`을 사용하여 값 비교를 용이하게 합니다.
    *   `repositories/`:
        *   `CalculatorRepository`: 데이터 계층이 구현해야 할 계약(인터페이스)을 정의합니다. "어떤 데이터를 어떻게 가져올 것인가"에 대한 추상적인 정의만 포함합니다.
    *   `usecases/`:
        *   `GeneratePaymentScheduleUseCase`, `RecalculateScheduleUseCase`: 특정 비즈니스 규칙을 캡슐화하고, Repository 인터페이스를 통해 데이터 작업을 조율합니다. 이들은 비즈니스 로직의 진입점입니다.
*   **의존성:** Data Layer나 Presentation Layer에 전혀 의존하지 않습니다. 오직 Domain Layer 내의 다른 구성 요소에만 의존합니다.

---

#### **2. Data Layer (`lib/data`)**

*   **목적:** Domain Layer에서 정의한 계약(Repository 인터페이스)을 실제로 구현하여 데이터를 가져오거나 저장하는 역할을 합니다. 외부 데이터 소스(API, 데이터베이스 등)와의 통신을 담당합니다.
*   **구성 요소:**
    *   `datasources/`:
        *   `ApiServices`: 외부 API와의 직접적인 통신을 처리합니다. HTTP 요청을 보내고 응답을 받습니다.
    *   `models/`:
        *   `PaymentModel`, `PaymentScheduleModel`, `CalculatorRequestModel`, `PaymentScheduleRequestModel`: API의 데이터 구조를 반영하는 데이터 전송 객체(DTO)입니다. `fromJson`/`toJson` 메서드를 통해 JSON 직렬화/역직렬화를 처리합니다.
    *   `mapper/`:
        *   `payment_mapper.dart`: Data Layer의 `Model` 객체를 Domain Layer의 `Entity` 객체로, 또는 그 반대로 변환하는 확장 메서드를 제공합니다.
    *   `repositories/`:
        *   `CalculatorRepositoryImpl`: `CalculatorRepository` 인터페이스의 구체적인 구현체입니다. `ApiServices`를 통해 데이터를 가져오고, 매퍼를 사용하여 `Model`을 `Entity`로 변환하여 Domain Layer에 전달합니다.
*   **의존성:** Domain Layer(인터페이스 및 엔티티)와 외부 패키지(`http`)에 의존합니다.

---

#### **3. Presentation Layer (`lib/presentation`)**

*   **목적:** 사용자 인터페이스를 담당하고, 사용자 입력을 받아 비즈니스 로직을 트리거하며, 비즈니스 로직의 결과를 화면에 표시합니다.
*   **구성 요소:**
    *   `screens/`:
        *   `CalculatorScreen`, `PaymentDetailScreen`, `HomeScreen`: 실제 사용자에게 보여지는 UI 화면 위젯들입니다. `CalculatorScreen`은 이제 `StatelessWidget`으로, BLoC의 상태에 따라 화면을 그립니다.
    *   `viewmodels/`:
        *   `CalculatorBloc`, `CalculatorEvent`, `CalculatorState`: BLoC(Business Logic Component) 패턴을 구현합니다. `CalculatorEvent` (사용자 행동)를 입력으로 받아 `CalculatorState` (UI 상태)를 출력으로 내보냅니다. Domain Layer의 UseCase에 의존하여 비즈니스 로직을 수행합니다.
    *   `widgets/`:
        *   `InfoRow` 등: 재사용 가능한 UI 컴포넌트들입니다.
*   **의존성:** Domain Layer(UseCase, Entity)와 외부 패키지(`flutter_bloc`, `flutter_screenutil`)에 의존합니다.

---

#### **4. Core Layer (`lib/core`)**

*   **목적:** 애플리케이션 전반에 걸쳐 사용되는 공통 유틸리티, 헬퍼 클래스, 추상화 등을 포함합니다.
*   **구성 요소:**
    *   `Result` 클래스: 비동기 작업의 성공/실패 결과를 표현하는 데 사용됩니다.
    *   `app_theme.dart`, `responsive.dart`: 앱의 테마, 반응형 UI 관련 유틸리티 등.
*   **의존성:** 최소화되어 있으며, 주로 Dart/Flutter의 기본 기능에만 의존합니다.

---

#### **5. Dependency Injection (`lib/di`)**

*   **목적:** 애플리케이션의 각 구성 요소들이 서로에게 직접 의존하는 대신, 외부에서 의존성을 주입받도록 관리합니다. 이를 통해 결합도를 낮추고 테스트 용이성을 높입니다.
*   **구성 요소:**
    *   `injection.dart`, `injection.config.dart` (자동 생성): `get_it`과 `injectable` 패키지를 사용하여 의존성을 등록하고 필요한 곳에 제공합니다.
*   **의존성:** 모든 계층의 구성 요소들을 연결하기 위해 모든 계층에 의존합니다.

---

#### **6. Routing (`lib/routes`)**

*   **목적:** 애플리케이션 내의 화면 이동 로직을 관리합니다.
*   **구성 요소:**
    *   `app_routes.dart`: `generateRoute` 메서드를 통해 모든 라우트 정의와 화면 생성 로직을 중앙에서 관리합니다.

---

### **제어 흐름 예시: 납입 일정 생성**

1.  **UI (Presentation Layer):** 사용자가 `CalculatorScreen`에서 날짜를 입력하고 '생성' 버튼을 누릅니다.
2.  **Event (Presentation Layer):** `CalculatorScreen`은 `GenerateSchedule` 이벤트를 생성하여 `CalculatorBloc`에 전달합니다.
3.  **Bloc (Presentation Layer):** `CalculatorBloc`은 `GenerateSchedule` 이벤트를 받으면, 먼저 `CalculatorLoading` 상태를 UI에 전달합니다.
4.  **UseCase (Domain Layer):** `CalculatorBloc`은 `GeneratePaymentScheduleUseCase`를 호출하여 비즈니스 로직을 시작합니다.
5.  **Repository Interface (Domain Layer):** `GeneratePaymentScheduleUseCase`는 `CalculatorRepository` 인터페이스의 `generatePaymentSchedule` 메서드를 호출합니다.
6.  **Repository Implementation (Data Layer):** `CalculatorRepositoryImpl`이 `generatePaymentSchedule` 호출을 받습니다.
7.  **Model (Data Layer):** `CalculatorRepositoryImpl`은 `CalculatorRequestModel`을 생성하고, `ApiServices`를 호출합니다.
8.  **DataSource (Data Layer):** `ApiServices`는 HTTP 요청을 보내고, 응답으로 `PaymentScheduleModel`을 받습니다.
9.  **Mapper (Data Layer):** `CalculatorRepositoryImpl`은 `payment_mapper.dart`를 사용하여 `PaymentScheduleModel`을 `PaymentScheduleEntity`로 변환합니다.
10. **Result (Core Layer):** `CalculatorRepositoryImpl`은 `Result.success(PaymentScheduleEntity)`를 UseCase에 반환합니다.
11. **Bloc (Presentation Layer):** `CalculatorBloc`은 UseCase로부터 결과를 받아 `CalculatorLoaded` 상태와 함께 `PaymentScheduleEntity`를 UI에 전달합니다.
12. **UI (Presentation Layer):** `CalculatorScreen`은 `BlocBuilder`를 통해 `CalculatorLoaded` 상태를 감지하고, 화면을 다시 그려 납입 일정을 표시합니다.

---
