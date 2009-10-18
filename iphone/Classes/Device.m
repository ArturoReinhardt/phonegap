/*
 *  Device.m 
 *  Used to display Device centric details handset.
 *
 *  Created by Nitobi on 12/12/08.
 *  Copyright 2008 Nitobi. All rights reserved.
 */

#import "Device.h"

@implementation Device

/**
 * returns a dictionary with various device settings
 *  - gap (version)
 *  - Device platform
 *  - Device version
 *  - Device name (e.g. user-defined name of the phone)
 *  - Device uuid
 */
- (NSDictionary*) deviceProperties
{
	UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *devProps = [NSMutableDictionary dictionaryWithCapacity:4];
    [devProps setObject:[device model] forKey:@"platform"];
    [devProps setObject:[device systemVersion] forKey:@"version"];
    [devProps setObject:[device uniqueIdentifier] forKey:@"uuid"];
    [devProps setObject:[device name] forKey:@"name"];
    [devProps setObject:@"0.8.0" forKey:@"gap"];

    NSDictionary *devReturn = [NSDictionary dictionaryWithDictionary:devProps];
    return devReturn;
}


/**
 * Hides the splash screen explicitly from JavaScript.
 */
- (void) hideSplashScreen:(NSMutableArray*) arguments withDict:(NSMutableDictionary*) options
{
    [[[self appDelegate] imageView] setHidden:TRUE];
    [[[self appDelegate] window] bringSubviewToFront:[self appViewController].view];
}

/**
 Save the web view as a screenshot.  Currently only supports saving to the photo library.
 */
- (void)saveScreenshot:(NSArray*)arguments withDict:(NSDictionary*)options
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	UIGraphicsBeginImageContext(screenRect.size);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor blackColor] set];
	CGContextFillRect(ctx, screenRect);
	
	[webView.layer renderInContext:ctx];
	
	UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
	UIImageWriteToSavedPhotosAlbum(image1, nil, nil, nil);
	UIGraphicsEndImageContext();
}

@end
