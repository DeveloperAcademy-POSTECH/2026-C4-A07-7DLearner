//
//  OfficeCanvasService.swift
//  C4
//
//  Created by YOOJUN PARK on 7/22/26.
//

import SwiftUI
import SwiftData

struct OfficeCanvasService: View {
    
    let characters: [Character]
    var onSelect: ((Character?) -> Void)? = nil // 호출부에 캐릭터 선택 여부 알려주는 콜백
    
    @State private var selectedCharacterID: UUID? // 현재 선택된 캐릭터
    @State private var canvasSize: CGSize = .zero // 배경 사이즈 -> 랜덤 좌표의 범위 한정에 필요
    
    var body: some View {
        // 뷰에 그려지는 오피스 화면 그 자체
        GeometryReader { proxy in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.12))
                
                // Avatar
                ForEach(characters) { character in
                    WanderingAvatar(
                        character: character,
                        isSelected: selectedCharacterID == character.id,
                        canvasSize: canvasSize
                    ) {
                        select(character)
                    }
                }
            }
            // 오피스 초기 실행 시 동작
            .onAppear { canvasSize = proxy.size }
            
            // 화면 크기 변경 시 동작
            .onChange(of: proxy.size) { _, newSize in canvasSize = newSize }
        }
    }
    
}

// MARK: - 캐릭터 선택 로직
private extension OfficeCanvasService {
    
    // 캐릭터 선택 또는 선택 해제
    func select(_ character: Character) {
        selectedCharacterID = (selectedCharacterID == character.id) ? nil : character.id
        let selected = characters.first { $0.id == selectedCharacterID }
        onSelect?(selected) // 호출부로, 선택된 캐릭터 객체 담아서 콜백
    }
    
}

// MARK: - Avatar 로직 (각자 랜덤하게 움직이도록)
private struct WanderingAvatar: View {
    
    let character: Character
    let isSelected: Bool
    let canvasSize: CGSize
    let onTap: () -> Void
    
    @State private var position: CGPoint = .zero // 이 캐릭터의 현재 위치
    
    var body: some View {
        avatar(for: character)
            .onTapGesture(perform: onTap)
            .position(position)
            .task(id: canvasSize) {
                guard canvasSize != .zero else { return }
                position = randomPoint() // 캐릭터의 초기 위치 부여
                await wanderLoop() // 이후 캐릭터 위치 및 이동 담당
            }
    }
    
}

// MARK: - Avatar 외형
private extension WanderingAvatar {
    
    func avatar(for character: Character) -> some View {
        VStack(spacing: 4) {
            avatarImage(for: character)
                .font(.system(size: 32))
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
            Text(character.title)
                .font(.caption2)
                .frame(maxWidth: .infinity)
        }
    }
    
    // 캐릭터의 이미지를 받아와서 Avatar 이미지로 사용
    func avatarImage(for character: Character) -> some View {
        Image(systemName: "person.crop.circle.fill")
    }
    
}

// MARK: - Avatar 이동 로직
private extension WanderingAvatar {
    
    // Task 취소 여부 감지 -> 캔버스 크기가 바뀌면 .task가 이 함수 취소하고 새로 시작
    func wanderLoop() async {
        while !Task.isCancelled { // loop 종료 전까지 반복
            let delay = Double.random(in: 4...8) // 랜덤 대기 시간
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            
            withAnimation(.easeInOut(duration: 3)) {
                position = randomPoint() // 캐릭터의 다음 좌표 부여
            }
        }
    }
    
    func randomPoint() -> CGPoint {
        let margin: CGFloat = 30 // 오피스 테두리에 Avatar 배치되지 않도록 바운더리 마진
        
        // margin보다 뷰 사이즈가 작은 경우 작동 불가 -> 중앙값 반환
        guard canvasSize.width > margin * 2, canvasSize.height > margin * 2 else {
            return CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        }
        
        return CGPoint(
            x: .random(in: margin...(canvasSize.width - margin)),
            y: .random(in: margin...(canvasSize.height - margin))
        )
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: Attachment.self, Character.self, Episode.self, Experience.self, Keyword.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext
    
    let keyword1 = Keyword(name: "협업")
    let keyword2 = Keyword(name: "도전")
    context.insert(keyword1)
    context.insert(keyword2)
    
    let characters = [
        Character(title: "위기에 강한 개발자", characterStatement: "문제를 만나도 끝까지 해결한다.", keywords: [keyword1]),
        Character(title: "도전을 두려워하지 않는 사람", characterStatement: "새로운 환경에도 일단 부딪혀본다.", keywords: [keyword2]),
        Character(title: "책임감 있는 실무자", characterStatement: "맡은 일은 끝까지 완수한다.", keywords: [keyword1, keyword2])
    ]
    characters.forEach { context.insert($0) }
    
    return OfficeCanvasService(characters: characters)
        .frame(height: 360)
        .padding()
        .modelContainer(container)
}
