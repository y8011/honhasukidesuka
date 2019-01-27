//
//  Generics.swift
//  honhaSukidesuka
//
//  Created by yuka on 2018/05/08.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit
//import StatusAlert
import GoogleMobileAds

extension UIViewController: StatusAlertDelegate
{
    class var className: String {
        return "\(self)"
    }
    var className: String {
        return type(of: self).className
    }
    
    func onDismiss(sender: StatusAlert) {

        switch sender.tag {
        case 2:
            alertDelete(s_title: "本当に削除しますか？", s_message: "")
        case 4:
            alertSelectCamera(s_title: "本の写真", s_message: "")
        default:
            break
        }

    }

    
    func alertDelete(s_title:String, s_message:String){
        
        let dvc = self as! detailViewController
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
                    action in dvc.deleteDetail()
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
    


    func alertNormal1(s_title:String, s_message:String,duration:Double,tag:Int) -> StatusAlert {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "Okayu_icon.jpg")
        statusAlert.title = s_title
        statusAlert.message = s_message
        statusAlert.canBePickedOrDismissed = true

        statusAlert.alertShowingDuration = duration
        statusAlert.appearance.messageFont = UIFont(name: "Hiragino Maru Gothic Pro", size: 16)!
        statusAlert.appearance.titleFont = UIFont(name: "Hiragino Maru Gothic Pro", size: 28)!
        statusAlert.tag = tag

        statusAlert.delegate = self
        return statusAlert
    }
    
    func alertSelectCamera(s_title:String, s_message:String){

        let alert = UIAlertController(
            title: s_title ,
            message: s_message,
            preferredStyle: .alert
        )
        
        switch self.className {
        case "submitViewController":
            let vc = self as! submitViewController
            alert.addAction(
                UIAlertAction(
                    title: "カメラ",
                    style: .default,
                    handler: {
                        action in vc.showCamera()
                }
                )
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "フォトアルバム",
                    style: .default,
                    handler: {
                        action in vc.showAlbum()
                }
                )
            )
            
        default:
            let vc = self as! detailViewController
            alert.addAction(
                UIAlertAction(
                    title: "カメラ",
                    style: .default,
                    handler: {
                        action in vc.showCamera()
                }
                )
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "フォトアルバム",
                    style: .default,
                    handler: {
                        action in vc.showAlbum()
                }
                )
            )
            
        }
        alert.addAction(
            UIAlertAction(
                title: "やめる",
                style: .default,
                handler: nil
            )
        )

        present(alert, animated: true, completion: nil)
        
        
    }
}

extension UIViewController {
    // Screen width.
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }


    
    func searchAPI(title search:String) {
        let searchGroup = DispatchGroup()
        let searchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        let searchEncoded = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=intitle:" + searchEncoded) else { return  }
        print(url)
        var books = [Book]()
        
        searchGroup.enter()
        searchQueue.async(group: searchGroup) {
            let req = NSMutableURLRequest(url: url)
            req.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: req as URLRequest, completionHandler: { (data, resp, err) in

                guard let data = data else {return}
                do {
                    let decoder = JSONDecoder()
                    let bookAPIResponse = try decoder.decode(BookAPIResponse.self, from: data)
                    books = bookAPIResponse.items
                   
                } catch {
                    print ("json error: \(error)")
                    print("searchAPI:Google Bookでは見つかりませんでした")
                    books = []
                }
                searchGroup.leave()
            })
            task.resume()
        }
        
        searchGroup.notify(queue: .main) {
            self.didSearchBookAPI(result: books)
            
        }
    }
    
    /** searchAPI()で検索APIの解析が完了した時にコールされる **/
    @objc func didSearchBookAPI(result books: [Book]) {
        
//        let imageLinks = books.map{$0.volumeInfo?.imageLinks?.thumbnail ?? ""}
//        var images: [UIImage?] = []

       // imageLinks.forEach {  images.append(imageFromURL($0))}
    }
}


extension UIViewController: GADBannerViewDelegate  // Admob


{
    //=================================
    // MARK:Admob
    //=================================
    
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Add banner to view and add constraints as above.
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
    }
}


// Notification
extension UIViewController {
    func addNotification() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowNotification(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideNotification(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc func keyboardWillShowNotification(notification: NSNotification) {
        
    }
    
    @objc func keyboardWillHideNotification(notification: NSNotification) {

        
    }
}
