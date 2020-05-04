//
//  FileMediaItem.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaItem.h"

@interface FileMediaItem : NSObject <MediaItem>

- (id)initWithPath:(NSString *)path;

- (void)setTitle:(NSString *)title;

- (void)setArtistTitle:(NSString *)artistTitle;

- (void)setAlbumTitle:(NSString *)albumTitle;

- (void)setDuration:(NSTimeInterval)durationSeconds;

@end

