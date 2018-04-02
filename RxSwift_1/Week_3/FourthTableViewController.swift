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
import RxDataSources

class FourthTableViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var mixButton: UIBarButtonItem!
    
    var datasources: BehaviorRelay<[NameModel]> = BehaviorRelay(value: [])
    var disposeBag: DisposeBag = DisposeBag()
    
    var names: [NameModel] = [NameModel(number: 1, name: "오진성"),
                                   NameModel(number: 2, name: "김태훈"),
                                   NameModel(number: 3, name: "유재석"),
                                   NameModel(number: 4, name: "이용주"),
                                   NameModel(number: 5, name: "김수영")]
    
//    var secondNames: [NameModel] = [NameModel(number: 5, name: "오진성"),
//                                   NameModel(number: 4, name: "김태훈"),
//                                   NameModel(number: 3, name: "유재석"),
//                                   NameModel(number: 2, name: "이용주"),
//                                   NameModel(number: 6, name: "최이슬"),
//                                   NameModel(number: 1, name: "김수영")]
    
    var secondNames: [NameModel] = [NameModel(number: 1, name: "오진성"),
                                   NameModel(number: 2, name: "김태훈"),
                                   NameModel(number: 3, name: "유재석"),
                                   NameModel(number: 4, name: "이용주"),
                                   NameModel(number: 5, name: "김수영"),
                                   NameModel(number: 6, name: "최이슬")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fourthWay()
        
    }
    
    
}

typealias NameSectionModel2 = AnimatableSectionModel<String,NameModel>

extension FourthTableViewController {
    
    func fourthWay() {

        let datasource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, NameModel>>(configureCell: { (datasource, tableView, indexPath, model) -> UITableViewCell in
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath) as! NameCell
        cell.nameLabel.text = model.name
        cell.numberLabel.text = "\(model.number)"
        return cell
            
        }, titleForHeaderInSection: { (datasource, sectionNumber) -> String? in
            return datasource.sectionModels[sectionNumber].model
        })
        
        datasources.map { 
            return [NameSectionModel2(model: "1", items: $0)]
            }.bind(to: tableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        datasources.accept(names)
    
        mixButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else {return}
            self.datasources.accept(self.secondNames)
        }).disposed(by: disposeBag)  
    }
}

extension NameModel: IdentifiableType, Equatable{
    static func ==(lhs: NameModel, rhs: NameModel) -> Bool {
        return lhs.number == rhs.number
    }
    
    var identity: Int{
        return number
    }
}

