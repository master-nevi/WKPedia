//
//  TableOfContentsViewController.m
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

#import "TableOfContentsViewController.h"
#import "TableOfContentsEntry.h"
#import "WebViewController.h"

@interface TableOfContentsViewController ()

@property (nonatomic, readonly) NSArray *tableOfContentsEntries;
@end

@implementation TableOfContentsViewController

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableOfContentsEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [_tableOfContentsEntries[indexPath.item] title];
    
    return cell;
}

static NSArray *makeEntries(NSArray *entries) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id entry in entries) {
        if (![entry isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        id title = entry[@"title"];
        if (![title isKindOfClass:[NSString class]]) {
            continue;
        }
        
        id urlString = entry[@"urlString"];
        if (![urlString isKindOfClass:[NSString class]]) {
            continue;
        }
        
        NSURL *URL = [NSURL URLWithString:urlString];
        if (!URL) {
            continue;
        }
        
        TableOfContentsEntry *tableOfContentsEntry = [[TableOfContentsEntry alloc] initWithTitle:title URL:URL];
        
        [array addObject:tableOfContentsEntry];
    }
    
    return array;
}

- (void)didFinishLoadingTableOfContents:(id)messageBody {
    if ([messageBody isKindOfClass:[NSArray class]]) {
        _tableOfContentsEntries = makeEntries(messageBody);
    }
    else {
        _tableOfContentsEntries = nil;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [_tableOfContentsEntries[indexPath.item] URL];
    
    WebViewController *webViewController = (WebViewController *)[self.splitViewController.viewControllers.lastObject topViewController];
    
    [webViewController loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
