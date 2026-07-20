import SwiftUI
import SwiftData

// MARK: Character Loading View
struct CharacterLoadingView: View {
    
    // MARK: ViewModel
    @Bindable var viewModel: CharacterViewModel
    
    // MARK: Body
    var body: some View {
        VStack(alignment: .center, spacing: 26) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 138, height: 138)
                .background(
                    Image("PATH_TO_IMAGE")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 138, height: 138)
                        .clipped()
                )
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .inset(by: 0.5)
                        .stroke(.black, lineWidth: 1)
                )
            
            Text("자료를 읽고 있어요")
                .font(
                    Font.custom("Inter", size: 17)
                        .weight(.bold)
                )
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Text("자료를 취합하는 중입니다.\n잠시만 기다려 주세요.")
                .font(Font.custom("SF Pro", size: 17))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("37%")
                .font(Font.custom("SF Pro", size: 17))
                .foregroundColor(.black)
            
            Image("Line 4")
                .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .stroke(Color(red: 0.79, green: 0.79, blue: 0.79), lineWidth: 10)
                )
                .rotationEffect(Angle(degrees: 0.07))
            
            Text("텍스트 추출 완료!\n\n키워드 분석 중...\n\n중심 경험 요약 중...\n\n경험 생성 중...")
                .font(Font.custom("SF Pro", size: 13))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .center)
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
//    let viewModel = CharacterViewModel(
//        modelContext: container.mainContext
//    )
//    
//    return CharacterLoadingView(viewModel: viewModel)
//        .modelContainer(container)
//}
