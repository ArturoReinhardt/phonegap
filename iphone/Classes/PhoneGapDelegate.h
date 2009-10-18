#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UINavigationController.h>
#import "JSON.h"

#import "Location.h"
#import "Device.h"

@class InvokedUrlCommand;
@class PhoneGapViewController;

@interface PhoneGapDelegate : NSObject <
    UIApplicationDelegate, 
    UIWebViewDelegate, 
    UIAccelerometerDelegate,
    UINavigationControllerDelegate
  >
{
	
	IBOutlet UIWindow *window;
	IBOutlet UIWebView *webView;
	IBOutlet PhoneGapViewController *viewController;
	
	IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activityView;

	NSURLConnection *conn;				// added by urbian
	NSMutableData *receivedData;		// added by urbian	

    UIInterfaceOrientation orientationType;
    NSDictionary *settings;
    NSMutableDictionary *commandObjects;
    NSURL *invokedURL;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) PhoneGapViewController *viewController;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableDictionary *commandObjects;
@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) NSURL *invokedURL;

- (id) getCommandInstance:(NSString*)className;
- (BOOL) hasCommandInstance:(NSString*)className;
- (void) javascriptAlert:(NSString*)text;
- (BOOL) execute:(InvokedUrlCommand*)command;
- (NSString*) appURLScheme;

+ (NSDictionary*)getBundlePlist:(NSString *)plistName;

@end
