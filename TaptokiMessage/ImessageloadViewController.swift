//
//  ImessageloadViewController.swift
//  Taptok
//
//  Created by Mehul Nahar on 05/11/22.
//

import UIKit
import SwiftUI
import Foundation
import Contacts

class ImessageloadViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, businessLogicLayerDelegate  {
    var arrayolist:NSArray = [["name" : "Mahendra", "mobile" : "8883838388","url" : "vcard"],
                              ["name" : "Manisha", "mobile" : "8883838388", "url" : "vcard"],
                              ["name" : "Pawan", "mobile" : "8883838388", "url" : "vcard"],
                              ["name" : "Deepak", "mobile" : "8883838388", "url" : "vcard"],
                              ["name" : "Khushal", "mobile" : "8883838388", "url" : "vcard"],
                              ["name" : "Madhuri", "mobile" : "8883838388", "url" : "vcard"],
                              ["name" : "Ankit", "mobile" : "8883838388", "url" : "vcard"]
    ] ;
    
    
    @IBOutlet weak var count_lbl: UILabel!
    @IBOutlet weak var pagination_lbl: UILabel!
    @IBOutlet weak var pagination_view: UIPageControl!
    @IBOutlet weak var count_view: UIView!
    @IBOutlet weak var logo_img: UIImageView!
    var checkviewsts = ""
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var detaile_lbl: UILabel!
    @IBOutlet weak var text_lbl: UILabel!
    
    @IBOutlet weak var Loder_top: NSLayoutConstraint!
    
    var decodedArray : [VcfcardfPart] = []
    weak var delegate: ImessageloadViewControllerDelegate?
    var SharedUser = UserDefaults(suiteName: SharedUserDefults.suiteName)
    var VCFBL: businessLogicLayer = businessLogicLayer()

    @IBOutlet weak var top_collection: NSLayoutConstraint!
    @IBOutlet weak var collection_hight: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    
    var centerFlowLayout: SJCenterFlowLayout {
        return collectionView.collectionViewLayout as! SJCenterFlowLayout
    }
    var scrollToEdgeEnabled: Bool = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
       
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logo_img.layer.cornerRadius = logo_img.frame.size.width / 2
        logo_img.clipsToBounds = true
        
        if checkviewsts == "compact"{
            print(checkviewsts)
            centerFlowLayout.itemSize = CGSize(
                width: view.bounds.width * 0.9,
                height:  view.bounds.height * 0.3
            )
            centerFlowLayout.animationMode = SJCenterFlowLayoutAnimation.scale(sideItemScale: 0.8, sideItemAlpha: 0.6, sideItemShift: 0.0)
            collection_hight.constant = 200
            Loder_top.constant = 80
            top_collection.constant = -1
            centerFlowLayout.scrollDirection = .horizontal
            pagination_view.isHidden = false
            pagination_lbl.isHidden = false
        }else if checkviewsts == "expanded" {
            print(checkviewsts)
            centerFlowLayout.itemSize = CGSize(
                width: view.bounds.width * 0.9,
                height:  view.bounds.height * 0.9
            )
            Loder_top.constant = 200
            centerFlowLayout.spacingMode = SJCenterFlowLayoutSpacingMode.fixed(spacing: -10)
            centerFlowLayout.animationMode = SJCenterFlowLayoutAnimation.scale(sideItemScale: 0.8, sideItemAlpha: 0.6, sideItemShift: 0.0)
           // centerFlowLayout.animationMode = SJCenterFlowLayoutAnimation.rotation(sideItemAngle: 0.8, sideItemAlpha: 0.6, sideItemShift: 0.0)
            collection_hight.constant = view.bounds.height
            top_collection.constant = -10
            centerFlowLayout.scrollDirection = .vertical
            
            pagination_view.isHidden = true
            pagination_lbl.isHidden = true
        }
        
       
        //centerFlowLayout.scrollDirection = .vertical
        guard let sharetoken = SharedUser?.string(forKey: SharedUserDefults.Values.token) else {
            return
        }
        guard let LOGIN = SharedUser?.string(forKey: SharedUserDefults.Values.LOGIN) else {
            return
        }
        if LOGIN == "YES"{
            showLoader()
            VCFBL.delegate = self
            self.VCFAPICall()
        }else {
            
        }
      
       
        
        // Do any additional setup after loading the view.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return decodedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryColCell
        let vcardInfo = decodedArray[indexPath.row]
        cell.user_img.layer.cornerRadius = cell.user_img.frame.size.width / 2
        cell.user_img.clipsToBounds = true
        
        cell.Professional_lbl.text = ""
        let bio_picture = vcardInfo.bio_picture
        cell.user_img.setImageFromUrl(ImageURL: bio_picture)
        cell.Vcard_lbl.text = vcardInfo.vcard_name
        cell.Org_lbl.text = vcardInfo.company
        cell.Name_lbl.text = vcardInfo.full_name
        cell.Date_lbl.text = vcardInfo.date
        cell.btn_Share.tag = indexPath.item;
        cell.btn_Share.addTarget(self, action: #selector(self.btn_Share), for: .touchUpInside)
        return cell
    }
    @objc func btn_Share(sender: AnyObject)
    {
        let btn = (sender as! UIButton)
        let Details = decodedArray[btn.tag]
        Loder_top.constant = 300
        self.showLoader()
        self.delegate?.iMessageLoadViewController(self, didSelect: Details)
        print(Details)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.scrollToEdgeEnabled, let cIndexPath = centerFlowLayout.currentCenteredIndexPath,
            cIndexPath != indexPath {
            centerFlowLayout.scrollToPage(atIndex: indexPath.row)
            self.pagination_view.currentPage = Int(indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.size.width - 40, height: 250)
    }
//    private func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//       let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
//       self.pagination_view.currentPage = Int(pageNumber)
//   }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            if let indexPath = centerFlowLayout.currentCenteredIndexPath {
               // print("Current IndexPath: \(indexPath)")
            }
            if let page = centerFlowLayout.currentCenteredPage {
               // print("Current Page: \(page)")
                self.pagination_view.currentPage = Int(page)
            }
        }
    
    @objc func showLoader() {
        self.loaderView.isHidden = false
    }
    
    @objc func hideLoader() {
        self.loaderView.isHidden = true
    }
    
    @objc func changeArrayListAndReloadTable(array : NSArray) {
        arrayolist = array
        collectionView.reloadData()
    }
    
    @objc func InviteShare(sender: AnyObject)
    {
        var btn = (sender as! UIButton)
        let vcardInfo = decodedArray[btn.tag]
        self.delegate?.iMessageLoadViewController(self, didSelect: vcardInfo)
    }

    func VCFAPICall()
    {
     
           guard let sharetoken = SharedUser?.string(forKey: SharedUserDefults.Values.token) else {
            return
           }
            var dictParameter: NSDictionary = NSDictionary()
            dictParameter = ["sharetoken" : sharetoken] as! NSDictionary
            
            VCFBL.VCFAPICallAPICall(dictParameter)
            return
        
    }
    @objc func VCFAPICallFinished(_ dictTeamarr : NSDictionary , massge : String) {
        do {
            let data = dictTeamarr["data"] as? NSArray
            let arrayData = try JSONSerialization.data(withJSONObject: data as Any)
            decodedArray = try JSONDecoder().decode([VcfcardfPart].self, from: arrayData)
            pagination_lbl.text = "1 of \(decodedArray.count)"
            count_lbl.text = "\(decodedArray.count)"
            self.pagination_view.numberOfPages = decodedArray.count
            self.pagination_view.currentPage = 0
            detaile_lbl.isHidden = false
            text_lbl.isHidden = false
            logo_img.isHidden = false
            
            count_view.isHidden = false
            collectionView.reloadData()
            if checkviewsts == "compact"{
                pagination_view.isHidden = false
                pagination_lbl.isHidden = false
            }else if checkviewsts == "expanded" {
                pagination_view.isHidden = true
                pagination_lbl.isHidden = true
            }
            hideLoader()
        } catch  {
            hideLoader()
            debugPrint(error.localizedDescription)
        }
    }
    
    @objc func VCFAPICallMessage(_ massge : String) {
        hideLoader()
    }
    
    @objc func VCFAPICallError(_ error: Error) {
        hideLoader()
    }
    
    
    
}

protocol ImessageloadViewControllerDelegate: AnyObject {

    /// Called when the user taps to select an `IceCreamPart` in the `BuildIceCreamViewController`.

   // func ImessageloadViewController(_ controller: ImessageloadViewController, didSelect VCFPart: VcfcardfPart)
    func iMessageLoadViewController(_ controller : ImessageloadViewController, didSelect VCFPart: VcfcardfPart)
}
