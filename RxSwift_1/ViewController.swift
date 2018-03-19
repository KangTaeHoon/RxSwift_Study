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
    case getCheerList(game_type: String, game_num: String, seq: Int, nation_code: String, user_key: String)
    case getMatotoList
    case testList(String, Int)
}

extension API {
  
    var host: String{
        return "https://sccomment.wisetoto.com:442"
    }
    
    var path: String {
        switch self {
        case .getCheerList(let game_type, let game_num, let seq, let nation_code, let user_key):
            return "/app/query/cheer_global.php?ext=json&game_type=\(game_type)&game_num=\(game_num)&seq=\(seq)&nation_code=\(nation_code)&user_key=\(user_key)"
        case .getMatotoList:
            return "/app/renew/get_matoto.php?ext=json"
        case let .testList(user_key, seq):
            return "/app/renew/testList.php?\(user_key)&\(seq)"
        }
    }
    
    var url: URL? {
        return URL(string: "\(self.host)\(self.path)")
    }
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

protocol Times{
    func times(_ times: Int) -> Times
}

extension String: Times {
    func times(_ times: Int) -> Times {
        return Array(0..<times)
            .map { _ in self }
            .reduce(""){ $0 + $1 }
    }
}

extension Int: Times {
    func times(_ times: Int) -> Times {
        return self * times
    }
}
    
extension Times {
    func printSomeThing() {
        print("self value is: \(self)")
    }
}

protocol somethingProtocol {
    associatedtype ElementType
    func isSomething(value: ElementType)
}

indirect enum BinaryTree{
    case leaf
    case node(left: BinaryTree, right: BinaryTree, data: Int)
}


extension BinaryTree {
    func hasData(_ data: Int) -> Bool {
        switch self {
        case .leaf:
            return false
        case let .node(_,_,nodeData) where data == nodeData :
            return true
        case let .node(left,_,nodeData) where data < nodeData :
            return left.hasData(data)
        case let .node(_,right,nodeData) where data > nodeData :
            return right.hasData(data)
        case .node:
            return false
        }
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

        let closure = { (str: String) -> String in
            return "Helloㄹㅈㄹㅉㄹ \(str)"
        }
        
        func performClosure(_ c: (String) -> String){
            let result = c("Swift")
            print(result)
        }
        
        performClosure(closure)
        
        //inline closure
        performClosure { (str: String) -> String in
            return "Hello \(str)"
        }
        
        //파라미터 자료형, 리턴형 생략
        performClosure({ str in
            return "Hello \(str)"
        })
        
        //리턴 키워드 생략
        
        //파라미터의 수를 생략할수 있으면 $0로 대체
        performClosure({ "Hello \($0)" })
        performClosure() { "Hello \($0)" }
        performClosure{ "Hello \($0)" }

        

        let double: (Int) -> Int = { value in
            return value * 2
        }
        print(double(3))
        
        let multiply: (Int, Int) -> Int = { value1, value2 in
            return value1 * value2
        }
        print(multiply(2, 3))
        
        let addition: (Int, Int) -> Int = { value1, value2 in
            return value1 + value2
        }
        print(addition(2, 3))
        
        func printResultByMutableOperator(value1: Int,
                                          value2: Int,
                                          operator mutableOperator: (Int, Int) -> Int) {
            print("result: \(mutableOperator(value1, value2))")
        }
        
        printResultByMutableOperator(value1: 3, value2: 5, operator: addition)
        printResultByMutableOperator(value1: 3, value2: 5) { ($0 + $1) * $1 / $0 }
        
        3.printSomeThing()
        "my".printSomeThing()
        
        
        let tree: BinaryTree = .node(
            left: .node(left:  .node(left: .leaf, right: .leaf, data: 1),
                        right: .node(left: .leaf, right: .leaf, data: 3), data: 2),
        
            right: .node(left: .node(left: .leaf, right: .leaf, data: 5),
                         right: .node(left: .leaf, right: .leaf, data: 7), data: 6),
            data: 4)
        
        print(tree.hasData(30))
        
        print(API.getCheerList(game_type: "soccer", game_num: "20", seq: 200, nation_code: "kr", user_key: "K1234").url ?? "")
        print(API.testList("F1234", 1234).url ?? "")
        
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
        
        let filterArray2 = array.filter { $0 % 2 == 0 }
        
        print(filterArray)
        print(filterArray2)

        //nil을 걸러낸다.
        let stringArray = ["good",
                           "http://google.com" ,
                           "http://agit.io" ,
                           "some words"]
        let hosts = stringArray.flatMap { (string: String) -> String? in
            return URL(string: string)?.host
        }
        
        let hosts2 = stringArray.flatMap { URL(string: $0)?.host }
        
        print(hosts)
        print(hosts2)

        
        //[0-9] (다쪼갬), [0-9]+ (연속된숫자)
        let rexArray = matches(for: "[0-9]", in: "ab2v9bc13j5jf4jv21")
        print(rexArray)
        
        collectionExample()
        
        
        
        print("3".times(3))
        
        let ar = Array(0..<3)
        print(ar)
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
        publishSubject.onNext(20)
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
            
            //2. nil처리
            .flatMap { Range($0.range, in: string) }
            .map { String(string[$0]) }) ?? []
        
        let r = numberArray
            .flatMap{ (number: String) -> Int? in
                return Int(number)
            }
            .filter { $0 % 2 != 0 }
            .map { $0 * $0 }
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
    
    //Type Constraints
    func compare<T: Equatable>(value1: T, value2: T) -> Bool{
        return value1 == value2
    }
}

