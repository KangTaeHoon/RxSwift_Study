//
//  ImagePickerTestViewController.swift
//  RxExample
//
//  Created by leonard on 2018. 3. 24..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImagePickerTestViewController: UIViewController {

    @IBOutlet weak var showPickerButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var progressbar: UIProgressView!
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension ImagePickerTestViewController {
    func bind() {
        showPickerButton.rx.tap.asObservable().flatMapLatest { [weak self] _ -> Observable<[String: Any]> in
            return UIImagePickerController.rx.create(parent: self, animated: true, configureImagePicker: { (picker) in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
            })
            }.map { info -> UIImage? in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }.debug("UIImage")
            .subscribe( onNext: { [weak self] (image: UIImage?) in
                guard let `self` = self else { return }
                self.imageView.image = image
                self.uploadButton.isHidden = false
                self.progressbar.isHidden = false
                self.uploadButton.isEnabled = true
            }).disposed(by: disposeBag)

        //        uploadButton.rx.tap.map { [weak self] () -> UIImage? in
        //            return self?.imageView.image
        //            }.flatMap { (image) -> Observable<Float> in
        //                guard let image = image else {return Observable.empty()}
        //                return API.upload(image: image)
        //            }.bind(to: progressbar.rx.progress)
        //            .disposed(by: disposeBag)
        
        //탭 이벤트가
        //(보이드) 이미지를 리턴
        uploadButton.rx.tap.flatMap { [weak self] _ -> Observable<Void> in
            guard let `self` = self else { return Observable.empty() }
            return self.rx.showOKCancelAlert(title: "업로드", message: "업로드를 하시겠습니까?")
            }.map { [weak self] () -> UIImage? in
            return self?.imageView.image
                
            //API가 float이므로,
            }.flatMap { (image) -> Observable<Float> in
                guard let image = image else { return Observable.empty() }
                return API.upload(image: image).debug("upload")
                    
                    //do와 subscribe의 차이:
                    //subscribe는 디스포저블을 리턴하는 반면 do는 옵저버블을 리턴한다. 그래서 계속 체이닝 연결이 가능하다.
                    .do( onCompleted: { [weak self] in
                        self?.uploadButton.isEnabled = false
                })
            }.debug("uploadButton").subscribe(onNext: { [weak self] (progress) in
                self?.progressbar.progress = progress
                })
            .disposed(by: disposeBag)
        
    }
}

extension Reactive where Base: UIViewController {
    func showOKCancelAlert(title: String?, message: String?) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { _ in
                observer.onNext(())
                observer.onCompleted()
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
                observer.onCompleted()
            }))
            self.base.present(alert, animated: true, completion: nil)
            return Disposables.create {
                
            }
        })
    }
}

struct API {
    static func upload(image: UIImage) -> Observable<Float> {
        guard let data = UIImagePNGRepresentation(image) else { return Observable.empty() }
        let imageSize: Float = Float(data.count)
        return Observable<Float>.create({ (observer) -> Disposable in
            
            //func stride<T>(from start: T, to end: T, by stride: T.Stride) -> StrideTo<T> where T : Strideable
            for i in stride(from: 0, to: imageSize, by: 40) {
                observer.onNext( Float(i / imageSize) )
            }
            observer.onNext( Float(1) )
            observer.onCompleted()
            return Disposables.create {
                
            }
            
            //업로드자체는 백그라운드에서 이후 처리는 메인에서
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
    }
}
