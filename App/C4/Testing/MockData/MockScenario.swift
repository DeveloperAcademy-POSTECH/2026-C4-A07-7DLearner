//
//  MockScenario.swift
//  C4
//
//  Created by YOOJUN PARK on 7/21/26.
//

//
//  MockScenario.swift
//  C4
//
//  Created by YOOJUN PARK on 7/21/26.
//

import Foundation

// MARK: 경험 시나리오
struct MockExperienceScenario {
    let title: String
    let statement: String
    let keywordInput: String
}

// MARK: 캐릭터 시나리오
struct MockCharacterScenario {
    let title: String
    let statement: String
    let keywordNames: [String]
}

enum MockScenarioSet {
    
    static let experiences: [MockExperienceScenario] = [
        MockExperienceScenario(
            title: "팀 프로젝트 위기 극복",
            statement: """
                출시 3주 전, 메인 디자이너가 하드웨어 UI 설계를 전담 중이던 팀 전체가 패닉에 빠졌다. \
                임시로 PM 역할을 자처해 매일 15분 스탠드업 미팅을 도입하고, 개발 파트의 제약 사항을 \
                파악해 대체 디자인 방안을 조율하고 팀원 간 업무 R&R을 명확히 재분배했다. 갈등 없이 \
                프로젝트 정상 궤도 복귀 및 기한 내 앱 스토어 제출 완료. 한편 CreateML 모델 정확도가 \
                낮아 데이터셋 불균형을 원인으로 특정하고, 추가 수집과 augmentation으로 78%에서 91%까지 \
                개선했다.
                """,
            keywordInput: "협업, 문제해결력"
        ),
        MockExperienceScenario(
            title: "해커톤 우승 프로젝트",
            statement: """
                48시간 동안 진행된 사내 해커톤에서 디자이너, 기획자와 팀을 이뤄 프로토타입을 완성했다. \
                아이디어 회의부터 서로 다른 직군 간 용어 차이로 소통에 어려움이 있었다. 매 시간 단위로 \
                짧게 싱크업하며 서로의 작업물을 공유하는 방식으로 전환한 뒤부터 속도가 붙었고, \
                결과적으로 심사위원단으로부터 최우수상을 받았다.
                """,
            keywordInput: "협업, 도전"
        ),
        MockExperienceScenario(
            title: "아르바이트 매장 운영 개선",
            statement: """
                카페 아르바이트 중 피크 시간대 주문 지연 문제를 발견하고 개선을 제안했다. 주문이 몰리는 \
                시간대에 제조 순서가 뒤섞여 반복적으로 지연이 발생했는데, 주문표에 색상 태그를 도입해 \
                음료 종류별로 제조 우선순위를 구분하는 방식을 점장에게 제안하고 직접 시범 운영한 결과, \
                평균 대기시간이 눈에 띄게 줄었다.
                """,
            keywordInput: "문제해결력, 책임감"
        )
    ]
    
    static let characters: [MockCharacterScenario] = [
        MockCharacterScenario(
            title: "위기에 강한 개발자",
            statement: "문제를 만나도 포기하지 않고 원인을 분석하며 끝까지 해결하려는 경향이 있다.",
            keywordNames: ["협업", "문제해결력"]
        ),
        MockCharacterScenario(
            title: "도전을 두려워하지 않는 사람",
            statement: "새로운 환경이나 처음 하는 일 앞에서도 일단 부딪혀보고 배우는 편이다.",
            keywordNames: ["도전", "협업"]
        ),
        MockCharacterScenario(
            title: "책임감 있는 실무자",
            statement: "맡은 일은 끝까지 완수하고, 문제가 생기면 스스로 나서서 해결한다.",
            keywordNames: ["책임감", "문제해결력"]
        )
    ]
    
}
