//
//  ViewController.swift
//  CryptoSwitfDemo
//
//  Created by Marko Budal on 29/09/15.
//  Copyright © 2015 Marko Budal. All rights reserved.
//

import UIKit
import CryptoSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let data:NSData = NSData(bytes: [49, 50, 51] as [UInt8], length: 3)
        
        print("md5: \(data.md5()!.toHexString())")
        print("sha1: \(data.sha1()!.toHexString())")
        print("sha224: \(data.sha224()!.toHexString())")
        print("sha256: \(data.sha256()!.toHexString())")
        print("sha334: \(data.sha384()!.toHexString())")
        print("sha512: \(data.sha512()!.toHexString())")
        print("crc32: \(data.crc32()!.toHexString())")
        
        print("Data: \(data.toHexString())")
        let crc32 = data.crc32()
        print("Crc32: \(crc32)")
        let d = crc32?.arrayOfBytes()
        print("Array: \(d)")
        

        var test = NSData(bytes: [0x10, 0x55, 0x01, 0x00, 0x55, 0x23, 0x06,0x94,0x00, 0xE4,0x10,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 ] as [UInt8], length: 28)
        //105501005523069400E4100300000000000000000000000000000000
        print(test.crc32()?.toHexString())
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

