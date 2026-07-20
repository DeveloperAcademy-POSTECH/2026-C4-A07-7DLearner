//
//  ExperienceViewModel.swift
//  C4
//
//  Created by 박시은 on 7/17/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
class ExperienceViewModel {
    // MARK: - 상태값
    var isKeywordMode: Bool = true
    var isGenerating: Bool = false
    var statusMessage: String = ""
    
    private(set) var context: ModelContext
    private var repository: ExperienceRepository
    private var keywordRepository: KeywordRepository
    private var attachmentRepository: AttachmentRepository
    private var episodeRepository: EpisodeRepository
    
    init(context: ModelContext) {
        self.context = context
        self.repository = ExperienceRepository(context: context)
        self.keywordRepository = KeywordRepository(context: context)
        self.attachmentRepository = AttachmentRepository(context: context)
        self.episodeRepository = EpisodeRepository(context: context)
    }
    
    // MARK: - 데이터 로직
    func createExperience(title: String, statement: String, keywordInput: String) {
        let keywordNames = keywordInput
            .split(separator: ",")
            .map { String($0) }
            .filter { !$0.isEmpty }
        
        guard !title.isEmpty, !keywordNames.isEmpty else {
            statusMessage = "제목과 키워드는 필수 입력"
            return
        }
        
        do {
            let keywords = try keywordNames.map { try keywordRepository.findOrCreate(name: $0) }
            
            let experience = repository.create(
                title: title,
                periodStart: .now,
                periodEnd: .now,
                experienceStatement: statement
            )
            experience.keywords = keywords
            
            try context.save()
            statusMessage = "경험 생성 완료"
        } catch {
            statusMessage = "경험 생성 실패: \(error)"
        }
    }
    
    // 경험 삭제 기능 (리스트에서 스와이프 삭제 구현 시 사용)
    func delete(_ experience: Experience) {
        repository.delete(experience)
        try? context.save()
    }
    
    // MARK: - 테스트용 더미 데이터 생성
    func addDummyData() {
        do {
            let keyword1 = try keywordRepository.findOrCreate(name: "협업")
            let keyword2 = try keywordRepository.findOrCreate(name: "문제해결력")
            
            let exp = repository.create(
                title: "애플 디벨로퍼 아카데미 C3",
                periodStart: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                periodEnd: Date(),
                experienceStatement: "디자이너 부재 위기를 넘긴 유연한 역할 분담과 소통"
            )
            
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
        } catch {
            print("더미데이터 생성 실패: \(error)")
        }
    }
}
