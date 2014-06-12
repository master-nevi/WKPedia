//
//  TableOfContentsEntry.m
//  WKPedia
//
//  Created by David Robles on 6/11/14.
//  Copyright (c) 2014 Some Company. All rights reserved.
//

#import "TableOfContentsEntry.h"

@implementation TableOfContentsEntry

- (instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL {
    if (self = [super init]) {
        _title = title;
        _URL = URL;
    }
    
    return self;
}

@end
