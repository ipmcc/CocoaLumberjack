#import "DDASLLogger.h"

#import <libkern/OSAtomic.h>

/**
 * Welcome to Cocoa Lumberjack!
 * 
 * The project page has a wealth of documentation if you have any questions.
 * https://github.com/robbiehanson/CocoaLumberjack
 * 
 * If you're new to the project you may wish to read the "Getting Started" wiki.
 * https://github.com/robbiehanson/CocoaLumberjack/wiki/GettingStarted
**/

//#if ! __has_feature(objc_arc)
//#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
//#endif


@implementation DDASLLogger

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return nil;
}

+ (id)allocWithZonePrivate:(struct _NSZone *)zone
{
    return [super allocWithZone: zone];
}

+ (DDASLLogger *)sharedInstance
{
    static DDASLLogger *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DDASLLogger allocWithZonePrivate: nil] init];
    });
	return sharedInstance;
}

- (id)init
{
	if ((self = [super init]))
	{
		// A default asl client is provided for the main thread,
		// but background threads need to create their own client.
		
		client = asl_open(NULL, "com.apple.console", 0);
	}
	return self;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
	NSString *logMsg = logMessage->logMsg;
	
	if (formatter)
	{
		logMsg = [formatter formatLogMessage:logMessage];
	}
	
	if (logMsg)
	{
		const char *msg = [logMsg UTF8String];
		
		int aslLogLevel;
		switch (logMessage->logFlag)
		{
			// Note: By default ASL will filter anything above level 5 (Notice).
			// So our mappings shouldn't go above that level.
			
			case LOG_FLAG_ERROR : aslLogLevel = ASL_LEVEL_CRIT;    break;
			case LOG_FLAG_WARN  : aslLogLevel = ASL_LEVEL_ERR;     break;
			case LOG_FLAG_INFO  : aslLogLevel = ASL_LEVEL_WARNING; break;
			default             : aslLogLevel = ASL_LEVEL_NOTICE;  break;
		}
		
		asl_log(client, NULL, aslLogLevel, "%s", msg);
	}
}

- (NSString *)loggerName
{
	return @"cocoa.lumberjack.aslLogger";
}

@end
