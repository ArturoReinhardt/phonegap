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
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSMutableArray *directoryParts = [NSMutableArray arrayWithArray:[(NSString*)[arguments objectAtIndex:0] componentsSeparatedByString:@"/"]];
    NSString       *filename       = [directoryParts lastObject];
    [directoryParts removeLastObject];
    
    NSMutableArray *filenameParts  = [NSMutableArray arrayWithArray:[filename componentsSeparatedByString:@"."]];
    NSString *directoryStr = [directoryParts componentsJoinedByString:@"/"];
    
    NSString *filePath = [mainBundle pathForResource:(NSString*)[filenameParts objectAtIndex:0]
                                              ofType:(NSString*)[filenameParts objectAtIndex:1]
                                         inDirectory:directoryStr];
	if (filePath == nil) {
		NSLog(@"Can't find filename %@ in the app bundle", [arguments objectAtIndex:0]);
		if ([[arguments objectAtIndex:0] hasPrefix:@"http"]){
	
			if (player != nil)
				[player stop];
					
			NSURL *sampleUrl = [NSURL URLWithString:[arguments objectAtIndex:0]];
			NSData *sampleAudio = [NSData dataWithContentsOfURL:sampleUrl];
			NSError *err;
			player = [[ AVAudioPlayer alloc ] initWithData:sampleAudio error:&err];
			if (err)
				NSLog(@"Failed to initialize AVAudioPlayer: %@\n", err);
			player.delegate = self;
			[ player prepareToPlay ];
			[ player play ];
		}
        return;
    }
    SystemSoundID soundID;
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundID);
    if (error != 0)
        NSLog(@"Sound error %d", error);
    
    AudioServicesPlaySystemSound(soundID);
}

@end
