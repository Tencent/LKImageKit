//
//  Tencent is pleased to support the open source community by making LKImageKit available.
//  Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
//  Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
//  https://opensource.org/licenses/BSD-3-Clause
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
//
//  Created by lingtonke

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
