//
//  FirstTableViewController.swift
//  RxTableView
//
//  Created by leonard on 2018. 3. 11..
//  Copyright © 2018년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NameCell: UITableViewCell {
  @IBOutlet var numberLabel: UILabel!
  @IBOutlet var nameLabel: UILabel!
}

struct NameModel {
  var number: Int
  var name: String
}

class FirstTableViewController: UIViewController {
  @IBOutlet var tableView: UITableView!
  var disposeBag: DisposeBag = DisposeBag()
  var datasource: [NameModel] = [NameModel(number: 1, name: "오진성"),
                                 NameModel(number: 2, name: "김태훈"),
                                 NameModel(number: 3, name: "유재석"),
                                 NameModel(number: 4, name: "이용주"),
                                 NameModel(number: 5, name: "김수영")]
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    firstWay()
    share()
  }
    
    func share(){
        
        //1
//        Observable.just(1).debug("just").subscribe().disposed(by: disposeBag)
        
        //2
//        let observable = Observable<Int>.interval(0.3, scheduler: MainScheduler.instance)
//            .take(3).skip(1)
//            .map { (element: Int) -> Int in
//                print("map: \(element)")
//                return element
//        }
//        observable.subscribe(onNext: { element in
//            print("observable subscribe 1 : \(element)")
//        }).disposed(by: disposeBag)
//        observable
//            .subscribe(onNext: { element in
//                print("observable subscribe 2 : \(element)")
//            }).disposed(by: disposeBag)
        
        //3: connect()
//        let observable2 = Observable<Int>
//            .interval(0.3, scheduler: MainScheduler.instance).take(7).skip(2)
//            .map { (element: Int) -> Int in
//                print("map: \(element)")
//                return element
//        }
//
//        let publishObservable = observable2.publish()
//
//        publishObservable
//            .subscribe(onNext: { element in
//                print("publishObservable subscribe 1 : \(element)")
//            }).disposed(by: disposeBag)
//        publishObservable
//            .subscribe(onNext: { element in
//                print("publishObservable subscribe 2 : \(element)")
//            }).disposed(by: disposeBag)
//        publishObservable.connect().disposed(by: disposeBag)
        
        //4: ReplySubject
        //이걸 써야겠다고 생각되면 다시생각하세요. 옵저버블 공유할때 내부적으로 이게 쓰이기때문에 설명한 것임.
//        let replaySubject = ReplaySubject<Int>.create(bufferSize: 2)
//        replaySubject
//            .subscribe(onNext: { (element: Int) in
//                print("subscribe 1: \(element)")
//            }).disposed(by: disposeBag)
//        replaySubject.onNext(1)
//        replaySubject.onNext(2)
//        replaySubject.onNext(3)
//        print("\nsubscribe2")
//        replaySubject
//            .subscribe(onNext: { (element: Int) in
//                print("subscribe 2: \(element)")
//            }).disposed(by: disposeBag)
//        print("subscribe2 subscribed \n")
//        replaySubject.onNext(4)
//        replaySubject.onNext(5)
        
        //5: refCount()
//        let observable3 = Observable<Int>
//            .interval(0.3, scheduler: MainScheduler.instance).take(3).skip(1)
//            .map { (element: Int) -> Int in
//                print("map: \(element)")
//                return element
//        }
//        let refCountedPublishObservable = observable3.publish().refCount()
//        refCountedPublishObservable
//            .subscribe(onNext: { element in
//                print("refCountedPublishObservable subscribe 1 : \(element)")
//            }).disposed(by: disposeBag)
//        refCountedPublishObservable
//            .subscribe(onNext: { element in
//                print("refCountedPublishObservable subscribe 2 : \(element)")
//            }).disposed(by: disposeBag)
        
        //6 func replay(_ bufferSize: Int) -> ConnectableObservable<Double>
//        let xs = Observable.deferred { () -> Observable<TimeInterval> in
//            print("Performing work ...")
//            return Observable.just(Date().timeIntervalSince1970)
//            }
//            .replay(2)
//        _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
//        _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
//        _ = xs.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
//        xs.connect().disposed(by: disposeBag)

        //7: forever 옵저버블이 이벤트가 다 끝나더라도 그 이벤트 하나를 가지고있다.
        //그래서 그 이벤트를 섭스크라이브할때 건네준다. 끝난 옵저버블의 이벤트도 공유를 한다고 받아들이면 된다.
        let xs2 = Observable.deferred { () -> Observable<TimeInterval> in
            print("Performing work ...")
            return Observable.just(Date().timeIntervalSince1970)
            }
            .share(replay: 1, scope: .forever)
        _ = xs2.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
        _ = xs2.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
        _ = xs2.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
        
        //8: whileConnected -> 커넥트드 된 동안에만 공유를하겠다.
        let xs3 = Observable.deferred { () -> Observable<TimeInterval> in
            print("Performing work ...")
            return Observable.just(Date().timeIntervalSince1970)
            }
            .share(replay: 2, scope: .whileConnected)
        _ = xs3.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
        _ = xs3.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
        _ = xs3.subscribe(onNext: { print("next \($0)") }, onCompleted: { print("completed\n") })
        
        //아래의 둘은 상반된 개념
        //Connect <-> RefCount(디스포저블의 ARC같은 개념)
        
        //9: single()
//        Observable.just(10).asSingle().debug()
//            .subscribe(onSuccess: { (element) in
//                print("single subscribe: \(element)")
//            }, onError: { error in
//                print(error.localizedDescription)
//            }).disposed(by: disposeBag)
//        print("\n")
//        Observable.of(3,2).asSingle().debug()
//            .subscribe(onSuccess: { (element) in
//                print("single subscribe: \(element)")
//            }, onError: { error in
//                print(error.localizedDescription)
//            }).disposed(by: disposeBag)
//        print("\n")
//        Single<Int>
//            .create { (single: ( (SingleEvent<Int>) -> () ) ) -> Disposable in
//                single(SingleEvent.success(30))
//                return Disposables.create()
//            }.debug().subscribe().disposed(by: disposeBag)
        
        //10: completable -> 쓰는걸 본적이 없다고한다.
//        Completable
//            .create { completable -> Disposable in
//                completable(CompletableEvent.completed)
//                completable(CompletableEvent.error(RxError.noElements))
//                return Disposables.create()
//            }.subscribe(onCompleted: {
//                print("completed")
//            }, onError : { error in
//                print("error: \(error.localizedDescription)")
//            }).disposed(by: disposeBag)
        
        //11: maybe() -> 필요한 경우가 있겠죠?..
//        Maybe<Int>
//            .create { (maybe) -> Disposable in
//                maybe(.success(30))
//                return Disposables.create()
//            }.subscribe { (maybe) in
//                switch maybe {
//                case .success(let element):
//                    print("maybe success: \(element)")
//                case .error(let error):
//                    print("maybe error: \(error)")
//                case .completed:
//                    print("maybe complete")
//                }
//            }.disposed(by: disposeBag)

        //12: Signal()
//        let publishSubject = PublishSubject<Int>()
//        let signal = publishSubject.asSignal(onErrorJustReturn: 100)
//        signal.emit(onNext: { (element) in
//            print("emit1: \(element)")
//        }).disposed(by: disposeBag)
//        publishSubject.onNext(1)
//        publishSubject.onNext(2)
//        publishSubject.onError(RxError.unknown)
//        signal.emit(onNext: { (element) in
//            print("emit2: \(element)")
//        }).disposed(by: disposeBag)
//        publishSubject.onNext(3)
//        publishSubject.onNext(4)
        
        //13: Driver()
//        let publishSubject2 = PublishSubject<Int>()
//        let driver = publishSubject2.asDriver(onErrorJustReturn: 100)
//        driver.drive(onNext: { (element) in
//            print("drive1: \(element)")
//        }).disposed(by: disposeBag)
//        publishSubject2.onNext(4)
//        driver.drive(onNext: { (element) in
//            print("drive2: \(element)")
//        }).disposed(by: disposeBag)
//        publishSubject2.onError(RxError.noElements)
        
        
        
    }
  
  
}

extension FirstTableViewController {
    
    func firstWay() {
        Observable<[NameModel]>.just(datasource).bind(to: tableView.rx.items) {
            (tableView, index, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell") as! NameCell
            cell.nameLabel.text = model.name
            cell.numberLabel.text = "\(model.number)"
            return cell
        }.disposed(by: disposeBag)
    }
    
    
    
    
    
    
    
}

