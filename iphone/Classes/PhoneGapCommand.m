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
    NSLog(@"File: %@", filePath);
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
