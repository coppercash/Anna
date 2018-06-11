//
//  ANAUICollectionView.m
//  Anna_iOS
//
//  Created by William on 2018/6/5.
//

#import "ANAUICollectionView.h"
#import <Anna/Anna-Swift.h>

@implementation ANAUICollectionView

- (void)reloadData
{
    [(UICollectionView *)self ana_reloadData];
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd);
}

- (void)reloadSections:(NSIndexSet *)sections
{
    [(UICollectionView *)self ana_reloadSections:sections];
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL, NSIndexSet *))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd, sections);
}

@end
