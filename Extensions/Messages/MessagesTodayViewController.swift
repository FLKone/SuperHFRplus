//
//  MessagesTodayViewController.swift
//  MP
//
//  Created by FLK on 05/12/2017.
//

import UIKit
import NotificationCenter

import SnapKit
@objc(MessagesTodayViewController)
class MessagesTodayViewController: UIViewController, NCWidgetProviding {

    private let helloLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.clipsToBounds = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        // Do any additional setup after loading the view from its nib.

        view.addSubview(helloLabel)
        helloLabel.text = "Hellooooww"
        helloLabel.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        print("widgetPerformUpdate")

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
