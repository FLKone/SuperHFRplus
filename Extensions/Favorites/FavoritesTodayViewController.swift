//
//  FavoritesTodayViewController.swift
//  Favorites
//
//  Created by FLK on 05/12/2017.
//

import UIKit
import NotificationCenter
import SnapKit

@objc(FavoritesTodayViewController)
class FavoritesTodayViewController: UIViewController, NCWidgetProviding {

    var tableView = UITableView(frame: .zero, style: .plain)

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.clipsToBounds = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        print("viewDidLoad")
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.register(BasicTableViewCell.self, forCellReuseIdentifier: "basicCell")

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }


    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        print("widgetActiveDisplayModeDidChange")
        let size = self.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

        print("widgetActiveDisplayModeDidChange TB Frame \(self.tableView.frame)")
        print("widgetActiveDisplayModeDidChange TB Content \(self.tableView.contentSize)")

        preferredContentSize = CGSize(width: 0.0, height: self.tableView.contentSize.height)
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
        print("widgetPerformUpdate TB Frame \(self.tableView.frame)")
        print("widgetPerformUpdate TB Content \(self.tableView.contentSize)")

        preferredContentSize = CGSize(width: 0.0, height: self.tableView.contentSize.height)
        completionHandler(NCUpdateResult.newData)
    }
    
}

// MARK: - UITableViewDataSource
extension FavoritesTodayViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)

        cell.textLabel?.text = "test"
        return cell
    }

}

// MARK: - UITableViewDelegate
extension FavoritesTodayViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("FavoritesTodayViewController didSelectRowAt \(indexPath)")
        self.tableView.deselectRow(at: indexPath, animated: true)
        //let filter = self.filterList[indexPath.row]
        //self.delegate?.selectFilter(filter)
    }

}
