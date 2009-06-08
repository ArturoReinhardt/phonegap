//
//  PhoneGapCommand.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "PhoneGapCommand.h"
#import "PhoneGapDelegate.h"

@implementation PhoneGapCommand
@synthesize webView;
@synthesize settings;

static PhoneGapCommand *sharedSingletonInstance = nil;

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

/**
 * Returns the frame size for the new element at the desired position,
 * and resizes the other surrounding frames
 */
- (void)setFrameFor:(UIView*)control withSettings:(NSDictionary*)controlSettings
{
    CGFloat height   = 38.0f;
    BOOL    atBottom = YES;

    if (controlSettings) {
        height   = [[controlSettings objectForKey:@"height"] floatValue];
        atBottom = [[controlSettings objectForKey:@"position"] isEqualToString:@"bottom"];
    }

    CGRect webViewBounds = webView.bounds;
    CGRect controlBounds;
    if (atBottom) {
        controlBounds = CGRectMake(
                                  webViewBounds.origin.x,
                                  webViewBounds.origin.y + webViewBounds.size.height - height,
                                  webViewBounds.size.width,
                                  height
                                  );
        webViewBounds = CGRectMake(
                                   webViewBounds.origin.x,
                                   webViewBounds.origin.y,
                                   webViewBounds.size.width,
                                   webViewBounds.size.height - height
                                   );
    } else {
        controlBounds = CGRectMake(
                                  webViewBounds.origin.x,
                                  webViewBounds.origin.y,
                                  webViewBounds.size.width,
                                  height
                                  );
        webViewBounds = CGRectMake(
                                   webViewBounds.origin.x,
                                   webViewBounds.origin.y + height,
                                   webViewBounds.size.width,
                                   webViewBounds.size.height - height
                                   );
    }
    [control setFrame:controlBounds];
    [webView setFrame:webViewBounds];
}

/**
 Utility function used to translate a string into an internal constant representing a system item icon type.
 These are typically used by tab bars or navigation bars to render a native icon type, such as "Search", "History", etc.
 */
- (UIBarButtonSystemItem) getBarButtonSystemItemFor:(NSString*)imageName
{
    if ([imageName isEqualToString:@"tabButton:More"])           return UITabBarSystemItemMore;
    if ([imageName isEqualToString:@"tabButton:Favorites"])      return UITabBarSystemItemFavorites;
    if ([imageName isEqualToString:@"tabButton:Featured"])       return UITabBarSystemItemFeatured;
    if ([imageName isEqualToString:@"tabButton:TopRated"])       return UITabBarSystemItemTopRated;
    if ([imageName isEqualToString:@"tabButton:Recents"])        return UITabBarSystemItemRecents;
    if ([imageName isEqualToString:@"tabButton:Contacts"])       return UITabBarSystemItemContacts;
    if ([imageName isEqualToString:@"tabButton:History"])        return UITabBarSystemItemHistory;
    if ([imageName isEqualToString:@"tabButton:Bookmarks"])      return UITabBarSystemItemBookmarks;
    if ([imageName isEqualToString:@"tabButton:Search"])         return UITabBarSystemItemSearch;
    if ([imageName isEqualToString:@"tabButton:Downloads"])      return UITabBarSystemItemDownloads;
    if ([imageName isEqualToString:@"tabButton:MostRecent"])     return UITabBarSystemItemMostRecent;
    if ([imageName isEqualToString:@"tabButton:MostViewed"])     return UITabBarSystemItemMostViewed;
    if ([imageName isEqualToString:@"toolButton:Done"])          return UIBarButtonSystemItemDone;
    if ([imageName isEqualToString:@"toolButton:Cancel"])        return UIBarButtonSystemItemCancel;
    if ([imageName isEqualToString:@"toolButton:Edit"])          return UIBarButtonSystemItemEdit;
    if ([imageName isEqualToString:@"toolButton:Save"])          return UIBarButtonSystemItemSave;
    if ([imageName isEqualToString:@"toolButton:Add"])           return UIBarButtonSystemItemAdd;
    // XXX Not applicable, since these are used when composing custom toolbars by hand; this is
    //     too difficult for me to worry about at the moment.
    //if ([imageName isEqualToString:@"toolButton:FlexibleSpace"]) return UIBarButtonSystemItemFlexibleSpace;
    //if ([imageName isEqualToString:@"toolButton:FixedSpace"])    return UIBarButtonSystemItemFixedSpace;
    if ([imageName isEqualToString:@"toolButton:Compose"])       return UIBarButtonSystemItemCompose;
    if ([imageName isEqualToString:@"toolButton:Reply"])         return UIBarButtonSystemItemReply;
    if ([imageName isEqualToString:@"toolButton:Action"])        return UIBarButtonSystemItemAction;
    if ([imageName isEqualToString:@"toolButton:Organize"])      return UIBarButtonSystemItemOrganize;
    if ([imageName isEqualToString:@"toolButton:Bookmarks"])     return UIBarButtonSystemItemBookmarks;
    if ([imageName isEqualToString:@"toolButton:Search"])        return UIBarButtonSystemItemSearch;
    if ([imageName isEqualToString:@"toolButton:Refresh"])       return UIBarButtonSystemItemRefresh;
    if ([imageName isEqualToString:@"toolButton:Stop"])          return UIBarButtonSystemItemStop;
    if ([imageName isEqualToString:@"toolButton:Camera"])        return UIBarButtonSystemItemCamera;
    if ([imageName isEqualToString:@"toolButton:Trash"])         return UIBarButtonSystemItemTrash;
    if ([imageName isEqualToString:@"toolButton:Play"])          return UIBarButtonSystemItemPlay;
    if ([imageName isEqualToString:@"toolButton:Pause"])         return UIBarButtonSystemItemPause;
    if ([imageName isEqualToString:@"toolButton:Rewind"])        return UIBarButtonSystemItemRewind;
    if ([imageName isEqualToString:@"toolButton:FastForward"])   return UIBarButtonSystemItemFastForward;
    return -1;
}

- (void)dealloc
{
    if (self.settings)
        [self.settings release];
    [super dealloc];
}

-(PhoneGapDelegate*) appDelegate
{
	return (PhoneGapDelegate*)[[UIApplication sharedApplication] delegate];
}

-(UIViewController*) appViewController
{
	return (UIViewController*)[self appDelegate].viewController;
}

@end
