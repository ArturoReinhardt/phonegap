//
//  PhoneGapCommand.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "PhoneGapCommand.h"

@implementation PhoneGapCommand
@synthesize webView;
@synthesize settings;

-(PhoneGapCommand*) initWithWebView:(UIWebView*)theWebView settings:(NSDictionary*)classSettings
{
    self = [self initWithWebView:theWebView];
    if (self)
        [self setSettings:classSettings];
    return self;
}

-(PhoneGapCommand*) initWithWebView:(UIWebView*)theWebView
{
    self = [super init];
    if (self)
        [self setWebView:theWebView];
    return self;
}

-(void) setWebView:(UIWebView*) theWebView
{
    webView = theWebView;
}

-(void) setSettings:(NSDictionary*) classSettings
{
    settings = classSettings;
}

/**
 Fire a callback to the JavaScript objects, using the given callback ID supplied from the JavaScript object at creation time.
 @param callbackId the unique identifier supplied by the JavaScript code to use as a reference for this callback
 @param arguments array of arguments to pass into the callback function.
 @returns dictionary representing the return data of the callback 
 */
-(id) fireCallback:(NSInteger)callbackId withArguments:(NSArray*)arguments
{
    if (!arguments)
        arguments = [[[NSArray alloc] init] autorelease];

    NSString *jsCallback = [NSString stringWithFormat:@"PhoneGap.invokeCallback(%d, %@);", callbackId, [arguments JSONFragment]];
    NSString *retValue = [webView stringByEvaluatingJavaScriptFromString:jsCallback];

    if ([retValue length] > 0)
        return [retValue JSONValue];
    else
        return [[[NSDictionary alloc] init] autorelease];
}

/**
 Attempts to find the named file in the application bundle, and returns a file object if it does so.
 \bNote: This currently doesn't support the use of filenames with more than one dot (".") in them.
 @param filename the string representing the file within the application bundle
 */
-(NSURL*) getLocalFileFor:(NSString*)filename
{
    NSBundle       *mainBundle     = [NSBundle mainBundle];
    NSMutableArray *directoryParts = [NSMutableArray arrayWithArray:[filename componentsSeparatedByString:@"/"]];
    NSString       *fileComponent  = [directoryParts lastObject];
    [directoryParts removeLastObject];
    NSString *directoryStr = [directoryParts componentsJoinedByString:@"/"];
    
    NSMutableArray *filenameParts  = [NSMutableArray arrayWithArray:[fileComponent componentsSeparatedByString:@"."]];
    if ([directoryParts count] <= 1)
        return nil;
    
    NSString *filePath = [mainBundle pathForResource:(NSString*)[filenameParts objectAtIndex:0]
                                              ofType:(NSString*)[filenameParts objectAtIndex:1]
                                         inDirectory:directoryStr];
    if (filePath == nil) {
        NSLog(@"Can't find filename %@ in the app bundle", filename);
        return nil;
    }
    return [NSURL fileURLWithPath:filePath];
}

- (void)dealloc
{
    if (self.settings)
        [self.settings release];
    [super dealloc];
}

@end
