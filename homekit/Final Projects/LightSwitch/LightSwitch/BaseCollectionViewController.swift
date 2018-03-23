//
//  BaseCollectionViewController.swift
//  LightSwitch
//
//  Created by Vijay Sharma on 2018-03-22.
//  Copyright © 2018 Ray Wnderlich. All rights reserved.
//

import UIKit

class BaseCollectionViewController : UICollectionViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = true
		self.navigationController?.navigationBar.tintColor = UIColor.white
		self.navigationController?.navigationBar.barStyle = UIBarStyle.black
		
		let width = view.frame.size.width / 3
		let height = width + 21
		let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
		layout.itemSize = CGSize(width: width, height: height)
	}
	
}
