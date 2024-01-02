/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The protocol and enums that define the different types of body parts that are used to build a robot.
*/

import UIKit

class VcfcardfPart : Codable {
    //"name" : "Mahendra", "mobile" : "8883838388"," url"
    
    /* "bio_picture": "https://app.taptok.dev/images/avatars/m35tpfz0ql1640532563.png",
     "full_name": "Jaime Manteiga",
     "vcard_name": "Jaime Manteiga's Professional vCard",
     "account_type": "professional",
     "date": "2021-11-22 05:47:20",
     "share_link": "https://app.taptok.dev/v/jaime-manteigas-professional-vcard",
     "company": "TAPTOK"*/
    var bio_picture : String
    var full_name : String
    var vcard_name : String
    var account_type : String
    var date : String
    var share_link : String
    var company : String
    
//    var name: String
//    var url : String
//    var mobile : String
    
    private enum CodingKeys : String, CodingKey {
       // case name, url, mobile
        case bio_picture, full_name, vcard_name, account_type, date, share_link, company
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(url, forKey: .url)
//        try container.encode(mobile, forKey: .mobile)
        try container.encode(bio_picture, forKey: .bio_picture)
        try container.encode(full_name, forKey: .full_name)
        try container.encode(vcard_name, forKey: .vcard_name)
        try container.encode(account_type, forKey: .account_type)
        try container.encode(date, forKey: .date)
        try container.encode(share_link, forKey: .share_link)
        try container.encode(company, forKey: .company)

    }
    
    required init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.bio_picture = try valueContainer.decode(String.self, forKey: .bio_picture)
        } catch  {
            self.bio_picture = ""
            debugPrint("bio_picture error \(error.localizedDescription)")
        }
        do {
            self.full_name = try valueContainer.decode(String.self, forKey: .full_name)
        } catch  {
            self.full_name = ""
            debugPrint("full_name error \(error.localizedDescription)")
        }
        do {
            self.vcard_name = try valueContainer.decode(String.self, forKey: .vcard_name)
        } catch  {
            self.vcard_name = ""
            debugPrint("vcard_name error \(error.localizedDescription)")
        }
        do {
            self.account_type = try valueContainer.decode(String.self, forKey: .account_type)
        } catch  {
            self.account_type = ""
            debugPrint("account_type error \(error.localizedDescription)")
        }
        do {
            self.date = try valueContainer.decode(String.self, forKey: .date)
        } catch  {
            self.date = ""
            debugPrint("date error \(error.localizedDescription)")
        }
        do {
            self.share_link = try valueContainer.decode(String.self, forKey: .share_link)
        } catch  {
            self.share_link = ""
            debugPrint("share_link error \(error.localizedDescription)")
        }
        do {
            self.company = try valueContainer.decode(String.self, forKey: .company)
        } catch  {
            self.company = ""
            debugPrint("company error \(error.localizedDescription)")
        }
    }
    
}


