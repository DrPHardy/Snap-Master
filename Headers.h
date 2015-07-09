@interface Manager
+(id) shared;
-(void) startTimer:(id)snap source:(int)source;
-(void) markSnapAsViewed:(id)snap;
@end

@interface Snap
-(void) setCanBeReplayed:(BOOL)canBeReplayed;
-(void) setReplayed:(BOOL)wasReplayed;
-(void) markAsViewed;
@end

@interface SCSnapSaver
+(id) shared;
-(void) saveSnapImageToSnapAlbum:(id)image completionBlock:(id)block;
@end

@interface MainViewController
-(void) presentLeftVCAnimated:(BOOL)animated;
@end

@interface SCCameraOverlayView
-(id) galleryButton;
@end

@interface SCGrowingButton
-(SEL) action;
@end

@interface PreviewViewController : UIViewController
-(id) captionManager;
-(void) loadView;
-(void) saveImage;
-(void) saveVideo;
-(void) savePressed;
-(void) saveSnap;
-(id) sendConfirmationVC;
-(void) sendPressed;
-(id) sendVC;
-(void) storyPressed;
-(id) selectRecipientsVC;
-(void) setAudioPresent:(BOOL)audioPresent;
-(void) setAudioEnabled:(BOOL)audioEnabled;
-(void) setCaptionManager:(id)captionManager;
-(void) setImage:(id)image;
-(void) setupImageFilterViewWithDrawingView;
-(void) setReplyUsername:(id)replyUsername;
-(void) setReplyParameters:(id)replyParameters;
-(void) setQuickSend:(BOOL)quickSend;
-(void) setVideoURL:(id)videoURL;
-(id) sourceImage;
-(id) swipeFilterView;
-(BOOL) quickSend;
-(id) videoURL;
-(void) xPressed;
@end

@interface SCImageSwipeFilterView
-(id) mediaSwipeView;
@end

@interface SCMediaFilterScrollView
-(id) subviewItems;
@end

@interface SCCaptionManager : NSObject
-(id) caption;
-(void) setCaption;
@end

@interface SCSendConfirmationViewController : UIViewController
-(void) sendPressed;
-(id)recipients;
-(void) setRecipients:(id)recipients;
-(void) megasnap;
-(void) saveSnap;
@end

@interface SCMediaView : UIView
-(id) imageView;
@end

@interface SCPlayerView : SCMediaView
-(id) player;
@end

@interface SCCaptionDefaultTextView
-(id) textView;
@end

@interface SCCaptionBigTextPlusView
-(id) textView;
@end