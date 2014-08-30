//
//  ThemeShopViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 2014. 8. 29..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit
import StoreKit

class ThemeShopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    @IBOutlet var tableView: UITableView! = nil

    override func viewWillAppear(animated: Bool) {
        let window = sharedAppDelegate.window!
        UIActivitiIndicatorViewForWindow(window).pushAnimating()

        dispatch_async(store.backgroundQueue, {
            let previousCount = store.entries.count
            store.refresh()

            dispatch_async(dispatch_get_main_queue(), {
                if previousCount > store.entries.count {
                    self.tableView.reloadData()
                }
                UIActivitiIndicatorViewForWindow(window).popAnimating()
            })
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return store.entries.count
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        let sub: AnyObject? = store.entries[section]["items"]
        assert(sub != nil)
        let items = sub! as Array<AnyObject>
        return items.count
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let item = store.itemForIndexPath(indexPath)

        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        assert(cell != nil)
        cell.textLabel.text = item.title
        if let product = item.product {
            let formatter = NSNumberFormatter()
            formatter.formatterBehavior = .Behavior10_4
            formatter.numberStyle = .CurrencyStyle
            formatter.locale = product.priceLocale
            cell.detailTextLabel.text = formatter.stringFromNumber(product.price)
        } else {
            cell.detailTextLabel.text = "구매 불가"

        }
        return cell
    }

    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return store.categoryForSection(section).title
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let item = store.itemForIndexPath(indexPath)
        if item.product == nil {
            let alertView = UIAlertView(title: "구매 불가한 상품입니다.", message: "안돼", delegate: nil, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
            alertView.show()
        } else {
            let alertView = UIAlertView(title: item.product.localizedTitle, message: item.product.localizedDescription, delegate: self, cancelButtonTitle: "cancel", otherButtonTitles: "other...")
            alertView.tag = (indexPath.section << 16) + indexPath.row
            alertView.show()
        }
    }

    func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int) {
        let (section, row) = (alertView.tag >> 16, alertView.tag & 0xffff)
        let item = store.categoryForSection(section).itemForRow(row)
        let payment = SKPayment(product: item.product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
}