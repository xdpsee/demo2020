//
//  MediaLibrary.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaLibrary : NSObject

+ (NSArray<id <MediaItem>> *)iPod;


@end

NS_ASSUME_NONNULL_END
