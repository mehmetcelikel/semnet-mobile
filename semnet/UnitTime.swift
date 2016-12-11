//
//  UnitTime.swift
//  semnet
//
//  Created by ceyda on 10/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import Foundation
import UIKit

typealias UnixTime = Int

extension UnixTime {
    private func formatType(form: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        dateFormatter.dateFormat = form
        return dateFormatter
    }
    var dateFull: NSDate {
        return NSDate(timeIntervalSince1970: Double(self))
    }
    var toHour: String {
        return formatType(form: "HH:mm").string(from: dateFull as Date)
    }
    var toDay: String {
        return formatType(form: "HH:mm MM/dd/yyyy").string(from: dateFull as Date)
    }
}

func synchronized<T>(lock: AnyObject, _ body: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    return try body()
}

func createActivityIndicator(point: CGPoint) -> UIActivityIndicatorView{
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 20, height: 20))
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    activityIndicator.center = point
    
    return activityIndicator
}
