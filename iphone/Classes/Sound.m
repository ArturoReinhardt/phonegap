/*
 *  Sound.m
 *
 *  Created by Nitobi on 12/12/08.
 *  Copyright 2008 Nitobi. All rights reserved.
 *
 */

#import "Sound.h"

@implementation Sound

- (void) play:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSURL *fileURL = [self getLocalFileFor:[arguments objectAtIndex:0]];
    if (fileURL == nil)
        return;
    
    // TODO Create a system facilitating handling callback responses in JavaScript easily, and no
    // longer in an ad-hoc fashion.  Getting error results of whether or not the sound played, or
    // other errors occurring in the system is important.
    SystemSoundID soundID;
    OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundID);
    if (error != 0)
        NSLog(@"Sound error %d", error);
    
    AudioServicesPlaySystemSound(soundID);
}

@end
