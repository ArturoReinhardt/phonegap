//
//  Toolbar.h
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/10/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIToolbar.h>
#import <QuartzCore/QuartzCore.h>

#import "PhoneGapCommand.h"

typedef enum {
	PGToolbarPositionBottom = 0,
	PGToolbarPositionTop    = 1
} PGToolbarPosition;

typedef enum {
	PGToolbarAnimationSlide = 0,
	PGToolbarAnimationFade  = 1
} PGToolbarAnimation;

@interface PGToolbarItem : NSObject {
	NSMutableDictionary *options;
	int cbEvent_Click;
	UIBarButtonItem *view;
}
@property (nonatomic,retain) UIBarButtonItem *view;
@property (readonly) int cbEvent_Click;

-(PGToolbarItem*) initWithOptions:(NSDictionary*)inOptions target:(id)target;
@end

@interface PGToolbarSpace : PGToolbarItem {
	BOOL flexible;
}
-(PGToolbarSpace*) initWithOptions:(NSDictionary*)inOptions target:(id)target;
@end

@interface PGToolbarLabel : PGToolbarItem {
	NSString *label;
}
-(PGToolbarLabel*) initWithOptions:(NSDictionary*)inOptions target:(id)target;
@end

@interface PGToolbarButton : PGToolbarLabel {
	BOOL enabled;
	UIBarButtonItemStyle style;
}
-(PGToolbarButton*) initWithOptions:(NSDictionary*)inOptions target:(id)target;
@end

@interface Toolbar : PhoneGapCommand {
    UIToolbar *mToolbar;
	NSMutableDictionary *mItems;
	PGToolbarPosition mPosition;
	PGToolbarAnimation mAnimation;
	int cbEvent_Shown;
	int cbEvent_Hidden;
}

- (void)createToolbar;
- (void)toggleVisibility:(BOOL)visible animated:(BOOL)isAnimated;
- (void)itemClicked:(id)sender;

- (void)show:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)hide:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)addItem:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)updateItem:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)removeItem:(NSArray*)arguments withDict:(NSDictionary*)options;
- (void)setItems:(NSArray*)arguments withDict:(NSDictionary*)options;

@end
