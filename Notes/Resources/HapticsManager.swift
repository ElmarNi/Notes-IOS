//
//  HapticsManager.swift
//  Notes
//
//  Created by Elmar Ibrahimli on 26.05.23.
//

import Foundation
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    private init(){}
    
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
