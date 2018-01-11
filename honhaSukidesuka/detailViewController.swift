//
//  pictureViewController.swift
//  ingCalc
//
//  Created by yuka on 2017/12/02.
//  Copyright © 2017年 yuka. All rights reserved.
//

import UIKit

class detailViewController: UIViewController

{

    var passedIndex:Int = -1
    
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorsTextField: UITextField!
    @IBOutlet weak var recomendTextView: UITextView!
    @IBOutlet weak var bookUrlTextField: UITextField!
    @IBOutlet weak var bookImageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookImageView.layer.borderWidth = 0.2
        bookImageView.layer.cornerRadius = 5
        recomendTextView.layer.borderWidth = 0.2
        recomendTextView.layer.cornerRadius = 5
        submitButton.layer.cornerRadius = 5
        submitButton.layer.masksToBounds = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if Constants.DEBUG == true {
            print(#function)
        }

        
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

    }


    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
