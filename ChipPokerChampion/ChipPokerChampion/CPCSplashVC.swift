//
//  CPCSplashVC.swift
//  ChipPokerChampion
//
//  Created by SunTory on 2024/9/26.
//

import UIKit

class CPCSplashVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func clickStartBtn(_ sender: Any) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "CPCHomeVC") as! CPCHomeVC
        let contentVC =  CPCNavigationController.init(rootViewController: gameVC)
        contentVC.modalPresentationStyle = .fullScreen
        present(contentVC, animated: true)
    }
}
