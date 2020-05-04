//
//  MediaPlayer.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/25.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "MediaCollection.h"
#import "MediaPlayMode.h"
#import "MediaItem.h"
#import "MediaCollection.h"

@interface MediaPlayer : NSObject

DEFINE_SINGLETON(MediaPlayer)

- (MediaPlayModelEnum)playMode;

- (void)playMediaItem:(id <MediaItem>)mediaItem;

- (void)playMediaCollection:(MediaCollection *)mediaCollection;

- (void)playMediaCollection:(MediaCollection *)mediaCollection index:(NSInteger)index;

- (void)pause;

- (void)play;

- (MediaCollection *)currMediaCollection;

- (id <MediaItem>)currMediaItem;

- (void)touch;

@end

