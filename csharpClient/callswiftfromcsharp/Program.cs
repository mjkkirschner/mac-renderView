using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading;
using System.Threading.Tasks;

namespace callswiftfromcsharp
{
    class Program
    {

        static int staticIndex = 0;
        static byte[] defaultColor;
        static IntPtr BufferPointer;

        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");

            var bytes = new List<byte>();
            for (var i = 0; i < 600 * 600; i++)
            {
                bytes.Add(0); //red
                bytes.Add(255); // green
                bytes.Add(0); //blue
                bytes.Add(0); // alpha - but we ignore it.
            }
            var bytesAsArray = bytes.ToArray();
            defaultColor = bytesAsArray.ToArray();
            var handle = GCHandle.Alloc(bytesAsArray, GCHandleType.Pinned);
            BufferPointer = handle.AddrOfPinnedObject();

            Task.Run(() =>
            {
                //Thread.Sleep(3000);
                Console.WriteLine("running on another thread");
                while (true)
                {
                    updateTexture(bytesAsArray);
                }
            });

            start_render_view(600, 600);

        }

        public static void updateTexture(Object bytesAsArray)
        {
            (bytesAsArray as byte[])[staticIndex] = 0;
            staticIndex++;
            if (staticIndex >= (bytesAsArray as byte[]).Length)
            {
                staticIndex = 0;
                defaultColor.CopyTo((bytesAsArray as byte[]), 0);
                update_tex(BufferPointer);
            }
            //Console.WriteLine("update tex");
            //update_tex(pointer);
        }


        // the method corresponding to the native function.
        [DllImport("libimageViewer.dylib")]
        private static extern void start_render_view(int width, int height);

        [DllImport("libimageViewer.dylib")]
        private static extern void update_tex(IntPtr data);
    }
}
