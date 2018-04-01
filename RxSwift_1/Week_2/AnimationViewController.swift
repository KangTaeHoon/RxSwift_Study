//
//  AnimationViewController.swift
//  RxSwift_1
//
//  Created by 강태훈 on 2018. 3. 24..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import RxCocoa
import RxSwift

enum Animation {
    case left
    case right
    case up
    case down
}

extension Animation {
    func transform(_ transform: CGAffineTransform) -> CGAffineTransform {
        switch self {
        case .left:
            return transform.translatedBy(x: -50, y: 0)
        case .right:
            return transform.translatedBy(x: 50, y: 0)
        case .up:
            return transform.translatedBy(x: 0, y: -50)
        case .down:
            return transform.translatedBy(x: 0, y: 50)
        }
    }
}

//Boxing
extension Reactive where Base: UIView {
    var animation: Binder<Animation> {
        return Binder(self.base) { view, animation in
            UIView.animate(withDuration: 1, animations: {
                view.transform = animation.transform(view.transform)
            }, completion: { (result) in })
        }
    }
}

import UIKit

class AnimationViewController: UIViewController {

    @IBOutlet weak var box: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    var disposBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        // Do any additional setup after loading the view.
    }
}

extension AnimationViewController {
    func bind() {
        
        //버튼 입력을 Animation으로 변환해서 box에 bind
        leftButton.rx.tap.map{ _ -> Animation in
            return Animation.left
            }.bind(to: box.rx.animation).disposed(by: disposBag)
        
        rightButton.rx.tap.map{ Animation.right }
            .bind(to: box.rx.animation).disposed(by: disposBag)
        
        upButton.rx.tap.map{ Animation.up }
            .bind(to: box.rx.animation).disposed(by: disposBag)
        
        downButton.rx.tap.map{ Animation.down }
            .bind(to: box.rx.animation).disposed(by: disposBag)
    }
    
}
