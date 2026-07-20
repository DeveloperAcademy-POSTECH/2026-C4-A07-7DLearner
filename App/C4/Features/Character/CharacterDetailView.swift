import SwiftUI
import SwiftData

// MARK: Character Detail View
struct CharacterDetailView: View {
    
    // MARK: ViewModel
    @Bindable var viewModel: CharacterViewModel
    
    // MARK: Properties
    private let episodeColumns = [GridItem(.adaptive(minimum:232), spacing: 8, alignment: .top)]
    
    // MARK: Body
    var body: some View {
        if let character = viewModel.selectedCharacter {
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 10) {
                    Image("캐릭터")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        
                    VStack(alignment:.leading, spacing: 12){
                            Text(character.title)
                            .font(
                            Font.custom("SF Pro", size: 12)
                            .weight(.semibold)
                            )
                            .foregroundColor(.black)
                        
                        Text(character.characterStatement)
                        .font(Font.custom("SF Pro", size: 12))
                        .foregroundColor(.black)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("키워드")
                    .font(
                    Font.custom("SF Pro", size: 15)
                    .weight(.semibold)
                    )
                    
                    LazyVGrid(columns: episodeColumns, alignment: .leading, spacing: 8){
                        ForEach(character.keywords, id: \.id) { keyword in
                            KeywordEpisodeCard(keyword: keyword, episodes: keyword.episodes)
                        }
                    }
                }

            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
              LinearGradient(
                stops: [
                  Gradient.Stop(color: Color(red: 0.85, green: 0.85, blue: 0.93), location: 0.00),
                  Gradient.Stop(color: .white, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.13)
              )
            )
            .cornerRadius(15)
        }
    }
}

// MARK: - Preview
//#Preview {
//
//    let container = try! ModelContainer(
//
//        for: Character.self,
//
//        Keyword.self,
//
//        Episode.self,
//
//        Experience.self,
//
//        Attachment.self,
//
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//
//    )
//
//    let context = container.mainContext
//
//    let viewModel = CharacterViewModel(
//
//        modelContext: context
//
//    )
//
//    return CharacterDetailView(
//
//        viewModel: viewModel
//
//    )
//
//    .modelContainer(container)
//
//}
