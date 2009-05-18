//
//  UIControls.h
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITabBar.h>
#import <UIKit/UIToolbar.h>

#import "PhoneGapCommand.h"

@interface UIControls : PhoneGapCommand <UITabBarDelegate, UINavigationBarDelegate> {
    UITabBar* tabBar;
    NSMutableDictionary* tabBarItems;
    
    /*
    UIToolbar* toolBar;
    UIBarButtonItem* toolBarTitle;
    NSMutableDictionary* toolBarItems;
     */
    
    UINavigationBar*  navBar;
    UIView*           navBarTitle;
    UINavigationItem* navBarBackButton;
    UINavigationItem* navBarLeftButton;
    UINavigationItem* navBarRightButton;
    NSMutableArray*   navBarEvents;
}

- (void)setFrameFor:(UIView*)control withSettings:(NSDictionary*)controlSettings;
- (UIBarButtonSystemItem) getBarButtonSystemItemFor:(NSString*)imageName;
- (UIBarButtonItemStyle)getBarButtonStyleFor:(NSString*)string;

/* Tab Bar methods 
 */
- (void)createTabBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)showTabBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)hideTabBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)showTabBarItems:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)createTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)updateTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)selectTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options;

/* NavBar methods
 */
- (void)createNavBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)setNavBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)navBarRightButtonClicked;

/*
- (void) navigationBar:(UINavigationBar*)theNavBar didPushItem:(UINavigationItem*)item;
- (void) navigationBar:(UINavigationBar*)theNavBar didPopItem:(UINavigationItem*)item;
- (BOOL) navigationBar:(UINavigationBar*)theNavBar shouldPushItem:(UINavigationItem*)item;
- (BOOL) navigationBar:(UINavigationBar*)theNavBar shouldPopItem:(UINavigationItem*)item;
*/

@end
