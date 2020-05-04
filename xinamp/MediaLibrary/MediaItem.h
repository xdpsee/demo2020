//
//  MediaItem.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaSource.h"

@protocol MediaItem <NSObject>

- (MediaSourceEnum)source;

- (NSString *)uri;

- (NSString *)title;

- (NSString *)albumTitle;

- (NSString *)artistTitle;

- (NSTimeInterval)durationSeconds;

@end

