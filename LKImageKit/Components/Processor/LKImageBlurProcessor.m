//
//  LKImageDefaultProcessor.m
//  LKImageKit
//
//  Created by lingtonke on 15/9/7.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageBlurProcessor.h"
#import "LKImageUtil.h"
#import <Accelerate/Accelerate.h>

@implementation LKImageBlurProcessor

- (void)process:(UIImage *)input request:(LKImageRequest *)request complete:(void (^)(UIImage *, NSError *))complete
{
    complete([self imageByApplyingBlurToImage:input
                                   withRadius:self.blurRadius
                                    tintColor:self.blurTintColor
                        saturationDeltaFactor:1.0f
                                    maskImage:nil],
        nil);
}

- (UIImage *)imageByApplyingBlurToImage:(UIImage *)inputImage
                             withRadius:(CGFloat)blurRadius
                              tintColor:(UIColor *)tintColor
                  saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                              maskImage:(UIImage *)maskImage
{

    // Check pre-conditions.
    if (inputImage.size.width < 1 || inputImage.size.height < 1)
    {
        NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@",
            inputImage.size.width, inputImage.size.height, inputImage);
        return nil;
    }
    if (!inputImage.CGImage)
    {
        NSLog(@"*** error: inputImage must be backed by a CGImage: %@", inputImage);
        return nil;
    }
    if (maskImage && !maskImage.CGImage)
    {
        NSLog(@"*** error: effectMaskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }

    BOOL hasBlur             = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;

    CGImageRef inputCGImage              = inputImage.CGImage;
    CGFloat inputImageScale              = inputImage.scale;
    CGBitmapInfo inputImageBitmapInfo    = CGImageGetBitmapInfo(inputCGImage);
    CGImageAlphaInfo inputImageAlphaInfo = (inputImageBitmapInfo & kCGBitmapAlphaInfoMask);

    CGSize outputImageSizeInPoints = inputImage.size;
    CGRect outputImageRectInPoints = {CGPointZero, outputImageSizeInPoints};

    // Set up output context.
    BOOL useOpaqueContext;
    if (inputImageAlphaInfo == kCGImageAlphaNone ||
        inputImageAlphaInfo == kCGImageAlphaNoneSkipLast ||
        inputImageAlphaInfo == kCGImageAlphaNoneSkipFirst)
        useOpaqueContext = YES;
    else
        useOpaqueContext = NO;
    UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext,
        inputImageScale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -outputImageRectInPoints.size.height);

    if (hasBlur || hasSaturationChange)
    {
        vImage_Buffer effectInBuffer;
        vImage_Buffer scratchBuffer1;

        vImage_Buffer *inputBuffer;
        vImage_Buffer *outputBuffer;

        vImage_CGImageFormat format = {
            .bitsPerComponent = 8,
            .bitsPerPixel     = 32,
            .colorSpace       = NULL,
            // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
            // requests a BGRA buffer.
            .bitmapInfo      = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
            .version         = 0,
            .decode          = NULL,
            .renderingIntent = kCGRenderingIntentDefault};

        vImage_Error e = vImageBuffer_InitWithCGImage(
            &effectInBuffer, &format, NULL, inputImage.CGImage, kvImagePrintDiagnosticsToConsole);
        if (e != kvImageNoError)
        {
            NSLog(@"*** error: vImageBuffer_InitWithCGImage returned error code %zi for "
                  @"inputImage: %@",
                e, inputImage);
            UIGraphicsEndImageContext();
            return nil;
        }

        vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width,
            format.bitsPerPixel, kvImageNoFlags);
        inputBuffer  = &effectInBuffer;
        outputBuffer = &scratchBuffer1;

        if (hasBlur)
        {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * inputImageScale;
            if (inputRadius - 2. < __FLT_EPSILON__)
                inputRadius = 2.;
            uint32_t radius = floor((inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);

            radius |= 1; // force radius to be odd so that the three box-blur methodology works.

            NSInteger tempBufferSize =
                vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, radius, radius,
                    NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
            void *tempBuffer = malloc(tempBufferSize);

            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius,
                NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radius, radius,
                NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius,
                NULL, kvImageEdgeExtend);

            free(tempBuffer);

            vImage_Buffer *temp = inputBuffer;
            inputBuffer         = outputBuffer;
            outputBuffer        = temp;
        }
        if (hasSaturationChange)
        {
            CGFloat s = saturationDeltaFactor;
            // These values appear in the W3C Filter Effects spec:
            // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/index.html#grayscaleEquivalent
            //
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,
                0.0722 - 0.0722 * s,
                0.0722 - 0.0722 * s,
                0,
                0.7152 - 0.7152 * s,
                0.7152 + 0.2848 * s,
                0.7152 - 0.7152 * s,
                0,
                0.2126 - 0.2126 * s,
                0.2126 - 0.2126 * s,
                0.2126 + 0.7873 * s,
                0,
                0,
                0,
                0,
                1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize =
                sizeof(floatingPointSaturationMatrix) / sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i)
            {
                saturationMatrix[i] = (int16_t) roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor,
                NULL, NULL, kvImageNoFlags);

            vImage_Buffer *temp = inputBuffer;
            inputBuffer         = outputBuffer;
            outputBuffer        = temp;
        }

        CGImageRef effectCGImage;
        if ((effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, &LKImageCleanupBuffer,
                 NULL, kvImageNoAllocate, NULL)) == NULL)
        {
            effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, NULL, NULL,
                kvImageNoFlags, NULL);
            free(inputBuffer->data);
        }
        if (maskImage)
        {
            // Only need to draw the base image if the effect image will be masked.
            CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
        }

        // draw effect image
        CGContextSaveGState(outputContext);
        if (maskImage)
            CGContextClipToMask(outputContext, outputImageRectInPoints, maskImage.CGImage);
        CGContextDrawImage(outputContext, outputImageRectInPoints, effectCGImage);
        CGContextRestoreGState(outputContext);

        // Cleanup
        CGImageRelease(effectCGImage);
        free(outputBuffer->data);
    }
    else
    {
        // draw base image
        CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
    }

    // Add in color tint.
    if (tintColor)
    {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, outputImageRectInPoints);
        CGContextRestoreGState(outputContext);
    }

    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return outputImage;
}

//| ----------------------------------------------------------------------------
//  Helper function to handle deferred cleanup of a buffer.
//
void LKImageCleanupBuffer(void *userData, void *buf_data)
{
    free(buf_data);
}

@end
