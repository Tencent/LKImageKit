//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

#import "LKImageWebPDecoder.h"
#import "webP/demux.h"
#import "webP/decode.h"

@implementation LKImageWebPDecoder

static void FreeWebPImageData(void *info, const void *data, size_t size)
{
    free((void*)data);
}

- (LKImageDecodeResult *)decodeResultFromData:(NSData *)data request:(LKImageRequest *)request
{
    NSDate *date = [NSDate date];
    WebPData webp_data;
    webp_data.bytes = data.bytes;
    webp_data.size = data.length;
    
    WebPDemuxer* demux = WebPDemux(&webp_data);
    if (!demux)
    {
        return nil;
    }
    LKImageDecodeResult *result = [[LKImageDecodeResult alloc] init];
    result.type = @"webP";
    uint32_t width = WebPDemuxGetI(demux, WEBP_FF_CANVAS_WIDTH);
    uint32_t height = WebPDemuxGetI(demux, WEBP_FF_CANVAS_HEIGHT);
    // ... (Get information about the features present in the WebP file).
    uint32_t flags = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS);
    
    NSMutableArray *array = [NSMutableArray array];
    
    // ... (Iterate over all frames).
    WebPIterator iter;
    NSInteger duration = 0;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapinfo = kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst;
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 4*width, colorSpace, bitmapinfo);
    if (!context)
    {
        WebPDemuxDelete(demux);
        result.error = [LKImageError errorWithCode:LKImageErrorCodeDecodeFailed];
        return result;
    }
    
    
    if (WebPDemuxGetFrame(demux, 1, &iter)) {
        do {
            if (duration == 0)
            {
                duration = iter.duration;
            }
            WebPDecoderConfig config;
            if (!WebPInitDecoderConfig(&config))
            {
                CGColorSpaceRelease(colorSpace);
                CGContextRelease(context);
                WebPDemuxReleaseIterator(&iter);
                WebPDemuxDelete(demux);
                return nil;
            }
            config.output.colorspace = MODE_bgrA;
            VP8StatusCode retCode = WebPDecode(iter.fragment.bytes, iter.fragment.size, &config);
            if (retCode != VP8_STATUS_OK)
            {
                CGColorSpaceRelease(colorSpace);
                CGContextRelease(context);
                WebPDemuxReleaseIterator(&iter);
                WebPDemuxDelete(demux);
                result.error = [LKImageError errorWithCode:LKImageErrorCodeDecodeFailed];
                return result;
            }
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                                      config.output.u.RGBA.rgba,
                                                                      config.output.u.RGBA.size,
                                                                      FreeWebPImageData);
            CGImageRef imageRef = CGImageCreate(iter.width, iter.height, 8, 32, 4*iter.width, colorSpace, bitmapinfo, provider, nil, NO, kCGRenderingIntentDefault);
            UIImage *newImage = nil;
            CGContextDrawImage(context, CGRectMake(iter.x_offset, height - iter.height - iter.y_offset, iter.width, iter.height), imageRef);
            CGImageRef image = CGBitmapContextCreateImage(context);
            newImage = [[UIImage alloc] initWithCGImage:image];
            [array addObject:newImage];
            CGImageRelease(imageRef);
            CGImageRelease(image);
            CGDataProviderRelease(provider);
            
            // ... (Consume 'iter'; e.g. Decode 'iter.fragment' with WebPDecode(),
            // ... and get other frame properties like width, height, offsets etc.
            // ... see 'struct WebPIterator' below for more info).
        } while (WebPDemuxNextFrame(&iter));
        WebPDemuxReleaseIterator(&iter);
    }
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    // ... (Extract metadata).
    WebPChunkIterator chunk_iter;
    if (flags & ICCP_FLAG) WebPDemuxGetChunk(demux, "ICCP", 1, &chunk_iter);
    // ... (Consume the ICC profile in 'chunk_iter.chunk').
    WebPDemuxReleaseChunkIterator(&chunk_iter);
    if (flags & EXIF_FLAG) WebPDemuxGetChunk(demux, "EXIF", 1, &chunk_iter);
    // ... (Consume the EXIF metadata in 'chunk_iter.chunk').
    WebPDemuxReleaseChunkIterator(&chunk_iter);
    if (flags & XMP_FLAG) WebPDemuxGetChunk(demux, "XMP ", 1, &chunk_iter);
    // ... (Consume the XMP metadata in 'chunk_iter.chunk').
    
    WebPDemuxReleaseChunkIterator(&chunk_iter);
    WebPDemuxDelete(demux);
    NSLog(@"WebPDecodeTime:%f",[[NSDate date] timeIntervalSinceDate:date]);
    UIImage *image = [LKImageUtil imageFromImages:array duration:duration/1000.0];
    result.image = image;
    return result;
}

@end
