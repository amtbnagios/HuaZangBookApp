//
//  HZBHomeCollectionCell.h
//  HuaZangBook
//
//  Created by BIN on 2019/8/30.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HZBHomeCollectionCell : UICollectionViewCell
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * imageURLString;
@property (nonatomic, assign) BOOL isEmpty;
@end

NS_ASSUME_NONNULL_END
