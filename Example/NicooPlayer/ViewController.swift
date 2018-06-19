//
//  ViewController.swift
//  NicooPlayer
//
//  Created by 504672006@qq.com on 06/19/2018.
//  Copyright (c) 2018 504672006@qq.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func playInView(_ sender: UIButton) {
        let vc = PlayVideoVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func playInCell(_ sender: UIButton) {
        let vc = CellPlayVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

