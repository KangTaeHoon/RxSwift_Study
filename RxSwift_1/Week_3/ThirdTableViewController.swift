//
//  ThirdTableViewController.swift
//  RxTableView
//
//  Created by leonard on 2018. 3. 11..
//  Copyright © 2018년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ThirdTableViewController: UIViewController {
  @IBOutlet var tableView: UITableView!
  @IBOutlet weak var mixButton: UIBarButtonItem!
    
    var datasources: BehaviorRelay<[NameModel]> = BehaviorRelay(value: [])
    var disposeBag: DisposeBag = DisposeBag()
    //디스포즈백은 뷰컨트롤러의 프로퍼티다. 그래서 뷰컨이 디얼록이되면 사라진다. 이 백이 가지고 있던 것들은 다 사라짐.

    var names: [NameModel] = [NameModel(number: 1, name: "오진성"),
                                 NameModel(number: 2, name: "김태훈"),
                                 NameModel(number: 3, name: "유재석"),
                                 NameModel(number: 4, name: "이용주"),
                                 NameModel(number: 5, name: "김수영")]

    var secondNames: [NameModel] = [NameModel(number: 5, name: "오진성"),
                                       NameModel(number: 4, name: "김태훈"),
                                       NameModel(number: 3, name: "유재석"),
                                       NameModel(number: 2, name: "이용주"),
                                       NameModel(number: 6, name: "최이슬"),
                                       NameModel(number: 1, name: "김수영")]
  
  //    var secondDatasource: [NameModel] = [NameModel(number: 1, name: "오진성"),
  //                                   NameModel(number: 2, name: "김태훈"),
  //                                   NameModel(number: 3, name: "유재석"),
  //                                   NameModel(number: 4, name: "이용주"),
  //                                   NameModel(number: 5, name: "김수영"),
  //                                   NameModel(number: 6, name: "최이슬")]
  
    override func viewDidLoad() {
    super.viewDidLoad()
    thirdWay()
    }
  
  
}

typealias NameSectionModel = SectionModel<String,NameModel>

//디스포저블이 안된 옵저버블 실습
extension ThirdTableViewController {
    func thirdWay() {
        
        //dispose 안해도되지만 경고가 뜰 것임.
//        Observable<Int>.just(10000)
//            .debug()
//            .subscribe()
        
//        Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
//            .debug()
//            .subscribe()
//            .disposed(by: disposeBag)

        let dataSource = RxTableViewSectionedReloadDataSource<NameSectionModel>(configureCell: { (datasource, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath) as! NameCell
            cell.nameLabel.text = model.name
            cell.numberLabel.text = "\(model.number)"
            return cell
            
        }, titleForHeaderInSection: { (datasource, sectionNumber) -> String? in
            return datasource.sectionModels[sectionNumber].model
        })
        
//        Observable<[NameModel]>.just(names).map {
//            return [SectionModel<String, NameModel>(model: "1", items: $0),
//                    SectionModel<String, NameModel>(model: "2", items: $0)]
//        }.bind(to: tableView.rx.items(dataSource: dataSource))
//        .disposed(by: disposeBag)
        
        datasources.map {
            return [NameSectionModel(model: "1", items: $0),
                    NameSectionModel(model: "2", items: $0)]
            }.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        datasources.accept(names)
        
        mixButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else {return}
            self.datasources.accept(self.secondNames)
        }).disposed(by: disposeBag)
        
        
    }
}

