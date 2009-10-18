//
//  NavigationBar.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "NavigationBar.h"
#import "NSString+HexColor.h"

@implementation NavigationBar
@synthesize webView;

-(PhoneGapCommand*) initWithWebView:(UIWebView*)theWebView
{
    self = (NavigationBar*)[super initWithWebView:theWebView];
    if (self) {
        navBarEvents = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

#pragma mark -
#pragma mark NavigationBar methods

/**
 Create a native navigation bar (or toolbar) in the application.
 @brief create a navigation bar / toolbar
 */
- (void)createNavBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (navBar) {
        NSLog(@"Navigation bar already exists; not creating another.");
        return;
    }
    
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 38.0f)];
    navBar.delegate = self;
    navBar.multipleTouchEnabled   = NO;
    navBar.autoresizesSubviews    = YES;
    navBar.userInteractionEnabled = YES;
    navBar.hidden = NO;
    [self setFrameFor:navBar withSettings:settings];
    [self.webView.superview addSubview:navBar];
    [self.webView.superview bringSubviewToFront:navBar];

    /**
     * Properties:
     *   opaque: If not specified, then the default is used; otherwise, it will be opaque or
     *           translucent if supplied, depending on the checked value.
     */
    if (settings) {
        /**
         * The opaque setting controls whether or not the background of the navbar will
         * be fully opaque, or translucent.
         */
        if ([settings objectForKey:@"opaque"]) {
            if ([[settings objectForKey:@"opaque"] boolValue])
                navBar.barStyle = UIBarStyleBlackOpaque;
            else
                navBar.barStyle = UIBarStyleBlackTranslucent;
        }

        /**
         * The tintColor property influences what the color of the navbar background will be,
         * which is also dependant on the opaque property.  Supply a color value in standard
         * RGB or RGBA hex.
         */
        if ([settings objectForKey:@"tintColor"]) {
            navBar.tintColor = [(NSString*)[settings objectForKey:@"tintColor"] colorFromHex];
        }
    }
}

/**
 Set a new navbar navigation level, with titlebar and buttons.  Automatically provides a "Back" button to
 go back to the previous navigation level.
 @brief set a new navigation level / title
 */
- (void)setNavBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!navBar)
        [self createNavBar:nil withDict:nil];

    BOOL isAnimated = YES;
    if (options != nil && [options objectForKey:@"animated"])
        isAnimated = [[options objectForKey:@"animated"] boolValue];
    
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithDictionary:options];
    [navBarEvents insertObject:events atIndex:[navBarEvents count]];

    UINavigationItem* item = [[[UINavigationItem alloc] initWithTitle:[arguments objectAtIndex:0]] autorelease];
    if ([arguments count] > 1) {
        NSString* rightTitle = [arguments objectAtIndex:1];
        if ([rightTitle length] > 0) {
            UIBarButtonSystemItem systemItem = [PhoneGapCommand getBarButtonSystemItemFor:rightTitle];
            NSURL *filePath = [self getLocalFileFor:rightTitle];
            UIBarButtonItemStyle itemStyle = [self getBarButtonStyleFor:[options objectForKey:@"rightStyle"]];
            UIBarButtonItem* rightButton;

            /* Create a button using a pre-defined system item */
            if (systemItem != -1) {
                rightButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem
                                                                             target:self
                                                                             action:@selector(navBarRightButtonClicked)
                               ] autorelease];
            }
            
            /* Create a button using an image in the app bundle */
            else if (filePath != nil) {
               /*UIImage image = [[[UIImage alloc] initWithContentsOfFile:filePath] autorelease];
                rightButton = [[[UIBarButtonItem alloc] initWithImage:image
                                                               target:self
                                                               action:@selector(navBarRightButtonClicked)
                                ] autorelease];*/
            }
            
            /* Create a plain-text button */
            else {
                rightButton = [[[UIBarButtonItem alloc] initWithTitle:rightTitle
                                                                style:itemStyle
                                                               target:self
                                                               action:@selector(navBarRightButtonClicked)
                                ] autorelease];
            }

            rightButton.tag = [(NSString*)[options objectForKey:@"onButton"] integerValue];
            [item setRightBarButtonItem:rightButton];
        }
    }
    [navBar pushNavigationItem:item animated:isAnimated];
}

- (void)navigationBar:(UINavigationBar*)theNavBar didPushItem:(UINavigationItem*)item
{
    NSInteger callbackId = [[[navBarEvents lastObject] objectForKey:@"onShow"] integerValue];
    if (callbackId)
        [self fireCallback:callbackId withArguments:nil];
}

- (void)navigationBar:(UINavigationBar*)theNavBar didPopItem:(UINavigationItem*)item
{
    NSInteger callbackId = [[[navBarEvents lastObject] objectForKey:@"onHide"] integerValue];
    [navBarEvents removeLastObject];
    if (callbackId)
        [self fireCallback:callbackId withArguments:nil];
}

- (BOOL)navigationBar:(UINavigationBar*)theNavBar shouldPushItem:(UINavigationItem*)item
{
    NSInteger callbackId = [[[navBarEvents lastObject] objectForKey:@"onShowStart"] integerValue];
    if (!callbackId)
        return YES;

    NSDictionary *result = [self fireCallback:callbackId withArguments:nil];
    if ([result count] > 0 && ![[result objectForKey:@"allow"] boolValue])
        return NO;
    else
        return YES;
}

- (BOOL)navigationBar:(UINavigationBar*)theNavBar shouldPopItem:(UINavigationItem*)item
{
    NSInteger callbackId = [[[navBarEvents lastObject] objectForKey:@"onHideStart"] integerValue];
    if (!callbackId)
        return YES;
    
    NSDictionary *result = [self fireCallback:callbackId withArguments:nil];
    if ([result count] > 0 && ![[result objectForKey:@"allow"] boolValue])
        return NO;
    else
        return YES;
}

/**
 Handler that is dispatched when a right navbar button is clicked.  This will call the appropriate callback
 in the JavaScript environment if one has been established.
 */
- (void)navBarRightButtonClicked
{
    UINavigationItem *topItem = navBar.topItem;
    NSInteger callbackId = topItem.rightBarButtonItem.tag;
    if (!callbackId || callbackId < 1)
        return;
    [self fireCallback:callbackId withArguments:nil]; 
}

#pragma mark -
#pragma mark Utility Functions

/**
 Utility function used to translate a string into an internal constant representing a button bar type.
 Valid values are:
 - \c bordered (default)
 - \c plain
 - \c done
 */
- (UIBarButtonItemStyle)getBarButtonStyleFor:(NSString*)string
{
    if (string) {
        if ([string isEqualToString:@"bordered"])
            return UIBarButtonItemStyleBordered;
        else if ([string isEqualToString:@"plain"])
            return UIBarButtonItemStylePlain;
        else if ([string isEqualToString:@"done"])
            return UIBarButtonItemStyleDone;
    }
    return UIBarButtonItemStyleBordered;
}

- (void)dealloc
{
    [navBarEvents release];
    [super dealloc];
}

@end
