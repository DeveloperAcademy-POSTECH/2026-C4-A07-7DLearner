import SwiftUI
import SwiftData

// MARK: Character Draft View
struct CharacterDraftView: View {
    
    // MARK: ViewModel
    @Bindable var viewModel: CharacterViewModel
    
    // MARK: Properties
    private let keywordColumns = [GridItem(.adaptive(minimum:50),spacing: 8, alignment: .leading)]
    private let episodeColumns = [GridItem(.adaptive(minimum:232), spacing: 8, alignment: .leading)]
    
    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            titleSection
            characterTitleSection
            characterStatementSection
            keywordSection
            episodeSection
        }
        .padding(30)
    }
    
    // MARK: - Title
    private var titleSection: some View {
        VStack(alignment: .leading,spacing: 6){
            Text("캐릭터 초안")
                .font(
                    Font.custom("SF Pro", size: 22)
                        .weight(.bold)
                )
                .foregroundColor(.black)
            
            Text("편집 버튼을 눌러 내용을 수정 후 캐릭터를 완성해보세요.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            
            Divider()
        }
    }
    
    // MARK: - Character Title
    private var characterTitleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("캐릭터명")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
            
            Group {
                if viewModel.isEditingDraft == true {
                    CustomTextField(placeholder: "", text: $viewModel.draftTitle)
                } else {
                    Text(viewModel.draftTitle)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Divider()
        }
    }
    
    // MARK: - Keyword
    private var keywordSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("키워드 선택")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
            
            LazyVGrid(columns: keywordColumns, alignment: .leading, spacing: 15) {
                
                ForEach(viewModel.draftKeywords, id: \.id) {keyword in
                    HStack (spacing: 4){
                        Text(keyword.name)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        if viewModel.isEditingDraft {
                            Button {
                                viewModel.removeDraftKeyword(keyword)
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(.plain)
                        }
                        
                    }
                    .font(Font.custom("SF Pro", size: 12))
                    .foregroundColor(Color(red: 0, green: 0.4, blue: 0.8).opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.85, green: 0.93, blue: 1))
                    .cornerRadius(20)
                    
                }
                
            }
            .background(.clear)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .overlay{
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(red: 0.77, green: 0.77, blue: 0.77), lineWidth: 1)
            }
            Divider()
        }
    }
    
    // MARK: - Character Statement
    private var characterStatementSection: some View {
        VStack(alignment:.leading, spacing: 6){
            
            Text("캐릭터 설명")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
            
            Group {
                if viewModel.isEditingDraft {
                    CustomTextField(placeholder: "", text: $viewModel.draftCharacterStatement)
                } else {
                    Text(viewModel.draftCharacterStatement)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Divider()
        }
    }
    
    // MARK: - Episode
    private var episodeSection: some View {
        VStack(alignment: .leading, spacing: 6){
            Text("키워드와 연결된 에피소드")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
            
            LazyVGrid(columns: episodeColumns,alignment: .leading, spacing: 8){
                ForEach(viewModel.draftKeywords, id: \.id) { keyword in
                    KeywordEpisodeCard(keyword: keyword, episodes: viewModel.episodesForKeyword(keyword: keyword))
                }
            }
        }
    }
    
}


//MARK: - Preview
//#Preview(
//    traits: .fixedLayout(width: 1000, height: 1000)
//) {
//    let configuration = ModelConfiguration(
//        isStoredInMemoryOnly: true
//    )
//    
//    let container = try! ModelContainer(
//        for: Character.self,
//        Keyword.self,
//        Episode.self,
//        configurations: configuration
//    )
//    
//    let viewModel = CharacterViewModel(
//        modelContext: container.mainContext
//    )
//    
//    CharacterCreateView(viewModel: viewModel)
//}


