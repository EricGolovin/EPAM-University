//
//  NavSecondViewController.swift
//  TabBar-HW
//
//  Created by Eric Golovin on 6/14/20.
//  Copyright © 2020 Eric Golovin. All rights reserved.
//

import UIKit

class NavSecondViewController: UIViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func moveTapped(_ sender: UIButton) {
        tabBarController?.selectedViewController = tabBarController?.children.last
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
