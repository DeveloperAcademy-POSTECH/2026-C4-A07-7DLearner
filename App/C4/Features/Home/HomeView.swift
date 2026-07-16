//
//  HomeView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Query private var experiences: [Experience]
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(experiences) { experience in
            Text(experience.title)
        }
    }
    
}
