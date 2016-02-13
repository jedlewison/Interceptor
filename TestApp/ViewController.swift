//
//  ViewController.swift
//  TestApp
//
//  Created by Jed Lewison on 2/12/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let sillyModel = SillyNetworkModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        sillyModel.startAlamofire(NSURL(string: "https://www.google.com")!)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

