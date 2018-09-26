//
//  ViewController.swift
//  StarRatingView
//
//  Created by calm on 2018/9/26.
//  Copyright © 2018 calm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let starWidth: CGFloat = 20.0
    
    @IBOutlet weak var starView1: StarRatingView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    
    lazy var starView: StarRatingView = {
        $0.starSize = CGSize(width: starWidth, height: starWidth)
        $0.set(normal: #imageLiteral(resourceName: "star_normal"))
        $0.set(selected: #imageLiteral(resourceName: "star_selected"))
        $0.currentScore = 2
        $0.touchEnabled = true
        $0.slideEnabled = true
        $0.ratingType = .unlimited
        return $0
    }(StarRatingView(frame: .zero))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup()  {
        
        /// 初始化storyboards设置
        widthConstraint.constant = starView1.totalWidth
        
        starView1.currentScore = 4
        
        view.addSubview(starView)
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        starView.frame = CGRect(x: 0, y: 0, width: starView.totalWidth, height: starWidth)
        
        starView.center = view.center
    }
}

