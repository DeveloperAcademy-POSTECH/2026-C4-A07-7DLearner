//
//  KeywordView.swift
//  C4
//
//  Created by 박시은 on 7/20/26.
//

import SwiftUI
import SwiftData
import Foundation

struct KeywordView: View {
    
    // MARK: ViewModel
    @Bindable var viewModel: KeywordViewModel
    @State private var selectedTab = "키워드"
    
    let selectedColor = Color("selectedColor")
    
    var body: some View {
        // MARK: - 리스트 영역
        VStack(spacing: 0) {
            if viewModel.keywords.isEmpty {
                emptyStateView
            } else {
                contentListView
            }
        }
        .navigationTitle("키워드")
        // 메인 툴바 분기 처리
        .toolbar {
            mainToolbar
        }
        // MARK: - Inspector
        .inspector(isPresented: Binding(
            get: { viewModel.isInspectorPresented },
            set: { isPresented in
                if !isPresented {
                    viewModel.currentInspectorScreen = nil
                }
            }
        )) {
            Group {
                switch viewModel.currentInspectorScreen {
                case .create:
                    KeywordCreateView(viewModel: viewModel)
                case .loading:
                    Text("loading")
                case .draft:
                    Text("draft")
                case .detail:
                    if let keyword = viewModel.selectedKeyword {
                        KeywordDetailView(keyword: keyword, episodes: viewModel.episodesForKeyword(keyword: keyword))
                    }
                case nil:
                    KeywordEmptyView(viewModel: viewModel)
                }
            }
            .inspectorColumnWidth(min: 350, ideal: 420, max: 600)
            
            // 인스펙터 툴바 분기 처리
            .toolbar {
                inspectorToolbar
            }
        }
    }
    
    // MARK: - 빈 화면
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("아직 생성된 키워드가 없습니다.")
            Text("+ 버튼을 눌러 새로운 키워드를 만들어 보세요.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 리스트 화면
    private var contentListView: some View {
        VStack(spacing: 0) {
            // 상단 탭
            HStack(spacing: 0) {
                Button(action: { selectedTab = "키워드" }) {
                    Text("키워드")
                        .font(Font.custom("SF Pro", size: 13))
                        .frame(width: 361 / 2, height: 24)
                        .background(selectedTab == "키워드" ? selectedColor : Color.clear)
                        .foregroundColor(selectedTab == "키워드" ? .white : .black)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: { selectedTab = "경험" }) {
                    Text("경험")
                        .font(Font.custom("SF Pro", size: 13))
                        .frame(width: 361 / 2, height: 24)
                        .background(selectedTab == "경험" ? selectedColor : Color.clear)
                        .foregroundColor(selectedTab == "경험" ? .white : .black)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .frame(width: 361, height: 24)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(6)
            .padding(.vertical, 12)
            
            // 키워드 리스트
            if selectedTab == "키워드" {
                List(viewModel.keywords, id: \.id, selection: $viewModel.selectedKeyword) { keyword in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(keyword.name)
                            .font(Font.custom("SF Pro", size: 15).weight(.semibold))
                            .foregroundColor(.black)
                        Text("에피소드 \(keyword.episodes.count)개")
                            .font(Font.custom("SF Pro", size: 12))
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                    }
                    .padding(.vertical, 8)
                    .tag(keyword)
                }
                .listStyle(.plain)
            } else {
                Spacer()
                Text("경험 리스트 영역")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
    
    // MARK: - 메인 툴바
    @ToolbarContentBuilder
    private var mainToolbar: some ToolbarContent {
        if viewModel.keywords.isEmpty {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.currentInspectorScreen = .create
                    viewModel.selectedKeyword = nil
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("새 키워드")
                    }
                    .font(Font.custom("SF Pro", size: 14).weight(.medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                }
                .buttonStyle(.plain)
                .clipShape(Capsule())
                .fixedSize()
            }
        } else {
            // 데이터 있을 때
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    // 휴지통 액션
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .clipShape(Circle())
                .fixedSize()
            }
        }
    }
    
    // MARK: - 인스펙터 툴바
    //    @ToolbarContentBuilder
    //    private var inspectorToolbar: some ToolbarContent {
    //        if !viewModel.keywords.isEmpty {
    //            ToolbarItemGroup(placement: .primaryAction) {
    //                Button(action: {
    //                    viewModel.currentInspectorScreen = .create
    //                    viewModel.selectedKeyword = nil
    //                }) {
    //                    // 새 키워드 버튼
    //                    HStack(spacing: 4) {
    //                        Image(systemName: "plus")
    //                        Text("새 키워드")
    //                    }
    //                    .font(Font.custom("SF Pro", size: 14).weight(.medium))
    //                    .foregroundColor(.black)
    //                    .padding(.horizontal, 10)
    //                    .frame(height: 36)
    //                }
    //                .buttonStyle(.plain)
    //                .clipShape(Capsule())
    //                .fixedSize()
    //
    //                Spacer()
    //                    .frame(width: 120)
    //
    //                // 돋보기 검색 버튼
    //                Button(action: {
    //                    // 검색 액션
    //                }) {
    //                    Image(systemName: "magnifyingglass")
    //                        .font(.system(size: 14))
    //                        .foregroundColor(.black)
    //                        .frame(width: 36, height: 36)
    //                }
    //                .buttonStyle(.plain)
    //                .clipShape(Circle())
    //                .fixedSize()
    //            }
    //        }
    //    }
    //}
    @ToolbarContentBuilder
    private var inspectorToolbar: some ToolbarContent {
        switch viewModel.currentInspectorScreen {
        case .create:
            // 생성 화면일 때: X, 임시저장, 분석 버튼
            ToolbarItem(placement: .navigation) {
                // 좌측 상단 (X 버튼)
                Button(action: {
                    viewModel.currentInspectorScreen = nil
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                .buttonStyle(.plain)
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                // 우측 상단 (임시저장, 분석)
                Button(action: {
                    // 임시저장 액션
                }) {
                    Text("임시저장")
                        .font(Font.custom("SF Pro", size: 13).weight(.medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .frame(height: 28)
                        .overlay(
                            Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    viewModel.currentInspectorScreen = .loading
                }) {
                    Text("분석")
                        .font(Font.custom("SF Pro", size: 13).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 28)
                        .background(Color(red: 0.0, green: 0.48, blue: 1.0)) // mainBlue
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            
        default:
            // 기본 상태일 때: 새 키워드, 검색 버튼 표시
            if !viewModel.keywords.isEmpty {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        viewModel.currentInspectorScreen = .create
                        viewModel.selectedKeyword = nil
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("새 키워드")
                        }
                        .font(Font.custom("SF Pro", size: 14).weight(.medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                    }
                    .buttonStyle(.plain)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(Capsule())
                    .fixedSize()
                    
                    Spacer()
                        .frame(width: 120)
                    
                    Button(action: {
                        // 검색 액션
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13))
                            .foregroundColor(.black)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(Circle())
                    .fixedSize()
                }
            }
        }
    }
}
