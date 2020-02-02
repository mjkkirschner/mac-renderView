//
//  entry.swift
//  imageViewer
//
//  Created by Michael Kirschner on 1/16/20.
//  Copyright © 2020 Michael Kirschner. All rights reserved.
//

import Foundation
import AppKit

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
            
            //create some random data.
            var arr = (0...600*600*4).map( {_ in UInt8.random(in: 0...255)} )
            let pointer: UnsafeMutablePointer< UInt8 > = UnsafeMutablePointer(&arr)
            
            let image = CreateImageFromARGB32Bitmap(width: 600,height: 600,address: pointer);
            
            let nsimg = NSImage(cgImage: image, size: NSZeroSize)
            let imageViewObject = NSImageView(frame: NSRect(origin: .zero, size: nsimg.size))
            imageViewObject.image = nsimg;
            
            win.contentView?.addSubview(imageViewObject);
             print("makeKey window");
            
        }

        func applicationWillTerminate(_ aNotification: Notification) {
                // Insert code here to tear down your application
        }
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
/*
func CGImageRef CreateImageFromARGB32Bitmap(     unsigned int height,     unsigned int width,     void *baseAddr,     unsigned int rowBytes) {     const size_t bitsPerComponent = 8;     const size_t bitsPerPixel = 32;
    CGImageRef retVal = NULL;
    // Create a data provider. We pass in NULL for the info     // and the release procedure pointer.     CGDataProviderRef dataProvider =             CGDataProviderCreateWithData(                     NULL, baseAddr, rowBytes * height, NULL);     // Get our hands on the generic RGB color space.     CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateWithName(             kCGColorSpaceGenericRGB);     // Create an image     retVal = CGImageCreate(             width, height, bitsPerComponent, bitsPerPixel,             rowBytes, rgbColorSpace, kCGImageAlphaPremultipliedFirst,             dataProvider, NULL, true, kCGRenderingIntentDefault);     // The data provider and color space now belong to the     // image so we can release them.     CGDataProviderRelease(dataProvider);     CGColorSpaceRelease(rgbColorSpace);     return retVal; }
*/
class entryPoint{
    init() {
    }
    func hello() {
        print("helloWorld");
    }
}
