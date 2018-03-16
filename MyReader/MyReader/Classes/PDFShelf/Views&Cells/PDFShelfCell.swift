//
//  PDFShelfCell.swift
//  MyReader
//
//  Created by GujyHy on 2018/3/13.
//  Copyright © 2018年 Gujy. All rights reserved.
//

import UIKit

class PDFShelfCell: JYTableViewCell {

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView).offset(15)
            make.top.equalTo(self.contentView).offset(10)
        }
        
        self.contentView.addSubview(self.timeLabel)
        self.timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
        }
        
        self.contentView.addSubview(self.sizeLabel)
        self.sizeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.timeLabel.snp.right).offset(15)
            make.bottom.equalTo(self.timeLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public
 
    
    // MARK: Lazy
    var titleLabel:UILabel = {
        let label = UILabel()
        label.textColor     = UIColor.black
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 15)
        return label
    }()

    
    var timeLabel:UILabel = {
        let label = UILabel()
        label.textColor     = UIColor.gray
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 12)
        return label
    }()

    
    var sizeLabel:UILabel = {
        let label = UILabel()
        label.textColor     = UIColor.gray
        label.textAlignment = .center
        label.font          = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
}
