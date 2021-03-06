//
//  EventViewController.swift
//  RxSwift_1
//
//  Created by 강태훈 on 2018. 3. 17..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EventViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    var disposeBag = DisposeBag()

    let subscribe: (Event<Int>) -> Void = { (event: Event) in
        switch event {
        case let .next(element):
            print("\(element)")
        case let .error(error):
            print(error.localizedDescription)
        case .completed:
            print("completed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        gugudan()
        bind2()
        //        bind()
    }
}

extension EventViewController{
    
    func gugudan(){
        
        let observable = textField.rx.text.orEmpty.map { Int($0) ?? 0}
        
        observable.map { (number) -> String in
            
            Array(1...9).map{ step -> String in
                return "\(number) * \(step) = \(step*number)\n"
                }.reduce("", +)
            
            }.subscribe(onNext: { [weak self] result in
                self?.textLabel.text = result
            }).disposed(by: disposeBag)
    }
    
    func bind2(){
        
        let firstNumberObservable = textField.rx.text.orEmpty.map { Int($0) ?? 0}
        let secondNumberObservable = textField2.rx.text.orEmpty.map { Int($0) ?? 0}
        
        //Merge: 이벤트 타입이 같은 옵저버블 여러개를 합친다.
        //        Observable
        //            .merge( [firstNumberObservable, secondNumberObservable])
        //            .subscribe( onNext: { [weak self] result in
        //                self?.textLabel.text = "\(result)"
        //            }).disposed(by: disposeBag)
        
        //Zip : 여러옵저버블에서 이벤트를 한쌍씩 순서대로 합친다.
        //        Observable
        //            .zip( [firstNumberObservable, secondNumberObservable])
        //            .subscribe( onNext: { [weak self] result in
        //                self?.textLabel.text = "\(result)"
        //            }).disposed(by: disposeBag)
        
        //CombineLatest : 여러 옵저버블에서 가장 최근 이벤트들을 합친다.
        Observable<String>
            .combineLatest(firstNumberObservable, secondNumberObservable) { (first, second) -> String in
                return "\(first)\(second)"
            }.subscribe(onNext:{ [weak self] result in
                self?.textLabel.text = "\(result)"
            }).disposed(by: disposeBag)
    }
    
    func bind(){
        
        //asObservable() 제거해도 동일
        textField.rx.text.asObservable().map{ text -> String in
            let string = text ?? ""
            return "\(string)\(string)"
            }
            .subscribe { [weak self] (event) in
                //            if case .next(let element) = event.element{
                self?.textLabel.text = event.element
                //            }
            }.disposed(by: disposeBag)
        
        
        button.rx.tap.asObservable().flatMap { _ -> Observable<String> in
            return Observable<String>.just("강태훈")
            
            }.subscribe { [weak self] (event) in
                if case .next(let element) = event{
                    self?.textLabel.text = element
                }
            }.disposed(by: disposeBag)
    }
}

