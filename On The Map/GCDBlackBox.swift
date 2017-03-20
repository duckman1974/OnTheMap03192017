//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Candice Reese on 3/16/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
