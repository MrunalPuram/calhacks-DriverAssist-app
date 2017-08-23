//
//  SDLVideoEncoder.m
//  SmartDeviceLink-iOS
//
//  Created by Muller, Alexander (A.) on 12/5/16.
//  Copyright © 2016 smartdevicelink. All rights reserved.
//

#import "SDLVideoEncoder.h"

#import "SDLH264ByteStreamPacketizer.h"
#import "SDLLogMacros.h"


NS_ASSUME_NONNULL_BEGIN

NSString *const SDLErrorDomainVideoEncoder = @"com.sdl.videoEncoder";
static NSDictionary<NSString *, id>* _defaultVideoEncoderSettings;


@interface SDLVideoEncoder ()

@property (assign, nonatomic, nullable) VTCompressionSessionRef compressionSession;
@property (assign, nonatomic, nullable) CFDictionaryRef sdl_pixelBufferOptions;
@property (assign, nonatomic) NSUInteger currentFrameNumber;
@property (nonatomic) id<SDLH264Packetizer> packetizer;
@property (assign, nonatomic) double timestampOffset;

@end


@implementation SDLVideoEncoder

+ (void)initialize {
    if (self != [SDLVideoEncoder class]) {
        return;
    }
    
    _defaultVideoEncoderSettings = @{
                                     (__bridge NSString *)kVTCompressionPropertyKey_ProfileLevel: (__bridge NSString *)kVTProfileLevel_H264_Baseline_AutoLevel,
                                     (__bridge NSString *)kVTCompressionPropertyKey_RealTime: @YES
                                     };
}

- (instancetype)initWithDimensions:(CGSize)dimensions properties:(NSDictionary<NSString *,id> *)properties delegate:(id<SDLVideoEncoderDelegate> __nullable)delegate error:(NSError * _Nullable __autoreleasing *)error {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _compressionSession = NULL;
    _currentFrameNumber = 0;
    _videoEncoderSettings = properties;
    
    _delegate = delegate;
    
    OSStatus status;
    
    // Create a compression session
    status = VTCompressionSessionCreate(NULL, dimensions.width, dimensions.height, kCMVideoCodecType_H264, NULL, self.sdl_pixelBufferOptions, NULL, &sdl_videoEncoderOutputCallback, (__bridge void *)self, &_compressionSession);
    
    if (status != noErr) {
        if (!*error) {
            *error = [NSError errorWithDomain:SDLErrorDomainVideoEncoder code:SDLVideoEncoderErrorConfigurationCompressionSessionCreationFailure userInfo:@{ @"OSStatus": @(status) }];
            SDLLogE(@"Error attempting to create video compression session: %@", *error);
        }
        
        return nil;
    }
    
    CFRelease(_sdl_pixelBufferOptions);
    _sdl_pixelBufferOptions = nil;
    
    // Validate that the video encoder properties are valid.
    CFDictionaryRef supportedProperties;
    status = VTSessionCopySupportedPropertyDictionary(self.compressionSession, &supportedProperties);
    if (status != noErr) {
        if (!*error) {
            *error = [NSError errorWithDomain:SDLErrorDomainVideoEncoder code:SDLVideoEncoderErrorConfigurationCompressionSessionSetPropertyFailure userInfo:@{ @"OSStatus": @(status) }];
        }
        
        return nil;
    }
    
    NSArray* videoEncoderKeys = self.videoEncoderSettings.allKeys;
    
    for (NSString *key in videoEncoderKeys) {
        if (CFDictionaryContainsKey(supportedProperties, (__bridge CFStringRef)key) == false) {
            if (!*error) {
                NSString *description = [NSString stringWithFormat:@"\"%@\" is not a supported key.", key];
                *error = [NSError errorWithDomain:SDLErrorDomainVideoEncoder code:SDLVideoEncoderErrorConfigurationCompressionSessionSetPropertyFailure userInfo:@{NSLocalizedDescriptionKey: description}];
            }
            CFRelease(supportedProperties);
            return nil;
        }
    }
    CFRelease(supportedProperties);
    
    // Populate the video encoder settings from provided dictionary.
    for (NSString *key in videoEncoderKeys) {
        id value = self.videoEncoderSettings[key];
        
        status = VTSessionSetProperty(self.compressionSession, (__bridge CFStringRef)key, (__bridge CFTypeRef)value);
        if (status != noErr) {
            if (!*error) {
                *error = [NSError errorWithDomain:SDLErrorDomainVideoEncoder code:SDLVideoEncoderErrorConfigurationCompressionSessionSetPropertyFailure userInfo:@{ @"OSStatus": @(status) }];
            }
            
            return nil;
        }
    }

    _packetizer = [[SDLH264ByteStreamPacketizer alloc] init];
    _timestampOffset = 0.0;

    return self;
}

- (void)stop {
    if (self.compressionSession != NULL) {
        VTCompressionSessionInvalidate(self.compressionSession);
        CFRelease(self.compressionSession);
        self.compressionSession = NULL;
    }
}

- (BOOL)encodeFrame:(CVImageBufferRef)imageBuffer {
    return [self encodeFrame:imageBuffer pts:kCMTimeInvalid];
}

- (BOOL)encodeFrame:(CVImageBufferRef)imageBuffer pts:(CMTime)pts {
    if (!CMTIME_IS_VALID(pts)) {
        pts = CMTimeMake(self.currentFrameNumber, 30);
    }
    self.currentFrameNumber++;

    OSStatus status = VTCompressionSessionEncodeFrame(_compressionSession, imageBuffer, pts, kCMTimeInvalid, NULL, (__bridge void *)self, NULL);

    return (status == noErr);
}

- (CVPixelBufferRef CV_NULLABLE)newPixelBuffer {
    if (self.pixelBufferPool == NULL) {
        return NULL;
    }
    
    CVPixelBufferRef pixelBuffer;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault,
                                       self.pixelBufferPool,
                                       &pixelBuffer);

    return pixelBuffer;
}

#pragma mark - Public
#pragma mark Getters
+ (NSDictionary<NSString *, id> *)defaultVideoEncoderSettings {
    return _defaultVideoEncoderSettings;
}

- (CVPixelBufferPoolRef CV_NULLABLE)pixelBufferPool {
    return VTCompressionSessionGetPixelBufferPool(self.compressionSession);
}

#pragma mark - Private
#pragma mark Callback
void sdl_videoEncoderOutputCallback(void * CM_NULLABLE outputCallbackRefCon, void * CM_NULLABLE sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CM_NULLABLE CMSampleBufferRef sampleBuffer) {
    // If there was an error in the encoding, drop the frame
    if (status != noErr) {
        SDLLogW(@"Error encoding video frame: %d", (int)status);
        return;
    }
    
    if (outputCallbackRefCon == NULL || sourceFrameRefCon == NULL || sampleBuffer == NULL) {
        return;
    }
    
    SDLVideoEncoder *encoder = (__bridge SDLVideoEncoder *)sourceFrameRefCon;
    NSArray *nalUnits = [encoder.class sdl_extractNalUnitsFromSampleBuffer:sampleBuffer];

    const CMTime ptsInCMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    double pts = 0.0;
    if (CMTIME_IS_VALID(ptsInCMTime)) {
        pts = CMTimeGetSeconds(ptsInCMTime);
    }
    if (encoder.timestampOffset == 0.0) {
        // remember this first PTS as the offset
        encoder.timestampOffset = pts;
    }

    NSArray *packets = [encoder.packetizer createPackets:nalUnits pts:(pts - encoder.timestampOffset)];
    
    if ([encoder.delegate respondsToSelector:@selector(videoEncoder:hasEncodedFrame:)]) {
        for (NSData *packet in packets) {
            [encoder.delegate videoEncoder:encoder hasEncodedFrame:packet];
        }
    }
}

#pragma mark Getters
- (CFDictionaryRef _Nullable)sdl_pixelBufferOptions {
    if (_sdl_pixelBufferOptions == nil) {
        CFMutableDictionaryRef pixelBufferOptions = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        OSType pixelFormatType = kCVPixelFormatType_32BGRA;
        
        CFNumberRef pixelFormatNumberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &pixelFormatType);
        
        CFDictionarySetValue(pixelBufferOptions, kCVPixelBufferCGImageCompatibilityKey, kCFBooleanFalse);
        CFDictionarySetValue(pixelBufferOptions, kCVPixelBufferCGBitmapContextCompatibilityKey, kCFBooleanFalse);
        CFDictionarySetValue(pixelBufferOptions, kCVPixelBufferPixelFormatTypeKey, pixelFormatNumberRef);
        
        CFRelease(pixelFormatNumberRef);
        
        _sdl_pixelBufferOptions = pixelBufferOptions;
    }

    return _sdl_pixelBufferOptions;
}

#pragma mark Helpers
+ (NSArray *)sdl_extractNalUnitsFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // Creating an elementaryStream: http://stackoverflow.com/questions/28396622/extracting-h264-from-cmblockbuffer
    NSMutableArray *nalUnits = [NSMutableArray array];
    BOOL isIFrame = NO;
    CFArrayRef attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, 0);
    
    if (CFArrayGetCount(attachmentsArray)) {
        CFBooleanRef notSync;
        CFDictionaryRef dict = CFArrayGetValueAtIndex(attachmentsArray, 0);
        BOOL keyExists = CFDictionaryGetValueIfPresent(dict, kCMSampleAttachmentKey_NotSync, (const void **)&notSync);
        
        // Find out if the sample buffer contains an I-Frame (sync frame). If so we will write the SPS and PPS NAL units to the elementary stream.
        isIFrame = !keyExists || !CFBooleanGetValue(notSync);
    }
    
    // Write the SPS and PPS NAL units to the elementary stream before every I-Frame
    if (isIFrame) {
        CMFormatDescriptionRef description = CMSampleBufferGetFormatDescription(sampleBuffer);
        
        // Find out how many parameter sets there are
        size_t numberOfParameterSets;
        CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description,
                                                           0,
                                                           NULL,
                                                           NULL,
                                                           &numberOfParameterSets,
                                                           NULL);
        
        // Write each parameter set to the elementary stream
        for (int i = 0; i < numberOfParameterSets; i++) {
            const uint8_t *parameterSetPointer;
            size_t parameterSetLength;
            CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description,
                                                               i,
                                                               &parameterSetPointer,
                                                               &parameterSetLength,
                                                               NULL,
                                                               NULL);
            
            // Output the parameter set
            NSData *nalUnit = [NSData dataWithBytesNoCopy:(uint8_t *)parameterSetPointer length:parameterSetLength freeWhenDone:NO];
            [nalUnits addObject:nalUnit];
        }
    }
    
    // Get a pointer to the raw AVCC NAL unit data in the sample buffer
    size_t blockBufferLength = 0;
    char *bufferDataPointer = NULL;
    CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
    
    CMBlockBufferGetDataPointer(blockBufferRef, 0, NULL, &blockBufferLength, &bufferDataPointer);
    
    // Loop through all the NAL units in the block buffer and write them to the elementary stream with start codes instead of AVCC length headers
    size_t bufferOffset = 0;
    static const int AVCCHeaderLength = 4;
    while (bufferOffset < blockBufferLength - AVCCHeaderLength) {
        // Read the NAL unit length
        uint32_t NALUnitLength = 0;
        memcpy(&NALUnitLength, bufferDataPointer + bufferOffset, AVCCHeaderLength);
        
        // Convert the length value from Big-endian to Little-endian
        NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
        
        // Write the NAL unit without the AVCC length header to the elementary stream
        NSData *nalUnit = [NSData dataWithBytesNoCopy:bufferDataPointer + bufferOffset + AVCCHeaderLength length:NALUnitLength freeWhenDone:NO];
        [nalUnits addObject:nalUnit];
        
        // Move to the next NAL unit in the block buffer
        bufferOffset += AVCCHeaderLength + NALUnitLength;
    }
    
    
    return nalUnits;
}

@end

NS_ASSUME_NONNULL_END
