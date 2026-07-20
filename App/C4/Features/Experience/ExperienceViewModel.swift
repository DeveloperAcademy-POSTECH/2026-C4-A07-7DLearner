//
//  ExperienceViewModel.swift
//  C4
//
//  Created by 박시은 on 7/17/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class ExperienceViewModel: ObservableObject {
    // MARK: - 상태값
    
    @Published var experiences: [Experience] = []
    @Published var keywords: [Keyword] = []
    @Published var isKeywordMode: Bool = true
    // 타 뷰에 의존성을 넘겨주기 위해 내부 context를 읽기 전용으로 노출
    private(set) var context: ModelContext
    
    private var repository: ExperienceRepository
    private var keywordRepository: KeywordRepository
    
    // MARK: - 초기화
    init(context: ModelContext) {
        self.context = context
        self.repository = ExperienceRepository(context: context)
        self.keywordRepository = KeywordRepository(context: context)
        fetchData()
    }
    
    // MARK: - 데이터 로직
    func fetchData() {
        self.experiences = (try? repository.fetchAll()) ?? []
        self.keywords = (try? keywordRepository.fetchAll()) ?? []
    }
    // MARK: - 테스트용 더미 데이터 생성
    func addDummyData() {
        for exp in experiences { context.delete(exp) }
        for keyword in keywords { context.delete(keyword) }
        try? context.save()
        
        // 키워드 생성
        let keyword1 = (try? keywordRepository.findOrCreate(name: "협업")) ?? Keyword(name: "협업")
        let keyword2 = (try? keywordRepository.findOrCreate(name: "문제해결력")) ?? Keyword(name: "문제해결력")
        
        // 경험 생성
        let exp = repository.create(
            title: "애플 디벨로퍼 아카데미 C3",
            periodStart: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
            periodEnd: Date(),
            experienceStatement: "디자이너 부재 위기를 넘긴 유연한 역할 분담과 소통"
        )
        
        // 경험에 키워드 연결
        exp.keywords.append(keyword1)
        exp.keywords.append(keyword2)
        
        // 첨부자료 더미 데이터 추가
        let attachment1 = Attachment(
            fileName: "계산기 앱.Xcode",
            storedFileName: "dummy_calc_123.xcode", // 샌드박스 저장용 가짜 이름
            fileType: "Xcode Project",
            fileSize: 185000,
            experience: exp // 어떤 경험에 속하는지 명시
        )
        
        let attachment2 = Attachment(
            fileName: "팀원 회고.PDF",
            storedFileName: "dummy_retrospect_456.pdf",
            fileType: "PDF 문서",
            fileSize: 604000,
            experience: exp // 어떤 경험에 속하는지 명시
        )
        
        exp.attachments.append(attachment1)
        exp.attachments.append(attachment2)
        
        // 에피소드 더미 데이터 추가
        let episode1 = Episode(
            title: "디자이너 부재 위기를 넘긴 유연한 역할 분담과 소통",
            problemContext: "출시 3주 전, 메인 디자이너의 하차로 UI 설계가 전면 중단되어 팀 전체가 패닉에 빠졌다.",
            concernPoint: "개발팀과 남은 인원들 사이에서 '누가 이 업무를 맡을 것인가'에 대한 혼선이 생겼다.",
            myAction: "임시 PM 역할을 자처하여 매일 15분 스탠드업 미팅을 도입했다. 개발 파트의 제약 사항을 파악한 뒤...",
            outcome: "갈등 없이 프로젝트 정상 궤도 복귀 및 기한 내 앱 스토어 제출 완료. 직군을 넘어선 소통 능력과 위기 속 유연한 협업의 중요성을 깨달았다.",
            sourceExcerpt: "메인 디자이너 하차 후 업무 분장 관련 회의록 발췌 내용...",
            experience: exp,
            keyword: keyword1,
            attachment: attachment2 // 옵셔널 첨부파일 연결
        )
        exp.episodes.append(episode1)
        
        // SwiftData 컨텍스트에 저장 반영
        try? context.save()
        fetchData()
    }
}
