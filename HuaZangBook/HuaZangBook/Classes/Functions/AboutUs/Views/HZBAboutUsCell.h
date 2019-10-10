//
//  HZBAboutUsCell.h
//  HuaZangBook
//
//  Created by BIN on 2019/8/29.
//  Copyright © 2019 Neusoft. All rights reserved.
//

#import "HZBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HZBAboutUsCell : HZBaseTableViewCell
@property (nonatomic, strong) RACSignal * URLSignal;
@property (nonatomic, strong) RACSignal * emailSignal;
@end

NS_ASSUME_NONNULL_END
