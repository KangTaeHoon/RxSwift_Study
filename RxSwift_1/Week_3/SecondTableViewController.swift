//
//  SecondTableViewController.Swift
//  RxTableView
//
//  Created by leonard on 2018. 3. 11..
//  Copyright © 2018년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SecondTableViewController: UIViewController {
  @IBOutlet var tableView: UITableView!
  var disposeBag: DisposeBag = DisposeBag()
  var datasource: [NameModel] = [NameModel(number: 1, name: "오진성"),
                                 NameModel(number: 2, name: "김태훈"),
                                 NameModel(number: 3, name: "유재석"),
                                 NameModel(number: 4, name: "이용주"),
                                 NameModel(number: 5, name: "김수영")]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    secondWay()
    
  }
  
  
}

extension SecondTableViewController {
  
    func secondWay() {
        
        Observable<[NameModel]>.just(datasource)
            .bind(to: tableView.rx.items(cellIdentifier: "NameCell", cellType: NameCell.self)){
            (row, model, cell) in
            cell.nameLabel.text = model.name
            cell.numberLabel.text = "\(model.number)"
            }.disposed(by: disposeBag) //디스포저블을 디스포즈백에 넣는 이유는 노란줄이 뜨기 때문이다;;
        
        tableView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (indexPath) in
            guard let `self` = self else {return}
            let model = self.datasource[indexPath.row]
            let alert = UIAlertController(title: "selected item", message: model.name, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }).disposed(by: disposeBag)
    }
  
  
}

