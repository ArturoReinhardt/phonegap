//
//  Dialog.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "Dialog.h"

@implementation Dialog
@synthesize webView;

#pragma mark -
#pragma mark Button Dialog methods

/**
 Opens an action sheet dialog containing a series of buttons.  This is a modal dialog, and the user is
 required to make a choice before they can continue.
 
 Note that button indexes all start at 1, rather than 0.
 
 The event \c actionSheetClicked will be dispatched on the \c document element when any button is clicked, and
 sets the following properties on the event object:
 - \c buttonIndex
 - \c buttonLabel
 - \c buttonType

 @param arguments[0] the title of the action sheet, to be displayed at the top
 @param arguments[1..*] a list of labels for the sequence of buttons to be shown, from bottom to top
 @param options   options to control how the buttons and callbacks for click events will be handled
   - \c type_*    the button type to style a given button with (default: default)
   - \c onclick_* the callback ID to invoke for the given button
   - \c onClick   the callback ID to invoke when any button is clicked
 */
- (void) openButtonDialog:(NSMutableArray*) arguments withDict:(NSMutableDictionary*) options
{

    int i, n = [arguments count];
    NSString *title = [NSString stringWithString:[arguments objectAtIndex:0]];
    NSString       *cancelButton      = nil;
    NSString       *destructiveButton = nil;
    NSMutableArray *otherButtons = [NSMutableArray arrayWithCapacity:n];
    
    for (i = 1; i < n; i++) {
        NSString *label = [arguments objectAtIndex:i];
        NSString *type  = [options objectForKey:[NSString stringWithFormat:@"type_%d", i]];
        if (type && [type isEqualToString:@"cancel"])
            cancelButton = label;
        else if (type && [type isEqualToString:@"destroy"])
            destructiveButton = label;
        else
            [otherButtons addObject:label];
    }

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
                                                    cancelButtonTitle:cancelButton
                                               destructiveButtonTitle:destructiveButton
                                                    otherButtonTitles:nil];
    n = [otherButtons count];
    for (i = 0; i < n; i++) {
        [actionSheet addButtonWithTitle:[otherButtons objectAtIndex:i]];
    }
    
    // Find out what button indexes worked out to be
    n = [arguments count];
    NSMutableDictionary *buttonIndexLookup = [NSMutableDictionary dictionaryWithCapacity:n];
    for (i = 0; i < n - 1; i++) {
        int j;
        NSString *currLabel = [actionSheet buttonTitleAtIndex:i];
        for (j = 1; j < n; j++) {
            if ([[arguments objectAtIndex:j] isEqualToString:currLabel]) {
                [buttonIndexLookup setValue:[NSNumber numberWithInt:j] forKey:currLabel];
                break;
            }
        }
    }
    [options setValue:buttonIndexLookup forKey:@"buttonIndexLookup"];
    dialogOptions = [[NSDictionary dictionaryWithDictionary:options] retain];

    actionSheet.actionSheetStyle = [self getActionSheetStyle:[options objectForKey:@"style"]];
    
    NSString *showFrom = @"default";
    if ([options objectForKey:@"showFrom"])
        showFrom = [options objectForKey:@"showFrom"];

    /*
    PhoneGapDelegate *pg = webView.delegate;
    if ([showFrom isEqualToString:@"tabbar"]
        && [pg hasCommandInstance:@"TabBar"]
        && [pg getCommandInstance:@"TabBar"].tabBar)
        [actionSheet showFromTabBar:[pg getCommandInstance:@"TabBar"].tabBar];
    else if ([showFrom isEqualToString:@"navigationbar"]
             && [pg hasCommandInstance:@"NavigationBar"]
             && [pg getCommandInstance:@"NavigationBar"].navBar)
        [actionSheet showFromToolbar:[pg getCommandInstance:@"NavigationBar"].navBar];
    else
     */
        [actionSheet showInView:webView];
    [actionSheet release];
}

/**
 Method called by UIActionSheet when a button is clicked on the button dialog.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonLabel = [actionSheet buttonTitleAtIndex:buttonIndex];
    int index = [[[dialogOptions objectForKey:@"buttonIndexLookup"] objectForKey:buttonLabel] intValue];
    NSString *escapedLabel = [buttonLabel stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *buttontype  = @"default";
    
    if ([actionSheet cancelButtonIndex] == buttonIndex)
        buttontype = @"cancel";
    else if ([actionSheet destructiveButtonIndex] == buttonIndex)
        buttontype = @"destroy";
    
    NSMutableString *jsCallback = [NSMutableString stringWithFormat:@"(function(){ "
                                     "var e = document.createEvent('Events'); "
                                     "e.initEvent('actionSheetClicked', 'false', 'false'); "
                                     "e.buttonIndex = %d; "
                                     "e.buttonLabel = \"%@\"; "
                                     "e.buttonType  = \"%@\"; "
                                     "document.dispatchEvent(e); "
                                     "})(); \n",
                                   index,
                                   escapedLabel,
                                   buttontype];

    if ([[dialogOptions objectForKey:@"onclick"] isGreaterThan:0]) {
        int globalCallback = [[dialogOptions objectForKey:@"onclick"] intValue];
        [jsCallback appendFormat:@"PhoneGap.invokeCallback(%d, [%d, \"%@\", \"%@\"]);\n", globalCallback, index, escapedLabel, buttontype];
    }


    int buttonCallback = [[dialogOptions objectForKey:[NSString stringWithFormat:@"onclick_%d", index]] intValue];
    if (buttonCallback > 0)
        [jsCallback appendFormat:@"PhoneGap.invokeCallback(%d, [%d, \"%@\", \"%@\"]);\n", buttonCallback, index, escapedLabel, buttontype];

    [webView stringByEvaluatingJavaScriptFromString:jsCallback];
    [dialogOptions release];
}

#pragma mark -
#pragma mark Utility Functions

/**
 Utility function used to translate a string into an internal constant representing an action sheet style.
 Valid values are:
 - \c default (default)
 - \c automatic
 - \c translucent
 - \c opaque
 */
- (UIActionSheetStyle)getActionSheetStyle:(NSString*)string
{
    if (string) {
        if ([string isEqualToString:@"automatic"])
            return UIActionSheetStyleAutomatic;
        else if ([string isEqualToString:@"default"])
            return UIActionSheetStyleDefault;
        else if ([string isEqualToString:@"translucent"])
            return UIActionSheetStyleBlackTranslucent;
        else if ([string isEqualToString:@"opaque"])
            return UIActionSheetStyleBlackOpaque;
    }
    return UIActionSheetStyleDefault;
}


@end
