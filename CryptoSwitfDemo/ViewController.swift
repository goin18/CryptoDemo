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
    
    enum StatusTx {
        case ST_SEND_INIT, ST_SEND_STX, ST_SEND_INFO_VER, ST_SEND_INFO_TYPE, ST_SEND_DATA, ST_SEND_END_DLE, ST_SEND_ETX, ST_SEND_CRC
    }
    
    struct TransportStruct {
        let MXP_TRANSPORT_DLE:UInt8 = 0x10		// 'Data Link Escape' byte identifier
        let MXP_TRANSPORT_stx:UInt8 = 0x02		// 'Start of Transmission' byte identifier for frames with 16-bit CRC
        let MXP_TRANSPORT_STX: UInt8 = 0x55		// 'Start of Transmission' byte identifier for frames with 32-bit CRC
        let MXP_TRANSPORT_ETX: UInt8 = 0x03 	// 'End of Transmission' byte identifier
        
        let MXP_TRANSPORT_VER: UInt8 = 0x01		// Application protocol version
        let MXP_TRANSPORT_TYPE: UInt8 = 0x00	// type of transported information ( 0x00 refers to satellite OBU, etc� )
        
    }

    
    var statusTx = StatusTx.ST_SEND_INIT
    var mBuffTransmitt:[UInt8] = [0x10, 0x55, 0x01]
    var mbRxLite = true
    var mbRxCrc16 = true
    var mbTxCrc16:Bool? = true
    
    
    func transmitt ( ) -> [UInt8]? {
        //var statusTx : StatusTx = StatusTx.ST_SEND_INIT;
        var bDle: Bool = false
        var pDataResult: [UInt8]
        var iSource: Int = 0
        var iDest: Int = 0
        var bData: UInt8 = 0
        var lcCrc16: UInt16 = 0
        var liCrc32:Int32 = 0
        var bContCrc: UInt8 = 0
        var bLoop: Bool = true
        var mcrc: Int = 0
        
        pDataResult = [UInt8](count: (self.mBuffTransmitt.count + 8) * 2, repeatedValue: 0)
        while  bLoop {
            switch ( statusTx ).self
            {
            case .ST_SEND_INIT:
                bDle = false
                bData = TransportStruct().MXP_TRANSPORT_DLE
                statusTx = StatusTx.ST_SEND_STX
                lcCrc16 = 0
                liCrc32 = 0
                bContCrc = 0
                break
                
            case .ST_SEND_STX:
                if ( mbTxCrc16 != nil)
                {
                    bData = TransportStruct().MXP_TRANSPORT_stx
                }
                else
                {
                    bData = TransportStruct().MXP_TRANSPORT_STX
                }
                
                if (mbRxLite == true)
                {
                    statusTx = StatusTx.ST_SEND_DATA
                }
                else
                {
                    statusTx = StatusTx.ST_SEND_INFO_VER
                }
                break;
                
            case .ST_SEND_INFO_VER:
                bData = TransportStruct().MXP_TRANSPORT_VER
                statusTx = StatusTx.ST_SEND_INFO_TYPE
                break
                
            case .ST_SEND_INFO_TYPE:
                bData = TransportStruct().MXP_TRANSPORT_TYPE
                statusTx = StatusTx.ST_SEND_DATA
                break
                
            case .ST_SEND_DATA:
                if ( iSource < mBuffTransmitt.count )
                {
                    if ( bDle )
                    {
                        bDle = false
                        bData = TransportStruct().MXP_TRANSPORT_DLE
                        iSource++
                        break
                    }
                    
                    if ( mBuffTransmitt[iSource] == TransportStruct().MXP_TRANSPORT_DLE )
                    {
                        bDle = true
                        bData = TransportStruct().MXP_TRANSPORT_DLE
                        break
                    }
                    
                    bData = mBuffTransmitt[iSource++]
                    break
                }
                statusTx = StatusTx.ST_SEND_END_DLE;
                
            case .ST_SEND_END_DLE:
                bData = TransportStruct().MXP_TRANSPORT_DLE
                statusTx = StatusTx.ST_SEND_ETX
                break
                
            case .ST_SEND_ETX:
                bData = TransportStruct().MXP_TRANSPORT_ETX
                statusTx = StatusTx.ST_SEND_CRC
                break
                
            case .ST_SEND_CRC:
                if(mcrc==0)
                {
                    let data  = NSData.withBytes(pDataResult)
                    let crc = data.crc32()
                    let checksumValue = crc?.checksum()
                    liCrc32 = Int32(checksumValue!)
                }
                if let a = mbRxCrc16 as? Bool {
                    if a == true
                    {
                        bData = UInt8(Int16(lcCrc16) >> Int16(8 * bContCrc) & 0x00FF)
                    }
                    else
                    {
                        bData = UInt8(Int32(liCrc32) >> Int32(8 * bContCrc) & 0xFF)
                        
                    }
                } else {
                    bData = UInt8(Int32(liCrc32) >> Int32(8 * bContCrc) & 0xFF)
                }
                
                bContCrc++
                break;
            }
            
            pDataResult[iDest++]=bData;
            if ( bContCrc == 4 )
            {
                bLoop = false
            }
        }
        
        pDataResult = resizeArray(pDataResult, piStart: 0, piLen: iDest)//UInt8
        return  pDataResult
        
    }
    
    func resizeArray(oldArray: [UInt8], piStart: Int, piLen: Int ) -> [UInt8] {
        
        var newLength = oldArray.count - piStart
        
        newLength = min(newLength, piLen)
        
        if newLength > 0 {
            return Array(oldArray[piStart...newLength+piStart-1])
        } else {
            return []
        }
    }
    


}

