//
//  ViewController.swift
//  honhaSukidesuka
//
//  Created by yuka on 2018/01/10.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage

class submitViewController: UIViewController
    , AVCaptureMetadataOutputObjectsDelegate
    , UIImagePickerControllerDelegate
    , UINavigationControllerDelegate
{
    
    @IBOutlet weak var searchView: SearchView!
    @IBOutlet weak var captureView: UIView!
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

    // 通知用ダミー初期化
    var statusAlert = StatusAlert()

    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookImageView.layer.borderWidth = 0.1
        bookImageView.layer.cornerRadius = 0
        recomendTextView.layer.borderWidth = 0.1
        recomendTextView.layer.cornerRadius = 5
        submitButton.layer.cornerRadius = 5
        submitButton.layer.masksToBounds = true
        
        self.navigationItem.title = "新規書籍登録"
        
        // 通知用ダミー初期化
        statusAlert.image = UIImage(named: "Okayu_icon.jpg")
        statusAlert.title = "dummy"
        statusAlert.message = ""
        statusAlert.canBePickedOrDismissed = true
        
        
        initTextField()
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    var onetime:Bool = true
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if onetime == true {
            setUpBarCode()
            onetime = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureView.layer.cornerRadius = 5
        captureView.layer.masksToBounds = true
        self.captureSession.startRunning()
        searchView.afterLoaded()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)

    }
    
    //MARK: TextField
    private var beforeText:String = ""
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
  
    }
    @IBAction func touchUpInside(_ sender: UITextField) {
    }
    
    @IBAction func touchUpOutside(_ sender: UITextField) {
        searchView.disappear()
    }
    func initTextField() {
        titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if textField.tag == 1 {  // title
                if text != beforeText {
                    if text != "" {
                        searchAPI(title: text)
                    } else {
                        searchView.disappear()
                    }
                }
            }
            beforeText = text
        }
    }
    
}

extension submitViewController {
    //==============================
    // MARK:Gesture
    //==============================
    @IBAction func touchDown(_ sender: UITextField) {
        if sender.tag == 1 {
            searchView.disappear()
        }
    }
    
    // 登録ボタンを押した時
    @IBAction func tapSubmitButton(_ sender: Any) {
        if titleTextField.text == "" {
            statusAlert = alertNormal1(s_title: "だめ", s_message: "本のタイトルは入れてください。", duration: 5, tag: 3)
            statusAlert.showInKeyWindow()

            return
        }
        let myCoreData:MyCoreData = MyCoreData()
        let myLocalImage:ingLocalImage = ingLocalImage()
        let newrid = myCoreData.insertRecommend(title: titleTextField.text!, author: authorsTextField.text!, recommendation: recomendTextView.text!,link: bookAmazonURL)
        myLocalImage.storeJpgImageInDocument(image: bookImageView.image!, name: "image\(newrid).jpg")
        
        if UserDefaults.standard.bool(forKey: "init") == false { // 初回登録チェック
            UserDefaults.standard.set(true, forKey: "init")
        }

        //戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    // イメージをタップした時
    @IBAction func tapBookImage(_ sender: UITapGestureRecognizer) {
        statusAlert =  alertNormal1(s_title: "本の写真を選択して下さい", s_message: "", duration: 5, tag: 4)
        statusAlert.showInKeyWindow()
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
            
            guard let isbn = convertISBN(value: value) else {
                //setResultLabel(text: "ISDNではなさそうです")

                continue }
            
            text += "ISBN:\t\(isbn)"
            //setResultLabel(text: text)
            
            bookAmazonURL = makeAmazonURL(isbn: isbn)
            let URLString = String(format: "https://www.googleapis.com/books/v1/volumes?q=isbn:%@",isbn)
            guard let URL = NSURL(string: URLString) else { continue }
            let url = URL as URL
            self.captureSession.stopRunning()
            let condition = NSCondition()
            var itemNum:Int = -1
            let req = NSMutableURLRequest(url: url as URL)
            req.httpMethod = "GET"
            // 取得したJSONを格納する変数を定義
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in
                condition.lock()
                // 受け取ったdataをJSONパース、エラーならcatchへジャンプ
                do {
                    // dataをJSONパースし、変数"getJson"に格納
                    var getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                    itemNum = getJson["totalItems"] as! Int
                    if  itemNum == 0{
                        
                        self.setResultLabel(text: "Google Bookでは見つかりませんでした")
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
    
    func setResultLabel (text:String) {
        _ = alertNormal1(s_title: text, s_message: "", duration: 5, tag: 3)
    }
    
    func displayBookDetail() {
        self.titleTextField.text = bookTitle
        self.authorsTextField.text = bookAuthor
        self.bookUrlTextField.text = bookAmazonURL
        if bookImageURL != "" {
            guard let URL = NSURL(string: bookImageURL) else { return }
            let url = URL as URL
            print(url)
            let imageData :Data = (try! Data(contentsOf: url ,options: NSData.ReadingOptions.mappedIfSafe))
            self.bookImageView.image = UIImage(data: imageData)
        }
        bookUrlTextField.text = bookAmazonURL
        //setResultLabel(text: "")
    }
    
    override func didReceiveMemoryWarning() {
        print(#function)
    }
    
    //===============================
    // MARK:カメラ
    //===============================
    func showCamera() {
        print(#function)
        //カメラが使える場合　撮影モードの画面を表示
        //クラス名.メソッド名　で使えるメソッド＝型メソッド
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            
            //カメラモードに設定
            picker.sourceType = .camera
            
            //デリゲートの設定（撮影後のメソッドを感知するため）
            picker.delegate = self
            
            //撮影モード画面の表示（モーダル）
            present(picker, animated: true, completion: nil)
        }
    }
    
    func showAlbum(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = .photoLibrary
            
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion:  nil)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        
        if Constants.DEBUG == true {
            print(#function)
        }
        
        //for camera
        // UIImagePickerControllerReferenceURL はカメラロールを選択した時だけ存在するので切り分け。
        if (info[UIImagePickerController.InfoKey.referenceURL] == nil) {
            //imageViewに撮影した写真をセットするために変数に保存する
            let takenimage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            bookImageView.image = takenimage
            
            //自分のデバイス（プログラムが動いている場所）に写真を保存（カメラロール）
            UIImageWriteToSavedPhotosAlbum(takenimage, nil, nil, nil)
            
            //モーダルで表示した撮影モード画面を閉じる（前の画面に戻る）
            dismiss(animated: true, completion: nil)
            
        }
        else {
            //for photolibrary
            let takenimage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            bookImageView.image = takenimage
            
            //閉じる処理
            picker.dismiss(animated: true, completion: nil)
        }
        //imageViewSetting()
        
    }
    
    
}

// MARK:- TableView
extension submitViewController: UITableViewDelegate,UITableViewDataSource {

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! searchTableCell
        
        let book = searchView.searchedBooks[indexPath.row]
        cell.titleLabel.text = book.volumeInfo?.title ?? ""
        cell.authorLabel.text = book.volumeInfo?.authors?.joined(separator: ",") ?? ""
        cell.publisherLabel.text = book.volumeInfo?.publisher ?? ""
        cell.publishDateLabel.text = book.volumeInfo?.publishedDate ?? ""
        if let imageLink = book.volumeInfo?.imageLinks?.thumbnail {
            guard let url = URL(string: imageLink) else { return cell }
            let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
                size: cell.bookImage.frame.size,
                radius: 1
            )
            cell.bookImage.af_setImage(
                withURL: url,
                placeholderImage: UIImage(named: "noimage"),
                filter: filter,
                imageTransition: .crossDissolve(0.2)
            )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  searchView.searchedBooks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = searchView.searchedBooks[indexPath.row]
        titleTextField.text = book.volumeInfo?.title
        authorsTextField.text = book.volumeInfo?.authors?.joined(separator: ",")
        if let imageURL = book.volumeInfo?.imageLinks?.thumbnail {
            bookImageView.af_setImage(withURL: URL(string: imageURL)!)
        }
        if let isbn = book.volumeInfo?.industryIdentifiers {
            bookAmazonURL = makeAmazonURL(isbn: isbn[0].identifier )
            bookUrlTextField.text = bookAmazonURL
        }
        else {
            bookAmazonURL = ""
        }
        searchView.disappear()

    }
    
}

// MARK:-

extension submitViewController  {
    

    
    override func didSearchBookAPI(result books: [Book]) {
        super.didSearchBookAPI(result: books)
        print("done")
        searchView.searchedBooks = books
        
        searchView.searchedTableView.reloadData()
        searchView.appear()
    }

    func makeAmazonURL(isbn: String) -> String {
        return String(format: "http://amazon.co.jp/dp/%@", isbn)
    }
    
    
}





