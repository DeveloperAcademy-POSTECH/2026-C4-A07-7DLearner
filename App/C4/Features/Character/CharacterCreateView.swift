import SwiftUI
import SwiftData

// MARK: Character Create View
struct CharacterCreateView: View {
    
    // MARK: ViewModel
    @Bindable var viewModel: CharacterViewModel
    
    // MARK: State
    @State private var isKeywordPickerExpanded = false
    
    // MARK: Properties
    private let columns = [GridItem(.adaptive(minimum:50),spacing: 8, alignment: .leading)]
    
    // MARK: Body
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            titleSection
            characterTitleSection
            characterStatementSection
            keywordSection
        }
        .padding(30)
    }
    
    // MARK: Components
    // MARK: - Title
    private var titleSection: some View {
        VStack (alignment: .leading,spacing: 6){
            Text("캐릭터 생성하기")
                .font(
                    Font.custom("SF Pro", size: 22)
                        .weight(.bold)
                )
                .foregroundColor(.black)
            
            Text("정리한 경험을 바탕으로 키워드를 선택하여 나만의 캐릭터를 만들어보세요.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            
            Divider()
        }
    }
    
    // MARK: - Character Title
    private var characterTitleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("캐릭터명 (필수)")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
            
            Text("만들고 싶은 캐릭터를 한 문장이나 짧은 이름으로 표현해보세요.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
        
            CustomTextField(placeholder: "ex) 실패를 두려워하지 않는 개발자", text: $viewModel.draftTitle)
                            
            Divider()
        }
    }
    
    
    
    
    // MARK: - Keyword
    private var keywordSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("키워드 선택 (필수)")
                .font(
                    Font.custom("SF Pro", size: 15)
                        .weight(.semibold)
                )
                .foregroundColor(.black)
            
            Text("이 캐릭터를 가장 잘 나타내는 핵심 키워드를 1개 이상 선택해주세요. ")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            
            Text("선택한 키워드와 연결된 경험을 모아 캐릭터를 구성합니다.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            
            LazyVGrid(columns:columns, alignment: .leading, spacing: 15) {
                
                Button {
                    isKeywordPickerExpanded.toggle()
                } label: {
                    Image(systemName: "plus")
                    
                }
                
                ForEach (viewModel.draftKeywords, id: \.id) {keyword in
                    HStack (spacing: 4){
                        Text(keyword.name)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Button {
                            viewModel.removeDraftKeyword(keyword)
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(.plain)
                    }
                    .font(Font.custom("SF Pro", size: 12))
                    .foregroundColor(Color(red: 0, green: 0.4, blue: 0.8).opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.85, green: 0.93, blue: 1))
                    .cornerRadius(20)
                    
                }
                
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if isKeywordPickerExpanded {
                TextField("검색",text: $viewModel.searchText)
                
                  LazyVGrid(columns:columns, alignment: .leading){
                    ForEach (viewModel.filteredKeywords, id: \.id) {keyword in
                        Button {
                            viewModel.addDraftKeyword(keyword)
                            viewModel.searchText = ""
                            
                        } label: {
                            Text(keyword.name)
                                .font(Font.custom("SF Pro", size: 12))
                                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.85))
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
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
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("이 캐릭터가 어떤 사람인지 자유롭게 설명해주세요.")
                .font(Font.custom("SF Pro", size: 12))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CustomTextField(placeholder: "ex) 개발 과정에서 마주하는 실패와 어려움을 성장의 기회로 받아들입니다.", text: $viewModel.draftCharacterStatement)

        }
    }
}

// MARK: - Preview
//#Preview {
//    let container = try! ModelContainer(
//        for: Character.self,
//        Keyword.self,
//        Episode.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    
//    let context = container.mainContext
//    
//    context.insert(Keyword(name: "협업"))
//    context.insert(Keyword(name: "소통"))
//    context.insert(Keyword(name: "책임감"))
//    context.insert(Keyword(name: "리더십"))
//    context.insert(Keyword(name: "도전"))
//    
//    let viewModel = CharacterViewModel(
//        modelContext: context
//    )
//    
//    viewModel.fetchAllKeywords()
//    
//    return CharacterCreateView(
//        viewModel: viewModel
//    )
//    .modelContainer(container)
//}
