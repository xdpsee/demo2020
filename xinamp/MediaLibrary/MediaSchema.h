//
//  MediaSchema.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/25.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MediaCollectionType.h"
#import "MediaItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaSchema : NSObject

+ (MediaSchema*) forIPodAllSongs;

+ (MediaSchema*) forIPodArtistSongs:(MPMediaEntityPersistentID) artistPersistentID;

+ (MediaSchema*) forIPodAlbumSongs:(MPMediaEntityPersistentID) albumPersistentID;

+ (MediaSchema*) forIPodGenreSongs:(MPMediaEntityPersistentID) genrePersistentID;

+ (MediaSchema*) forIPodPlaylistSongs:(MPMediaEntityPersistentID) playlistPersistentID;

+ (MediaSchema*) forLocalAllSongs;

+ (MediaSchema*) forLocalArtistSongs:(RecordID) artistRecordID;

+ (MediaSchema*) forLocalAlbumSongs:(RecordID) albumRecordID;

+ (MediaSchema*) forLocalGenreSongs:(RecordID) genreRecordID;

+ (MediaSchema*) forLocalPlaylistSongs:(RecordID) playlistRecordID;

+ (MediaSchema*) forLocalFolderSongs:(RecordID) folderRecordID;

- (BOOL) isEqual:(id)object;

- (NSArray<id<MediaItem>>*) loadMediaItems;

@end

NS_ASSUME_NONNULL_END
