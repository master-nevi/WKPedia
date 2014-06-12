//
//  TableOfContentsEntry.h
//  WKPedia
//
//  Created by David Robles on 6/11/14.
//  Copyright (c) 2014 Some Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableOfContentsEntry : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSURL *URL;

- (instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL;

@end
