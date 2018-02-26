//
//  LKImageDefine.m
//  LKImageViewExample
//
//  Created by lingtonke on 2016/12/6.
//  Copyright ©2014 - 2018 Tencent.All Rights Reserved. This software is licensed under the terms in the LICENSE.TXT file that accompanies this software.
//

#import "LKImageError.h"

NSString *const LKImageErrorDomain = @"LKImageErrorDomain";

@implementation LKImageError

+ (NSString *)descriptionForCode:(NSInteger)code
{
    NSString *desc = @"Unknow";
    switch (code)
    {
        case 0:
            desc = @"No error";
            break;
        case LKImageErrorCodeUnknow:
            desc = @"Unknow";
            break;
        case LKImageErrorCodeCancel:
            desc = @"Cancel: URL of LKImageView has been changed, retain count of request is 0,call cancel automaticly";
            break;
        case LKImageErrorCodeInvalidRequest:
            desc = @"InvalidRequest";
            break;
        case LKImageErrorCodeInvalidLoader:
            desc = @"InvalidLoader: A requst has been send to a datasourch which can not handle.Please check function 'isValidRequest' in Loader";
            break;
        case LKImageErrorCodeLoaderNotFound:
            desc = @"LoaderNotFound: Can not found loader check function 'isValidRequest' in loader";
            break;
        case LKImageErrorCodeFileNotFound:
            desc = @"FileNotFound";
            break;
        case LKImageErrorCodeInvalidFile:
            desc = @"InvalidFile.Can not generate image from file";
            break;
        case LKImageErrorCodeInvalidDecoder:
            desc = @"InvalidDecoder: ";
            break;
        case LKImageErrorCodeDecoderNotFound:
            desc = @"DecoderNotFound: Can not find decoder";
            break;
        case LKImageErrorCodeDecodeFailed:
            desc = @"DecodeFailed: Decoder can not decode file";
            break;
        case LKImageErrorCodeDataEmpty:
            desc = @"DataEmpty: Loading from loader is success but data is empty.Please check loader.";
            break;
        case LKImageErrorCodeProcessorFailed:
            desc = @"ProcessorFailed: The image process operation failed.";
            break;
        case LKImageErrorCodeLoaderReturnNoImage:
            desc = @"LoaderReturnNoImage: The loader is wrong and return nil and no error with progress = 1.";
            break;
        case LKImageErrorCodeRequestIsDecoding:
            desc = @"RequestIsDecoding: The request is decoding,so this data will not be decoded in case of too many decoding task.";
            break;
    }
    return desc;
}

+ (instancetype)errorWithCode:(NSInteger)code
{
    return [[LKImageError alloc] initWithCode:code];
}

- (instancetype)initWithCode:(NSInteger)code
{
    if (self = [super initWithDomain:LKImageErrorDomain
                                code:code
                            userInfo:@{NSLocalizedDescriptionKey:[LKImageError descriptionForCode:code]}])
    {
        
    }
    return self;
}

@end
