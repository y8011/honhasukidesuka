//
//  ViewController.swift
//  honhaSukidesuka
//
//  Created by yuka on 2018/01/10.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController
, AVCaptureMetadataOutputObjectsDelegate
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
{
    
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var resultTextLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    
    var moveDisplay:Bool = true
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorsTextField: UITextField!
    @IBOutlet weak var recomendTextView: UITextView!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookUrlTextField: UITextField!
    
    var bookTitle:String = ""
    var bookAuthor:String = ""
    var bookImageURL:String = ""
    var bookAmazonURL:String = ""
    var bookISDN:String = ""
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()

        bookImageView.layer.borderWidth = 0.2
        bookImageView.layer.cornerRadius = 5
        recomendTextView.layer.borderWidth = 0.2
        recomendTextView.layer.cornerRadius = 5
        submitButton.layer.cornerRadius = 5
        submitButton.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
        self.configureObserver()
        
    }

    var onetime:Bool = true
    override func viewDidLayoutSubviews() {
        print(#function)
        super.viewDidLayoutSubviews()
        if onetime == true {
            setUpBarCode()
            onetime = false
        }


    }
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
        captureView.layer.cornerRadius = 10
        captureView.layer.masksToBounds = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)

        super.viewWillDisappear(animated)
        self.removeObserver() // Notificationを画面が消えるときに削除
    }
    
    //==============================
    // MARK:Gesture
    //==============================
    //リターンでキーボードを閉じる
    @IBAction func editDidEndOnExit(_ sender: UITextField) {
        switch sender.tag {
        case 1:
            authorsTextField.becomeFirstResponder()
        case 2:
            sender.endEditing(true)

        default:
            sender.endEditing(true)
        }
    }
    
    //おすすめ理由以外は、画面をずらさないようにするためのフラグ
    @IBAction func touchDown(_ sender: UITextField) {
        moveDisplay = false
    
    }
    
    // 他のビューを触ったら、キーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        moveDisplay = true
    }
    
    @IBAction func tapSubmitButton(_ sender: Any) {
        let myCoreData:ingCoreData = ingCoreData()
        let myLocalImage:ingLocalImage = ingLocalImage()
        let newrid = myCoreData.insertRecommend(title: titleTextField.text!, author: authorsTextField.text!, recommendation: recomendTextView.text!,link: bookAmazonURL)
        myLocalImage.storeJpgImageInDocument(image: bookImageView.image!, name: "image\(newrid).jpg")
    }
    
    @IBAction func tapBookImage(_ sender: UITapGestureRecognizer) {
        
        alertAction2(s_title: "本の写真を選択して下さい", s_message: "")
    }
    
    //========================
    // MARK: Barcode
    //========================
    func setUpBarCode() {
        // カメラがあるか確認し，取得する
        captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //let inputDevice = AVCaptureDeviceInput(device: self.captureDevice, error: &error)
        if captureDevice != nil {
            do {
                let inputDevice = try AVCaptureDeviceInput(device: captureDevice!)
                
                self.captureSession.addInput(inputDevice)
                
            }
            catch{
                print(error)
            }
            
            
            
            // カメラからの取得映像を画面全体に表示する
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            // self.previewLayer?.frame = CGRect(x:0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
            //self.view.layer.insertSublayer(self.previewLayer!, at: 0)
            self.previewLayer?.frame = CGRect(x:0, y: 0, width: self.captureView.bounds.width, height: self.captureView.bounds.height)
            self.captureView.layer.insertSublayer(self.previewLayer!, at: 0)
            
            // metadata取得に必要な初期設定
            let metaOutput = AVCaptureMetadataOutput()
            metaOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //        metaOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: .background))
            self.captureSession.addOutput(metaOutput)
            
            // どのmetadataを取得するか設定する
            metaOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8]
            
            // capture session をスタートする
            self.captureSession.startRunning()
        }
    }
    // 映像からmetadataを取得した場合に呼び出されるデリゲートメソッド
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print(#function)
        guard let objects = metadataObjects as? [AVMetadataObject] else {
            setResultLabel(text: "ISDNではなさそうです")
            return }
        var detectionString: String? = nil
        let barcodeTypes = [AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13]
        for metadataObject in metadataObjects {
            loop: for type in barcodeTypes {
                guard metadataObject.type == type else { continue }
                guard self.previewLayer!.transformedMetadataObject(for: metadataObject) is AVMetadataMachineReadableCodeObject else { continue }
                if let object = metadataObject as? AVMetadataMachineReadableCodeObject {
                    detectionString = object.stringValue
                    break loop
                }
            }
            var text = ""
            guard let value = detectionString else { continue }

            
            guard let isbn = convertISBN(value: value) else { continue }

            text += "ISBN:\t\(isbn)"
            setResultLabel(text: text)
            
            bookAmazonURL = String(format: "http://amazon.co.jp/dp/%@", isbn)
            let URLString = String(format: "https://www.googleapis.com/books/v1/volumes?q=isbn:%@",isbn)
            guard let URL = NSURL(string: URLString) else { continue }
            let url = URL as URL
            print(url)
            //UIApplication.shared.open(url)
            self.captureSession.stopRunning()
            let condition = NSCondition()
            var itemNum:Int = -1
            let req = NSMutableURLRequest(url: url as URL)
            req.httpMethod = "GET"
            // 取得したJSONを格納する変数を定義
            //var getJson: NSDictionary!
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in
                condition.lock()
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    print("getJsoooon")
                    // dataをJSONパースし、変数"getJson"に格納
                    var getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                    itemNum = getJson["totalItems"] as! Int
                    if  itemNum == 0{

                        self.setResultLabel(text: "Google Bookにはありませんでした")
                    }
                    else{
                        //配列の中身を高速列挙で表示
                        for (key,dat) in getJson {

                            if key == "items" {
                                let array = dat as! Array<Any>
                                let dic = array[0] as! NSDictionary
                                let dic2 = dic["volumeInfo"] as! NSDictionary

                                for (key2,dat2) in dic2 {
                                    switch key2 as! String {
                                    case "title":
                                        self.bookTitle = dat2 as! String
                                    case "authors":
                                        let arrayAthr = dat2 as! Array<String>
                                        self.bookAuthor = arrayAthr[0]
                                    case "imageLinks":
                                        let dicImage = dat2 as! NSDictionary
                                        self.bookImageURL = dicImage["thumbnail"] as! String
                                    default :
                                        break
                                    }
//                                    print("key2:\(key2)")
//                                    print("値2:\(dat2)")
                                    
                                }
                                
                            }

                        }
                        
                    }
                } catch {
                    print ("json error")
                    return
                }
                condition.signal()
                condition.unlock()
            })
            condition.lock()
            task.resume()
            condition.wait()
            condition.unlock()
            if itemNum > 0 {
                displayBookDetail()
            }
        }

        self.captureSession.startRunning()
    }
    
    private func convertISBN(value: String) -> String? {
        print(#function)
        let v = NSString(string: value).longLongValue
        let prefix: Int64 = Int64(v / 10000000000)
        guard prefix == 978 || prefix == 979 else { return nil }
        let isbn9: Int64 = (v % 10000000000) / 10
        var sum: Int64 = 0
        var tmpISBN = isbn9
        /*
         for var i = 10; i > 0 && tmpISBN > 0; i -= 1 {
         let divisor: Int64 = Int64(pow(10, Double(i - 2)))
         sum += (tmpISBN / divisor) * Int64(i)
         tmpISBN %= divisor
         }
         */
        
        var i = 10
        while i > 0 && tmpISBN > 0 {
            let divisor: Int64 = Int64(pow(10, Double(i - 2)))
            sum += (tmpISBN / divisor) * Int64(i)
            tmpISBN %= divisor
            i -= 1
        }
        
        let checkdigit = 11 - (sum % 11)
        return String(format: "%lld%@", isbn9, (checkdigit == 10) ? "X" : String(format: "%lld", checkdigit % 11))
    }
    
    //=================================
    // MARK:画面ずらす処理
    //=================================
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        print(#function)
        if moveDisplay == true {
            let rect = (notification?.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            UIView.animate(withDuration: duration!, animations: { () in
                let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
                self.view.transform = transform
                
            })
        }
    }

    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        print(#function)
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
    }

    
    func setResultLabel (text:String) {
        resultTextLabel?.text = text

    }
    
    func displayBookDetail() {
        self.titleTextField.text = bookTitle
        self.authorsTextField.text = bookAuthor
        guard let URL = NSURL(string: bookImageURL) else { return }
        let url = URL as URL
        print(url)
        let imageData :Data = (try! Data(contentsOf: url ,options: NSData.ReadingOptions.mappedIfSafe))
        self.bookImageView.image = UIImage(data: imageData)
        bookUrlTextField.text = bookAmazonURL
        setResultLabel(text: "")
    }
    
    override func didReceiveMemoryWarning() {
        print(#function)
    }
    
    //===============================
    // MARK:カメラ
    //===============================
    func showCamera() {
        print(#function)
        //カメラボタンが使えるかどうか判別するための情報を取得（列挙体）
        //意味のわかる言葉に置き換え。中身はenumで数字で作ってる
        let camera = UIImagePickerControllerSourceType.camera
        
        //カメラが使える場合　撮影モードの画面を表示
        //クラス名.メソッド名　で使えるメソッド＝型メソッド
        if UIImagePickerController.isSourceTypeAvailable(camera) {
            let picker = UIImagePickerController()
            
            //カメラモードに設定
            picker.sourceType = camera
            
            //デリゲートの設定（撮影後のメソッドを感知するため）
            picker.delegate = self
            
            //撮影モード画面の表示（モーダル）
            present(picker, animated: true, completion: nil)
            
            
        }
        
        
    }
    
    
    func showAlbum(){
        
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            //インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion:  nil)
            
        }
    }
    
    
    
    //カメラロールで写真を選んだ後発動
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if Constants.DEBUG == true {
            print(#function)
        }
        
        //for camera
        // UIImagePickerControllerReferenceURL はカメラロールを選択した時だけ存在するので切り分け。
        if (info.index(forKey: UIImagePickerControllerReferenceURL) == nil) {
            //imageViewに撮影した写真をセットするために変数に保存する
            let takenimage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            //画面上のimageViewに設定
            bookImageView.image = takenimage
            
            //自分のデバイス（プログラムが動いている場所）に写真を保存（カメラロール）
            UIImageWriteToSavedPhotosAlbum(takenimage, nil, nil, nil)
            
            
            //モーダルで表示した撮影モード画面を閉じる（前の画面に戻る）
            dismiss(animated: true, completion: nil)
            
        }
        else {
            //for photolibrary

            
            
            let takenimage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            //画面上のimageViewに設定
            bookImageView.image = takenimage
            
            //閉じる処理
            imagePicker.dismiss(animated: true, completion: nil)
        }
        //imageViewSetting()
        
    }
    
    //=============================
    // MARK:Alert
    //=============================
    func alertAction2(s_title:String, s_message:String){
        
        //部品となるアラート
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        //ボタンを増やしたいときは、addActionをもう一つ作ればよい
        alert.addAction(
            UIAlertAction(
                title: "カメラ",
                style: .default,
                handler: {
                    action in self.showCamera()
            }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "フォトアルバム",
                style: .default,
                handler: {
                    action in self.showAlbum()
            }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "やめる",
                style: .default,
                handler: nil
            )
        )
        // アラート表示
        present(alert, animated: true, completion: nil)
        
        
    }

}



