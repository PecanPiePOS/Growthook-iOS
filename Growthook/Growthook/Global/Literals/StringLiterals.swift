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
            static let removeActionPlan = "삭제한 액션플랜은 다시 복구할 수 없으니\n신중하게 결정해 주세요!"
        }
        
        enum UnLockCave {
            static let title = "내 동굴에 친구를 초대해\n인사이트를 공유해요!"
            static let description = "해당 기능은 추후 업데이트 예정이에요:)"
            static let check = "확인"
        }
        
        enum ToastMessage {
            static let moveInsight = "씨앗을 옮겨 심었어요"
            static let removeInsight = "씨앗이 삭제되었어요"
            static let removeCave = "동굴이 삭제되었어요"
            static let scrap = "스크랩 완료!"
        }
        
        enum Identifier {
            static let deSelectNoti = "DeSelectInsightNotification"
            static let customDetent = "customDetent"
            static let type = "type"
        }
        
        enum Button {
            static let check = "확인"
            static let newCave = "새 동굴 짓기"
        }
    }
    
    enum Home {
        static let select = "선택"
        static let seedsCollected = "개의 씨앗을 모았어요!"
        static let notiDescription1 = "잠금이 3일 이하로"
        static let notiDescription2 = "남은 씨앗이 "
        static let notiDescription3 = "개 있어요!"
        static let day3 = "3일 이하"
        static let notNotiDescription1 = "씨앗의 잠금이 3일"
        static let notNotiDescription2 = "남았을 때 알려드릴게요!"
        static let caveName = "동굴 이름"
        static let emptyCaveList = "아직 지어진 동굴이 없어요"
        static let emptyCave = "오른쪽의 +를 눌러 동굴을 지어보세요!"
        static let count = "개"
        static let userCave = "님의 동굴 속"
        static let emptySeedList = "아직 심겨진 씨앗이 없어요"
    }
    
    enum CaveDetail {
        static let addSeed = "씨앗 심기"
        static let caveChange = "동굴 편집"
        static let name = "이름"
        static let introduce = "소개"
        static let isShared = "공개 여부"
        static let changeCaveMenu = "수정하기"
        static let deleteCaveMenu = "삭제하기"
    }
    
    enum InsightList {
        static let lockInsight = "일 후 잠금"
    }
    
    enum ActionList {
        static let reviewPlaceholder = "액션 플랜을 달성하며 어떤 것을 느꼈는지 작성해보세요"
        static let insightDetailPlaceholder = "구체적인 계획을 설정해보세요"
        static let insightDetailReviewPlaceholder = "액션 플랜을 달성하며 어떤 것을 느꼈는지 작성해보세요"
    }
    
    enum CreateInsight {
        static let insightTextViewPlaceholder = "찾아낸 새로운 가치를 한 줄로 표현해주세요"
        static let memoTextViewPlaceholder = "찾아낸 가치에 대한 생각을 적어보세요 (선택)"
        static let caveTitle = "어떤 동굴에 저장할까요?"
        static let referencePlaceholder = "출처의 정보를 입력해주세요"
        static let referenceUrlPlaceholder = "참고한 url을 적어주세요 (선택)"
    }
    
    enum Auth {
        static let kakao = "KAKAO"
        static let apple = "APPLE"
        static let nickname = "nickname"
        static let memberId = "memberId"
        static let jwtToken = "jwtToken"
        static let hasBeenLaunched = "hasBeenLaunchedBefore"
        static let isLoggedIn = "isLoggedIn"
        static let loginType = "loginType"
        static let refreshToken = "refreshToken"
    }
    
    enum Mypage {
        static let deleteTitle = "정말 탈퇴 하시겠어요?"
        static let deleteDescription = "탈퇴 시, 수집한 인사이트와\n달성한 액션플랜에 대한 정보가\n모두 없어져요."
        static let maintain = "남아있기"
        static let withdraw = "탈퇴하기"
        static let logoutTitle = "로그아웃 하시겠습니까?"
        static let cancel = "취소"
        static let logout = "로그아웃"
    }
}
