/*
 *  Image.m
 *  PhoneGap
 *
 *  Created by Nitobi on 04/02/09. 
 *  Copyright 2009 Nitobi. All rights reserved.
 *  Rob Ellis * Brian LeRoux * Brock Whitten
 *
 *  Special thanks to urbian.org - g.mueller @urbian.org
 *
 */

#import "Image.h"

@implementation Image

/**
 Open the device's image picker interface to allow the user to select or take a picture to use.
 @param arguments[0] success callback
 @param arguments[1] error callback
 @param options[source] source to take the picture from; one of camera, library, or saved (default: library)
 @param options[destination] where to save the picture to, file:// or http:// only
 @param options[jpegQuality] compression quality used only for JPEG destination types; between 0.0 and 1.0
 */
- (void)openImagePicker:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *imageSource = @"library";
    if ([options objectForKey:@"source"])
        imageSource = [options objectForKey:@"source"];
    
    NSNumber *successCallback;
    if ([arguments count] > 0)
        successCallback = [NSNumber numberWithInt:[[arguments objectAtIndex:0] intValue]];
    else
        successCallback = [NSNumber numberWithInt:0];
    
    NSNumber *errorCallback;
    if ([arguments count] > 1)
        errorCallback = [NSNumber numberWithInt:[[arguments objectAtIndex:1] intValue]];
    else
        errorCallback = [NSNumber numberWithInt:0];

    if ([imageSource isEqualToString:@"camera"] && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self fireCallback:[errorCallback intValue]
             withArguments:[NSArray arrayWithObject:@"Device does not support the \"camera\" source"]];
        return;
    }
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    if ([imageSource isEqualToString:@"camera"])
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else if ([imageSource isEqualToString:@"library"])
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    else if ([imageSource isEqualToString:@"saved"])
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    else {
        [self fireCallback:[errorCallback intValue]
             withArguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"Unknown image source type \"%@\" specified", imageSource]]];
        return;
    }
    picker.delegate = self;
    picker.allowsImageEditing = YES;
    
    // Picker is displayed asynchronously.
    PhoneGapDelegate *gap = (PhoneGapDelegate*)[UIApplication sharedApplication].delegate;
    PhoneGapViewController *controller = gap.viewController;
    [controller presentModalViewController:picker animated:YES];
    
    imagePickerOptions = [[NSMutableDictionary dictionaryWithCapacity:5] retain];
    [imagePickerOptions setObject:successCallback forKey:@"successCallback"];
    [imagePickerOptions setObject:errorCallback forKey:@"errorCallback"];
    
    /**
     imageQuality - Floating-point value between 0.0 and 1.0 indicating the compression quality you want
     */
    NSNumber *quality = [NSNumber numberWithFloat:[[options objectForKey:@"jpegQuality"] floatValue]];
    if (quality && [quality floatValue] >= 0.0f && [quality floatValue] <= 1.0f)
        [imagePickerOptions setValue:quality forKey:@"jpegQuality"];
    else
        [imagePickerOptions setValue:[NSNumber numberWithFloat:0.75f] forKey:@"jpegQuality"];
    
    /**
     destination - Destination URL (http://someserver/image.jpg or file:///image.jpg) to save the image to. 
     */
    NSString *destURL = [options objectForKey:@"destination"];
    [imagePickerOptions setValue:destURL forKey:@"destination"];
}


- (void)imagePickerController:(UIImagePickerController *)thePicker didFinishPickingImage:(UIImage *)theImage editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"Picked photo %@", theImage);
    [[thePicker parentViewController] dismissModalViewControllerAnimated:YES];

    NSLog(@"photo: picked image");
    NSInteger successCallback = [[imagePickerOptions objectForKey:@"successCallback"] integerValue];
    NSInteger errorCallback = [[imagePickerOptions objectForKey:@"errorCallback"] integerValue];

    NSString *urlString = [imagePickerOptions objectForKey:@"destination"];
	NSData *imageData;
    if ([[[urlString pathExtension] lowercaseString] isEqualToString:@"png"])
        imageData = UIImagePNGRepresentation(theImage);
    else
        imageData = UIImageJPEGRepresentation(theImage, [(NSNumber*)[imagePickerOptions objectForKey:@"jpegQuality"] floatValue]);
	
    NSURL *saveUrl = [NSURL URLWithString:urlString];
    if ([saveUrl isFileURL]) {
        if ([[saveUrl path] length] < 1) {
            NSLog(@"File URL didn't have a path to it; are you sure you used file:///foo.ext?");
            [self fireCallback:errorCallback
                 withArguments:[NSArray arrayWithObjects:@"Could not find the filename in the supplied file URL", urlString, nil]];
            return;
        }
        NSString *filePath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], [saveUrl path]];
        NSLog(@"File path: %@", filePath);
        BOOL result = [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
        if (result) {
            NSLog(@"Saved %@ successfully", filePath);
            [self fireCallback:successCallback
                 withArguments:[NSArray arrayWithObjects:urlString, [saveUrl path], nil]];
        } else {
            NSLog(@"Couldn't save %@", filePath);
            [self fireCallback:errorCallback
                 withArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"Could not save the file to \"%@\"", filePath], urlString, nil]];
        }
        [imagePickerOptions release];
        return;
    }
    
    /*
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	// ---------
	//Add the header info
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add data field and file data
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"photo_0\"; filename=\"photo\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[NSData dataWithData:imageData]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// ---------
	[request setHTTPBody:postBody];
	
	//NSURLConnection *
	conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if(conn) {    
		receivedData=[[NSMutableData data] retain];
		NSString *sourceSt = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
		NSLog([@"photo: connection sucess" stringByAppendingString:sourceSt]);
		
	} else {
		NSLog(@"photo: upload failed!");
	}
	
	[[thePicker parentViewController] dismissModalViewControllerAnimated:YES];
	
	webView.hidden = NO;
	[window bringSubviewToFront:webView];
*/	
    [imagePickerOptions release];
    return;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)thePicker
{
    NSInteger successCallback = [[imagePickerOptions objectForKey:@"successCallback"] integerValue];
    NSInteger errorCallback = [[imagePickerOptions objectForKey:@"errorCallback"] integerValue];

    NSLog(@"Cancelled photo picker");
    [[thePicker parentViewController] dismissModalViewControllerAnimated:YES];
    [self fireCallback:errorCallback
         withArguments:[NSArray arrayWithObjects:@"The user clicked cancel", [imagePickerOptions objectForKey:@"destination"]]];
    [imagePickerOptions release];
    
//    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"

/*
	// Dismiss the image selection and close the program
	[[thePicker parentViewController] dismissModalViewControllerAnimated:YES];
	
	//added by urbian - the webapp should know when the user canceled
	NSString * jsCallBack = nil;
	
	jsCallBack = [[NSString alloc] initWithFormat:@"gotPhoto('CANCEL');", lastUploadedPhoto];
	[webView stringByEvaluatingJavaScriptFromString:jsCallBack];  
	[jsCallBack release];
	
	// Hide the imagePicker and bring the web page back into focus
	NSLog(@"Photo Cancel Request");
	webView.hidden = NO;
	[window bringSubviewToFront:webView];
 */
}


/*

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSLog(@"photo: upload finished!");
	//added by urbian.org - g.mueller
	NSString *aStr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	//upload.php should return "filename=<filename>"
	NSLog(aStr);
	NSArray * parts = [aStr componentsSeparatedByString:@"="];
	//set filename
	lastUploadedPhoto = (NSString *)[parts objectAtIndex:1];
	
	//now the callback: return lastUploadedPhoto
	
	NSString * jsCallBack = nil;
	
	if(lastUploadedPhoto == nil) lastUploadedPhoto = @"ERROR";
	
	jsCallBack = [[NSString alloc] initWithFormat:@"gotPhoto('%@');", lastUploadedPhoto];
	
	[webView stringByEvaluatingJavaScriptFromString:jsCallBack];
	
	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	NSLog(jsCallBack);
	
    // release the connection, and the data object
    [conn release];
    [receivedData release];
}
 */

/*
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response {
	
	//added by urbian.org
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	NSLog(@"HTTP Status Code: %i", [httpResponse statusCode]);
	
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
    NSLog(@"photo: progress");
}
*/

/*
 * Failed with Error
 */
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    NSLog([@"photo: upload failed! " stringByAppendingString:[error description]]);
//    
//}



@end
