//
//  String+Extensions.swift
//  RegX
//
//  Created by Krunoslav Zaher on 9/9/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension String {
    func count() -> Int {
        return self.startIndex.distanceTo(self.endIndex)
    }
}