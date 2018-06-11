//
//  ANAUICollectionViewCell.m
//  Anna_iOS
//
//  Created by William on 2018/5/26.
//

#import "ANAUICollectionViewCell.h"
#import <Anna/Anna-Swift.h>

@implementation ANAUICollectionViewCell

- (void)prepareForReuse
{
    [(UICollectionViewCell *)self ana_prepareAnalyzerForReuse];
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd);
}


@end
