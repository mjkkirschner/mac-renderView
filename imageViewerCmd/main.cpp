//
//  main.cpp
//  imageViewerCmd
//
//  Created by Michael Kirschner on 1/16/20.
//  Copyright © 2020 Michael Kirschner. All rights reserved.
//

#include <iostream>
// only "extern" when targeting C.
extern "C" void start_render_view(int width,int height);
extern "C" void next_frame();


int main(int argc, const char * argv[]) {
    start_render_view(600,600);
    while(true){
        next_frame();
    }
    std::cout << std::endl << "called from cpp" << std::endl;
    return 0;
}
