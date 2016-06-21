#include "Headers.h"


#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.drp.snapmaster.bundle"
NSBundle *bundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];


NSDictionary *prefs = nil;

inline BOOL GetPrefBool(NSString *key) {
	@try {

		if([[prefs valueForKey:@"isEnabled"] boolValue]) return [[prefs valueForKey:key] boolValue];

		return NO;

	}@catch(NSException *) {}

	return NO;
}


id currentSnap = nil;
int currentSnapSource = 0;
BOOL allowTimer = NO;
BOOL snapShowing = NO;
BOOL snapShowingIsStory = NO;
id PVC = nil;
BOOL isFromLibrary = NO;
NSMutableDictionary *viewControllers = [NSMutableDictionary dictionary];
BOOL firstLoad = YES;
BOOL isMegaSnapRunning = NO;


%hook SCGCDTimer

	+(id) scheduleTimerWithInterval:(double)arg1 target:(id)target selector:(SEL)selector dispatchQueue:(id)arg4
	{
		NSLog(@"Target: %@\nSelector: %@", NSStringFromClass([target class]), NSStringFromSelector(selector));

		return %orig;
	}

%end


%hook SCPreviewConfiguration


	-(void) setFromPhoneGallery:(BOOL)ag1
	{
		if(GetPrefBool(@"snapSelect"))
			return %orig(NO);

		%orig;
	}


	-(void) setAudioPresentInVideo:(BOOL)arg1
	{
		if(GetPrefBool(@"snapSelect"))
			return %orig(YES);

		%orig;
	}

%end


%hook AppDelegate



	-(id) init
	{

		// Enable/Disable Snapchat Extender
		prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.drp.snapmaster.plist"];

		[viewControllers setObject:[NSNull null] forKey:@"SCFeedViewController"];
		[viewControllers setObject:[NSNull null] forKey:@"SCChatViewControllerV2"];
		[viewControllers setObject:[NSNull null] forKey:@"SCViewingStoryViewController"];

	    return %orig;

	}


	-(void) applicationWillResignActive:(id)arg1
	{

		firstLoad = YES;

		%orig;

	}

%end


%hook Manager



	// Disable Snap Timer
	-(void) startTimer:(id)snap source:(int)source
	{
		currentSnap = snap;
		currentSnapSource = source;

		if(GetPrefBool(@"disableTimer"))
		{

				if(allowTimer)
				{

					allowTimer = NO;
					return %orig;

				}

				return;

		}

		%orig;
	}



	-(void) markSnapAsViewed:(id)snap 
	{

		if(GetPrefBool(@"breakReplay"))
		{

			[snap markAsViewed];

		 	return;

		 }

		%orig;

	}


	-(void)tick:(id)tick
	{
		if(GetPrefBool(@“noExpire”)) return;
	
		%orig;
	}
		

%end


%hook MainViewController


	-(void) viewWillAppear:(BOOL)animated
	{

		%orig;

		if(GetPrefBool(@"openFeed") && firstLoad)
		{

			firstLoad = NO;

			[self presentLeftVCAnimated:NO];

		}

	}


	-(void) presentMiddleVCAnimated:(BOOL)animated
	{

		%orig;

		if(GetPrefBool(@"openFeed") && firstLoad)
		{

			firstLoad = NO;

			[self presentLeftVCAnimated:NO];

		}

	}

%end


%hook SCFeedViewController

	
	-(id) init
	{

		id o = %orig;

		[viewControllers setObject:o forKey:@"SCFeedViewController"];

		return o;

	}

	/*
		// Mark snap as viewed after release.
		-(void) touchesEndedForCellWithSnap:(id)snap
		{

			if(!GetPrefBool(@"tapClose"))
			{
				
				%orig;
			
				@try
					{

						if(GetPrefBool(@"disableTimer"))
						{

							[[%c(Manager) shared] markSnapAsViewed:snap];

							if(GetPrefBool(@"breakReplay")) [snap setCanBeReplayed:YES];

							currentSnap = nil;

						}					

					}

					@catch(NSException *){}

				}		

		}
	*/


		-(void) showSnap:(id)snap
		{
			snapShowing = YES;
			currentSnap = snap;
			%orig;
		}



		-(void) tapToSkip:(id)gesture 
		{

			NSLog(@"SCFeedViewController -> tapToSkip:");

			// BOOL saveSnapButtonPressed = NO;

			// if(GetPrefBool(@"saveSnap") && !GetPrefBool(@"autoSaveSnap") && snapShowing)
			// {

			// 	CGPoint coords = [((UITapGestureRecognizer *)gesture) locationInView:((UITapGestureRecognizer *)gesture).view];

			// 	switch([[prefs valueForKey:@"saveButtonLocation"] intValue])
			// 	{

			// 		case 0:

			// 			if(coords.x <= 50 && coords.y <= 50) saveSnapButtonPressed = YES;

			// 			break;

			// 		case 1:

			// 			if(coords.x >= ([UIScreen mainScreen].bounds.size.width - 50) && coords.y <= 50) saveSnapButtonPressed = YES;

			// 			break;

			// 		case 2:

			// 			if(coords.x <= 50 && coords.y >= ([UIScreen mainScreen].bounds.size.height - 50)) saveSnapButtonPressed = YES;

			// 			break;

			// 		default:

			// 			if(coords.x >= ([UIScreen mainScreen].bounds.size.width - 50) && coords.y >= ([UIScreen mainScreen].bounds.size.height - 50)) saveSnapButtonPressed = YES;

			// 			break;

			// 		}					

			// 	}

			// 	if(!saveSnapButtonPressed)
			// 	{

			// 		if(GetPrefBool(@"disableTimer"))
			// 		{	

			// 		@try
			// 		{
			// 			allowTimer = YES;
			// 			[[%c(Manager) shared] startTimer:currentSnap source:currentSnapSource];
			// 			currentSnap = nil;
			// 		}

			// 		@catch(NSException *){}

			// 	}	

				%orig;

			//}

		}



		// Discrete Screenshot
		-(void) userDidTakeScreenshot
		{

			if(GetPrefBool(@"disableSSNotif")) return;

			%orig;

		}

%end


%hook FeedTableViewCell


	-(void) setHideSublabel:(BOOL)hideSublabel
	{

		if(GetPrefBool(@"showSublabels")) return %orig(NO);

		%orig;

	}


	-(void) finishedDisplayingSubLabelBriefly
	{

		if(GetPrefBool(@"showSublabels")) return;

		%orig;

	}


	-(BOOL) hideSublabel
	{

		if(GetPrefBool(@"showSublabels")) return NO;

		return %orig;

	}

%end


%hook SCChatViewControllerV2

	-(id) init
	{

		id o = %orig;

		[viewControllers setObject:o forKey:@"SCChatViewControllerV2"];

		return o;

	}


	/*
		-(void) longPressEndedForCellWithSnap:(id)snap
		{

			if(!GetPrefBool(@"tapClose"))
			{

				%orig;

				@try
				{

					if(GetPrefBool(@"disableTimer"))
					{

						[[%c(Manager) shared] markSnapAsViewed:snap];
						currentSnap = nil;

						if(GetPrefBool(@"breakReplay")) [snap setCanBeReplayed:YES];

					}				

				}

				@catch(NSException *){}

			}

		}
	*/
	


	-(void) showSnap:(id)snap
	{
		snapShowing = YES;
		%orig;
	}



	-(void) tapToSkip:(id)gesture 
	{
		
		BOOL saveSnapButtonPressed = NO;

		if(GetPrefBool(@"saveSnap") && !GetPrefBool(@"autoSaveSnap") && snapShowing)
		{

			CGPoint coords = [((UITapGestureRecognizer *)gesture) locationInView:((UITapGestureRecognizer *)gesture).view];

			if(coords.x <= 50 && coords.y <= 50) saveSnapButtonPressed = YES;

		}

		if(!saveSnapButtonPressed)
		{

			if(GetPrefBool(@"disableTimer"))
			{	

				@try
				{

					if(currentSnap)
					{

						allowTimer = YES;
						[[%c(Manager) shared] startTimer:currentSnap source:currentSnapSource];
						currentSnap = nil;

					}

				}

				@catch(NSException *){}

			}	

			%orig;

		}

	}



	// Discrete Screenshot
	-(void) userDidTakeScreenshot
	{

		if(GetPrefBool(@"disableSSNotif")) return;

		%orig;

	}

%end


%hook SCViewingStoryViewController

	
	-(id) init
	{

		id o = %orig;

		[viewControllers setObject:o forKey:@"SCSViewingStoryViewController"];

		return o;

	}

	
	// Discrete Screenshot
	-(void) userDidTakeScreenshot
	{

		if(GetPrefBool(@"disableSSNotif")) return;

		%orig;

	}


	-(void) tap:(id)gesture
	{

		BOOL saveSnapButtonPressed = NO;

		if(GetPrefBool(@"saveSnap") && !GetPrefBool(@"autoSaveSnap") && snapShowing)
		{

			CGPoint coords = [((UITapGestureRecognizer *)gesture) locationInView:((UITapGestureRecognizer *)gesture).view];

			if(coords.x <= 50 && coords.y <= 50) saveSnapButtonPressed = YES;

		}

		if(!saveSnapButtonPressed) %orig;

	}


	-(void) touchesBeganForFriendStoriesCellWithIndexPath:(id)indexPath
	{

		snapShowing = YES;
		snapShowingIsStory = YES;

		%orig;

	}

%end


%hook User


	// Break the daily replay limit.
	-(void) updateCanReplaySnapsTimeWithCurrentDate:(id)rDate replayedDate:(id)cDate
	{

		if(GetPrefBool(@"breakReplay")) return %orig([NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*25.0f)], cDate);

		%orig;

	}


	// Discrete Replay
	-(void) setReplayedSnap
	{

		if(GetPrefBool(@"disableRPNotif")) return;

		%orig;

	}

%end


%hook SCCounterLabel



	// Disable timer label.
	-(id) init 
	{

		if(GetPrefBool(@"disableTimerUI")) return nil;
		
		return %orig;

	}

%end


%hook Story


	
	// Manual Story Advance
	-(void) setIsCountingDown:(BOOL)isCountingDown forViewingType:(int)viewingType
	{

		if(GetPrefBool(@"manualAdvance")) return %orig(NO, viewingType);

		%orig;

	}

%end


%hook Snap

	// Discrete Replay
	-(void)didReplay {
		if(GetPrefBool(@"disableRPNotif"))
		else %orig;
	}
	//Free Replays?
	-(bool)hasFreeReplay {
		if(GetPrefBool(@"breakReplay")) return true;
		return %orig;
	}
	-(bool)canBeReplayed {
		if(GetPrefBool(@"breakReplay")) return true;
		return %orig;
	}

%end


%hook SCHeader



	// Prepare for check all functionality.
	-(void) setDelegate:(id)delegate
	{

		if(GetPrefBool(@"checkAll"))
		{

			// Check if this is a SendViewController header.
			if([[delegate performSelector:@selector(className)] isEqualToString:@"SendViewController"])
			{

				// Give label touch action.
				((UILabel *)[self performSelector:@selector(headerLabel)]).userInteractionEnabled = YES;
			    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHeaderLabel:)];
			    [[self performSelector:@selector(headerLabel)] addGestureRecognizer:tapGesture];
			    [tapGesture release];

			}			

		}

		%orig;

	}



	%new
	-(void) didTapHeaderLabel:(UITapGestureRecognizer *)tapGesture
	{

		// Check all / Uncheck all.
		[[self performSelector:@selector(dataSource)] performSelector:@selector(checkAllFriends)];

	}

%end

// Needs Updating
%hook SCCameraOverlayView


	-(void) setStoriesButton:(id)button
	{


		if(GetPrefBool(@"snapSelect")) return [self.galleryButton setHidden:NO];

		%orig;

	}

%end


%hook SCGrowingButton

	-(void) setHidden:(BOOL)hide
	{

		if(GetPrefBool(@"snapSelect") && [NSStringFromSelector([self action]) isEqualToString:@"galleryButtonPressed"]) return %orig(NO);

		%orig;

	}

%end


%hook PreviewViewController


	-(void) setFromGallery:(BOOL)fromGallery
	{

		isFromLibrary = fromGallery;

		if(GetPrefBool(@"snapSelect")) return %orig(NO);

		%orig;

	}


	-(void) setSaveButton:(id)saveButton
	{

		if(!isMegaSnapRunning) PVC = self;

		if(GetPrefBool(@"saveAllSent")) return;

		%orig;

	}


	-(void) storyPressed
	{

		if(GetPrefBool(@"saveAllSent") && !isFromLibrary) [self saveSnap];

		%orig;

	}


	-(void) setAudioPresent:(BOOL)audioPresent 
	{

		if(GetPrefBool(@"snapSelect")) return %orig(YES);

		%orig;

	}


	%new
	-(void) saveSnap
	{

		// Save the Image or Video before creating the PreviewViewController to prevent null image or video.
		UIImage *image = [self sourceImage];
		NSString *videoPath = [[self videoURL] path];


		// Set the image and save.
		if(!videoPath)
		{

			// Empty block for callback method to prevent crash.
			void (^fillerBlock)(void) = ^{};
			[[%c(SCSnapSaver) shared] saveSnapImageToSnapAlbum:image completionBlock:fillerBlock];

		}

		// Or set the video and save.
		else
		{


			id captionManager = [self captionManager];

			// Create PreviewViewController and load snap into it.
			PreviewViewController *previewViewController = [[%c(PreviewViewController) alloc] init];
			[previewViewController loadView];

			// Load the caption.
			[previewViewController setCaptionManager:captionManager];

			// Copy the video and update the path.
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *copiedVideoPath = [videoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@"1.mp4"];
			[fileManager copyItemAtPath:videoPath toPath:copiedVideoPath error:nil];
			[fileManager release];

			[previewViewController setVideoURL:[NSURL URLWithString:copiedVideoPath]];
			[previewViewController saveVideo];

			// Clean up memory.
			[previewViewController release];

		}

	}
 
%end


%hook SendViewController


	%new
	-(void) checkAllFriends
	{
		
		// Uncheck all
		if([[[self performSelector:@selector(selectRecipientsVC)] performSelector:@selector(recipients)] count] > 0) [[self performSelector:@selector(selectRecipientsVC)] performSelector:@selector(setMutableRecipients:) withObject:[NSMutableArray array]];


		// Check all
		else [[self performSelector:@selector(selectRecipientsVC)] performSelector:@selector(setMutableRecipients:) withObject:[self performSelector:@selector(extractedFriends:) withObject:[[self performSelector:@selector(selectRecipientsVC)] performSelector:@selector(friends)]]];


		// Update view
		[[self performSelector:@selector(selectRecipientsVC)] performSelector:@selector(friendsDidChange)];
		[self performSelector:@selector(didUpdateRecipients)];
		
	}



	%new
	-(id) extractedFriends:(id)friends
	{

		NSMutableArray *extFriends = [[NSMutableArray alloc] init];

		int i;
		for(i = 0; i < [friends count]; i++)
		{

			int x;
			for(x = 0; x < [[friends objectAtIndex:i] count]; x++)
			{

				if(![extFriends containsObject:[[friends objectAtIndex:i] objectAtIndex:x]]) [extFriends addObject:[[friends objectAtIndex:i] objectAtIndex:x]];

			}

		}

		return [extFriends autorelease];

	}

%end


%hook SCSendConfirmationViewController


	-(void) sendPressed
	{

		if(GetPrefBool(@"saveAllSent") && !isFromLibrary) [self saveSnap]; // Save Snap.

		// if(GetPrefBool(@"megasnap") && [[self recipients] count] > 99) return [self megasnap];

		%orig;

	}


	%new
	-(void) saveSnap
	{

		// Save the Image or Video before creating the PreviewViewController to prevent null image or video.
		UIImage *image = [PVC sourceImage];
		NSString *videoPath = [[PVC videoURL] path];

		// Set the image and save.
		if(!videoPath)
		{

			// Empty block for callback method to prevent crash.
			void (^fillerBlock)(void) = ^{};
			[[%c(SCSnapSaver) shared] saveSnapImageToSnapAlbum:image completionBlock:fillerBlock];

		}


		// Or set the video and save.
		else
		{

			id captionManager = [PVC captionManager];


			// Create PreviewViewController and load snap into it.
			PreviewViewController *previewViewController = [[%c(PreviewViewController) alloc] init];
			[previewViewController loadView];

			// Load the caption.
			[previewViewController setCaptionManager:captionManager];

			// Copy the video and update the path.
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *copiedVideoPath = [videoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@"1.mp4"];
			[fileManager copyItemAtPath:videoPath toPath:copiedVideoPath error:nil];
			[fileManager release];

			[previewViewController setVideoURL:[NSURL URLWithString:copiedVideoPath]];
			[previewViewController saveVideo];

			// Clean up memory.
			[previewViewController release];

		}

	}


	%new
	-(void) megasnap
	{

		isMegaSnapRunning = YES;

		BOOL isImage = [PVC imageView] ? YES : NO;

		NSMutableArray *recipientsCopy = [NSMutableArray array];
		recipientsCopy = [self recipients];

		PreviewViewController *previewViewController = nil;
		
		NSMutableDictionary *replyParameters = [NSMutableDictionary dictionary];
		[replyParameters setObject:[NSNull null] forKey:@"username"];
		[replyParameters setObject:[NSNumber numberWithInt:0] forKey:@"type"];
		[replyParameters setObject:@YES forKey:@"double_tap"];

		NSString *username = nil;

		int i = 0;
		for(i = 0; i < [[self recipients] count]; i++)
		{

			username = [recipientsCopy[i] performSelector:@selector(name)];

			[replyParameters setObject:username forKey:@"username"];

			previewViewController = [[%c(PreviewViewController) alloc] init];
			[previewViewController loadView];
			[previewViewController setQuickSend:YES];
			[previewViewController setReplyUsername:username];
			[previewViewController setReplyParameters:replyParameters];
			
			if(isImage) [previewViewController setImage:[PVC sourceImage]];

			else
			{

				[previewViewController setAudioPresent:YES];
				[previewViewController setAudioEnabled:YES];
				[previewViewController setVideoURL:[PVC videoURL]];

			}

			[previewViewController setCaptionManager:[PVC captionManager]];
			[previewViewController sendPressed];

		}

		[PVC xPressed];

		isImage = NO;

		isMegaSnapRunning = NO;

	}

%end


BOOL ignoreCall = NO;

%hook SCMediaView

	
	-(void) hideMedia
	{

		snapShowing = NO;
		snapShowingIsStory = NO;

		%orig; 

	}


	-(void) setImageView:(id)imageView
	{

		%orig;
		

		if(GetPrefBool(@"saveSnap"))
		{

			// Add Save Snap Button
			UIButton *saveSnapButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[saveSnapButton addTarget:self action:@selector(saveImageSnapButtonPress:) forControlEvents:UIControlEventTouchUpInside];
			[saveSnapButton setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:GetPrefBool(@"snapButtonInverted") ? @"save_inverted" : @"save" ofType:@"png"]] forState:UIControlStateNormal];
			[saveSnapButton setHidden:YES];

			switch([[prefs valueForKey:@"saveButtonLocation"] intValue])
			{

				case 0:

					saveSnapButton.frame = CGRectMake(5, 5, 40, 40);

					break;

				case 1:

					saveSnapButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 45, 5, 40, 40);

					break;

				case 2:

					saveSnapButton.frame = CGRectMake(5, [UIScreen mainScreen].bounds.size.height - 45, 40, 40);

					break;

				default:

					saveSnapButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 45, [UIScreen mainScreen].bounds.size.height - 45, 40, 40);

					break;

			}	

			[self addSubview:saveSnapButton];		

			[self setUserInteractionEnabled:YES];

		}
		
	}


	-(void) bringSubviewToFront:(id)subview
	{
		%orig;

		if(!ignoreCall)
		{

			for(UIView *sView in self.subviews)
				{

					if([sView isKindOfClass:[UIButton class]])
					{

						ignoreCall = YES;						
						[self bringSubviewToFront:sView];

					}

				}

		}

		ignoreCall = NO;
	}


	%new
	-(void) saveImageSnapButtonPress:(id)sender
	{

		// Save the snap.

		// Empty block for callback method to prevent crash.
		void (^fillerBlock)(void) = ^{};

		[[%c(SCSnapSaver) shared] saveSnapImageToSnapAlbum:[self.imageView image] completionBlock:fillerBlock];

		[(UIButton *)sender setHidden:YES];

	}

%end


%hook UIImageView


	-(void) setImage:(id)image
	{

		%orig;

		if([[self.superview performSelector:@selector(className)] isEqualToString:@"SCMediaView"] && !CGSizeEqualToSize(((UIImage *)image).size, CGSizeMake(0,0)))
		{

			if(GetPrefBool(@"saveSnap"))
			{

				for(UIView *sView in self.superview.subviews)
				{

					if([sView isKindOfClass:[UIButton class]])
					{

						// Bring the Save Button to the front.
						[sView.superview bringSubviewToFront:sView];

						// Make it visible when appropriate.
						if((!GetPrefBool(@"autoSaveSnap") && !snapShowingIsStory) || (!GetPrefBool(@"autoSaveStories") && snapShowingIsStory))
						{ 

							// Check if the button has the right selector and correct it if it doesn't.
							if(![[[(UIButton *)sView actionsForTarget:self.superview forControlEvent:UIControlEventTouchUpInside] objectAtIndex:0] isEqualToString:@"saveImageSnapButtonPress:"])
							{

								// Remove the action.
								[(UIButton *)sView removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];

								// Add the right action.
								[(UIButton *)sView addTarget:self.superview action:@selector(saveImageSnapButtonPress:) forControlEvents:UIControlEventTouchUpInside];

							}

							// if([sView actionsForTarget:self.superview forControlEvents:UIControlEventTouchUpInside])
							[sView setHidden:NO];

						}

						else if((GetPrefBool(@"autoSaveSnap") && !snapShowingIsStory) || (GetPrefBool(@"autoSaveStories") && snapShowingIsStory)) [self.superview performSelector:@selector(saveImageSnapButtonPress:) withObject:nil];

					}

				}

			}

			else if((GetPrefBool(@"autoSaveSnap") && !snapShowingIsStory) || (GetPrefBool(@"autoSaveStories") && snapShowingIsStory)) [self.superview performSelector:@selector(saveImageSnapButtonPress:) withObject:nil];

		}

	}

%end


%hook AVPlayer

	-(void) play
	{

		%orig;

		if(snapShowing)
		{

			if(GetPrefBool(@"saveSnap"))
			{

				id playerView = [self performSelector:@selector(findSCPlayerView:) withObject:self];

				for(UIView *sView in ((UIView *)playerView).superview.subviews)
				{

					if([sView isKindOfClass:[UIButton class]])
					{

						[sView.superview bringSubviewToFront:sView];

						if((!GetPrefBool(@"autoSaveSnap") && !snapShowingIsStory) || (!GetPrefBool(@"autoSaveStories") && snapShowingIsStory))
						{ 

							// Check if the button has the right selector and correct it if it doesn't.
							if(![[[(UIButton *)sView actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] objectAtIndex:0] isEqualToString:@"saveVideoSnapButtonPress:"])
							{

								// Remove the action.
								[(UIButton *)sView removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];

								// Add the right action.
								[(UIButton *)sView addTarget:self action:@selector(saveVideoSnapButtonPress:) forControlEvents:UIControlEventTouchUpInside];

							}

							[sView setHidden:NO];

						}
						
						else if((GetPrefBool(@"autoSaveSnap") && !snapShowingIsStory) || (GetPrefBool(@"autoSaveStories") && snapShowingIsStory)) [self performSelector:@selector(saveVideoSnapButtonPress:) withObject:nil];

					}

				}

			}

			else if((GetPrefBool(@"autoSaveSnap") && !snapShowingIsStory) || (GetPrefBool(@"autoSaveStories") && snapShowingIsStory)) [self performSelector:@selector(saveVideoSnapButtonPress:) withObject:nil];

		}		

	}


	%new
	-(BOOL) saveSnapButtonIsHidden:(id)subviews
	{

		for(UIButton *saveSnapButton in subviews) 
		{

			if(saveSnapButton.isHidden) 
			{

				if((!GetPrefBool(@"autoSaveSnap") && !snapShowingIsStory) || (!GetPrefBool(@"autoSaveStories") && snapShowingIsStory)) [saveSnapButton setHidden:NO];

				return YES;

			}

		}

		return NO;

	}


	%new
	-(id) findSCPlayerView:(id)referencePlayer
	{

		id correctPlayerView = nil;
		BOOL playerViewFound = NO;

		if(![[viewControllers valueForKey:@"SCFeedViewController"] isEqual:[NSNull null]])
		{

			for(SCPlayerView *playerView in [[[viewControllers valueForKey:@"SCFeedViewController"] performSelector:@selector(mediaView)] performSelector:@selector(subviews)])
			{

				@try
				{

					if([referencePlayer isEqual:[playerView performSelector:@selector(player)]])
					{

						playerViewFound = YES;

						correctPlayerView = playerView;

						break;

					}


				} 

				@catch(NSException *){}

			}

		}


		if(![[viewControllers valueForKey:@"SCChatViewControllerV2"] isEqual:[NSNull null]] && !playerViewFound)
		{

			for(SCPlayerView *playerView in [[[viewControllers valueForKey:@"SCChatViewControllerV2"] performSelector:@selector(mediaView)] performSelector:@selector(subviews)])
			{

				@try
				{

					if([referencePlayer isEqual:[playerView performSelector:@selector(player)]])
					{

						playerViewFound = YES;

						correctPlayerView = playerView;

						break;

					}


				} @catch(NSException *){}

			}

		}

		if(![[viewControllers valueForKey:@"SCViewingStoryViewController"] isEqual:[NSNull null]] && !playerViewFound)
		{

			for(SCPlayerView *playerView in [[[viewControllers valueForKey:@"SCViewingStoryViewController"] performSelector:@selector(mediaView)] performSelector:@selector(subviews)])
			{

				@try
				{

					if([referencePlayer isEqual:[playerView performSelector:@selector(player)]])
					{

						playerViewFound = YES;

						correctPlayerView = playerView;

						break;

					}


				} @catch(NSException *){}

			}

		}

		return correctPlayerView;

	}


	%new
	-(void) saveVideoSnapButtonPress:(id)sender
	{

		[(UIButton *)sender setHidden:YES];
		
		if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([[[[self performSelector:@selector(currentItem)] performSelector:@selector(asset)] performSelector:@selector(URL)] performSelector:@selector(path)])) UISaveVideoAtPathToSavedPhotosAlbum([[[[self performSelector:@selector(currentItem)] performSelector:@selector(asset)] performSelector:@selector(URL)] performSelector:@selector(path)], nil, nil, nil);

		else
		{

			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Failed..." message:@"Sorry, this video is not supported." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		    [alert show];
		    [alert release];

		}

	}

%end 


%hook SCCaptionDefaultTextView


	-(BOOL) textView:(id)textView shouldChangeTextInRange:(_NSRange)range replacementText:(id)text 
	{

		if(GetPrefBool(@"moreText")) return YES;

		return %orig;

	}


	-(void) trimTextViewTextIfNecessary
	{

		if(GetPrefBool(@"moreText")) return;

		%orig;

	}


	-(void)initializeViews
	{

		%orig;

		if(GetPrefBool(@"moreText")) ((UITextView *)self.textView).returnKeyType = UIReturnKeyDefault;

	}

%end


%hook SCCaptionBigTextPlusView


	-(BOOL) textView:(id)textView shouldChangeTextInRange:(_NSRange)range replacementText:(id)text 
	{

		if(GetPrefBool(@"moreText")) return YES;

		return %orig;

	}


	-(void)initializeViewsWithSuperviewBounds:(CGRect)superviewBounds
	{

		%orig;

		if(GetPrefBool(@"moreText")) ((UITextView *)self.textView).returnKeyType = UIReturnKeyDefault;

	}

%end


%hook UIImagePickerController


	-(void) viewWillAppear:(BOOL)animated
	{
		
		%orig;		

		if(GetPrefBool(@"snapSelect")) [self setMediaTypes:[[NSArray alloc] initWithObjects: @"public.image", @"public.movie", nil]];	

	}

%end
