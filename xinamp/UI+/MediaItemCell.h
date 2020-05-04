//
//  MediaItemCell.h
//  xinamp
//
//  Created by chen zhenhui on 2020/4/18.
//  Copyright © 2020 chen zhenhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MediaItemCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* artwork;
@property (strong, nonatomic) IBOutlet UILabel* title;
@property (strong, nonatomic) IBOutlet UILabel* subtitle;
@end

NS_ASSUME_NONNULL_END
