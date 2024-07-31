//
//  NotificationsVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 11/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var notificationTV : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
    }
}

/* MARK:- Methods */
extension NotificationsVC {
    
    func registerNibs(){
        self.notificationTV.register(
            UINib(
                nibName: Constants.TVCells.NOTIFICATIONS_CELL,
                bundle: nil),
            forCellReuseIdentifier: Constants.TVCells.NOTIFICATIONS_CELL
        )
    }
}

/* MARK:- TableView Delegate & Datasource */
extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TVCells.NOTIFICATIONS_CELL) as! NotificationCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.notificationTV.bounds.height / 6.45
    }
    
}
