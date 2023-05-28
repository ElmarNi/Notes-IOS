//
//  Extensions.swift
//  Notes
//
//  Created by Elmar Ibrahimli on 26.05.23.
//

import Foundation
import UIKit
import MediaPlayer

extension UIView {
    var width: CGFloat{
        return frame.size.width
    }
    
    var height: CGFloat{
        return frame.size.height
    }
    
    var left: CGFloat{
        return frame.origin.x
    }
    
    var right: CGFloat{
        return left + width
    }

    var top: CGFloat{
        return frame.origin.y
    }
    
    var bottom: CGFloat{
        return top + height
    }
}

extension String {
    func getHeightForLabel(font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return boundingBox.height
    }
}

func showAlert(title: String, message: String, target: UIViewController?){
    guard let target = target else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    target.present(alert, animated: true)
}

func updateDataToUserDefaults(notes: [Note]?, completion: ((Bool) -> Void)? = nil) {
    guard let notes = notes else { return }
    do {
        let data = try PropertyListEncoder().encode(notes)
        UserDefaults.standard.set(data, forKey: "Notes")
        HapticsManager.shared.vibrate(for: .success)
        completion?(true)
    }
    catch {
        HapticsManager.shared.vibrate(for: .error)
        completion?(false)
    }
}

func getUserDefaults(completion: ([Note]?, Bool) -> Void){
    if let data = UserDefaults.standard.data(forKey: "Notes") {
        do {
            let result = try PropertyListDecoder().decode([Note].self, from: data)
            completion(result, true)
        }
        catch {
            HapticsManager.shared.vibrate(for: .error)
            completion(nil, false)
        }
    }
}
