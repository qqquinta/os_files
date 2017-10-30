import strutils
import nimx.write_image_impl

{.passL: "-framework Foundation".}
{.passL: "-framework AppKit".}

type NSWorkspace {.importobjc: "NSWorkspace*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object

{.pragma: objc, header: "<Foundation/Foundation.h>", nodecl.}
type NSObject* {.objc, importobjc, final.} = ptr object {.inheritable.}
type NSString* {.objc, importobjc, final.} = ptr object of NSObject
type NSArrayAbstract* {.objc, importc: "NSArray", final.} = ptr object of NSObject
type NSArray*[T] = ptr object of NSArrayAbstract
type NSMutableArray*[T] = ptr object of NSArray[T]
type NSMutableArrayAbstract* {.objc, importc: "NSMutableArray", final.} = ptr object of NSArrayAbstract

proc newWorkspace: NSWorkspace {.importobjc: "NSWorkspace sharedWorkspace", nodecl.}

proc NSStringWithString*(n: cstring): NSString {.importobjc: "NSString stringWithUTF8String", nodecl.}
converter toNSString*(s: string): NSString = NSStringWithString(s)


proc iconBitmapForFile*(path: string, w, h: int): seq[byte] =
    let tt: cstring = path
    let workspace = newWorkspace()
    var pixels = newSeq[byte](4 * w * h)
    var data = addr pixels[0]

    {.emit: """
        unsigned char* d = `data`;
        NSImage* img = [`workspace` iconForFile: [NSString stringWithUTF8String: `tt`]];

        // downscale
        NSSize newSize = NSMakeSize(`w`/2, `h`/2);
        NSImage *smallImage = [[[NSImage alloc] initWithSize: newSize] autorelease];
        [smallImage lockFocus];
        [img setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [img compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
        [smallImage unlockFocus];

        // get bitmap
        NSBitmapImageRep *bmp = [NSBitmapImageRep imageRepWithData:[smallImage TIFFRepresentation]];
        memcpy(d, [bmp bitmapData], 4 * `w` * `h`);

        NSLog(@" icon %d ", bmp.pixelsWide);

    """.}

    result = pixels

    # for y in 0 ..< h:
    #     for x in 0 ..< w:
    #         let i = 4 * (w * y + x)
    #         echo "pixels = ", pixels[i + 0], " ", pixels[i + 1], " ",pixels[i + 2], " ", pixels[i + 3]

    discard stbi_write_png("/Users/rrenderr/Documents/a1.png".cstring, w.cint, h.cint, 4.cint, addr pixels[0], 0)
