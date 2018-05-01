//
//  ANAUITableViewDelegate.m
//  Anna_iOS
//
//  Created by William on 2018/5/2.
//

#import "ANAUITableViewDelegate.h"
#import <Anna/Anna-Swift.h>
#import <objc/runtime.h>

@implementation ANAUITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    if ([superObj.super_class instancesRespondToSelector:_cmd]) {
        __auto_type const
        objc_msgSendSuperCasted =
        (
         void (*)
         (
          struct objc_super *,
          SEL,
          UITableView *,
          UITableViewCell *,
          NSIndexPath *
          )
         )objc_msgSendSuper;
        objc_msgSendSuperCasted(&superObj, _cmd, tableView, cell, indexPath);
    }

    __auto_type const
    event = @"ui-table-will-display-row";
    [cell ana_forwardRecordingEventNamed:event
                          withProperties:nil];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return
    [ANAUITableViewDelegate instancesRespondToSelector:aSelector] ||
    [super respondsToSelector:aSelector];
}

@end
