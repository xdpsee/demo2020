//
//  MediaPlayback.h
//  xinamp
//
//  Created by chen zhenhui on 2020/5/3.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaPlaybackDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaPlayback : NSObject

@property(nonatomic) id <MediaPlaybackDelegate> delegate;

@property(nonatomic, readonly) const char *uri;

@property(atomic, readwrite) BOOL loop;

- (id)initWithUri:(const char *)uri delegate:(id <MediaPlaybackDelegate>)delegate start:(BOOL)start;

- (void)play;

- (void)pause;

- (void)setPosition:(NSInteger)milliseconds;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
