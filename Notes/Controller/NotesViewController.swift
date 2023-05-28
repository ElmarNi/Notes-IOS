//
//  NotesViewController.swift
//  Notes
//
//  Created by Elmar Ibrahimli on 25.05.23.
//

import UIKit

class NotesViewController: UIViewController {

    private var notes = [Note]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isHidden = true
        return tableView
    }()
    
    private let noNotesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isHidden = true
        return stackView
    }()
    
    private let noNotesTitle: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = "You don't have any notes"
        label.textAlignment = .center
        return label
    }()
    
    private let createNoteBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Create note", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                                            style: .plain, target: self, action: #selector(createDidTap))
        
        view.addSubview(tableView)
        view.addSubview(noNotesStackView)
        noNotesStackView.addSubview(noNotesTitle)
        noNotesStackView.addSubview(createNoteBtn)
        createNoteBtn.addTarget(self, action: #selector(createNoteBtnDidTapped), for: .touchUpInside)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        
        getUserDefaults { notes, success in
            if success {
                self.notes = notes!
            }
            else {
                showAlert(title: "Error", message: "Something went wrong when getting notes", target: self)
            }
        }
        
        checkNotesCountForShowViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noNotesStackView.frame = CGRect(x: 0, y: 0, width: view.width, height: 65)
        noNotesStackView.center = view.center
        noNotesTitle.frame = CGRect(x: 10, y: 0, width: view.width - 20, height: 30)
        createNoteBtn.frame = CGRect(x: 10, y: noNotesTitle.bottom + 5, width: view.width - 20, height: 30)
    }

    @objc private func createDidTap() {
        createNote()
    }
    
    @objc private func createNoteBtnDidTapped() {
        createNote()
    }
    
    private func createNote() {
        let alert = UIAlertController(title: "Create Note", message: "Please enter note name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Note name..."
        })
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {[weak self] _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty
            else{
                showAlert(title: "Error", message: "Note name can not be empty", target: self)
                HapticsManager.shared.vibrate(for: .error)
                return
            }
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/YYYY"
            
            let id = self?.notes.last?.id ?? 0
            self?.notes.append(Note(id: id + 1, name: text, body: nil, createDate: dateFormatter.string(from: date)))
            updateDataToUserDefaults(notes: self?.notes) { result in
                if result {
                    self?.tableView.reloadData()
                    self?.checkNotesCountForShowViews()
                }
                else {
                    showAlert(title: "Error", message: "Something went wrong when adding note", target: self)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    
    private func checkNotesCountForShowViews() {
        if notes.count == 0 {
            tableView.isHidden = true
            noNotesStackView.isHidden = false
        }
        else {
            tableView.isHidden = false
            noNotesStackView.isHidden = true
        }
    }
    
}

extension  NotesViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.identifier, for: indexPath) as? NoteTableViewCell
        else{
            return UITableViewCell()
        }
        let model = notes[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = notes[indexPath.row]
        let nameLabelHeight = model.name.getHeightForLabel(font: .systemFont(ofSize: 20, weight: .bold), width: tableView.width - 20)
        let dateLabelHeight = model.createDate.getHeightForLabel(font: .systemFont(ofSize: 15, weight: .regular), width: tableView.width - 20)
        return nameLabelHeight + dateLabelHeight + 25
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            let alert = UIAlertController(title: "Delete Note", message: "Are you sure to delete this note?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {[weak self] _ in
                self?.notes.remove(at: indexPath.row)
                updateDataToUserDefaults(notes: self?.notes) { result in
                    if result {
                        self?.tableView.reloadData()
                        self?.checkNotesCountForShowViews()
                    }
                    else {
                        showAlert(title: "Error", message: "Something went wrong when adding note", target: self)
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default))
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        let model = notes[indexPath.row]
        let noteViewController = NoteViewController(note: model)
        noteViewController.delegate = self
        navigationController?.pushViewController(noteViewController, animated: true)
    }
    
}

extension NotesViewController: NoteViewControllerDelegate {
    
    func updateNotes(notes: [Note]) {
        self.notes = notes
    }
    
}
