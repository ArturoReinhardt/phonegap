//
//  PhoneGapViewController.m
//  PhoneGap
//
//  Created by Nitobi on 15/12/08.
//  Copyright 2008 Nitobi. All rights reserved.
//

#import "PhoneGapViewController.h"
#import "PhoneGapDelegate.h" 

@implementation PhoneGapViewController

/**
 Used by UIKit to determine if the device's interface should rotate to the device's physical orientation.
 This can be controlled by setting the \c RotateOrientation property in PhoneGap.plist
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation 
{
    if (autoRotate == YES) {
        return YES;
    } else {
        if ([rotateOrientation isEqualToString:@"portrait"]) {
            return (interfaceOrientation == UIInterfaceOrientationPortrait ||
                    interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
        } else if ([rotateOrientation isEqualToString:@"landscape"]) {
            return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                    interfaceOrientation == UIInterfaceOrientationLandscapeRight);
        } else {
            return NO;
        }
    }
}

/**
 Called when the device starts to rotate to a new orientation.  This fires the \c setOrientation
 method on the Orientation object in JavaScript, which in turn dispatches the \c startOrientationChange event on the document element.
 Look at the JavaScript documentation for more information.
 */
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration: (NSTimeInterval)duration
{
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"navigator.orientation.setOrientation(%f, %d);",
                                                     [self getRotationInDegrees:toInterfaceOrientation],
                                                     duration * 1000
     ]];
}

/**
 Called when the device orientation animation finishes; calls the \c stopOrientationChange event on the document element directly
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSString *jsCallback = [NSString stringWithFormat:@"(function(){ "
									"var e = document.createEvent('Events'); "
									"e.initEvent('stopOrientationChange', 'false', 'false'); "
									"e.orientation = %f; "
									"document.dispatchEvent(e); })()",
                                [self getRotationInDegrees:fromInterfaceOrientation]
                            ];
	[webView stringByEvaluatingJavaScriptFromString:jsCallback];
}

/**
 Internal method used in the view controller to convert UI orientation constants into
 degrees
 @param forOrientation the constant to return an orientation for
 */
- (double)getRotationInDegrees: (UIInterfaceOrientation)forOrientation
{
	double i = 0;
	
	switch (forOrientation){
		case UIInterfaceOrientationPortrait:
			i = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			i = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			i = 90;
			break;
		case UIInterfaceOrientationLandscapeRight:
			i = -90;
			break;
	}
    return i;
}

- (void) setAutoRotate:(BOOL) shouldRotate {
    autoRotate = shouldRotate;
}

- (void) setRotateOrientation:(NSString*) orientation {
    rotateOrientation = orientation;
}

@end