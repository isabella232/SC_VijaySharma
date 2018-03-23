//
//  AccessoryViewController.swift
//  HomeKit
//
//  Created by Vijay Sharma on 2018-03-22.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import UIKit
import HomeKit

class AccessoryViewController : BaseCollectionViewController {
	let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
	var accessories: [HMAccessory] = []
	var home: HMHome? = nil
	
	// For discovering new accessories
	let browser = HMAccessoryBrowser()
	var discoveredAccessories:[HMAccessory] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "\(self.home?.name ?? "") Accessories"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverAccessories(sender:)))
		
		self.loadAccessories();
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return accessories.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let accessory = self.accessories[indexPath.row]
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath)
		if let label = cell.viewWithTag(101) as! UILabel! {
			label.text = accessory.name
		}
		
		if let image = cell.viewWithTag(100) as! UIImageView! {
			let state = self.getLightbulbState(accessory)
			image.image = UIImage(named: state)
		}
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		
		let accessory = accessories[indexPath.row];
		
		guard let characteristic = accessory.find(serviceType:HMServiceTypeLightbulb, characteristicType:HMCharacteristicMetadataFormatBool) else {
			return
		}
		
		let toggleState = (characteristic.value as! Bool) ? false : true
		characteristic.writeValue(NSNumber(value: toggleState), completionHandler: { (error) -> Void in
			if error != nil {
				print("Something went wrong when attempting to update the service characteristic.")
			}
			self.collectionView?.reloadData()
		})
	}
	
	private func loadAccessories() {
		if let homeAccessories = self.home?.accessories {
			for accessory in homeAccessories {
				if let characteristic = accessory.find(serviceType:HMServiceTypeLightbulb, characteristicType:HMCharacteristicMetadataFormatBool) {
					accessories.append(accessory)
					accessory.delegate = self
					characteristic.enableNotification(true, completionHandler: { (error) -> Void in
						if error != nil {
							print("Something went wrong when enabling notification for a chracteristic.")
						}
					})
				}
			}
			
			self.collectionView?.reloadData()
		}
	}
	
	private func getLightbulbState(_ accessory: HMAccessory) -> String {
		guard let characteristic = accessory.find(serviceType:HMServiceTypeLightbulb, characteristicType:HMCharacteristicMetadataFormatBool) else {
			return "off"
		}
		
		if characteristic.value as! Bool == true {
			return "on"
		} else {
			return "off"
		}
	}
	
	@objc func discoverAccessories(sender: UIBarButtonItem) {
		activityIndicator.startAnimating()
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
		
		discoveredAccessories.removeAll()
		browser.delegate = self
		browser.startSearchingForNewAccessories()
		perform(#selector(stopDiscoveringAccessories), with:nil, afterDelay: 10)
	}
	
	@objc private func stopDiscoveringAccessories() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverAccessories(sender:)))
//		browser.stopSearchingForNewAccessories() // BUG!!
		if (discoveredAccessories.count == 0) {
			let alert = UIAlertController(title: "No Accessories Found", message: "No Accessories were found. Make sure your accessory is nearby and on the same network.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		} else {
			let homeName = self.home?.name
			let alert = UIAlertController(title: "Accessories Found", message: "A total of \(discoveredAccessories.count) were found. They will all be added to your home '\(homeName ?? "")'.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action in
				self.add(accessories:self.discoveredAccessories)
			})
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	private func add(accessories: [HMAccessory]) {
		for accessory in accessories {
			self.home?.addAccessory(accessory) {error in
				if let error = error {
					print("Failed to add accessory to Home. \(error.localizedDescription)")
				} else {
					self.loadAccessories()
				}
			}
		}
	}
}

extension AccessoryViewController: HMAccessoryDelegate {
	func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
		self.collectionView?.reloadData()
	}
}

extension AccessoryViewController: HMAccessoryBrowserDelegate {
	func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
		self.discoveredAccessories.append(accessory)
	}
}

extension HMAccessory {
	func find(serviceType: String, characteristicType: String) -> HMCharacteristic? {
		for service in self.services {
			if serviceType == service.serviceType {
				for item in service.characteristics {
					let characteristic = item as HMCharacteristic
					if let metadata = characteristic.metadata as HMCharacteristicMetadata? {
						if metadata.format == characteristicType {
							return characteristic
						}
					}
				}
			}
		}
		
		return nil
	}
}

