//
//  StarRating.swift
//  Star
//
//  Created by 方林威 on 2018/6/27.
//  Copyright © 2018年 DeyiLife. All rights reserved.
//


import UIKit

protocol StarRatingDelegate: NSObjectProtocol {
    
    /// 当前分数变更回调
    func current(scoreChange score: CGFloat)
}

class StarRatingView: UIView {
    
    enum RatingType {
        case whole          // 整颗星星
        case half           // 半颗星星
        case unlimited      // 无限制
    }
    
    weak var delegate: StarRatingDelegate?
    
    /// 星星总个数 只有初始化设置
    @IBInspectable
    var count: Int = 5 {
        didSet {
            assert(count > 0, "星星总个数不能小于1")
            setup(stars: count)
            layoutSubviews()
            update(currentScore/maxScore)
        }
    }

    /// 已选中星星图片
    @IBInspectable
    private(set) var selectedImage: UIImage?
    
    /// 未选中星星图片
    @IBInspectable
    private(set) var normalImage: UIImage?
    
    /// 是否开启分数动画  默认开启
    @IBInspectable
    var starAnimation: Bool = true
    
    /// 间距 默认 5.0
    @IBInspectable
    var spacing: CGFloat = 5.0 {
        didSet {
            
            spacing = max(spacing, 0)
        }
    }
    
    /// 最大分数 (初始化后设置 , 默认 5.0)
    @IBInspectable
    var maxScore: CGFloat = 5.0 {
        didSet {
            assert(minScore >= 0, "最小分数不能小于0")
        }
    }
    
    /// 最小分数 (初始化后设置 , 默认 0.0)
    @IBInspectable
    var minScore: CGFloat = 0.0 {
        didSet {
            assert(maxScore >= 0, "最大分数不能小于0")
            
            assert(maxScore > minScore, "最大分数不能小于最小分数")
        }
    }
    
    /// 启用点击 (初始化后设置 , 默认 NO)
    @IBInspectable
    var touchEnabled: Bool = false {
        didSet {
            if touchEnabled {
                isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureEvent))
                addGestureRecognizer(tapGesture)
            }
            isUserInteractionEnabled = touchEnabled || slideEnabled
        }
    }
    
    /// 启用滑动 (初始化后设置 , 默认 NO)
    @IBInspectable
    var slideEnabled: Bool = false {
        didSet {
            if slideEnabled {
                isUserInteractionEnabled = true
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureEvent))
                addGestureRecognizer(panGesture)
            }
            isUserInteractionEnabled = touchEnabled || slideEnabled
        }
    }
    
    /// 评分类型 (初始化后设置 , 默认 whole)
    var ratingType: RatingType = .unlimited
    
    var currentScore: CGFloat = 0.0 {
        didSet {
            
            var score = currentScore
            
            assert(minScore <= score, "当前分数小于最小分数")
            
            assert(maxScore >= score, "当前分数大于最大分数")
            
            score = max(score, minScore)
            
            score = min(score, maxScore)
            
            currentScore = score
            update(currentScore / maxScore)
        }
    }
    
    private lazy var normalView: UIView = UIView()
    
    private lazy var selectedView: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    
    /// 星星大小  默认图片大小
    var starSize: CGSize = CGSize(width: 24.0, height: 24.0)
    
    var totalWidth: CGFloat {
        return (starSize.width + spacing) * count.f + spacing
    }

    /// count 个数 (默认为 5)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setup(stars: count)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        setupLayout()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup(stars: count)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
    }
    
    private func setupUI()  {
        
        addSubview(normalView)
        
        addSubview(selectedView)
    }
    
    private func setup(stars count: Int) {
        
        normalView.subviews.forEach({ $0.removeFromSuperview()})
        selectedView.subviews.forEach({ $0.removeFromSuperview()})
        
        // 循环初始化已选中和未选中子视图
        (0 ..< count).forEach { (_) in
            let normal = UIImageView(image: normalImage)
            normalView.addSubview(normal)
            
            let selected = UIImageView(image: selectedImage)
            selectedView.addSubview(selected)
        }
    }
}


extension StarRatingView {
    
    public func set(selected image: UIImage?) {
        
        guard let image = image else { return }
        
        selectedView.subviews.forEach({ ($0 as! UIImageView).image = image })
    }
    
    public func set(normal image: UIImage?) {
        
        guard let image = image else { return }
        
        normalView.subviews.forEach({ ($0 as! UIImageView).image = image })
    }
}
extension StarRatingView {
    @objc private func tapGestureEvent(_ tap: UITapGestureRecognizer) {
        
        let point: CGPoint = tap.location(in: self)
        update(ratio(for: point))
    }
    @objc private func panGestureEvent(_ pan: UIPanGestureRecognizer) {
        let point: CGPoint = pan.location(in: self)
        update(ratio(for: point))
    }
}

extension StarRatingView {
    
    private func setupLayout()  {
        
        guard
            !normalView.subviews.isEmpty,
            !selectedView.subviews.isEmpty
        else { return }
        
        // 宽度或高度发生改变 更新子视图布局
//        guard
//            normalView.bounds.width != frame.width ||
//            normalView.bounds.height != starSize.height
//            else { return }

        normalView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: starSize.height)
        
        normalView.center.y = frame.height * 0.5
        
        selectedView.frame = CGRect(x: 0,
                                    y: normalView.frame.minY,
                                    width: selectedView.bounds.width,
                                    height: starSize.height)
        
        
        for i in 0 ..< count {
            
            let normalImageView = normalView.subviews[i]
            
            let selectedImageView = selectedView.subviews[i]
            
            let x = (starSize.width + spacing) * i.f + spacing
            let imageFrame = CGRect(x: x, y: 0, width: starSize.width, height: starSize.height)
            
            normalImageView.frame = imageFrame
            
            selectedImageView.frame = imageFrame
        }
    }
    
    private func ratio(for point: CGPoint) -> CGFloat {
        // 坐标 转 所选中的比例
        var ratio: CGFloat = 0.0
        
        if (spacing > point.x) {
            
            ratio = 0.0
            
        } else if (frame.width - spacing < point.x) {
            
            ratio = 1.0
            
        } else {
            
            /* 比例转换
             *
             * 当前点击位置在当前视图宽度中的比例 转换为 当前点击星星位置在全部星星宽度中的比例
             * 当前点击位置去除其中的间距宽度等于星星的宽度 point.x - 间距 = 所选中的星星宽度
             * 所选中的星星宽度 / 所有星星宽度 = 当前选中的比例
             */
            let itemWidth = spacing + starSize.width
            
            let icount = point.x / itemWidth

            let count = icount.rounded(.down)
            
            var added = (itemWidth * (icount - count))
            
            added = min(spacing, added)
            let x = point.x - spacing * count - added
            
            ratio = x / (starSize.width * self.count.f)
        }
 
        if (minScore != 0) {
            let minRatio = minScore / maxScore
            ratio = max(ratio, minRatio)
        }
        
        return ratio
    }

    /// 更新星星视图 传入当前所选中的比例值
    private func update(_ ratio: CGFloat) {
        
        guard (0...1).contains(ratio)   else {
            return
        }
        
        var ratio: CGFloat = ratio
        
        var width: CGFloat = 0.0
        
        
        switch (ratingType) {
        case .whole:
            
            ratio = (count.f * ratio).rounded(.up)
            
            width = starSize.width * ratio + (spacing * ratio.rounded())
            
        case .half:
            
            ratio = count.f * ratio
            
            let z: CGFloat = ratio.rounded(.down)
            
            let s: CGFloat = ratio - z
            
            if (s > 0.5) { ratio = z + 1.0 }
            
            if (s <= 0.5 && s >= 0.001) { ratio = z + 0.5 }
            
            width = starSize.width * ratio + (spacing * ratio.rounded())
            
        case .unlimited:
            
            ratio = count.f * ratio
            
            width = starSize.width * ratio + (spacing * ratio.rounded(.up))
        }
        
        // 设置宽度
        
        if (width < 0) { width = 0 }
        
//        if (width > frame.width) { width = self.frame.width }
        
        let time: TimeInterval = starAnimation ? 0.3 : 0
        
        UIView.animate(withDuration: time) {
            self.selectedView.frame.size.width = width
        }

        
        // 设置当前分数
        let numRatio: NSDecimalNumber = NSDecimalNumber(string: String(format: "%.4lf", ratio / count.f))
        
        let numScore: NSDecimalNumber = NSDecimalNumber(string: String(format: "%.4lf", maxScore))

        let numResult: NSDecimalNumber = numRatio.multiplying(by: numScore)
        
        var currentScore: CGFloat = numResult.floatValue.f
        
        currentScore = max(currentScore, minScore)
        
        currentScore = min(currentScore, maxScore)
        
        if (self.currentScore != currentScore) {
            
            self.currentScore = currentScore
            
            delegate?.current(scoreChange: currentScore)
        }
    }
}

fileprivate extension IntegerLiteralType {
    var f: CGFloat {
        return CGFloat(self)
    }
}

fileprivate extension FloatLiteralType {
    var f: CGFloat {
        return CGFloat(self)
    }
}
fileprivate extension Float32 {
    var f: CGFloat {
        return CGFloat(self)
    }
}

