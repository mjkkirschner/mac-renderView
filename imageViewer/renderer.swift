//
//  renderer.swift
//  imageViewer
//
//modified from BasicTexturing sample.

//

import Foundation;
import Metal;
import simd;
import MetalKit;

class renderer: NSObject,MTKViewDelegate {
   
    var device:MTLDevice;
    var pipelineState:MTLRenderPipelineState?;
    var commandQ:MTLCommandQueue;
    public var texture:MTLTexture;
    var planeVerts:MTLBuffer;
    var vertNum:Int;
    var viewPortSize:vector_uint2?;
    
    public init(view:MTKView){
        
        let width = 600;
        let height = 600;
        
        device = view.device!;
        texture = renderer.CreateMetalTexture(width: width,height: height);
        viewPortSize = vector_uint2(UInt32(width), UInt32(height));
        let quadVertices =
               // Pixel positions, Texture coordinates
                 //TODO normalize these and scale them.... or create these when we need to after the image size/format is known.
           [
               AAPLVertex(position:vector_float2(600,-600),textureCoordinate:vector_float2(1.0, 1.0)),
               AAPLVertex(position:vector_float2(-600,-600),textureCoordinate:vector_float2(0.0, 1.0)),
               AAPLVertex(position:vector_float2(-600,600),textureCoordinate:vector_float2(0.0, 0.0)),
               
               AAPLVertex(position:vector_float2(600,-600),textureCoordinate:vector_float2(1.0, 1.0)),
               AAPLVertex(position:vector_float2(-600,600),textureCoordinate:vector_float2(0.0, 0.0)),
               AAPLVertex(position:vector_float2(600,600),textureCoordinate:vector_float2(1.0, 0.0)),
               
           ];
        
        // Create a vertex buffer, and initialize it with the quadVertices array
        planeVerts = device.makeBuffer(bytes: quadVertices,length: quadVertices.count * MemoryLayout<AAPLVertex>.stride,options: MTLResourceOptions.storageModeShared)!;
        // Calculate the number of vertices by dividing the byte length by the size of each vertex

        vertNum = quadVertices.count * MemoryLayout<AAPLVertex>.stride /  MemoryLayout<AAPLVertex>.size;
        print (vertNum);
        /// Create the render pipeline.

        // Load the shaders from the default library
        let defaultLibrary = device.makeDefaultLibrary();
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader");
        let fragmentFunction = defaultLibrary?.makeFunction(name: "samplingShader");
        
         // Set up a descriptor for creating a pipeline state object
        var pipelinestatedescriptor = MTLRenderPipelineDescriptor();
        pipelinestatedescriptor.label = "Texturing Pipeline";
        pipelinestatedescriptor.vertexFunction = vertexFunction;
        pipelinestatedescriptor.fragmentFunction = fragmentFunction;
        pipelinestatedescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
        
        
        do{
        try pipelineState = device.makeRenderPipelineState(descriptor: pipelinestatedescriptor);
        }
        catch{
            print(error);
        
        }
        commandQ = device.makeCommandQueue()!;
                
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewPortSize!.x = UInt32(size.width);
        viewPortSize!.y = UInt32(size.height);
       }
       
       func draw(in view: MTKView) {
          // Create a new command buffer for each render pass to the current drawable
        
        var commandBuffer = commandQ.makeCommandBuffer();
        commandBuffer?.label = "MyCommand";
        

               // Obtain a renderPassDescriptor generated from the view's drawable textures
        
        var renderPassDescriptor = view.currentRenderPassDescriptor;
        if(renderPassDescriptor != nil){
            var renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!);
            renderEncoder!.label? = "MyRenderEncoder";
            renderEncoder!.setViewport(MTLViewport(originX: 0.0, originY: 0.0, width: Double(viewPortSize!.x), height: Double(viewPortSize!.y), znear: -1.0, zfar: 1.0));
            renderEncoder!.setRenderPipelineState(pipelineState!);
            renderEncoder!.setVertexBuffer(planeVerts, offset: 0, index: Int(AAPLVertexInputIndexVertices.rawValue));
            renderEncoder!.setVertexBytes(&viewPortSize, length: MemoryLayout.size(ofValue: viewPortSize), index: Int(AAPLVertexInputIndexViewportSize.rawValue));
            
            // Set the texture object.  The AAPLTextureIndexBaseColor enum value corresponds
                              ///  to the 'colorMap' argument in the 'samplingShader' function because its
                              //   texture attribute qualifier also uses AAPLTextureIndexBaseColor for its index.
            renderEncoder?.setFragmentTexture(texture, index:Int(AAPLTextureIndexBaseColor.rawValue));
               // Draw the triangles.
            renderEncoder?.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart:0, vertexCount:vertNum);
            
            renderEncoder?.endEncoding();
            // Schedule a present once the framebuffer is complete using the current drawable

            commandBuffer?.present(view.currentDrawable!);
          
        }
        
        // Finalize rendering here & push the command buffer to the GPU

                  commandBuffer?.commit();
             

        
           }
    

    public static func  CreateMetalTexture(width:Int, height:Int)->MTLTexture{
        let descriptor = MTLTextureDescriptor();
        descriptor.pixelFormat = MTLPixelFormat.rgba8Unorm;
        descriptor.width = width;
        descriptor.height = height;
        
        let texture = MTLCreateSystemDefaultDevice()!.makeTexture(descriptor: descriptor);
        return texture!;
    }

   public func UpdateTextureWithColorDataPointer(tex:MTLTexture,pointer:UnsafeMutablePointer< UInt8 >){
        //the entire texture is to be updated...
        let region:MTLRegion = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: tex.width, height: tex.height, depth: 1));
        let bytesPerRow = 4*tex.width;
        tex.replace(region: region, mipmapLevel: 0, withBytes: pointer, bytesPerRow: bytesPerRow);
    }

   
    
}