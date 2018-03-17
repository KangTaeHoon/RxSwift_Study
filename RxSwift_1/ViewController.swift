//
//  ViewController.swift
//  RxSwift_1
//
//  Created by 강태훈 on 2018. 3. 13..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

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
        // Do any additional setup after loading the view, typically from a nib.
        
//        rxCreate()
        rxSubject()
    }
}

extension ViewController{
    
    func rxSubject(){
        
        let publishSubject = PublishSubject<Int>()
        
        publishSubject.subscribe(subscribe).disposed(by: disposeBag)
        
        //이벤트 발행을 하기전까지는 아무일도 일어나지 않음
        
        publishSubject.on(Event.next(1))
        publishSubject.on(Event.next(2))
        publishSubject.on(Event.next(3))
        publishSubject.on(Event.completed)
        
        //completed가 일어난 다음의 이벤트는 동작하지 않는다.
        publishSubject.on(Event.next(4))

        /*output : 1
                   2
                   3
                   completed
         */
        
        let behavoirSubject = BehaviorSubject<Int>(value: 3)
        
        behavoirSubject.subscribe(subscribe).disposed(by: disposeBag)
        behavoirSubject.onNext(10)
        behavoirSubject.onNext(20)
        
        //값을 추출한다. ex)테이블 데이터의 인덱스 확인
        let midValue = (try? behavoirSubject.value()) ?? 100
        print("midValue: \(midValue)") //20
        
        //몇가지 서브젝트 종류가 더있는데 잘 사용하지 않으므로 넘어간다.
    }
    
    func rxCreate(){
        
        // 1. obervable 생성 - just
        Observable<Int>.just(1).subscribe { (event: Event) in
            
            switch event {
                
            case let .next(element):
                print("\(element)")
                
            case let .error(error):
                print(error.localizedDescription)
                
            case .completed:
                print("completed")
            }
        }.disposed(by: disposeBag)
        
        // 2. obervable 생성 - just
        Observable.from([1,2,3,4,5]).subscribe(subscribe).disposed(by: disposeBag)
        
        // 3.  obervable 생성 - empty
        // 아무 Element를 보내지않음. completed는 보냄
        Observable<Int>.empty().subscribe(subscribe).disposed(by: disposeBag)
        
        //4. obervable 생성 - never
        Observable<Int>.never().subscribe(subscribe).disposed(by: disposeBag)

        //5. obervable 생성 - error
        Observable<Int>.error(RxError.unknown).subscribe(subscribe).disposed(by: disposeBag)

        //6. observable 생성 - create
        Observable<Int>.create { (anyObserver: AnyObserver<Int>) -> Disposable in
            anyObserver.on(Event.next(1))
            anyObserver.on(Event.next(2))
            anyObserver.on(Event.next(3))
            anyObserver.on(Event.next(4))
            anyObserver.on(Event.next(5))
            anyObserver.on(Event.completed)
            return Disposables.create {
                print("dispose")
            }
        }.subscribe(subscribe).disposed(by: disposeBag)
        
        //7. observabel 생성 - repeatElement
//        Observable<Int>.repeatElement(3).subscribe(subscribe).disposed(by: disposeBag)
        Observable<Int>.repeatElement(3).take(10).subscribe(subscribe).disposed(by: disposeBag)

        //8. observabel 생성 - interval
//        Observable<Int>.interval(0.5, scheduler: MainScheduler.instance).subscribe(subscribe).disposed(by: disposeBag)
        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).take(20).subscribe(subscribe).disposed(by: disposeBag)
    }
    
    func collectionExample(){
        
        let string = "ab2v9bc13j5jf4jv21"
        let numberArray = (try? NSRegularExpression(pattern: "[0-9]+")
            .matches(in: string,
                     range: NSRange(string.startIndex..., in: string))
            .flatMap { Range($0.range, in: string) }
            .map { String(string[$0]) }) ?? []
        let r = numberArray
            .flatMap{ (number: String) -> Int? in
                return Int(number)
            }.filter { (value: Int) -> Bool in
                return value % 2 != 0
            }.map { $0 * $0 }
            .reduce(0, +)
        print(r)
    }
}

