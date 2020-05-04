//
//  LibraryControllerTableViewController.m
//  xinamp
//
//  Created by chen zhenhui on 2020/4/17.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import "LibraryController.h"
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"
#import "UI+/MediaItemCell.h"
#import "MediaCollection.h"
#import "MediaPlayer.h"
#import "iPodMediaItem.h"
#import "MediaSchema.h"
#import "MediaNotification.h"


@interface LibraryController () {
    NSArray<id<MediaItem>> *_mediaItems;
    MediaSchema *_mediaSchema;
}

- (void) mediaItemChangedNotified:(NSNotification*) notification;

@end

@implementation LibraryController

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMediaItemChangedNotification
                                                  object:nil];
    
    self->_mediaSchema = nil;
    self->_mediaItems = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Media Library"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MediaItemCell" bundle:nil] forCellReuseIdentifier:@"MediaItemCell"];
    self.tableView.allowsMultipleSelection = FALSE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaItemChangedNotified:)
                                                 name:kMediaItemChangedNotification
                                               object:nil];
    
    if (MPMediaLibrary.authorizationStatus != MPMediaLibraryAuthorizationStatusAuthorized) {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                self->_mediaSchema = [MediaSchema forIPodAllSongs];
                self->_mediaItems = [self->_mediaSchema loadMediaItems];
            }
        }];
    } else {
        self->_mediaSchema = [MediaSchema forIPodAllSongs];
        self->_mediaItems = [self->_mediaSchema loadMediaItems];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[self->_mediaItems count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaItemCell" forIndexPath:indexPath];
    if (nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MediaItemCell" owner:self options:nil];
        cell = (MediaItemCell *) nib[0];
    }
    
    id<MediaItem> mediaItem = self->_mediaItems[(NSUInteger) indexPath.row];
    cell.title.text = [mediaItem title];
    cell.subtitle.text = [mediaItem albumTitle];
    cell.artwork.image = [UIImage imageNamed:@"AlbumIcon"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([[[MediaPlayer sharedInstance] currMediaCollection].schema isEqual:self->_mediaSchema]) {
        id<MediaItem> selectedMediaItem = self->_mediaItems[indexPath.row];
        NSInteger index = [[[MediaPlayer sharedInstance] currMediaCollection] indexOf:selectedMediaItem];
        if (index >= 0) {
            [[MediaPlayer sharedInstance] playMediaItem:selectedMediaItem];
        }
    } else {
        MediaCollection* mediaCollection = [[MediaCollection alloc] initWithSchema:self->_mediaSchema];
        [mediaCollection setPlayMode:kMediaPlayModeLoopCollection];
        [[MediaPlayer sharedInstance] playMediaCollection:mediaCollection index:indexPath.row];
    }
}


#pragma mark -- Handle Notification

- (void) mediaItemChangedNotified:(NSNotification*) notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSNumber* nextIndex = [userInfo valueForKey:kMediaItemChangedNotificationKeyNextIndex];
    if (nextIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[nextIndex unsignedIntegerValue] inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

@end

