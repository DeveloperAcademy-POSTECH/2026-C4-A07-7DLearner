import SwiftData
import Foundation

@Model
final class Character {
    
    // MARK: 식별자
    var id: UUID
    
    // MARK: 시스템 데이터
    //    var createdAt: Date
    
    // MARK: 사용자 입력값
    var title: String
    var characterStatement: String // 캐릭터 생성 시 입력 받는 '캐릭터 설명'
    
    // MARK: 시스템 생성값
    var bodyAssetIndex: Int // 캐릭터 몸통
    var headAssetIndex: Int // 캐릭터 머리
    
    // MARK: 관계
    @Relationship(inverse: \Keyword.characters) var keywords: [Keyword] = []
    var offices: [Office] = []
    
    // MARK: 생성자
    init(title: String, characterStatement: String, keywords: [Keyword]/*, createdAt: Date = .now*/) {
        self.id = UUID()
        //        self.createdAt = createdAt
        self.title = title
        self.characterStatement = characterStatement
        self.keywords = keywords
        
        self.bodyAssetIndex = .random(in: 0...2)
        self.headAssetIndex = .random(in: 0...2)
    }
    
}

// MARK: - 유효성 검사
extension Character {
    
    // 저장 가능한지 (제목 + 키워드)
    var isReadyToSave: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !self.keywords.isEmpty // 생성자가 빈 배열을 받아오는 것에 대한 방지
    }
    
}

// MARK: - 외형 (에셋 이름)
extension Character {
    
    // Assets -> Body0, Head0 ...
    var bodyAssetName: String {
        "Body\(self.bodyAssetIndex)"
    }
    
    var headAssetName: String {
        "Head\(self.headAssetIndex)"
    }
    
}

// MARK: - 파생 데이터 조회
extension Character {
    
    // 이 캐릭터가 가진 키워드들에 포함된 모든 에피소드 조회
    var episodes: [Episode] {
        self.keywords.flatMap { $0.episodes }
    }
    
}
