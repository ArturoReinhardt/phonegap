//
//  NavigationBar.h
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIToolbar.h>

#import "PhoneGapCommand.h"

@interface NavigationBar : PhoneGapCommand <UINavigationBarDelegate> {
    UINavigationBar*  navBar;
    UIView*           navBarTitle;
    UINavigationItem* navBarBackButton;
    UINavigationItem* navBarLeftButton;
    UINavigationItem* navBarRightButton;
    NSMutableArray*   navBarEvents;
}

- (UIBarButtonItemStyle)getBarButtonStyleFor:(NSString*)string;

/* NavBar methods
 */
- (void)createNavBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)setNavBar:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)navBarRightButtonClicked;

@end
