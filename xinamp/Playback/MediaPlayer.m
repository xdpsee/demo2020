//
//  MediaPlayer.m
//  xinamp
//
//  Created by chen zhenhui on 2020/4/25.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import "MediaPlayer.h"
#import "MediaPlaybackDelegate.h"
#import "MediaPlayback.h"
#import "MediaNotification.h"

@interface MediaPlayer () <MediaPlaybackDelegate> {

    MediaPlayback *_plaback;
    MediaCollection *_mediaCollection;
}
- (id)init;

@end

@implementation MediaPlayer
IMPLEMENT_SINGLETON(MediaPlayer)

- (void)touch {
    NSLog(@"MediaPlayer instance");
}


- (id)init {
    self = [super init];

    return self;
}

- (void)dealloc {
    self->_plaback = nil;
    self->_mediaCollection = nil;
}

- (MediaPlayModelEnum)playMode {
    if (self->_mediaCollection) {
        [self->_mediaCollection playMode];
    }

    return kMediaPlayModeNone;
}

- (void)playMediaItem:(id <MediaItem>)mediaItem {
    if (self->_mediaCollection) {
        NSInteger index = [self->_mediaCollection indexOf:mediaItem];
        if (index >= 0) {
            [self->_mediaCollection setCurrent:index];
            id <MediaItem> currMediaItem = [self->_mediaCollection currMediaItem];
            if (currMediaItem) {
                [self->_plaback stop];
                self->_plaback = [[MediaPlayback alloc] initWithUri:[currMediaItem.uri UTF8String] delegate:self start:TRUE];
            }
        }
    }
}

- (void)playMediaCollection:(MediaCollection *)mediaCollection {
    self->_mediaCollection = nil;
    self->_mediaCollection = mediaCollection;

    id <MediaItem> currMediaItem = [self->_mediaCollection currMediaItem];
    if (currMediaItem) {
        [self->_plaback stop];
        self->_plaback = [[MediaPlayback alloc] initWithUri:[currMediaItem.uri UTF8String] delegate:self start:TRUE];
    }
}

- (void)playMediaCollection:(MediaCollection *)mediaCollection index:(NSInteger)index {
    self->_mediaCollection = nil;
    self->_mediaCollection = mediaCollection;

    [self->_mediaCollection setCurrent:index];
    id <MediaItem> currMediaItem = [mediaCollection currMediaItem];
    if (currMediaItem) {
        [self->_plaback stop];
        self->_plaback = [[MediaPlayback alloc] initWithUri:[currMediaItem.uri UTF8String] delegate:self start:TRUE];
    }
}

- (void)pause {
    [self->_plaback pause];
}

- (void)play {
    [self->_plaback play];
}

- (MediaCollection *)currMediaCollection {
    return self->_mediaCollection;
}

- (id <MediaItem>)currMediaItem {
    return [self->_mediaCollection currMediaItem];
}

#pragma mark -- MediaPlaybackDelegate

- (void)playbackProgressChanged:(int)pos duration:(int)duration {

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"playback progress changed: %d - %d\n", duration, pos);
    });
}

- (void)playbackState:(GstState)oldState changed:(GstState)newState {

}

- (void)playbackCompleted:(const char *)uri {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        __block NSInteger prevIndex = self->_mediaCollection.currMediaIndex;

        [self->_plaback stop];
        self->_plaback = nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            id <MediaItem> currMediaItem = [self->_mediaCollection currMediaItem];
            id <MediaItem> mediaItem = [self->_mediaCollection nextMediaItem];
            if (mediaItem && ![currMediaItem.uri isEqual:mediaItem.uri]) {
                self->_plaback = [[MediaPlayback alloc] initWithUri:[mediaItem.uri UTF8String]
                                                           delegate:self
                                                              start:TRUE];
                NSDictionary *userInfo = @{
                        kMediaItemChangedNotificationKeyPrevIndex: [NSNumber numberWithInteger:prevIndex],
                        kMediaItemChangedNotificationKeyNextIndex: [NSNumber numberWithInteger:self->_mediaCollection.currMediaIndex]
                };
                [[NSNotificationCenter defaultCenter] postNotificationName:kMediaItemChangedNotification
                                                                    object:self
                                                                  userInfo:userInfo];
            }
        });
    });
}

- (void)playbackError:(const char *)error {

    dispatch_async(dispatch_get_main_queue(), ^{
        printf("MediaPlayback error ocurred: %s\n", error);
    });

}


@end
