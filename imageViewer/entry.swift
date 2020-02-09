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

var controller:TestApplicationController? = nil;

var app:NSApplication? = nil ;

@_cdecl("start_render_view")
public func start_render_view(width:Int,height:Int){
    print("Hello, World - from swift!")
    app = NSApplication.shared;
    controller =  TestApplicationController(width: width,height: height);
    app!.delegate = controller;
     print("about to try running")
    
    //app.run();
    
    //since we do not use the built in main loop
    //need to finish launching ourselves.
    app?.finishLaunching();
    print("GoodBye, World - from swift!");
}

@_cdecl("next_frame")
public func next_frame(){
    var event:NSEvent? = nil;
    repeat{
        controller?.win.viewsNeedDisplay = true;
        event = (app?.nextEvent(matching: NSEvent.EventTypeMask.any, until:nil, inMode: RunLoop.Mode.default, dequeue:true));
        if  (event != nil)
        {
            app?.sendEvent(event!);
        }
    }
        while (event != nil);
}

@_cdecl("update_tex")
public func update_tex(data:UnsafeMutablePointer<uint8>){
    controller?.updateTextureData(data: data);
}

final class TestApplicationController: NSObject, NSApplicationDelegate
{
    var win:NSWindow;
    var imageWidth:Int;
    var imageHeight:Int;
    var imageData: Array<uint8>;
    var pointer:UnsafeMutablePointer<uint8>;
    
    init(width:Int,height:Int) {
        win = NSWindow(contentRect: NSMakeRect(100, 100, CGFloat(width), CGFloat(height)),
                    styleMask: [.titled, .miniaturizable,.closable,.resizable],
                     backing: NSWindow.BackingStoreType.buffered, defer: true);
        imageWidth = width;
        imageHeight = height;
        
        print(imageWidth);
        print(imageHeight);
        //create some random data.
        //we assume we are writing RGBA colors
        //rgba8Unorm texture pix format width * height * 4 bytes per pixel.
        imageData = (0...imageWidth*imageHeight*4).map( {_ in UInt8.random(in: 0...255)} );
        pointer = UnsafeMutablePointer(&imageData);

    }
    
    
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
            
            let tex2dRendererInstance = renderer(view: mtkView);
            mtkView.delegate = tex2dRendererInstance;
            
            
           
          
            var i = 0;

            //update the image fast.
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true)
            { timer in
                tex2dRendererInstance.UpdateTextureWithColorDataPointer(tex: tex2dRendererInstance.texture,pointer: self.pointer);
                print("inside timer");
            }
            
          /*
            DispatchQueue.global(qos: .background).async {
                while(i < arr.count-1){
                    arr[i] = UInt8(i%255);
                    
                    i = i + 1;
                }
            }
        */
             print("makeKey window");
            
         
            }
            

        func applicationWillTerminate(_ aNotification: Notification) {
                // Insert code here to tear down your application
        }
    
    func updateTextureData(data:UnsafeMutablePointer<uint8>) {
        print("setting pointer to", data);
        pointer = data;
    }
}

