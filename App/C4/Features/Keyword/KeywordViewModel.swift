//
//  KeywordViewModel.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData
import Observation

enum KeywordViewSelection: Hashable {
    case keyword(Keyword)
    case experience(Experience)
}

// MARK: - 생성 폼에서 선택한 첨부 파일 (분석 시점에 실제 복사/추출)
// 파일 선택 시엔 URL과 표시용 정보만 보관하고,
// 실제 파일 복사 + 텍스트 추출은 "분석" 시점에 manager.addAttachment로 수행한다.
struct DraftAttachment: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let fileName: String
    let fileType: String
    let fileSize: Int

    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
}

@Observable
final class KeywordViewModel {

    // MARK: - Dependencies
    private let context: ModelContext
    private let keywordRepository: KeywordRepository
    private let experienceRepository: ExperienceRepository
    // 로딩 화면(KeywordLoadingView)에서 직접 사용하므로 노출한다.
    let episodeGenerationManager: EpisodeGenerationManager
    
    var keywords: [Keyword] = []
    var selectedKeyword: Keyword?
    
    // MARK: Loading State
    // 로딩 화면(KeywordLoadingView)에 넘길, 현재 분석 중인 경험
    var analysisExperience: Experience?
    
    // MARK: State
    // KeywordDraftView에서 참조하는 AI 분석 결과
    var generatedKeywords: [Keyword] = []
    var generatedEpisodes: [Episode] = []
    
    var selectedTab: String = "키워드"
    var viewSelection: KeywordViewSelection?
    var allExperiences: [Experience] = []
    
    // 탭 변경 및 선택 초기화 함수
    func changeTab(to tab: String) {
        self.selectedTab = tab
        self.viewSelection = nil
        self.currentInspectorScreen = nil
        if tab == "경험" {
            fetchAllExperiences()
        }
    }
    
    // 전체 경험 조회 함수
    func fetchAllExperiences() {
        do {
            let descriptor = FetchDescriptor<Experience>()
            allExperiences = try context.fetch(descriptor)
        } catch {
            print("Experience 조회 실패: \(error)")
        }
    }
    

    // MARK: State
    var keywords: [Keyword] = []
    var selectedKeyword: Keyword?

    // MARK: Loading State
    // 로딩 화면(KeywordLoadingView)에 넘길, 현재 분석 중인 경험
    var analysisExperience: Experience?

    // KeywordDraftView에서 참조하는 AI 분석 결과
    var generatedKeywords: [Keyword] = []
    var generatedEpisodes: [Episode] = []

    // MARK: Inspector State
    var currentInspectorScreen: InspectorScreen?
    var isInspectorPresented: Bool {
        currentInspectorScreen != nil
    }    

    // MARK: Draft State (생성 폼 입력값)
    var draftExperienceTitle: String = ""
    var draftStartDate: Date = .now
    var draftEndDate: Date = .now
    var draftStatement: String = ""
    var draftKeywords: [String] = []
    var draftAttachedFiles: [DraftAttachment] = []    

    // 분석(생성) 버튼 활성화 조건 — 경험명 + 올바른 기간 + 경험진술 + 키워드 1개 이상
    var isDraftReadyToAnalyze: Bool {
        !draftExperienceTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && draftStartDate <= draftEndDate
        && !draftStatement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !draftKeywords.isEmpty
    }

    // MARK: Initializer
    init(modelContext: ModelContext) {
        self.context = modelContext
        self.keywordRepository = KeywordRepository(context: modelContext)
        self.experienceRepository = ExperienceRepository(context: modelContext)
        self.episodeGenerationManager = EpisodeGenerationManager(modelContext: modelContext)
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

    // MARK: - 생성 폼

    // 새 키워드(경험) 생성 화면 열기 — 이전 draft/결과를 초기화한다.
    func startKeywordCreation() {
        draftExperienceTitle = ""
        draftStartDate = .now
        draftEndDate = .now
        draftStatement = ""
        draftKeywords = []
        draftAttachedFiles = []
        
        generatedKeywords = []
        generatedEpisodes = []
        analysisExperience = nil
        
        selectedKeyword = nil
        currentInspectorScreen = .create
    }
    
    // draft 입력값으로 Experience를 생성/저장하고 로딩 화면으로 전환한다.
    // 실제 Claude API 호출은 KeywordLoadingView가 담당한다.
    func startAnalysis() {
        guard isDraftReadyToAnalyze else { return }
        
        // 1. 키워드 객체 생성/매핑 (중복은 findOrCreate에서 방지)
        var realKeywords: [Keyword] = []
        for name in draftKeywords {
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if let keyword = try? keywordRepository.findOrCreate(name: trimmed) {
                realKeywords.append(keyword)
            }
        }
        generatedKeywords = realKeywords
        
        // 2. Experience 생성
        let experience = experienceRepository.create(
            title: draftExperienceTitle,
            periodStart: draftStartDate,
            periodEnd: draftEndDate,
            experienceStatement: draftStatement
        )
        experience.keywords = realKeywords
        
        // 3. 첨부파일 복사 + 텍스트 추출 후 Experience에 연결
        //    (fileImporter에서 얻은 보안 스코프 URL이므로 접근 권한을 다시 확보한다.)
        for file in draftAttachedFiles {
            let gotAccess = file.url.startAccessingSecurityScopedResource()
            defer {
                if gotAccess { file.url.stopAccessingSecurityScopedResource() }
            }
            episodeGenerationManager.addAttachment(from: file.url, to: experience)
        }
        
        // 4. 저장 후 로딩 화면으로 전환
        do {
            try context.save()
        } catch {
            print("경험 저장 실패: \(error)")
        }
        
        analysisExperience = experience
        currentInspectorScreen = .loading
    }
    

        generatedKeywords = []
        generatedEpisodes = []
        analysisExperience = nil

        selectedKeyword = nil
        currentInspectorScreen = .create
    }

    // draft 입력값으로 Experience를 생성/저장하고 로딩 화면으로 전환한다.
    // 실제 Claude API 호출은 KeywordLoadingView가 담당한다.
    func startAnalysis() {
        guard isDraftReadyToAnalyze else { return }

        // 1. 키워드 객체 생성/매핑 (중복은 findOrCreate에서 방지)
        var realKeywords: [Keyword] = []
        for name in draftKeywords {
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if let keyword = try? keywordRepository.findOrCreate(name: trimmed) {
                realKeywords.append(keyword)
            }
        }
        generatedKeywords = realKeywords

        // 2. Experience 생성
        let experience = experienceRepository.create(
            title: draftExperienceTitle,
            periodStart: draftStartDate,
            periodEnd: draftEndDate,
            experienceStatement: draftStatement
        )
        experience.keywords = realKeywords

        // 3. 첨부파일 복사 + 텍스트 추출 후 Experience에 연결
        //    (fileImporter에서 얻은 보안 스코프 URL이므로 접근 권한을 다시 확보한다.)
        for file in draftAttachedFiles {
            let gotAccess = file.url.startAccessingSecurityScopedResource()
            defer {
                if gotAccess { file.url.stopAccessingSecurityScopedResource() }
            }
            episodeGenerationManager.addAttachment(from: file.url, to: experience)
        }

        // 4. 저장 후 로딩 화면으로 전환
        do {
            try context.save()
        } catch {
            print("경험 저장 실패: \(error)")
        }

        analysisExperience = experience
        currentInspectorScreen = .loading
    }

    // 로딩(생성) 완료 후 호출 — 결과 반영 및 다음 화면 전환
    func finishAnalysis() {
        if let experience = analysisExperience {
            generatedEpisodes = experience.episodes
        }
        fetchKeywords()
        currentInspectorScreen = .draft
    }
}
