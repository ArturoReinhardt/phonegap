//
//  UIControls.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "UIControls.h"
#import "NSString+HexColor.h"

@implementation UIControls
@synthesize webView;

-(PhoneGapCommand*) initWithWebView:(UIWebView*)theWebView
{
    self = (UIControls*)[super initWithWebView:theWebView];
    if (self) {
        tabBarItems  = [[NSMutableDictionary alloc] initWithCapacity:5];
        navBarEvents = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
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

#pragma mark -
#pragma mark TabBar methods

/**
 * Create a native tab bar at either the top or the bottom of the display.
 * @brief creates a tab bar
 * @param arguments unused
 * @param options unused
 * - \c height integer indicating the height of the tab bar (default: \c 49)
 * - \c position specifies whether the tab bar will be placed at the \c top or \c bottom of the screen (default: \c bottom)
 */
- (void)createTabBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (tabBar) {
        NSLog(@"Tab bar already exists; not creating another.");
        return;
    }

    tabBar = [UITabBar new];
    [tabBar sizeToFit];
    tabBar.delegate = self;
    tabBar.multipleTouchEnabled   = NO;
    tabBar.autoresizesSubviews    = YES;
    tabBar.hidden                 = NO;
    tabBar.userInteractionEnabled = YES;

    if ([options objectForKey:@"height"])
        [settings setValue:[options objectForKey:@"height"] forKey:@"height"];
    if ([options objectForKey:@"position"])
        [settings setValue:[options objectForKey:@"position"] forKey:@"position"];
    
    [self setFrameFor:tabBar withSettings:[settings objectForKey:@"TabBar"]];

	[self.webView.superview addSubview:tabBar];    
}

/**
 * Show the tab bar after its been created.
 * @brief show the tab bar
 * @param arguments unused
 * @param options used to indicate options for where and how the tab bar should be placed
 * - \c height integer indicating the height of the tab bar (default: \c 49)
 * - \c position specifies whether the tab bar will be placed at the \c top or \c bottom of the screen (default: \c bottom)
 */
- (void)showTabBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!tabBar) return;

    tabBar.hidden = NO;
}

/**
 * Hide the tab bar
 * @brief hide the tab bar
 * @param arguments unused
 * @param options unused
 */
- (void)hideTabBar:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!tabBar) return;
    tabBar.hidden = YES;
}

/**
 * Create a new tab bar item for use on a previously created tab bar.  Use ::showTabBarItems to show the new item on the tab bar.
 *
 * If the supplied image name is one of the labels listed below, then this method will construct a tab button
 * using the standard system buttons.  Note that if you use one of the system images, that the \c title you supply will be ignored.
 * - <b>Tab Buttons</b>
 *   - tabButton:More
 *   - tabButton:Favorites
 *   - tabButton:Featured
 *   - tabButton:TopRated
 *   - tabButton:Recents
 *   - tabButton:Contacts
 *   - tabButton:History
 *   - tabButton:Bookmarks
 *   - tabButton:Search
 *   - tabButton:Downloads
 *   - tabButton:MostRecent
 *   - tabButton:MostViewed
 * @brief create a tab bar item
 * @param arguments Parameters used to create the tab bar
 *  -# \c name internal name to refer to this tab by
 *  -# \c title title text to show on the tab, or null if no text should be shown
 *  -# \c image image filename or internal identifier to show, or null if now image should be shown
 *  -# \c tag unique number to be used as an internal reference to this button
 * @param options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if nil or unspecified, the badge will be hidden
 */
- (void)createTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if ([arguments count] < 4) {
        NSLog(@"ERROR: createTabBarItem called incorrectly; not enough arguments");
        return;
    }

    if (!tabBar)
        [self createTabBar:nil withDict:nil];

    NSString  *name      = [arguments objectAtIndex:0];
    NSString  *title     = [arguments objectAtIndex:1];
    NSString  *imageName = [arguments objectAtIndex:2];
    int tag              = [[arguments objectAtIndex:3] intValue];

    UITabBarItem *item = nil;    
    UIBarButtonSystemItem systemItem = [self getBarButtonSystemItemFor:imageName];
    if (systemItem != -1) {
        item = [[UITabBarItem alloc] initWithTabBarSystemItem:systemItem tag:tag];
    } else {
        item = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageName] tag:tag];
    }

    if ([options objectForKey:@"badge"])
        item.badgeValue = [options objectForKey:@"badge"];
    
    [tabBarItems setObject:item forKey:name];
}

/**
 * Update an existing tab bar item to change its badge value.
 * @brief update the badge value on an existing tab bar item
 * @param arguments Parameters used to identify the tab bar item to update
 *  -# \c name internal name used to represent this item when it was created
 * @param options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if nil or unspecified, the badge will be hidden
 */
- (void)updateTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!tabBar)
        [self createTabBar:nil withDict:nil];
    if ([arguments count] == 0)
        return;

    NSString  *name = [arguments objectAtIndex:0];
    UITabBarItem *item = [tabBarItems objectForKey:name];
    if (item)
        item.badgeValue = [options objectForKey:@"badge"];
}

/**
 * Show previously created items on the tab bar
 * @brief show a list of tab bar items
 * @param arguments the item names to be shown
 * @param options dictionary of options, notable options including:
 *  - \c animate indicates that the items should animate onto the tab bar
 * @see createTabBarItem
 * @see createTabBar
 */
- (void)showTabBarItems:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!tabBar)
        [self createTabBar:nil withDict:nil];
    
    int i, count = [arguments count];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:count];
    for (i = 0; i < count; i++) {
        NSString *itemName = [arguments objectAtIndex:i];
        UITabBarItem *item = [tabBarItems objectForKey:itemName];
        if (item)
            [items addObject:item];
    }
    
    BOOL animateItems = YES;
    if ([options objectForKey:@"animate"])
        animateItems = [(NSString*)[options objectForKey:@"animate"] boolValue];
    [tabBar setItems:items animated:animateItems];
}

/**
 * Manually select an individual tab bar item, or nil for deselecting a currently selected tab bar item.
 * @brief manually select a tab bar item
 * @param arguments the name of the tab bar item to select
 * @see createTabBarItem
 * @see showTabBarItems
 */
- (void)selectTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
    if (!tabBar)
        [self createTabBar:nil withDict:nil];

    NSString *itemName = [arguments objectAtIndex:0];
    UITabBarItem *item = [tabBarItems objectForKey:itemName];
    if (item)
        tabBar.selectedItem = item;
    else
        tabBar.selectedItem = nil;
}

/**
 Callback called when a tab item is selected, and notifies the JavaScript environment of this action.
 */
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSString * jsCallBack = [NSString stringWithFormat:@"uicontrols.tabBarItemSelected(%d);", item.tag];    
    [webView stringByEvaluatingJavaScriptFromString:jsCallBack];
}

#pragma mark -
#pragma mark NavBar methods

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
    
    NSDictionary* navBarSettings = [settings objectForKey:@"NavBar"];

    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 38.0f)];
    navBar.delegate = self;
    navBar.multipleTouchEnabled   = NO;
    navBar.autoresizesSubviews    = YES;
    navBar.userInteractionEnabled = YES;
    navBar.hidden = NO;
    [self setFrameFor:navBar withSettings:navBarSettings];
    [self.webView.superview addSubview:navBar];
    [self.webView.superview bringSubviewToFront:navBar];

    /**
     * Properties:
     *   opaque: If not specified, then the default is used; otherwise, it will be opaque or
     *           translucent if supplied, depending on the checked value.
     */
    if (navBarSettings) {
        /**
         * The opaque setting controls whether or not the background of the navbar will
         * be fully opaque, or translucent.
         */
        if ([navBarSettings objectForKey:@"opaque"]) {
            if ([[navBarSettings objectForKey:@"opaque"] boolValue])
                navBar.barStyle = UIBarStyleBlackOpaque;
            else
                navBar.barStyle = UIBarStyleBlackTranslucent;
        }

        /**
         * The tintColor property influences what the color of the navbar background will be,
         * which is also dependant on the opaque property.  Supply a color value in standard
         * RGB or RGBA hex.
         */
        if ([navBarSettings objectForKey:@"tintColor"]) {
            navBar.tintColor = [(NSString*)[navBarSettings objectForKey:@"tintColor"] colorFromHex];
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
            UIBarButtonSystemItem systemItem = [self getBarButtonSystemItemFor:rightTitle];
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
    if (tabBar)
        [tabBar release];
    [navBarEvents release];
    [super dealloc];
}

@end
