//
//  EpisodePrompt.swift
//  C4
//
//  Created by YOOJUN PARK on 7/17/26.
//

import Foundation

// MARK: LanguageModel 프롬프트
enum EpisodePrompt {
    
    static func build(from input: EpisodeGenerationInput) -> String {
        """
        당신의 역할은 사용자의 경험 기록에서, 지정된 키워드에 해당하는 에피소드를 찾아 정리하는 것입니다.
        
        ## 분석 대상 키워드
        \(input.keywordNames.joined(separator: ", "))
        
        ## 경험 진술 (사용자가 직접 작성함)
        \(input.experienceStatement)
        
        ## 첨부 자료 발췌
        \(input.attachmentTexts.map { "[attachmentID: \($0.attachmentID)]\n\($0.text)" }.joined(separator: "\n\n"))
        
        ## 지시사항
        - 위 키워드 각각에 대해, 경험 진술과 첨부 자료에서 해당 키워드를 뒷받침하는 구체적인 에피소드를 찾아 STAR 형식(문제상황/고민포인트/액션/성과)으로 정리하세요.
        - 하나의 키워드에 여러 개의 서로 다른 에피소드가 있다면 각각 별도 항목으로 작성하세요.
        - 어떤 키워드에 해당하는 내용이 전혀 없다면, 그 키워드는 결과에서 생략하세요.
        - sourceExcerpt에는 근거가 된 원문 발췌를 그대로 포함하세요.
        - 첨부 자료에서 근거를 찾았다면 sourceAttachmentID에 해당 attachmentID를 반드시 포함하고, 경험 진술에서만 근거를 찾았다면 sourceAttachmentID는 null로 두세요.
        
        ## 출력 형식
        아래 JSON 스키마를 따르는 배열만 응답하세요. 다른 설명이나 텍스트는 포함하지 마세요.
        [
          {
            "keywordName": "string",
            "title": "string",
            "problemContext": "string",
            "concernPoint": "string",
            "myAction": "string",
            "outcome": "string",
            "sourceExcerpt": "string",
            "sourceAttachmentID": "UUID string or null"
          }
        ]
        """
    }
    
}
