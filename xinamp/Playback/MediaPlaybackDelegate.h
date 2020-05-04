//
// Created by chen zhenhui on 2020/4/12.
// Copyright (c) 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <gst/gst.h>

@protocol MediaPlaybackDelegate <NSObject>

- (void)playbackState:(GstState)oldState changed:(GstState)newState;

- (void)playbackProgressChanged:(int)pos duration:(int)duration;

- (void)playbackCompleted:(const char *)uri;

- (void)playbackError:(const char *)error;

@end

