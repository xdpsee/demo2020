//
//  MediaCollection.m
//  xinamp
//
//  Created by chen zhenhui on 2020/4/25.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import "MediaCollection.h"
#import "../Utility/NSMutableArray+Shuffle.h"

@interface MediaCollection () {
    MediaSchema* _schema;
    MediaPlayModelEnum _playMode;
    /* Media Items Data */
    NSArray<id<MediaItem>> *_items;
    NSInteger _currMediaIndex;
    NSMutableArray<NSNumber*> *_shuffleRecords;
    NSMutableArray<NSNumber*> *_shuffleRemains;
}

- (void) resetShuffle;

- (void) clearShuffle;

- (NSInteger) nextShuffle;

@end

@implementation MediaCollection
@synthesize schema = _schema;
@synthesize currMediaIndex = _currMediaIndex;

- (id) initWithSchema:(MediaSchema*) schema {
    self = [super init];
    if (self) {
        self->_schema = schema;
        self->_items = [schema loadMediaItems];
        self->_shuffleRecords = [NSMutableArray new];
        self->_shuffleRemains = [NSMutableArray new];
        self->_currMediaIndex = 0;
    }
    
    return self;
}

- (id) initWithSchema:(MediaSchema*) schema current:(NSInteger)currentIndex {
    self = [super init];
    if (self) {
        self->_schema = schema;
        self->_items = [schema loadMediaItems];
        self->_shuffleRecords = [NSMutableArray new];
        self->_shuffleRemains = [NSMutableArray new];
        self->_currMediaIndex = currentIndex;
    }
    
    return self;
}

- (void) setCurrent:(NSInteger) currentIndex {
    if (self->_playMode != kMediaPlayModeShuffle
        && ![self isEmpty]
        && currentIndex >= 0
        && currentIndex < [self->_items count]) {
        self->_currMediaIndex = currentIndex;
    }
}

- (void) dealloc {
    self->_items = nil;
    self->_shuffleRecords = nil;
    self->_shuffleRemains = nil;
}

- (NSUInteger) count {
    return [self->_items count];
}

- (id<MediaItem>) currMediaItem {
    
    NSInteger size = [self->_items count];
    if (size > 0 && self->_currMediaIndex >= 0 && self->_currMediaIndex <= (size - 1)) {
        return self->_items[self->_currMediaIndex];
    }
    
    return nil;
}

- (id<MediaItem>) nextMediaItem {
    switch (self->_playMode) {
        case kMediaPlayModeNone: {
            if (self->_currMediaIndex < ([self->_items count] - 1)) {
                self->_currMediaIndex++;
                return [self currMediaItem];
            }
        }
            break;
        case kMediaPlayModeLoopCurrent: {
            return [self currMediaItem];
        }
            break;
        case kMediaPlayModeLoopCollection: {
            self->_currMediaIndex++;
            if (self->_currMediaIndex >= [self->_items count]) {
                self->_currMediaIndex = 0;
            }
            return [self currMediaItem];
        }
            break;
        case kMediaPlayModeShuffle: {
            NSInteger index = [self nextShuffle];
            if (index >= 0) {
                return self->_items[index];
            }
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (id<MediaItem>) prevMediaItem {
    switch (self->_playMode) {
        case kMediaPlayModeNone: {
            if (self->_currMediaIndex > 0) {
                self->_currMediaIndex--;
                return [self currMediaItem];
            }
        }
            break;
        case kMediaPlayModeLoopCurrent: {
            return [self currMediaItem];
        }
            break;
        case kMediaPlayModeLoopCollection: {
            self->_currMediaIndex--;
            if (self->_currMediaIndex <= 0) {
                self->_currMediaIndex = ([self->_items count] - 1);
            }
            return [self currMediaItem];
        }
            break;
        case kMediaPlayModeShuffle: {
            NSInteger index = [self nextShuffle];
            if (index >= 0) {
                return self->_items[index];
            }
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (MediaPlayModelEnum) playMode {
    
    return self->_playMode;
    
}

- (void) setPlayMode:(MediaPlayModelEnum) playMode {
    switch (self->_playMode) {
        case kMediaPlayModeNone:
        case kMediaPlayModeLoopCurrent:
        case kMediaPlayModeLoopCollection: {
            switch (playMode) {
                case kMediaPlayModeNone:
                case kMediaPlayModeLoopCurrent:
                case kMediaPlayModeLoopCollection:
                    self->_playMode = playMode;
                    break;
                case kMediaPlayModeShuffle: {
                    self->_playMode = playMode;
                    [self resetShuffle];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case kMediaPlayModeShuffle: {
            switch (playMode) {
                case kMediaPlayModeNone:
                case kMediaPlayModeLoopCurrent:
                case kMediaPlayModeLoopCollection:
                    self->_playMode = playMode;
                    [self clearShuffle];
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -- Private Methods

- (BOOL) isEmpty {
    return [self->_items count] == 0;
}

- (void) resetShuffle {
    
    [self clearShuffle];
    
    if ([self->_items count] > 0 && self->_currMediaIndex >= 0 && self->_currMediaIndex < [self->_items count]) {
        [self->_shuffleRecords addObject:[NSNumber numberWithInt:(int)self->_currMediaIndex]];
        NSMutableArray<NSNumber*> * remains = [NSMutableArray new];
        for (int i = 0; i < [self->_items count]; ++i) {
            if (i != self->_currMediaIndex) {
                [remains addObject:[NSNumber numberWithInt:i]];
            }
        }
        [remains shuffle];
        [self->_shuffleRemains addObjectsFromArray:remains];
    }
}

- (void) clearShuffle {
    
    [self->_shuffleRemains removeAllObjects];
    [self->_shuffleRecords removeAllObjects];
    
}

- (NSInteger) nextShuffle {
    
    if (self->_playMode == kMediaPlayModeShuffle) {
        NSUInteger remains = [self->_shuffleRemains count];
        if (remains > 0) {
            NSNumber* index = [self->_shuffleRemains lastObject];
            [self->_shuffleRecords addObject:index];
            [self->_shuffleRemains removeLastObject];
            return (NSInteger)[index intValue];
        }
    }
    
    return -1;
}

- (NSInteger) indexOf:(id<MediaItem>) mediaItem {
    
    NSUInteger size = [self->_items count];
    for (NSUInteger i = 0; i < size; ++i) {
        if ([self->_items[i].uri isEqualToString:mediaItem.uri]) {
            return i;
        }
    }
    
    return -1;
}

@end
