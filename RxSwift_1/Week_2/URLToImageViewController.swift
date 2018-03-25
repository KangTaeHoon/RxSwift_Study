//
//  URLToImageViewController.swift
//  RxExample
//
//  Created by leonard on 2018. 3. 24..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class URLToImageViewController: UIViewController {
    @IBOutlet weak var urlTextFeild: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

}

/* Rx로 이미지 가져오기
 1. 버튼 탭을 TextField의 Text 이벤트로 바꾼다.
 2. Text이벤트를 URL로 변경
 3. 확장자로, 이미지가 아닌것들은 filtering
 4. URL 로 다운로드가 완료되면 Path를 이벤트로 변경
 5. Path 이벤트를 UIImage 이벤트로 변경
 6. UIImage를 UIImageView에 바인드
 */
extension URLToImageViewController {
    func bind() {
        
        // 1. 버튼 탭을 TextField의 Text 이벤트로 바꾼다.
        
        /* 플랫맵으로 데이터를 가져오는데 이것은 사이드 이펙트다.
         맵이나 플랫맵에서는 셀프가 들어가는것은 좋지않다. */
        goButton.rx.tap.withLatestFrom(self.urlTextFeild.rx.text.orEmpty)
        /* 텍스트필드의 텍스트가 바뀔때마다 이벤트가 발생하는 옵저버블
         가장마지막 이벤트를 가져온다. orEmpty <- 옵셔널 제거. */
            
            //2. Text이벤트를 URL로 변경
            .map { (text: String) -> URL in
                return try text.asURL()
                
            //3. 확장자로, 이미지가 아닌것들은 filtering
            }.filter { (url: URL) -> Bool in
                let imageExtension = ["jpg", "jpeg", "gif", "png"]
                return imageExtension.contains(url.pathExtension)

            //4. URL 로 다운로드가 완료되면 Path를 이벤트로 변경
            }.flatMap { (url: URL) -> Observable<String> in
                return Observable<String>.create({ anyObserver -> Disposable in
                    let destination = DownloadRequest.suggestedDownloadDestination()
                    let download = Alamofire.download(url, to: destination)
                        .response { (response: DefaultDownloadResponse) in
                            
                            /* alamofire의 다운로드를 사용해서 받아온 URL을 넣어주고 ,
                            데스티네이션URL의 패스를 이벤트로 발생시켜주고,
                            그렇지않으면 에러. */
                            if let data = response.destinationURL {
                                anyObserver.onNext(data.path)
                                anyObserver.onCompleted()
                            } else {
                                anyObserver.onError(RxError.unknown)
                            } }
                    return Disposables.create {
                        //중간에 디스포즈가 일어났을 상황에 다운로드중이라면, 다운을 취소시킨다.
                        download.cancel()
                    }
                })
                
            //5. Path 이벤트를 UIImage 이벤트로 변경
            }.map { (data: String) -> UIImage in
                guard let image = UIImage(contentsOfFile: data)
                    else { throw RxError.noElements }
                return image
                
            //6. UIImage를 UIImageView에 바인드
            }.bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }
}


