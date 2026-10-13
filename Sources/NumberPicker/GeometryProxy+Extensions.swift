//
//  GeometryProxy+Extensions.swift
//  NumberPicker
//
//  Created by David Kennedy on 13/10/2026.
//

import SwiftUI

extension GeometryProxy {
    
    var ratio: Int? {
        let w = size.width
        let h = size.height
        guard w.isFinite, h.isFinite, w != 0 else { return nil }
        let rd = (w / h)
        guard rd.isFinite else { return nil }
        let r = Int(rd)
        guard r != 0 else { return nil }
        return r
    }
    
}
