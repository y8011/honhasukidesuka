//
//  pictureViewController.swift
//  ingCalc
//
//  Created by yuka on 2017/12/02.
//  Copyright © 2017年 yuka. All rights reserved.
//

import UIKit

class detailViewController: UIViewController
    , UIImagePickerControllerDelegate
    , UINavigationControllerDelegate
{

    var passedIndex:Int = -1
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorsTextField: UITextField!
    @IBOutlet weak var recomendTextView: UITextView!
    @IBOutlet weak var bookUrlTextField: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookImageView.layer.borderWidth = 0.1
        bookImageView.layer.cornerRadius = 5
        bookImageView.layer.masksToBounds = true
        recomendTextView.layer.borderWidth = 0.1
        recomendTextView.layer.cornerRadius = 5
        submitButton.layer.cornerRadius = 5
        submitButton.layer.masksToBounds = true
        deleteButton.layer.cornerRadius = 5
        deleteButton.layer.masksToBounds = true

        
    }

    override func viewWillAppear(_ animated: Bool) {
        if Constants.DEBUG == true {
            print(#function)
        }

        
 
    }
    
    //===============================
    // updateViewConstraints
    //===============================
    override func updateViewConstraints() {
        print(#function)
        
        // Constraints

        
        super.updateViewConstraints()
        
        
    }
    //===============================
    // viewDidAppear
    //===============================
    var onetime:Bool = false
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
        if onetime == false {
            initDetail()
            onetime = true
        }

    }


    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //==================
    // MARK:init
    //==================
    func initDetail () {
        let myIngCoreData:ingCoreData = ingCoreData()
        let dic = myIngCoreData.readRecommend(id: passedIndex)
        
        titleTextField.text = dic["title"] as! String
        authorsTextField.text = dic["author"] as! String
        recomendTextView.text = dic["recommendation"] as! String
        bookUrlTextField.text = dic["linkURL"] as! String
        
        let myLocalImage:ingLocalImage = ingLocalImage()
        let image = myLocalImage.readJpgImageInDocument(nameOfImage: "image\(passedIndex).jpg")
        
        bookImageView.image = image
        
        //日付を文字列に変換
        let df = DateFormatter()
        //ローカライズ
        let hereLocale = Locale.autoupdatingCurrent
        df.timeZone = TimeZone.ReferenceType.local
        
        df.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: hereLocale)
        df.dateStyle = .long
        df.timeStyle = .short
        
        df.doesRelativeDateFormatting = true
        
        //myNavigationBar.topItem?.title = df.string(from: dic["resultDate"] as! Date)
        
    }
    
    //=====================
    // MARK:Gesture
    //=====================
    var isDuringEdit:Bool = false
    //　編集ボタンを押した時
    @IBAction func tapEditButton(_ sender: UIButton) {
        isDuringEdit = !(isDuringEdit)
        
        titleTextField.isEnabled = isDuringEdit
        authorsTextField.isEnabled = isDuringEdit
        recomendTextView.isEditable = isDuringEdit
        bookUrlTextField.isEnabled = isDuringEdit
        bookImageView.isUserInteractionEnabled = isDuringEdit
        
        if isDuringEdit == true {
            submitButton.setTitle("完了!", for: .normal)
            submitButton.backgroundColor = UIColor.brown
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = UIColor(red: 255/255, green: 225/255, blue: 225/255, alpha: 1)
            })
            
        }
        else { // edit完了
            submitButton.setTitle("編集!", for: .normal)
            submitButton.backgroundColor = UIColor(red: 0, green: 164/255, blue: 255/255, alpha: 1)
            UIView.animate(withDuration: 0.2, animations: {
                
            self.view.backgroundColor = UIColor.white
            })
            
           let myCoreData:ingCoreData = ingCoreData()
            let myLocalImage:ingLocalImage = ingLocalImage()
             myCoreData.editRecommend(id: passedIndex, title: titleTextField.text!, author: authorsTextField.text!, recommendation: recomendTextView.text!,link: bookUrlTextField.text!)

            myLocalImage.storeJpgImageInDocument(image: bookImageView.image!, name: "image\(passedIndex).jpg")
        }
        
    }
    
    // 削除ボタン押した時
    @IBAction func tapDelete(_ sender: UIButton) {
        alertDelete(s_title: "削除します", s_message: "本当に削除しますか？")
        
    }
    
    
    // 本のイメージを押した時
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        alertAction2(s_title: "本の写真を選択して下さい", s_message: "")
    }
    
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
    // 他のビューを触ったら、キーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
            self.bookImageView.image = takenimage
            //自分のデバイス（プログラムが動いている場所）に写真を保存（カメラロール）
            UIImageWriteToSavedPhotosAlbum(takenimage, nil, nil, nil)
            
            
            //モーダルで表示した撮影モード画面を閉じる（前の画面に戻る）
            dismiss(animated: true, completion: nil)
            
        }
        else {
            //for photolibrary
            
            
            
            let takenimage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            //画面上のimageViewに設定
            self.bookImageView.image = takenimage

            //閉じる処理
            imagePicker.dismiss(animated: true, completion: nil)
        }
        //imageViewSetting()
        
    }
    
    //=============================
    // MARK:deleteデータ
    //=============================
    func deleteDetail()  {
        let myCoreData:ingCoreData = ingCoreData()
        myCoreData.deleteRecommend(id: passedIndex)
        let myLocalImage:ingLocalImage = ingLocalImage()
        myLocalImage.deleteJpgImageInDocument(nameOfImage: "image\(passedIndex).jpg")
        
        self.navigationController?.popViewController(animated: true)

    }
    
    //=============================
    // MARK:Alert
    //=============================
    func alertDelete(s_title:String, s_message:String){
        
        //部品となるアラート
        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        //ボタンを増やしたいときは、addActionをもう一つ作ればよい
        alert.addAction(
            UIAlertAction(
                title: "はい",
                style: .default,
                handler: {
                    action in self.deleteDetail()
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
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
