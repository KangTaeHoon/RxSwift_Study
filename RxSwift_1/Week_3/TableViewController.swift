//
//  TableViewController.swift
//  RxTableViewPractice
//
//  Created by leonard on 2018. 3. 30..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TableNameCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

class TableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var disposeBag = DisposeBag()
    var datasources: BehaviorRelay<[String]> = BehaviorRelay(value: ["오진성", "김창대", "강태훈", "강수민", "남덕호", "신정열", "윤진호", "이종은", "한진우", "장선혜", "은소영"])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        bind()
    }    
}

typealias NameSectionModels = AnimatableSectionModel<String, String>

extension TableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func bind() {
        //과제
        
        let originSource = self.datasources.value
        
        searchBar.rx.text.orEmpty
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (text) in
                guard let `self` = self else { return }
                if text.isEmpty {
                    self.datasources.accept(originSource)
                }else{
                    let showNames = originSource.filter{ $0.contains(text) }
                    self.datasources.accept(showNames)
                }
            }).disposed(by: disposeBag)
        
        
        addButton.rx.tap
            .flatMap { [weak self] _ -> Observable<String> in
                
                guard let `self` = self else { return Observable.empty() }
                return self.textFieldAlert(title: "입력" , message: "추가할 이름을 입력하세요")
                
            }.subscribe(onNext: { [weak self] name in
                guard let `self` = self else { return }
                var names = self.datasources.value
                names.append(name)
                self.datasources.accept(names)
            }).disposed(by: disposeBag)
        
        datasources.map { [NameSectionModels(model: "", items: $0)]
            }.bind(to: tableView.rx.items(dataSource: createDatasources()))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asObservable(
            ).withLatestFrom(datasources.asObservable()) { (indexPath: IndexPath, names: [String]) -> (IndexPath, String) in
                return (indexPath, names[indexPath.row])
            }.flatMap { [weak self] (indexPath, name) -> Observable<(IndexPath, String)> in
                guard let `self` = self else { return Observable<(IndexPath, String)>.empty() }
                return self.textFieldAlert(title: "입력", message: "변경할 이름을 입력하세요.", indexPath: indexPath, inputText: name)
            }.subscribe(onNext: { [weak self] (indexPath, name) in
                guard let `self` = self else { return }
                var names = self.datasources.value
                names[indexPath.row] = name
                self.datasources.accept(names)
            }).disposed(by: disposeBag)
        
        editButton.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.asObservable().subscribe(onNext: {[weak self] (indexPath) in
            guard let `self` = self else { return }
            var names = self.datasources.value
            names.remove(at: indexPath.row)
            self.datasources.accept(names)
        }).disposed(by: disposeBag)
        
        tableView.rx.itemMoved.asObservable().subscribe(onNext: { [weak self] (sourceIndexPath, destinationIndexPath) in
            guard let `self` = self else { return }
            
            var names = self.datasources.value
            let currentName = self.datasources.value[sourceIndexPath.row]
            names.remove(at: sourceIndexPath.row)
            names.insert(currentName, at: destinationIndexPath.row)            
            self.datasources.accept(names)
            
        }).disposed(by: disposeBag)
    }
    
    
    func createDatasources() -> RxTableViewSectionedAnimatedDataSource<NameSectionModels> {
        let datasource = RxTableViewSectionedAnimatedDataSource<NameSectionModels>(configureCell: { (datasource, tableView, indexPath, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableNameCell", for: indexPath)
            cell.textLabel?.text = model
            return cell
        }, canEditRowAtIndexPath: { (datasource, indexPath) -> Bool in
            return true
        }, canMoveRowAtIndexPath: { (datasource, indexPath) -> Bool in
            return true
        })
        return datasource
    }
    
    func textFieldAlert(title: String? , message: String?) -> Observable<String> {
        return Observable<String>.create{ [weak self] (observer) -> Disposable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                
            })
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
                let text: String = alert.textFields?[0].text ?? ""
                observer.onNext(text)
                observer.onCompleted()
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
            }
        }
    }
    
    func textFieldAlert(title: String? , message: String?, indexPath: IndexPath, inputText: String) -> Observable<(IndexPath, String)> {
        return Observable<(IndexPath, String)>.create{ [weak self] (observer) -> Disposable in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = inputText
            })
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
                let text: String = alert.textFields?[0].text ?? ""
                observer.onNext( (indexPath, text) )
                observer.onCompleted()
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
            }
        }
    }
    
}
