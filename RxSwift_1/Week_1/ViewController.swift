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

//MARK: - Enumerate Pattern + Extension
//enum API {
//    case getCheerList(game_type: String, game_num: String, seq: Int, nation_code: String, user_key: String)
//    case getMatotoList(user: String)
//    case testList(String, Int)
//}

//extension API {
//
//    var host: String{
//        return "https://sccomment.wisetoto.com:442"
//    }
//
//    var path: String {
//        switch self {
//        case let .getCheerList(game_type, game_num, seq, nation_code, user_key):
//            return "/app/query/cheer_global.php?ext=json&game_type=\(game_type)&game_num=\(game_num)&seq=\(seq)&nation_code=\(nation_code)&user_key=\(user_key)"
//        case let .getMatotoList(user):
//            return "/app/renew/get_matoto.php?ext=json&=user=\(user)"
//        case let .testList(user_key, seq):
//            return "/app/renew/testList.php?\(user_key)&\(seq)"
//        }
//    }
//
//    var url: URL? {
//        return URL(string: "\(self.host)\(self.path)")
//    }
//}

//MARK: - Struct Extension
struct Position {
    var x: Float
    var y: Float
}
extension Position {
    func transform(withOther position: Position) -> Position {
        return Position(x: self.x + position.x, y: self.y + position.y)
    }
}

//MARK: - Protocol Extension
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

//MARK: - Protocol Generic + associatedtype
protocol somethingProtocol {
    associatedtype T
    func isSomething(value: T)
}

//MARK: - indirect
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
    
    //Subscribe
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
        
        print(3.times(3))
        print("3".times(3))
        3.printSomeThing()
        "my".printSomeThing()
        
//        print(API.getCheerList(game_type: "soccer", game_num: "20", seq: 200, nation_code: "kr", user_key: "K1234").url ?? "")
//        print(API.testList("F1234", 1234).url ?? "")
        
        let tree: BinaryTree = .node(
            left: .node(left:  .node(left: .leaf, right: .leaf, data: 1),
                        right: .node(left: .leaf, right: .leaf, data: 3), data: 2),
            
            right: .node(left: .node(left: .leaf, right: .leaf, data: 5),
                         right: .node(left: .leaf, right: .leaf, data: 7), data: 6),
            data: 4)
        
        print(tree.hasData(30))
        
        //기본 클로저 형태
        // { (파라미터 명 : 타입) -> 리턴타입 in
        //    return ""
        // }
        
        // 클로저를 변수에 담음
        let closure = { (str: String) -> String in
            return "Hello \(str)"
        }
        
        print(closure("a"))
        
        //함수의 파라미터로 클로저를 받음
        func performClosure(_ c: (String) -> String){
            let result = c("Swift")
            print(result)
        }
        
        performClosure(closure)
        
        //인라인 클로저
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
        
        let array = [0,1,2,3,4,5,6,7]
        
        //map
        let mapArray = array.map { (item: Int) -> String in
            "\(item*10)"
        }
        print(mapArray)
        
        let mapArray2 = array.map { "\($0 * 10)" }
        print(mapArray2)
        
        //filter
        let filterArray = array.filter { (item: Int) -> Bool in
            item % 2 == 0
        }
        print(filterArray)
        
        let filterArray2 = array.filter { $0 % 2 == 0 }
        print(filterArray2)
        
        //flatmap -> nil을 걸러낸다.
        let stringArray = ["good",
                           "http://google.com" ,
                           "http://agit.io" ,
                           "some words"]
        let hosts = stringArray.flatMap { (string: String) -> String? in
            return URL(string: string)?.host
        }
        print(hosts)
        
        let hosts2 = stringArray.flatMap { URL(string: $0)?.host }
        print(hosts2)
        
        let rexArray = matches(for: "[0-9]+", in: "ab2v9bc13j5jf4jv21")
            .flatMap{ Int($0) }
            .filter { (number: Int) -> Bool in return number % 2 != 0 }
            .map{ $0 * $0 }
            .reduce(0, +)
        print(rexArray)
        
        
        //        rxCreate()
        //        rxSubject()
    }
}

extension ViewController{
    
    func rxSubject(){
        
        /*
         보통의 앱개발에서 필요한 것은 실시간으로 Observable에 새로운 값을 수동으로 추가하고 subscriber에게 방출하는 것
         다시 말하면, Observable이자 Observer인 녀석이 필요하다. 이 것을 Subject라고 부른다.
         Subject = Observable + Observer (와 같이 행동한다)
         Subject는 .next 이벤트를 받고, 이런 이벤트를 수신할 때마다 subscriber에 방출한다.
         
         RxSwift에는 4가지 타입의 subject가 있다.
         PublishSubject: 빈 상태로 시작하여 새로운 값만을 subscriber에 방출한다.
         BehaviorSubject: 하나의 초기값을 가진 상태로 시작하여, 새로운 subscriber에게 초기값 또는 최신값을 방출한다.
         ReplaySubject: 버퍼를 두고 초기화하며, 버퍼 사이즈 만큼의 값들을 유지하면서 새로운 subscriber에게 방출한다.
         Variable: BehaviorSubject를 래핑하고, 현재의 값을 상태로 보존한다. 가장 최신/초기 값만을 새로운 subscriber에게 방출한다. */
        
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
        
        //        Observable은 어떤 구성요소를 가지는 next 이벤트를 계속해서 방출할 수 있다.
        //        Observable은 error 이벤트를 방출하여 완전 종료될 수 있다.
        //        Observable은 complete 이벤트를 방출하여 완전 종료 될 수 있다.
        
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
            anyObserver.onNext(1)
            anyObserver.on(Event.next(2))
            anyObserver.on(Event.next(3))
            anyObserver.onNext(4)
            anyObserver.on(Event.next(5))
            anyObserver.on(Event.completed)
            //            anyObserver.onCompleted()
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
        // regpattern: [0-9] (다쪼갬), [0-9]+ (연속된숫자)
        
        let string = "ab2v9bc13j5jf4jv21"
        
        //1. 정규식 패턴으로 숫자만 걸러낸다.
        let numberArray = (try? NSRegularExpression(pattern: "[0-9]+")
            .matches(in: string, range: NSRange(string.startIndex..., in: string))
            .flatMap { Range($0.range, in: string) }
            .map { String(string[$0]) }) ?? []
        
        let r = numberArray
            .flatMap{ (number: String) -> Int? in
                return Int(number)
            }
            .filter { $0 % 2 != 0 }
            .map { $0 * $0 }
            .reduce(0) { $0 + $1 }
        
        print(r)
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.flatMap { Range($0.range, in: text)
                .map { String(text[$0]) }
            }
            
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    //MARK: - Type Constraints
    func compare<T: Equatable & Comparable>(value1: T, value2: T) -> Bool{
        return value1 == value2
    }
}

