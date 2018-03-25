//
//  GroupListViewController.swift
//  RxExample
//
//  Created by leonard on 2018. 3. 24..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class GroupListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
}
typealias GroupSection = SectionModel<String, Group>

extension GroupListViewController {
    
    //이해하지말고, 그냥 써볼것 (섹션을 놓고싶으면 이걸 무조건 써야한다.)
    func createDatasource() -> RxTableViewSectionedReloadDataSource<GroupSection> {
        return RxTableViewSectionedReloadDataSource<GroupSection>(configureCell: { (datasource, tableView, indexPath, group) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
            cell.textLabel?.text = group.name
            return cell
        }, titleForHeaderInSection: { (datasource, index) -> String? in
            return datasource.sectionModels[index].model
        })
    }
    
    func bind() {
        
        //두 api의 값을 엮는다. //RxDatasource 사용
        let items: Observable<[GroupSection]> = Observable.zip(GroupListAPI.groupList(), GroupListAPI.categoryList()) { (groups: [Group], categories: [Category]) -> [GroupSection] in
            return categories.map { (category) -> GroupSection in
                let groups = groups.filter { $0.categoryID == category.ID }
                return GroupSection(model: category.name, items: groups)
            }
        }
        items.bind(to: tableView.rx.items(dataSource: createDatasource() ))
            .disposed(by: disposeBag)
    }
}

struct Group {
    let name: String
    let categoryID: Int
    let ID: Int
}

struct Category {
    let name: String
    let ID: Int
    let groups: [Int]
}

struct GroupListAPI {
    static func groupList() -> Observable<[Group]> {
        let groupList: [Group] =
            [Group(name: "첫번째 그룹", categoryID: 1, ID: 1),
             Group(name: "두번째 그룹", categoryID: 1, ID: 2),
             Group(name: "세번째 그룹", categoryID: 1, ID: 3),
             Group(name: "네번째 그룹", categoryID: 2, ID: 4),
             Group(name: "다섯번째 그룹", categoryID: 2, ID: 5),
             Group(name: "여섯번째 그룹", categoryID: 2, ID: 6),
             Group(name: "일곱번째 그룹", categoryID: 2, ID: 7),
             Group(name: "여덟번째 그룹", categoryID: 3, ID: 8),
             Group(name: "아홉번째 그룹", categoryID: 3, ID: 9),
             Group(name: "열번째 그룹", categoryID: 3, ID: 10),
             Group(name: "열한번째 그룹", categoryID: 3, ID: 11),
             Group(name: "열두번째 그룹", categoryID: 4, ID: 12),
             Group(name: "열세번째 그룹", categoryID: 4, ID: 13)]
        return Observable.just(groupList).delay(0.5, scheduler: MainScheduler.instance)
    }
    
    static func categoryList() -> Observable<[Category]> {
        let categoryList: [Category] =
            [Category(name: "첫번째 카테고리", ID: 1, groups: [1,2,3]),
             Category(name: "두번째 카테고리", ID: 2, groups: [4,5,6,7]),
             Category(name: "세번째 카테고리", ID: 3, groups: [8,9,10,11]),
             Category(name: "네번째 카테고리", ID: 4, groups: [12,13])]
        return Observable.just(categoryList).delay(0.7, scheduler: MainScheduler.instance)
    }
}
