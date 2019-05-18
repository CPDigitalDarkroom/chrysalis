#import "TBCSAppSwitcherManager.h"
#import "TBCSDisplayItem.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <version.h>

@interface SBDisplayItem : NSObject {
	NSString *_displayIdentifier;
}

+ (instancetype)displayItemWithType:(NSString *)type displayIdentifier:(NSString *)identifier;

@end

@interface SBAppSwitcherModel : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)mainSwitcherDisplayItems;

- (NSArray *)mainSwitcherAppLayouts;

- (void)remove:(SBDisplayItem *)displayItem;

@end

@interface SBAppLayout : NSObject

- (SBDisplayItem *)itemForLayoutRole:(long long)arg1;

@end


@implementation TBCSAppSwitcherManager

+ (NSMutableArray <TBCSDisplayItem *> *)displayItems {
	
	NSMutableArray <TBCSDisplayItem *> *displayItems = [NSMutableArray array];

	if(IS_IOS_OR_NEWER(iOS_11_0)) {
		NSArray <SBAppLayout *> *appLayouts = ((SBAppSwitcherModel *)[%c(SBAppSwitcherModel) sharedInstance]).mainSwitcherAppLayouts;
		
		for (SBAppLayout *appLayout in appLayouts) {
			SBDisplayItem *displayItem = [appLayout itemForLayoutRole:1];
			[displayItems addObject:[TBCSDisplayItem displayItemWithSBDisplayItem:displayItem]];
		}
	} else {
		NSArray <SBDisplayItem *> *sbDisplayItems = ((SBAppSwitcherModel *)[%c(SBAppSwitcherModel) sharedInstance]).mainSwitcherDisplayItems;

		for (SBDisplayItem *displayItem in sbDisplayItems) {
			[displayItems addObject:[TBCSDisplayItem displayItemWithSBDisplayItem:displayItem]];
		}
	}

	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];

	// if we’re in an app, it’ll be at position 0. remove it
	if (app._accessibilityFrontMostApplication) {
		[displayItems removeObjectAtIndex:0];
	}

	return displayItems;
}

+ (void)quitAllApps {
	for (TBCSDisplayItem *displayItem in self.displayItems) {
		[[%c(SBAppSwitcherModel) sharedInstance] remove:displayItem.sbDisplayItem];
	}
}

+ (void)suspend {
	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	SBApplication *frontmostApp = app._accessibilityFrontMostApplication;

	if (frontmostApp) {
		[[%c(SBApplicationController) sharedInstance] applicationService:nil suspendApplicationWithBundleIdentifier:frontmostApp.bundleIdentifier];
	}
}

@end
