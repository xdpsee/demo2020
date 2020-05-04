//
//  MediaCollection.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/25.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaItem.h"
#import "MediaPlayMode.h"
#import "MediaCollectionType.h"
#import "MediaSchema.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaCollection : NSObject

@property (readonly) MediaSchema* schema;

@property (readwrite) MediaPlayModelEnum playMode;

@property (readonly) NSInteger currMediaIndex;

@property (readonly) id<MediaItem> currMediaItem;

@property (readonly) id<MediaItem> nextMediaItem;

@property (readonly) id<MediaItem> prevMediaItem;

- (id) initWithSchema:(MediaSchema*) schema;

- (id) initWithSchema:(MediaSchema*) schema current:(NSInteger)currentIndex;

- (void) setCurrent:(NSInteger) currentIndex;

- (NSInteger) indexOf:(id<MediaItem>) mediaItem;

- (NSUInteger) count;

@end

NS_ASSUME_NONNULL_END
