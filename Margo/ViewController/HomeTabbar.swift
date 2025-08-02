//
//  HomeTabbar.swift
//  Margo
//
//  Created by Lenovo on 10/01/25.
//

import UIKit


import UIKit

class HomeTabbar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarShadow()
    }

    private func setupTabBarShadow() {
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBar.layer.shadowRadius = 6
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3

        tabBar.isTranslucent = false

        tabBar.backgroundColor = .white
        
        tabBar.layer.masksToBounds = false
    }
}
