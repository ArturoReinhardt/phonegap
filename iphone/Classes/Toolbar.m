//
//  Toolbar.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/10/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "Toolbar.h"

@implementation PGToolbarItem
@synthesize view;
@synthesize cbEvent_Click;

-(PGToolbarItem*) initWithOptions:(NSDictionary*)inOptions target:(id)target
{
    self = [super init];
    if (self) {
        options = [[[NSMutableDictionary alloc] initWithDictionary:inOptions] retain];
		cbEvent_Click = [[options objectForKey:@"onClick"] intValue];
    }
    return self;
}

- (void)dealloc
{
	[options release];
    [super dealloc];
}

@end

@implementation PGToolbarSpace

-(PGToolbarSpace*) initWithOptions:(NSDictionary*)inOptions target:(id)target
{
    self = (PGToolbarSpace*)[super initWithOptions:inOptions target:target];
    if (self) {
        flexible = [[options objectForKey:@"flexible"] boolValue];
		UIBarButtonSystemItem itemType;
		
		if (flexible)
			itemType = UIBarButtonSystemItemFlexibleSpace;
		else
			itemType = UIBarButtonSystemItemFixedSpace;
		
		view = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:itemType
															 target:target
															 action:@selector(itemClicked:)];
		if (!flexible) {
			int width = 42;
			if ([[options objectForKey:@"width"] intValue] > 0)
				width = [[options objectForKey:@"width"] intValue];
			view.width = width;
		}
    }
    return self;
}

@end

@implementation PGToolbarLabel

-(PGToolbarLabel*) initWithOptions:(NSDictionary*)inOptions target:(id)target
{
    self = (PGToolbarLabel*)[super initWithOptions:inOptions target:target];
    if (self) {
        label = [options objectForKey:@"label"];
		view = [[UIBarButtonItem alloc] initWithTitle:label
												style:UIBarButtonItemStylePlain
											   target:target
											   action:@selector(itemClicked:)];
    }
    return self;
}

@end

@implementation PGToolbarButton

-(PGToolbarButton*) initWithOptions:(NSDictionary*)inOptions target:(id)target
{
    self = (PGToolbarButton*)[super initWithOptions:inOptions target:target];
    if (self) {
        enabled = [[options objectForKey:@"enabled"] boolValue];
		if ([[options objectForKey:@"style"] isEqualToString:@"done"]) {
			style = UIBarButtonItemStyleDone;
		} else {
			style = UIBarButtonItemStyleBordered;
		}
		label = (NSString*)[options objectForKey:@"label"];

		UIBarButtonSystemItem labelItem = [PhoneGapCommand getBarButtonSystemItemFor:label];
		if (labelItem != -1) {
			view = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:labelItem
																 target:target
																 action:@selector(itemClicked:)];
		} else {
			view = [[UIBarButtonItem alloc] initWithTitle:label
													style:style
												   target:target
												   action:@selector(itemClicked:)];
		}
		view.style = style;
    }
    return self;
}

@end

@implementation Toolbar

-(PhoneGapCommand*) initWithWebView:(UIWebView*)theWebView
{
    self = (Toolbar*)[super initWithWebView:theWebView];
    if (self) {
        mItems = [[NSMutableDictionary alloc] initWithCapacity:5];
		[self createToolbar];
    }
    return self;
}

#pragma mark -
#pragma mark Toolbar methods

- (void)createToolbar
{
    if (mToolbar) {
        NSLog(@"Toolbar already exists; not creating another.");
        return;
    }

    mToolbar = [UIToolbar new];
    [mToolbar sizeToFit];
    mToolbar.multipleTouchEnabled   = NO;
    mToolbar.autoresizesSubviews    = YES;
    mToolbar.hidden                 = YES;
    mToolbar.userInteractionEnabled = YES;

    [self setFrameFor:mToolbar withSettings:settings];
	[self.webView.superview addSubview:mToolbar];
	
	mPosition = PGToolbarPositionBottom;
	if ([[settings objectForKey:@"position"] isEqualToString:@"bottom"])
		mPosition = PGToolbarPositionBottom;
	else if ([[settings objectForKey:@"position"] isEqualToString:@"top"])
		mPosition = PGToolbarPositionTop;
	
	mAnimation = PGToolbarAnimationSlide;
	if ([[settings objectForKey:@"animation"] isEqualToString:@"slide"])
		mAnimation = PGToolbarAnimationSlide;
	else if ([[settings objectForKey:@"animation"] isEqualToString:@"fade"])
		mAnimation = PGToolbarAnimationFade;
}

- (void)toggleVisibility:(BOOL)visible animated:(BOOL)isAnimated
{
	if (isAnimated) {
		CATransition *animation = [CATransition animation];
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		animation.duration = [[settings objectForKey:@"animationDuration"] floatValue];
		animation.type = kCATransitionMoveIn;
		if (animation.duration <= 0.0)
			animation.duration = 0.35;
		
		if (mPosition == PGToolbarPositionBottom)
			animation.subtype = kCATransitionFromTop;
		else if (mPosition == PGToolbarPositionTop)
			animation.subtype = kCATransitionFromBottom;
		[mToolbar.layer addAnimation:animation forKey:kCATransition];
	}
	
	mToolbar.hidden = !visible;
	if (visible)
		[self fireCallback:cbEvent_Shown withArguments:nil];
	else
		[self fireCallback:cbEvent_Hidden withArguments:nil];
}

- (void)show:(NSArray*)arguments withDict:(NSDictionary*)options
{
	BOOL animation = YES;
	if ([options objectForKey:@"animated"])
		animation = [[options objectForKey:@"animated"] boolValue];
	
	[self toggleVisibility:YES animated:animation];
}

- (void)hide:(NSArray*)arguments withDict:(NSDictionary*)options
{
	BOOL animation = YES;
	if ([options objectForKey:@"animated"])
		animation = [[options objectForKey:@"animated"] boolValue];
	
	[self toggleVisibility:NO animated:animation];
}

- (void)addItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
	if ([arguments count] == 0) {
		NSLog(@"Toolbar.addItem requires an id to be supplied");
		return;
	}
	NSString *itemId = [arguments objectAtIndex:0];
	
	NSString *type = [options objectForKey:@"type"];
	if (type == nil) {
		NSLog(@"Toolbar.addItem requires a type attribute");
		return;
	}
	
	PGToolbarItem *item;
	if ([type isEqualToString:@"button"])
		item = [[PGToolbarButton alloc] initWithOptions:options target:self];
	else if ([type isEqualToString:@"label"])
		item = [[PGToolbarLabel alloc] initWithOptions:options target:self];
	else if ([type isEqualToString:@"space"])
		item = [[PGToolbarSpace alloc] initWithOptions:options target:self];
	else {
		NSLog(@"Invalid type %@ passed to Toolbar.addItem", type);
		return;
	}
	
	[mItems setObject:item forKey:itemId];
}

- (void)updateItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
}

- (void)removeItem:(NSArray*)arguments withDict:(NSDictionary*)options
{
}

- (void)setItems:(NSArray*)arguments withDict:(NSDictionary*)options
{
	BOOL isAnimated = [[options objectForKey:@"animated"] boolValue];

	int i, c = [arguments count];
	NSMutableArray *itemViews = [[NSMutableArray alloc] initWithCapacity:c];
	for (i = 0; i < c; i++) {
		NSString *itemId = [arguments objectAtIndex:i];
		PGToolbarItem *item = (PGToolbarItem*)[mItems objectForKey:itemId];
		if (item == nil || item.view == nil)
			continue;
		[itemViews addObject:item.view];
	}
	
	[mToolbar setItems:[NSArray arrayWithArray:itemViews] animated:isAnimated];
	[itemViews release];
}

- (void)itemClicked:(id)sender
{
	NSEnumerator *keys = [mItems keyEnumerator];
	NSString *itemId;
	while (itemId = [keys nextObject]) {
		PGToolbarItem *item = [mItems objectForKey:itemId];
		if (item != nil && item.view == sender) {
			[self fireCallback:item.cbEvent_Click withArguments:[NSArray array]];
			return;
		}
	}
}

- (void)dealloc
{
    if (mToolbar)
        [mToolbar release];
	if (mItems)
		[mItems release];
    [super dealloc];
}

@end
