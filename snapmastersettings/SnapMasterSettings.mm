#import <Preferences/Preferences.h>

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

-(void) killSnapchat
{
	system("/usr/bin/killall Snapchat");
}

-(void) donate
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=9929QRU69AXKA&lc=US&item_name=DrP&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"]];
}
@end

// vim:ft=objc
