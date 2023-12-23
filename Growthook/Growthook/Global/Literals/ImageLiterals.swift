//
//  ImageLiterals.swift
//  Growthook
//
//  Created by KJ on 11/4/23.
//

import UIKit

enum ImageLiterals {
    
    enum NavigationBar {
        static var back: UIImage { .load(name: "navi_back_btn") }
        static var close: UIImage { .load(name: "navi_close_btn") }
        static var menu: UIImage { .load(name: "navi_menu_btn") }
    }
    
    enum TabBar {
        static var home: UIImage { .load(name: "home_default").withRenderingMode(.alwaysOriginal) }
        static var selected_home: UIImage { .load(name: "home_active").withRenderingMode(.alwaysOriginal) }
        static var actionList: UIImage { .load(name: "actionList_default").withRenderingMode(.alwaysOriginal) }
        static var selected_actionList: UIImage { .load(name: "actionList_active").withRenderingMode(.alwaysOriginal) }
        static var mypage: UIImage { .load(name: "mypage_default").withRenderingMode(.alwaysOriginal) }
        static var selected_mypage: UIImage { .load(name: "mypage_active").withRenderingMode(.alwaysOriginal) }
    }
    
    enum Component {
        static var icn_check_green: UIImage { .load(name: "check_green") }
        static var icn_check_white: UIImage { .load(name: "check_white") }
        static var img_mugwort: UIImage { .load(name: "mugwort_img") }
        static var icn_seed_dark: UIImage { .load(name: "seed_dark_icn") }
        static var icn_seed_light: UIImage { .load(name: "seed_light_icn") }
        static var ic_largethook_color: UIImage { .load(name: "ic_largethook_color") }
        static var ic_largethook_mono: UIImage { .load(name: "ic_largethook_mono") }
        static var ic_thook: UIImage { .load(name: "ic_thook") }
        static var ic_scrapToast: UIImage { .load(name: "ic_scrapToast") }
    }
    
    enum Home {
        static var btn_add_cave: UIImage { .load(name: "addCave_btn") }
        static var btn_add_seed: UIImage { .load(name: "addSeed_btn") }
        static var img_cave: UIImage { .load(name: "cave_img") }
        static var btn_delete: UIImage { .load(name: "delete_btn") }
        static var btn_move: UIImage { .load(name: "move_btn") }
        static var icn_lock: UIImage { .load(name: "lock_img") }
        static var icn_noti_check: UIImage { .load(name: "noti_check") }
        static var icn_noti_checking: UIImage { .load(name: "noti_checking") }
        static var icn_noti_new: UIImage { .load(name: "noti_new") }
        static var btn_scrap: UIImage { .load(name: "btn_scrap") }
        static var btn_scrap_dark_off: UIImage { .load(name: "btn_scrap_dark_off") }
        static var btn_scrap_dark_on: UIImage { .load(name: "btn_scrap_dark_on") }
        static var btn_scrap_light_off: UIImage { .load(name: "btn_scrap_light_off") }
        static var btn_scrap_light_on: UIImage { .load(name: "btn_scrap_light_on") }
        static var notification_empty: UIImage { .load(name: "notification_empty") }
        static var notification_new: UIImage { .load(name: "notification_new") }
        static var img_cave_night: UIImage { .load(name: "img_cave_night") }
        static var img_cave_pink: UIImage { .load(name: "img_cave_pink") }
        static var img_cave_sunrise: UIImage { .load(name: "img_cave_sunrise") }
        static var img_cave_sunset: UIImage { .load(name: "img_cave_sunset") }
    }
    
    enum Insight {
        static var btn_down: UIImage { .load(name: "down_btn") }
        static var btn_up: UIImage { .load(name: "up_btn") }
        static var img_warning: UIImage { .load(name: "warning_img") }
    }
    
    enum ActionPlan {
        static var btn_add: UIImage { .load(name: "add_btn") }
        static var btn_more: UIImage { .load(name: "more_active_btn") }
        static var btn_folding: UIImage { .load(name: "more_default_btn") }
        static var btn_submenu: UIImage { .load(name: "submenu_btn") }
    }
    
    enum Scrap {
        static var btn_scrap_active: UIImage { .load(name: "scrap_active") }
        static var btn_scrap_default: UIImage { .load(name: "scrap_default") }
        static var seed_dark_active: UIImage { .load(name: "seed_dark_active") }
        static var seed_dark_default: UIImage { .load(name: "seed_dark_default") }
        static var seed_light_active: UIImage { .load(name: "seed_light_active") }
        static var seed_light_default: UIImage { .load(name: "seed_light_default") }
    }
    
    enum CaveDetail {
        static var btn_close: UIImage { .load(name: "close_btn") }
        static var btn_open: UIImage { .load(name: "open_btn") }
        static var img_mugwort_empty: UIImage { .load(name: "mugwort_empty_img") }
    }
    
    enum Storage {
        static var img_mugwort_empty: UIImage { .load(name: "mugwort_empty_img") }
    }
    
    enum MyPage {
        static var ic_mypage_profileImage: UIImage { .load(name: "ic_mypage").withRenderingMode(.alwaysTemplate).withTintColor(.gray100) }
    }
}
