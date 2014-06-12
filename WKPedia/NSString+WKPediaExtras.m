//
//  NSString+WKPediaExtras.m
//  WKPedia
//
//  Created by David Robles on 6/11/14.
//  Copyright (c) 2014 Some Company. All rights reserved.
//

#import "NSString+WKPediaExtras.h"

@implementation NSString (WKPediaExtras)

- (NSString *)wkpedia_stringByDeletingWikipediaSnippet {
    NSRange wikipediaRange = [self rangeOfString:@" - Wikipedia, the free encyclopedia" options:NSBackwardsSearch];
    if (wikipediaRange.location == NSNotFound) {
        return self;
    }
    
    return [self substringToIndex:wikipediaRange.location];
}

@end
