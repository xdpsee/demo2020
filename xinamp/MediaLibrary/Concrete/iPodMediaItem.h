//
//  iPodMediaItem.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "../MediaItem.h"

@interface iPodMediaItem : NSObject<MediaItem>

- (id) initWith:(MPMediaItem*) item;

@end

