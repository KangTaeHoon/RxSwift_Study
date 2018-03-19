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

enum API {
    case getCheerList
    case getMatotoList
}

extension API {
    
    //https://sccomment.wisetoto.com:442/app/query/cheer_global.php?ext=json&game_type=%@&game_num=%@&seq=%ld&nation_code=%@&user_key=%@
    //http://api.wisetoto.com/app/renew/get_matoto.php?user_key=%@&list_type=%@&game_category=%@&game_year=%@&game_round=%@&date=%@&os_type=i&app_version=%@
    
    var host: String{
        return "https://sccomment.wisetoto.com:442"
    }
    
    var path: String {
        switch self {
        case .getMatotoList:
            return "/app/renew/get_matoto.php"
        case .getCheerList:
            return "/app/query/cheer_global.php"
        }
    }
    
    var url: URL? {
        return URL(string: "\(self.host)\(self.path)")
    }
    
    //print(API.getCheerList.url ?? "")
    //output https://sccomment.wisetoto.com:442/app/query/cheer_global.php
}

struct Position {
    var x: Float
    var y: Float
}
extension Position {
    func transform(withOther position: Position) -> Position {
        return Position(x: self.x + position.x, y: self.y + position.y)
    }
}

protocol Times {
    func times(_ times: Int) -> Times
}

extension String: Times {
    func times(_ times: Int) -> Times {
        return Array(0..<times)
            .map { _ in
                return self
            }.reduce(""){
                $0 + $1
        }
        
        //.reduce("", +)
    }
}

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
        
        
        let array = [0,1,2,3,4,5,6,7]
        
        //return 생략 가능
        let mapArray = array.map { (item: Int) -> String in
            "\(item*10)"
        }
        print(mapArray)
        
        let mapArray2 = array.map {
            return "\($0 * 10)"
        }
        
        print(mapArray2)
        
        let mapArray3 = array.map { (item: Int) -> Bool in
            item % 2 == 0
        }
        print(mapArray3)
        
        
        let filterArray = array.filter { (item: Int) -> Bool in
            item % 2 == 0
        }
        
        print(filterArray)
        
        //nil을 걸러낸다.
        let stringArray = ["good",
                           "http://google.com" ,
                           "http://agit.io" ,
                           "some words"]
        let hosts = stringArray.flatMap { (string: String) -> String? in
            return URL(string: string)?.host
        }
        
        print(hosts)
        
        //[0-9] (다쪼갬), [0-9]+ (연속된숫자)
        let rexArray = matches(for: "[0-9]", in: "ab2v9bc13j5jf4jv21")
        print(rexArray)
        
        collectionExample()
        
        //        collectionExample()
        
        
        //        print("3".times(3))
        
        //        let position = Position(x: 10, y: 10)
        //        let newPosition = position.transform(withOther: Position(x: 30, y: 30))
        //        print(newPosition)
        
        //        print(API.getCheerList.url ?? "")
        
        //        rxCreate()
        //        rxSubject()
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
        
        
        /* question : 주어진 문자열에서 홀수인 숫자들의 제곱의 합을 출력한다.
         예) "ab2v9bc13j5jf4jv21" -> 9^2 + 13^2 + 5^2 + 21^2 = 716 */
        
        let string = "ab2v9bc13j5jf4jv21"
        
        //1. 정규식 패턴으로 숫자만 걸러낸다.
        let numberArray = (try? NSRegularExpression(pattern: "[0-9]+")
            .matches(in: string, range: NSRange(string.startIndex..., in: string))
            
            //참조: https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
            //2. nil처리
            .flatMap { Range($0.range, in: string) }
            
            .map { String(string[$0]) }) ?? []
        
        let r = numberArray
            
            .flatMap{ (number: String) -> Int? in
                return Int(number)
            }
            .filter { (value: Int) -> Bool in
                return value % 2 != 0
            }.map { $0 * $0 }
            .reduce(0, +)
        
        print(r)
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
