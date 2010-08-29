#import "KBrowserWindowController.h"
#import "KAppDelegate.h"
#import "KBrowser.h"
#import "KTabContents.h"
#import <ChromiumTabs/common.h>

@implementation KBrowserWindowController

// We forward windowDid{Become,Resign}Main to our browser instance so it can
// help the KBrowser class to keep track of the current "main" browser.
- (void)windowDidBecomeMain:(NSNotification*)notification {
  [super windowDidBecomeMain:notification];
  [(KBrowser*)browser_ windowDidBecomeMain:notification];
}

- (void)windowDidResignMain:(NSNotification*)notification {
  [super windowDidResignMain:notification];
  [(KBrowser*)browser_ windowDidResignMain:notification];
}


#pragma mark -
#pragma mark Proxy for selected tab

// Since we become firstResponder, we need to forward objc invocations to the
// currently selected tab (if any), following the NSDocument architecture.

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  NSMethodSignature* sig = [super methodSignatureForSelector:selector];
	if (!sig) {
    KTabContents* tab = (KTabContents*)[browser_ selectedTabContents];
    if (tab)
      sig = [tab methodSignatureForSelector:selector];
  }
  return sig;
}

- (BOOL)respondsToSelector:(SEL)selector {
	BOOL y = [super respondsToSelector:selector];
  if (!y) {
    KTabContents* tab = (KTabContents*)[browser_ selectedTabContents];
    y = !!tab && [tab respondsToSelector:selector];
  }
  return y;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  SEL selector = [invocation selector];
  KTabContents* tab = (KTabContents*)[browser_ selectedTabContents];
  if (tab && [tab respondsToSelector:selector])
    [invocation invokeWithTarget:tab];
  else
    [self doesNotRecognizeSelector:selector];
}


@end
