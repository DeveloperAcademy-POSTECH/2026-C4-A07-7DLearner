//
//  OfficeRepository.swift
//  C4
//
//  Created by YOOJUN PARK on 7/22/26.
//

import SwiftData
import Foundation

struct OfficeRepository {
    
    let context: ModelContext
    
    // MARK: 조회
    func fetchAll() throws -> [Office] {
        try context.fetch(FetchDescriptor<Office>())
    }
    
    // MARK: 생성
    func create(title: String, characters: [Character]) -> Office {
        let office = Office(title: title, characters: characters)
        context.insert(office)
        return office
    }
    
    // MARK: 삭제
    func delete(_ office: Office) {
        context.delete(office)
    }
    
}
