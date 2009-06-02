#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UINavigationController.h>
#import <JSON/JSON.h>

#import "Location.h"
#import "Device.h"

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
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) PhoneGapViewController *viewController;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) NSMutableDictionary *commandObjects;
@property (nonatomic, retain) NSDictionary *settings;

-(id) getCommandInstance:(NSString*)className;
+ (NSDictionary*)getBundlePlist:(NSString *)plistName;

@end
