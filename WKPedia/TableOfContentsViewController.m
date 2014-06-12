//
//  TableOfContentsViewController.m
//  WKPedia
//
//  Created by David Robles on 6/11/14.
//  Copyright (c) 2014 Some Company. All rights reserved.
//

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
