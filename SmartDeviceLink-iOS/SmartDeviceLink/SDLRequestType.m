//  SDLRequestType.m
//


#import "SDLRequestType.h"

SDLRequestType* SDLRequestType_HTTP = nil;
SDLRequestType* SDLRequestType_FILE_RESUME = nil;
SDLRequestType* SDLRequestType_AUTH_REQUEST = nil;
SDLRequestType* SDLRequestType_AUTH_CHALLENGE = nil;
SDLRequestType* SDLRequestType_AUTH_ACK = nil;
SDLRequestType* SDLRequestType_PROPRIETARY = nil;
SDLRequestType* SDLRequestType_QUERY_APPS = nil;
SDLRequestType* SDLRequestType_LAUNCH_APP = nil;

NSMutableArray* SDLRequestType_values = nil;

@implementation SDLRequestType

+(SDLRequestType*) valueOf:(NSString*) value {
    for (SDLRequestType* item in SDLRequestType.values) {
        if ([item.value isEqualToString:value]) {
            return item;
        }
    }
    return nil;
}

+(NSMutableArray*) values {
    if (SDLRequestType_values == nil) {
        SDLRequestType_values = [[NSMutableArray alloc] initWithObjects:
                                 SDLRequestType.HTTP,
                                 SDLRequestType.FILE_RESUME,
                                 SDLRequestType.AUTH_REQUEST,
                                 SDLRequestType.AUTH_CHALLENGE,
                                 SDLRequestType.AUTH_ACK,
                                 SDLRequestType.PROPRIETARY,
                                 SDLRequestType_QUERY_APPS,
                                 SDLRequestType_LAUNCH_APP,
                                 nil];
    }
    return SDLRequestType_values;
}

+(SDLRequestType*) HTTP {
    if (SDLRequestType_HTTP == nil) {
        SDLRequestType_HTTP = [[SDLRequestType alloc] initWithValue:@"HTTP"];
    }
    return SDLRequestType_HTTP;
}

+(SDLRequestType*) FILE_RESUME {
    if (SDLRequestType_FILE_RESUME == nil) {
        SDLRequestType_FILE_RESUME = [[SDLRequestType alloc] initWithValue:@"FILE_RESUME"];
    }
    return SDLRequestType_FILE_RESUME;
}

+(SDLRequestType*) AUTH_REQUEST {
    if (SDLRequestType_AUTH_REQUEST == nil) {
        SDLRequestType_AUTH_REQUEST = [[SDLRequestType alloc] initWithValue:@"AUTH_REQUEST"];
    }
    return SDLRequestType_AUTH_REQUEST;
}

+(SDLRequestType*) AUTH_CHALLENGE {
    if (SDLRequestType_AUTH_CHALLENGE == nil) {
        SDLRequestType_AUTH_CHALLENGE = [[SDLRequestType alloc] initWithValue:@"AUTH_CHALLENGE"];
    }
    return SDLRequestType_AUTH_CHALLENGE;
}

+(SDLRequestType*) AUTH_ACK {
    if (SDLRequestType_AUTH_ACK == nil) {
        SDLRequestType_AUTH_ACK = [[SDLRequestType alloc] initWithValue:@"AUTH_ACK"];
    }
    return SDLRequestType_AUTH_ACK;
}

+(SDLRequestType*) PROPRIETARY {
    if (SDLRequestType_PROPRIETARY == nil) {
        SDLRequestType_PROPRIETARY = [[SDLRequestType alloc] initWithValue:@"PROPRIETARY"];
    }
    return SDLRequestType_PROPRIETARY;
}

+(SDLRequestType*) QUERY_APPS {
    if (SDLRequestType_QUERY_APPS == nil) {
        SDLRequestType_QUERY_APPS = [[SDLRequestType alloc] initWithValue:@"QUERY_APPS"];
    }
    
    return SDLRequestType_QUERY_APPS;
}

+(SDLRequestType*) LAUNCH_APP {
    if (SDLRequestType_LAUNCH_APP == nil) {
        SDLRequestType_LAUNCH_APP = [[SDLRequestType alloc] initWithValue:@"LAUNCH_APP"];
    }
    
    return SDLRequestType_LAUNCH_APP;
}

@end