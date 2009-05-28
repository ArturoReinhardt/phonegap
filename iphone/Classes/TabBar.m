//
//  TabBar.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "TabBar.h"

@implementation TabBar
@synthesize webView;

-(PhoneGapCommand*) initWithWebView:(UIWebView*)theWebView
{
    self = (TabBar*)[super initWithWebView:theWebView];
    if (self) {
        tabBarItems = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return self;
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
    
    [self setFrameFor:tabBar withSettings:settings];

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
    NSString * jsCallBack = [NSString stringWithFormat:@"tabbar.tabBarItemSelected(%d);", item.tag];    
    [webView stringByEvaluatingJavaScriptFromString:jsCallBack];
}

- (void)dealloc
{
    if (tabBar)
        [tabBar release];
    [super dealloc];
}

@end
