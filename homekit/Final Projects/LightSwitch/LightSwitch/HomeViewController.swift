//
//  ViewController.swift
//  HomeKit
//
//  Created by Vijay Sharma on 2018-02-13.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: BaseCollectionViewController {
	var homes:[HMHome] = []
	let homeManager = HMHomeManager()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		homeManager.delegate = self
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Homes"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newHome(sender:)))
		self.addHomes(self.homeManager.homes)
		self.collectionView?.reloadData()
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return homes.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath)
		if let label = cell.viewWithTag(101) as! UILabel! {
			label.text = homes[indexPath.row].name
		}
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		
		let target = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryViewController
		target.home = homes[indexPath.row]
		self.navigationController?.pushViewController(target, animated: true)
	}
	
	@objc func newHome(sender: UIBarButtonItem) {
		self.showInputDialog { (homeName, roomName) in
			self.homeManager.addHome(withName: homeName, completionHandler: { (home, error) in
				if let error = error {
					print("Failed to add home: \(error.localizedDescription)")
				}
				if let discoveredHome = home {
					discoveredHome.addRoom(withName: roomName, completionHandler: { _, error  in
						if let error = error {
							print("Failed to add room: \(error.localizedDescription)")
						} else {
							self.homes.append(discoveredHome)
							self.collectionView?.reloadData()
						}
					})
				}
			})
		}
	}
	
	func showInputDialog(_ handler: @escaping ((String, String) -> Swift.Void)) {
		let alertController = UIAlertController(title: "Create new Home?", message: "Enter the name of your new home and give it a Room", preferredStyle: .alert)
		
		let confirmAction = UIAlertAction(title: "Create", style: .default) { (_) in
			guard let homeName = alertController.textFields?[0].text, let roomName = alertController.textFields?[1].text else {
					return
			}
			
			handler(homeName, roomName)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		
		alertController.addTextField { (textField) in
			textField.placeholder = "Enter Home name"
		}
		alertController.addTextField { (textField) in
			textField.placeholder = "Enter Room name"
		}
		
		alertController.addAction(confirmAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	func addHomes(_ homes:[HMHome]) {
		self.homes.removeAll()
		for home in homes {
			self.homes.append(home)
		}
		
		self.collectionView?.reloadData()
	}
}

extension HomeViewController : HMHomeManagerDelegate {
	func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
		self.addHomes(manager.homes)
	}
}

