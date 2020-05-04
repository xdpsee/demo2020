//
//  iPodMediaItem.m
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import "iPodMediaItem.h"

@interface iPodMediaItem () {
    MPMediaItem* _mediaItem;
}

@end

@implementation iPodMediaItem

- (id) initWith:(MPMediaItem *)mediaItem {
    
    self = [self init];
    if (self) {
        self->_mediaItem = mediaItem;
    }
    
    return self;
}

- (void) dealloc {
    self->_mediaItem = nil;
}

- (NSString *)albumTitle {
    return [self->_mediaItem albumTitle];
}

- (NSString *)artistTitle {
    return [self->_mediaItem artist];
}

- (NSTimeInterval) durationSeconds {
    return [self->_mediaItem playbackDuration];
}

- (NSString *)title {
    return [self->_mediaItem title];
}

- (MediaSourceEnum)source {
    return kMediaSourceIPod;
}

- (NSString *)uri {
    return [[self->_mediaItem assetURL] absoluteString];
}

@end
