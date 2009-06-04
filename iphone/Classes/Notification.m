//
//  Notification.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 16/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "Notification.h"

@implementation Notification

/**
 * Show a native alert window, with one or two buttons.  Depending on the options given, it can customize
 * the title, button labels, and can even be issued a callback to be invoked when a button is clicked.
 *
 * Additionally this command will issue a DOMEvent on the \c document element within JavaScript when a button
 * is clicked.  The \c alertClosed event will be fired, with \c buttonIndex and \c buttonLabel properties on
 * the supplied event object.
 *
 * @brief show a native alert window
 * @param arguments The message to display in the alert window
 * @param options dictionary of options, notable options including:
 *  - \c title {String} title text
 *  - \c okLabel {String=OK} label of the OK button
 *  - \c cancelLabel {String} optional label for a second Cancel button
 *  - \c onClose {Integer} callback ID used to invoke a function in JavaScript when the alert window closes
 * @see alertView:clickedButtonAtIndex
 */
- (void)alert:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (openURLAlert) {
        NSLog(@"Cannot open an alert when one already exists");
        return;
    }

	NSString* message      = [arguments objectAtIndex:0];
	NSString* title        = [options objectForKey:@"title"];
	NSString* okButton     = [options objectForKey:@"okLabel"];
	NSString* cancelButton = [options objectForKey:@"cancelLabel"];
	NSInteger onCloseId    = [(NSString*)[options objectForKey:@"onClose"] integerValue];
    
    if (!title)
        title = @"Alert";
    if (!okButton)
        okButton = @"OK";
    if (onCloseId)
        alertCallbackId = onCloseId; 
    
    openURLAlert = [[UIAlertView alloc] initWithTitle:title
                                              message:message
                                             delegate:self
                                    cancelButtonTitle:okButton
                                    otherButtonTitles:nil];
    if (cancelButton)
        [openURLAlert addButtonWithTitle:cancelButton];
    
	[openURLAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonLabel = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertCallbackId) {
        NSString *buttonIndexStr = [NSString stringWithFormat:@"%d", buttonIndex];
        NSArray *arguments = [NSArray arrayWithObjects:buttonIndexStr, buttonLabel, nil];
        [self fireCallback:alertCallbackId withArguments:arguments];
        alertCallbackId = 0;
    }
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"(function(){ "
                                                        "var e = document.createEvent('Events'); "
                                                        "e.initEvent('alertClosed', 'false', 'false'); "
                                                        "e.buttonIndex = %d; "
                                                        "e.buttonLabel = \"%@\"; "
                                                        "document.dispatchEvent(e); "
                                                     "})()", buttonIndex, [buttonLabel stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
    [openURLAlert release];
    openURLAlert = nil;
}

- (void)activityStart:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}

- (void)activityStop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void)vibrate:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
