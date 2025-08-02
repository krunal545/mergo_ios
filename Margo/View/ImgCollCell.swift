//
//  ImgCollCell.swift
//  Margo
//
//  Created by Lenovo on 10/01/25.
//

import UIKit

class ImgCollCell: UICollectionViewCell {
    
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var lblMain: UILabel!
    @IBOutlet weak var vwImgEdit: UIView!
    @IBOutlet weak var vwMain: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var AddImgView: UIView!
    var AddImage : (() -> ()) = {}
    var EditImage: (() -> ()) = {}
    
    @IBAction func btnEditImageAction(_ sender: UIButton) {
        EditImage()
    }
    @IBAction func btnAddImageAction(_ sender: UIButton) {
        AddImage()
    }
    
    
}
