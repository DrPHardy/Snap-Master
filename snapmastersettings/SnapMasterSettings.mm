#import <Foundation/NSTask.h>
#import <Preferences/Preferences.h>

static void killSnapchat()
{
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/killall";
	task.arguments = [NSArray arrayWithObjects: @"-9", @"Snapchat", nil];
	[task launch];
}

static void savePreferences(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) 
{
	CFStringRef appID = CFSTR("com.drp.snapmaster");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		NSLog(@"There's been an error getting the key list!");
		return;
	}
	NSDictionary *prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!prefs) {
		NSLog(@"There's been an error getting the preferences dictionary!");
	}
	CFRelease(keyList);

	// Update the prefs file
	[prefs writeToFile:@"/var/mobile/Library/Preferences/com.drp.snapmaster.plist" atomically:YES];

	// Restart Snapchat
	killSnapchat();
}

@interface SnapMasterSettingsListController: PSListController {
}
@end

@implementation SnapMasterSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SnapMasterSettings" target:self] retain];
	}
	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated 
{
	// Register to listen for Notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)savePreferences,
        CFSTR("com.drp.snapmaster/preferences.changed"),
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
}

-(void) donate
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=9929QRU69AXKA&lc=US&item_name=DrP&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"]];
}
@end

// vim:ft=objc
