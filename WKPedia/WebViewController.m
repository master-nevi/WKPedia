//
//  ViewController.m
//
//  Copyright (c) 2015 David Robles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import "TableOfContentsViewController.h"
#import "NSString+WKPediaExtras.h"

@interface WebViewController () <UISplitViewControllerDelegate, WKScriptMessageHandler>

@property (nonatomic, readonly) WKWebView *webView;
@property (nonatomic, readonly) TableOfContentsViewController *tableOfContentsViewController;
@property (nonatomic, readwrite) IBOutlet UIBarButtonItem *contentsBarButtonItem;

@end

static void* WebViewControllerObservationContext = &WebViewControllerObservationContext;

@implementation WebViewController

- (WKWebView *)webView {
    return  (WKWebView *)self.view;
}

- (TableOfContentsViewController *)tableOfContentsViewController {
    return  (TableOfContentsViewController *)[self.splitViewController.viewControllers.firstObject topViewController];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        self.navigationItem.leftBarButtonItem = self.contentsBarButtonItem;
    }
}

- (IBAction)contentsButtonActivated:(id)sender {
    [[UIApplication sharedApplication] sendAction:self.splitViewController.displayModeButtonItem.action to:self.splitViewController.displayModeButtonItem.target from:sender forEvent:nil];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"loading" context:WebViewControllerObservationContext];
    [self.webView removeObserver:self forKeyPath:@"title" context:WebViewControllerObservationContext];
}

- (void)loadView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    [self addUserScriptsToUserContentController:configuration.userContentController];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    
    self.view = webView;
}

- (void)addUserScriptsToUserContentController:(WKUserContentController *)userContentController {
    NSString *hideTableOfContentsScriptString = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"hide" withExtension:@"js"] encoding:NSUTF8StringEncoding error:NULL];
    
    WKUserScript *hideTableOfContentsScript = [[WKUserScript alloc] initWithSource:hideTableOfContentsScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    
    [userContentController addUserScript:hideTableOfContentsScript];
    
    NSString *fetchTableOfContentsScriptString = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fetch" withExtension:@"js"] encoding:NSUTF8StringEncoding error:NULL];
    
    WKUserScript *fetchTableOfContentsScript = [[WKUserScript alloc] initWithSource:fetchTableOfContentsScriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:fetchTableOfContentsScript];
    
    [userContentController addScriptMessageHandler:self name:@"didFetchTableOfContents"];
}

#pragma mark - WKScriptMessageHandler methods

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqual:@"didFetchTableOfContents"])
        [self.tableOfContentsViewController didFinishLoadingTableOfContents:message.body];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.webView addObserver:self forKeyPath:@"loading" options:(NSKeyValueObservingOptions)0 context:WebViewControllerObservationContext];
    [self.webView addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptions)0 context:WebViewControllerObservationContext];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://en.wikipedia.org/w/index.php?title=San_Francisco&mobileaction=toggle_view_desktop"]];
    [self.webView loadRequest:request];
}

#pragma mark - External API

- (void)loadRequest:(NSURLRequest *)request {
    [self.webView loadRequest:request];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        self.title = [self.webView.title wkpedia_stringByDeletingWikipediaSnippet];
    }
}

@end
