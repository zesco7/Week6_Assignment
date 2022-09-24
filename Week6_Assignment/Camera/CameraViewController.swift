//
//  CameraViewController.swift
//  Week6_Assignment
//
//  Created by Mac Pro 15 on 2022/09/23.
//

import UIKit

import Alamofire
import SwiftyJSON
import YPImagePicker

/*카메라 순서
 1. 이미지 관련 이벤트 관리하는 인스턴스 생성
 2,3. 프로토콜 연결, 선언
 4,5. 버튼 클릭시 뷰실행 기능 추가(사진선택하거나 카메라 촬영할 때 새 화면 열리는 것), 취소버튼 클릭시 실행 기능 추가
 */

/*카메라 포인트
 -.사진 저장할 때 저장결과에 대한 알림 필요: 알림 없으면 갤러리에 불필요하게 많은 사진 저장 할 수 있음
 -.dismiss코드 직접 구현해줘야 함: dismiss코드를 직접 추가하지 않으면 화면 전환이 이뤄지지 않아서 메서드실행결과를 확인할 수 없음
 -.단순히 사진 가지고 오는 기능은 권한 필요없음(ex.다이어리앱에 사진등록하기)
 */
class CameraViewController: UIViewController {

    @IBOutlet weak var resultImageView: UIImageView!
    
    //UIImagePickerController1. 이미지 관련 이벤트 관리하는 인스턴스 생성
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UIImagePickerController2. 프로토콜 연결
        picker.delegate = self  //피커에 딜리게이트 연결하는 이유?
        
    }
    
    //YPImagePicker 라이브러리 사용: YPImagePicker에 권한요청이 내부구현되어있기 때문에 지도처럼 따로 권한요청코드를 추가하지 않아도 됨
    @IBAction func YPImagePickerButtonClicked(_ sender: UIButton) {
        let picker = YPImagePicker()
        //let picker = YPImagePicker(configuration: <#T##YPImagePickerConfiguration#>) //configuration통해 추가기능 사용가능(필터이미지 갤러리 저장 등)
        picker.didFinishPicking { [unowned picker] items, _ in //사진선택 -> 사진정보확인 -> 사진제거 구조로 실행
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
                
                self.resultImageView.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }

    @IBAction func cameraButtonClicked(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { //카메라 기능지원여부 체크
            print("사용불가 + 사용자에게 토스트/얼럿")
            return
        }
        picker.sourceType = .camera //실행할 기능 설정
        picker.allowsEditing = true //촬영 후 편집 기능 추가
        
        present(picker, animated: true) //카메라 기능 있으면 picker 실행
    }
    
    @IBAction func photoButtonClicked(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("사용불가 + 사용자에게 토스트/얼럿")
            return
        }
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    @IBAction func saveToPhotoLibrary(_ sender: UIButton) {
        print(#function)
        if let image = resultImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) //isSourceTypeAvailable대신 사용하는 사진저장메서드
        }
    }
  
    /*클로버 얼굴인식 포인트
     -.이미지뷰에 있는 이미지를 네이버에 얼굴분석 네트워크 요청
     -.문자열이 아닌 파일(이미지,pdf 등)은 네트워크 통신 요청 시 인코딩처리 명령을 추가해주어야 함: 파일 그대로가 아니라 텍스트로 인코딩되어 전송되기 때문
     -.서버로 전달되는 파일 종류를 헤더에 명시해야 하지만(content-type) alamofire라이브러리에서 기본적으로 제공하기 때문에 생략 가능
     -.멀티파트폼 데이터 타입 확인방법? MIME에서 확인
     -.네트워크통신 성공여부를 확인하려면 print로 결과값 꼭 확인!!!!!!!!
    */
    @IBAction func clovaFaceButtonClicked(_ sender: UIButton) {
        print(#function)
        let url = "https://openapi.naver.com/v1/vision/celebrity" //유명인 얼굴 인식 API
        let header: HTTPHeaders = [
            "X-Naver-Client-Id": "tfYqqDDQUPRUW3CIm5x4",
            "X-Naver-Client-Secret": "NAoG26YRAW",
            //"Content-Type": "multipart/form-data"
        ]
        
        //네트워크 통신 요청시 UIImage를 텍스트 형태로 인코딩하는 명령 추가
        guard let imageData = resultImageView.image?.pngData() else { return } //전송파일이 이미지 데이터인 경우 인코딩 실행
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "image") //전송파일을 추가하고 api사용설명서에 따라 메시지 이름을 image로 설정
        }, to: url, headers: header).validate(statusCode: 200...500).responseData { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

//UIImagePickerController3. 프로토콜 선언(네비게이션 등록한 이유: 네비게이션컨트롤러 상속받고 있기 때문)
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //UIImagePickerController4. 버튼 클릭시 뷰실행 기능 추가(사진선택하거나 카메라 촬영할 때 새 화면 열리는 것)
    //infoKey: 원본, 편집, 메타데이터 등 가지고 있는 딕셔너리
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(#function)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { //editedImage는 갤러리에서 선택안됨. 메서드 실행기준으로 편집사진이 아니기 때문에 nil값이라 타입캐스팅이 안되기 때문. originalImage는 갤러리 선택 가능.
            self.resultImageView.image = image //편집한 사진을 이미지로 띄움
            dismiss(animated: true) //화면닫기기능없으면 이미지선택 후 이전화면으로 돌아가지 않기 때문에 dismiss 코드 필요.
        }
    }
    
    //UIImagePickerController5. 취소버튼 클릭시 실행 기능 추가
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(#function)
        dismiss(animated: true) //dismiss코드를 직접 추가하지 않으면 취소버튼 작동 안함
    }
}

