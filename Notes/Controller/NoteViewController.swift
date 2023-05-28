//
//  NoteViewController.swift
//  Notes
//
//  Created by Elmar Ibrahimli on 26.05.23.
//

import UIKit

protocol NoteViewControllerDelegate: AnyObject{
    func updateNotes(notes: [Note])
}
class NoteViewController: UIViewController {

    weak var delegate: NoteViewControllerDelegate?
    private let note: Note
    private var notes = [Note]()
    
    private let textView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = note.name
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        textView.text = note.body
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        if let data = UserDefaults.standard.data(forKey: "Notes") {
            do {
                notes = try PropertyListDecoder().decode([Note].self, from: data)
            }
            catch {
                showAlert(title: "Error", message: "Something went wrong when getting notes", target: self)
                HapticsManager.shared.vibrate(for: .error)
            }
        }
        
        getUserDefaults { notes, success in
            if success {
                self.notes = notes!
            }
            else {
                showAlert(title: "Error", message: "Something went wrong when getting notes", target: self)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.frame = view.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        
        notes[index].body = textView.text
        updateDataToUserDefaults(notes: self.notes)
        delegate?.updateNotes(notes: self.notes)
    }
    
    @objc private func updateTextView(param: Notification) {
        guard let keyboardFrame = param.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        if param.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        }
        else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
}
