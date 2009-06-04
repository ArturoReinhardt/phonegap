//
//  Dialog.h
//  PhoneGap
//
//  Created by Michael Nachbaur on 13/04/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PhoneGapCommand.h"

@interface Dialog : PhoneGapCommand <UIActionSheetDelegate> {
    NSDictionary *dialogOptions;
}

- (void) openButtonDialog:(NSMutableArray*) arguments withDict:(NSMutableDictionary*) options;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (UIActionSheetStyle)getActionSheetStyle:(NSString*)string;

@end
