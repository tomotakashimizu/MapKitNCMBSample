//
//  MaterialDesignButton.swift
//  MapKitNCMBSample
//
//  Created by 清水智貴 on 2021/09/20.
//

import UIKit

class MaterialDesignButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchStartAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEndAnimation()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchEndAnimation()
    }
}

// MARK: - Private functions
extension MaterialDesignButton {
    
    //角丸・影付きのボタンの生成
    @objc internal func commonInit(){
        // 角を丸くする
        self.layer.cornerRadius = 10
        
        // 影を付ける
        self.layer.shadowColor = UIColor.gray.cgColor // 影の色
        self.layer.shadowOffset = CGSize(width: 1, height: 1 ) // 影の方向（width=右方向、height=下方向）
        self.layer.shadowRadius = 5 // 影のぼかしの大きさ
        self.layer.shadowOpacity = 1.0 // 影の濃さ
    }
    
    //ボタンが押された時のアニメーション
    internal func touchStartAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95);
            self.alpha = 0.9
        },completion: nil)
    }
    
    //ボタンから手が離れた時のアニメーション
    internal func touchEndAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
            self.alpha = 1
        },completion: nil)
    }
}
