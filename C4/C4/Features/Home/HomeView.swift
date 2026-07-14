//
//  HomeView.swift
//  C4
//
//  Created by YOOJUN PARK on 7/13/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Experience.createdAt, order: .reverse)
    private var experiences: [Experience]
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        //
    }
}
