//
//  TabBar.h
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITabBar.h>

#import "PhoneGapCommand.h"

@interface TabBar : PhoneGapCommand <UITabBarDelegate> {
    UITabBar* tabBar;
    NSMutableDictionary* tabBarItems;
}
@property (nonatomic, retain) UITabBar *tabBar;

/* Tab Bar methods 
 */
- (void)createTabBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)showTabBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)hideTabBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)showTabBarItems:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)createTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)updateTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)selectTabBarItem:(NSArray*)arguments withDict:(NSDictionary*)options;

@end
