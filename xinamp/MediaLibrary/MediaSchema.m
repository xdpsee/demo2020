//
//  MediaSchema.m
//  xinamp
//
//  Created by chen zhenhui on 2020/4/25.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import "MediaSchema.h"
#import "iPodMediaItem.h"

@interface MediaSchema () {
    MediaCollectionTypeEnum _type;
    MPMediaEntityPersistentID _persistentId;
    RecordID _recordId;
}

- (id) init;

@end

@implementation MediaSchema

+ (MediaSchema*) forIPodAllSongs {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeIPodAllSongs;
    }
    
    return schema;
}

+ (MediaSchema*) forIPodArtistSongs:(MPMediaEntityPersistentID) artistPersistentID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeIPodArtistSongs;
        schema->_persistentId = artistPersistentID;
    }
    
    return schema;
}

+ (MediaSchema*) forIPodAlbumSongs:(MPMediaEntityPersistentID) albumPersistentID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeIPodAlbumSongs;
        schema->_persistentId = albumPersistentID;
    }
    
    return schema;
}

+ (MediaSchema*) forIPodGenreSongs:(MPMediaEntityPersistentID) genrePersistentID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeIPodGenreSongs;
        schema->_persistentId = genrePersistentID;
    }
    
    return schema;
}

+ (MediaSchema*) forIPodPlaylistSongs:(MPMediaEntityPersistentID) playlistPersistentID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeIPodPlaylistSongs;
        schema->_persistentId = playlistPersistentID;
    }
    
    return schema;
}

+ (MediaSchema*) forLocalAllSongs {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeLocalAllSongs;
    }
    
    return schema;
}

+ (MediaSchema*) forLocalArtistSongs:(RecordID) artistRecordID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeLocalArtistSongs;
        schema->_recordId = artistRecordID;
    }
    
    return schema;
}

+ (MediaSchema*) forLocalAlbumSongs:(RecordID) albumRecordID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeLocalAlbumSongs;
        schema->_recordId = albumRecordID;
    }
    
    return schema;
}

+ (MediaSchema*) forLocalGenreSongs:(RecordID) genreRecordID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeLocalGenreSongs;
        schema->_recordId = genreRecordID;
    }
    
    return schema;
}

+ (MediaSchema*) forLocalPlaylistSongs:(RecordID) playlistRecordID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeLocalPlaylistSongs;
        schema->_recordId = playlistRecordID;
    }
    
    return schema;
}

+ (MediaSchema*) forLocalFolderSongs:(RecordID) folderRecordID {
    MediaSchema* schema = [MediaSchema new];
    if (schema) {
        schema->_type = kMediaCollectionTypeLocalFolderSongs;
        schema->_recordId = folderRecordID;
    }
    
    return schema;
}

- (NSArray<id<MediaItem>>*) loadMediaItems {
    switch (self->_type) {
        case kMediaCollectionTypeIPodAllSongs: {
            NSArray<MPMediaItem*> *mediaItems = [[MPMediaQuery songsQuery] items];
            NSMutableArray<id<MediaItem>>* result = [NSMutableArray new];
            for (int i = 0; i < [mediaItems count]; ++i) {
                iPodMediaItem* item = [[iPodMediaItem alloc] initWith:mediaItems[i]];
                [result addObject:item];
            }
            return result;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

#pragma mark -- Equals
- (BOOL) isEqual:(id)object {
    
    if ([object isKindOfClass:MediaSchema.class]) {
        MediaSchema* that = (MediaSchema*)object;
        return self->_type == that->_type && self->_persistentId == that->_persistentId && self->_recordId == that->_recordId;
    }
    
    return FALSE;
}

#pragma mark -- Private Methods

- (id) init {
    self = [super init];
    if (self) {
        self->_persistentId = 0L;
        self->_recordId = 0L;
    }
    return self;
}

@end
