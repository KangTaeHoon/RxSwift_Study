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
    firstWay()
    
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

