//
//  File.h
//  PhoneGap
//
//  Created by Michael Nachbaur on 30/05/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"

@interface File : PhoneGapCommand {
}

- (void)listDirectoryContents:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
