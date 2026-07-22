//
//  KeywordViewModel.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class KeywordViewModel {
    
    // MARK: - Dependencies
    private let context: ModelContext
    
    private let episodeGenerationManager: EpisodeGenerationManager
    private let keywordRepository: KeywordRepository
    private let experienceRepository: ExperienceRepository
    
    // MARK: State
    var keywords: [Keyword] = []
    var selectedKeyword: Keyword?
    
    // MARK: Inspector State
    var currentInspectorScreen: InspectorScreen?
    var isInspectorPresented: Bool {
        currentInspectorScreen != nil
    }
    
    // MARK: Draft State
    var draftExperienceTitle: String = ""
    var draftStartDate: String = ""
    var draftEndDate: String = ""
    var draftStatement: String = ""
    var draftKeywords: [String] = []
    var draftAttachedFiles: [Attachment] = []
    
    // KeywordDraftView에서 참조하는 AI 분석 결과 변수
    var generatedKeywords: [Keyword] = []
    var generatedEpisodes: [Episode] = []
    
    // 분석 버튼 활성화를 위한 필수값 검증 프로퍼티
    var isDraftReadyToAnalyze: Bool {
        !draftExperienceTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftStartDate.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftEndDate.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftStatement.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draftKeywords.isEmpty
    }
    
    // MARK: Initializer
    init(modelContext: ModelContext) {
        self.context = modelContext
        // 의존성 초기화
        self.episodeGenerationManager = EpisodeGenerationManager(modelContext: modelContext)
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.experienceRepository = ExperienceRepository(context: modelContext)
        
        fetchKeywords()
    }
    
    // MARK: - Functions
    // 저장된 전체 키워드 조회
    func fetchKeywords() {
        do {
            let descriptor = FetchDescriptor<Keyword>()
            keywords = try context.fetch(descriptor)
        } catch {
            print("Keyword 조회 실패: \(error)")
        }
    }
    
    // 특정 키워드와 연결된 에피소드 반환
    func episodesForKeyword(keyword: Keyword) -> [Episode] {
        return keyword.episodes
    }
    
    // 실제 AI 분석 파이프라인 연동
    @MainActor
    func generateEpisodes() async {
        guard isDraftReadyToAnalyze else { return }
        
        // 1. 날짜 파싱 (YYYY.MM.DD 또는 YYYY/MM/DD 대응)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let normalizedStart = draftStartDate.replacingOccurrences(of: "/", with: ".")
        let normalizedEnd = draftEndDate.replacingOccurrences(of: "/", with: ".")
        let start = formatter.date(from: normalizedStart) ?? .now
        let end = formatter.date(from: normalizedEnd) ?? .now
        
        // 2. 키워드 객체 생성/매핑
        var realKeywords: [Keyword] = []
        for kwName in draftKeywords {
            if let keyword = try? keywordRepository.findOrCreate(name: kwName) {
                realKeywords.append(keyword)
            }
        }
        self.generatedKeywords = realKeywords
        
        // 3. Experience 엔티티 생성 (DB 저장)
        let newExperience = experienceRepository.create(
            title: draftExperienceTitle,
            periodStart: start,
            periodEnd: end,
            experienceStatement: draftStatement
        )
        newExperience.keywords = realKeywords
        
        // 4. 업로드된 첨부파일들을 새 Experience와 연결
        for file in draftAttachedFiles {
            file.experience = newExperience
        }
        
        try? context.save()
        
        // 5. Claude API (EpisodeGenerationManager) 호출하여 에피소드 생성
        await episodeGenerationManager.generateEpisodes(for: newExperience)
        
        // 6. 생성된 에피소드 결과물을 뷰모델 변수에 담아서 화면 갱신
        self.generatedEpisodes = newExperience.episodes
        
        print("AI 에피소드 생성 완료! 갯수: \(self.generatedEpisodes.count)")
    }
    
    // 생성창 초기화 함수
    func startKeywordCreation() {
        draftExperienceTitle = ""
        draftStartDate = ""
        draftEndDate = ""
        draftStatement = ""
        draftKeywords = []
        draftAttachedFiles = []
        
        // 이전 분석 결과 초기화
        generatedKeywords = []
        generatedEpisodes = []
        
        selectedKeyword = nil
        currentInspectorScreen = .create
    }
}
