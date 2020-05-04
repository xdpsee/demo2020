//
//  FileMediaItem.m
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import "FileMediaItem.h"

@interface FileMediaItem () {
    NSString *_uri;
    NSString *_title;
    NSString *_artist;
    NSString *_album;
    NSTimeInterval _duration;
}
@end

@implementation FileMediaItem

#pragma mark -- Instance Methods

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        self->_uri = [@"file://" stringByAppendingString:path];
    }

    return self;
}

- (void)dealloc {
    _uri = nil;
    _title = nil;
    _artist = nil;
    _album = nil;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setArtistTitle:(NSString *)artistTitle {
    _artist = artistTitle;
}

- (void)setAlbumTitle:(NSString *)albumTitle {
    _album = albumTitle;
}

- (void)setDuration:(NSTimeInterval)durationSeconds {
    _duration = durationSeconds;
}

#pragma mark -- MediaItem Protocol

- (MediaSourceEnum)source {
    return kMediaSourceLocal;
}

- (NSString *)uri {
    return _uri;
}

- (NSString *)title {
    return _title;
}

- (NSString *)albumTitle {
    return _album;
}

- (NSString *)artistTitle {
    return _artist;
}

- (NSTimeInterval)durationSeconds {
    return _duration;
}


@end
