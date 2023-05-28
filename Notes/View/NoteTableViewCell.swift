//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by Elmar Ibrahimli on 26.05.23.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    static let identifier = "NoteTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        contentView.clipsToBounds = true
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.sizeToFit()
        dateLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 10, y: 10, width: contentView.width - 20, height: nameLabel.height)
        dateLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 5, width: contentView.width - 20, height: dateLabel.height)
    }
    
    public func configure(with model: Note) {
        nameLabel.text = model.name
        dateLabel.text = model.createDate
    }
}
