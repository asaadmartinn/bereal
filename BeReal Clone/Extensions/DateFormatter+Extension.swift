//  DateFormatter+Extension.swift
//  BeReal Clone
//  Created by Amir on 2/29/24.

import Foundation

extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
