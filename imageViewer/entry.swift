//
//  entry.swift
//  imageViewer
//
//  Created by Michael Kirschner on 1/16/20.
//  Copyright © 2020 Michael Kirschner. All rights reserved.
//

import Foundation
import AppKit
import MetalKit

@_cdecl("say_hello")
public func say_hello(){
    print("Hello, World - from swift!")
    let app = NSApplication.shared;
    let con =  TestApplicationController();
    app.delegate = con;
     print("about to try running")
    app.run();
    
    print("GoodBye, World - from swift!");
}

final class TestApplicationController: NSObject, NSApplicationDelegate
{
    let win = NSWindow(contentRect: NSMakeRect(100, 100, 600, 600),
              styleMask: [.titled, .miniaturizable,.closable,.resizable],
               backing: NSWindow.BackingStoreType.buffered, defer: true);
    
   

    
     func applicationDidFinishLaunching(_ aNotification: Notification)
        {
             print("inside finish launch");
              win.makeKeyAndOrderFront(self);
            
            //TODO refactor into method create mtkView.
            let mtkView = MTKView();
               //TODO look this up.
               mtkView.translatesAutoresizingMaskIntoConstraints = false;
               //add to window.
               let view = win.contentView;
               view?.addSubview(mtkView);
               
            //TODO look this up.
            view!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
            view!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
            
            let device = MTLCreateSystemDefaultDevice()!
            mtkView.device = device;
            
            //instantiate our renderer - which will render images into the view:
            
            let myRenderer = renderer(view: mtkView);
            mtkView.delegate = myRenderer;
            
            
            //create some random data.
            var arr = (0...600*600*4).map( {_ in UInt8.random(in: 0...255)} )
            let pointer: UnsafeMutablePointer< UInt8 > = UnsafeMutablePointer(&arr)
          
            var i = 0;
            Timer.scheduledTimer(withTimeInterval: 0.00001, repeats: true) { timer in
                i = i + 1;
                arr[i] = UInt8(i%255);
                
                myRenderer.UpdateTextureWithColorDataPointer(tex: myRenderer.texture,pointer: pointer);
            }
            
             print("makeKey window");
            
         
            }
            

        func applicationWillTerminate(_ aNotification: Notification) {
                // Insert code here to tear down your application
        }
}



func CreateBitmapContextFromARGB32Bitmap(width:uint,height:uint, address:UnsafeMutablePointer<CUnsignedChar>) -> CGContext {
    let bitsPerColor:size_t = 8;
       let bitsPerPixel:size_t = 32;
       let rowBytes:uint = uint(Int(width) * (bitsPerPixel/bitsPerColor));
       let retVal:CGContext;
       let colorSpace:CGColorSpace = CGColorSpace(name:CGColorSpace.genericRGBLinear)!;
         
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    retVal = CGContext(data: address,width: Int(width),height: Int(height),bitsPerComponent: bitsPerColor,bytesPerRow: Int(rowBytes),space: colorSpace,bitmapInfo: bitmapInfo.rawValue)!;
    return retVal;
    
}

    
//create an image from a buffer.
func CreateImageFromARGB32Bitmap(width:uint,height:uint, address:UnsafeMutablePointer<CUnsignedChar>)->CGImage
{
    let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
    // https://developer.apple.com/reference/coregraphics/cgdataproviderreleasedatacallback
    // N.B. 'CGDataProviderRelease' is unavailable: Core Foundation objects are automatically memory managed
    return
    };
    
    let bitsPerColor:size_t = 8;
    let bitsPerPixel:size_t = 32;
    let rowBytes:uint = uint(Int(width) * (bitsPerPixel/bitsPerColor));
    let retVal:CGImage;
    
    let dataProvider = CGDataProvider(dataInfo: nil,data: address,size: Int(rowBytes*height),releaseData: releaseMaskImagePixelData)!;
    
    let colorSpace:CGColorSpace = CGColorSpace(name:CGColorSpace.genericRGBLinear)!;
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
        .union(.byteOrder32Little)
    
    retVal = CGImage(width:Int(width), height:Int(height), bitsPerComponent:bitsPerColor, bitsPerPixel:bitsPerPixel, bytesPerRow:Int(rowBytes),space: colorSpace , bitmapInfo: bitmapInfo, provider: dataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)!;
    return retVal;
}

class entryPoint{
    init() {
    }
    func hello() {
        print("helloWorld");
    }
}
