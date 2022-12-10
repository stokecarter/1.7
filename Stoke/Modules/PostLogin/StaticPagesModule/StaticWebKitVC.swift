//
//  StaticWebKitVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit
import WebKit

enum WebPages{
    case tnc
    case pvc
    case faq
    case rules
}


class StaticWebKitVC: BaseVC {

    @IBOutlet weak var webView: WKWebView!
    
    
    var heading = ""
    var baseUrl = WebService.pageUrl
    var type:WebPages = .tnc
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: heading, backButton: true)
        loadUrl()
    }
    
    private func loadUrl(){
        switch type {
        case .pvc:
            webView.load(URLRequest(url: URL(string: "\(baseUrl)policy-view")!))
        case .rules:
            webView.load(URLRequest(url: URL(string: "\(baseUrl)rules-view")!))
        default:
            webView.load(URLRequest(url: URL(string: "\(baseUrl)terms-view")!))
        }
    }

}
