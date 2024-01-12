//
//  StringLiterals.swift
//  Growthook
//
//  Created by KJ on 11/4/23.
//

import Foundation

enum I18N {
    
    enum Onboarding {
        static let loginMainTitle = "얻은 깨달음이 오래 방치되어 썩지 않도록\n도전할 일을 기록하고 수정해요."
        static let loginSubTitle = "인사이트를 영구히 내 것으로 만드는 순간,\n가파르게 성장할 거예요."
    }
    
    enum Component {
        
        enum UnLockInsight {
            static let title = "잠금 해제하기"
            static let description = "씨앗의 잠금을 해제하기 위해\n쑥 1개를 사용합니다."
            static let insightTip = "Tip. 인사이트의 액션 플랜을 만들고 이를 달성하면,\n쑥을 얻을 수 있어요!"
            static let tip = "Tip."
            static let leftover = "현재 남은 쑥"
            static let giveUp = "포기하기"
            static let use = "사용하기"
        }
        
        enum RemoveAlert {
            static let title = "정말로 삭제할까요?"
            static let removeInsight = "삭제한 인사이트는 다시 복구할 수 없으니\n신중하게 결정해 주세요!"
            static let removeCave = "삭제한 보관함은 다시 복구할 수 없으니\n신중하게 결정해 주세요!"
            static let keep = "유지하기"
            static let remove = "삭제하기"
        }
        
        enum UnLockCave {
            static let title = "내 동굴에 친구를 초대해\n인사이트를 공유해요!"
            static let description = "해당 기능은 추후 업데이트 예정이에요:)"
            static let check = "확인"
        }
    }
    
    enum Home {
        static let select = "선택"
        static let seedsCollected = "개의 씨앗을 모았어요!"
        static let notiDescription1 = "잠금이 "
        static let notiDescription2 = "일 이하로\n남은 씨앗이 "
        static let notiDescription3 = "개 있어요!"
        static let caveName = "동굴 이름"
        static let emptyCaveList = "아직 만들어진 동굴이 없어요"
    }
    
    enum CaveDetail {
        static let addSeed = "씨앗 심기"
    }
    
    enum InsightList {
        static let lockInsight = "일 후 잠금"
    }
    
    enum ActionList {
        static let reviewPlaceholder = "액션 플랜을 달성하며 어떤 것을 느꼈는지 작성해보세요"
    }
    
    enum CreateInsight {
        static let insightTextViewPlaceholder = "찾아낸 새로운 가치를 한 줄로 표현해주세요"
        static let memoTextViewPlaceholder = "찾아낸 가치에 대한 생각을 적어보세요 (선택)"
        static let caveTitle = "어떤 동굴에 저장할까요?"
        static let referencePlaceholder = "출처의 정보를 입력해주세요"
        static let referenceUrlPlaceholder = "참고한 url을 적어주세요 (선택)"
    }
}
