//
//  File.m
//  PhoneGap
//
//  Created by Michael Nachbaur on 30/05/09.
//  Copyright 2009 Decaf Ninja Software. All rights reserved.
//

#import "File.h"

@implementation File

/**
 Lists the contents of a directory, and returns a datastructure describing the files within that directory.
 Ensure that the "onComplete" option is supplied, indicating which callback to invoke with the results.
 
 @param arguments[0] {String} Path to the directory, or null for the main bundle directory.
 @param arguments[1] {String} Optional file extension to filter by
 @param options {Dictionary} Options to supply to this method, including the callback to run when finished. 
 */
- (void)listDirectoryContents:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSInteger callbackId = [(NSString*)[options objectForKey:@"onComplete"] integerValue];
    if (callbackId < 1) {
        NSLog(@"Useless call to listDirectoryContents ignored; invoked without an onComplete callback");
        return;
    }
    
    /**
     If supplied, the first argument is the path to the directory where you want to look for files in.
     If unspecified, it defaults to the main application bundle directory.
     */
    NSString *path = [[NSBundle mainBundle] bundlePath];
    if ([arguments count] > 0 && [arguments objectAtIndex:0])
        path = [path stringByAppendingFormat:@"/%@", [arguments objectAtIndex:0]];
    
    /**
     If a second argument is supplied, it is assumed to be the file extension to limit the file search by.
     If unspecified, then all files are returned unfiltered.
     */
    NSString *filterFileType = nil;
    if ([options objectForKey:@"extension"])
        filterFileType = [options objectForKey:@"extension"];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%B %d, %Y %H:%M:%S" allowNaturalLanguage:NO] autorelease];
    
    // Load the directory contents and add it to a dictionary
    NSMutableDictionary *contents = [NSMutableDictionary dictionaryWithCapacity:1];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *filename;
    while (filename = [direnum nextObject]) {
        [direnum skipDescendents]; // Only work at one directory level at a time

        if (filterFileType != nil && ![[filename pathExtension] isEqualToString:filterFileType])
            continue;

        NSDictionary *attr = [direnum fileAttributes];
        NSMutableDictionary *file = [NSMutableDictionary dictionaryWithCapacity:10];
        [file setObject:[dateFormatter stringFromDate:[attr objectForKey:@"NSFileCreationDate"]]
                 forKey:@"created"];
        [file setObject:[dateFormatter stringFromDate:[attr objectForKey:@"NSFileModificationDate"]]
                 forKey:@"modified"];
        [file setObject:[attr objectForKey:@"NSFileSize"]
                 forKey:@"size"];
        [file setObject:[filename pathExtension]
                 forKey:@"extension"];
        [file setObject:filename
                 forKey:@"filename"];

        if ([(NSString*)[attr objectForKey:@"NSFileType"] isEqualToString:@"NSFileTypeDirectory"])
            [file setObject:@"true" forKey:@"isDirectory"];
        else
            [file setObject:@"false" forKey:@"isDirectory"];

        [contents setObject:file forKey:filename];
    }
    NSArray *return_arguments = [NSArray arrayWithObject:[contents JSONFragment]];
    [self fireCallback:callbackId withArguments:return_arguments];
}

@end
