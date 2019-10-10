//
//  HZBBookListBookCell.h
//  HuaZangBook
//
//  Created by BIN on 2019/8/30.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZBBookListBookCell : HZBaseTableViewCell
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * desc;
@property (nonatomic, strong) NSString * imageURLString;
@end

NS_ASSUME_NONNULL_END
