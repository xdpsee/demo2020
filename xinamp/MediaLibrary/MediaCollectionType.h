//
//  MediaCollectionType.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/25.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#ifndef MediaCollectionType_h
#define MediaCollectionType_h


typedef NS_ENUM(NSUInteger, MediaCollectionTypeEnum) {
    kMediaCollectionTypeIPodAllSongs = 1,
    kMediaCollectionTypeIPodArtistSongs = 2,
    kMediaCollectionTypeIPodAlbumSongs = 3,
    kMediaCollectionTypeIPodGenreSongs = 4,
    kMediaCollectionTypeIPodPlaylistSongs = 5,
    kMediaCollectionTypeLocalAllSongs = 6,
    kMediaCollectionTypeLocalArtistSongs = 7,
    kMediaCollectionTypeLocalAlbumSongs = 8,
    kMediaCollectionTypeLocalGenreSongs = 9,
    kMediaCollectionTypeLocalPlaylistSongs = 10,
    kMediaCollectionTypeLocalFolderSongs = 11
};


typedef NSUInteger RecordID;

#endif /* MediaCollectionType_h */
