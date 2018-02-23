//
//  AlbumCell.swift
//  paths
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import Foundation
import UIKit

class AlbumCell : UICollectionViewCell {
    var representedAssetIdentifier : String?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
}
