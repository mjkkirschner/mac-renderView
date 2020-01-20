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
    let win = NSWindow(contentRect: NSMakeRect(100, 100, 600, 200),
              styleMask: [.titled, .miniaturizable,.closable,.resizable],
               backing: NSWindow.BackingStoreType.buffered, defer: true);
    
     func applicationDidFinishLaunching(_ aNotification: Notification)
        {
             print("inside finish launch");
              win.makeKeyAndOrderFront(self);
             print("makeKey window");
            
        }

        func applicationWillTerminate(_ aNotification: Notification) {
                // Insert code here to tear down your application
        }
}

class entryPoint{
    init() {
    }
    func hello() {
        print("helloWorld");
    }
}
