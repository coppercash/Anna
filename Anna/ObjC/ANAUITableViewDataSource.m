//
//  ANAUITableViewDataSource.m
//  Anna_iOS
//
//  Created by William on 2018/5/2.
//

#import "ANAUITableViewDataSource.h"
#import <Anna/Anna-Swift.h>

@implementation ANAUITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (UITableViewCell * (*)(struct objc_super *, SEL, UITableView *, NSIndexPath *))objc_msgSendSuper;
    __auto_type const
    cell = objc_msgSendSuperCasted(&superObj, _cmd, tableView, indexPath);

    if (!(
          [tableView conformsToProtocol:@protocol(ANAAnalyzerOwning)] &&
          [tableView.delegate conformsToProtocol:@protocol(ANAAnalyzableTableViewDelegate)]
          )) { return cell; }
    __auto_type const
    delegate = (id<ANAAnalyzableTableViewDelegate, NSObject>)tableView.delegate;
    
    // TODO: Remove the force casting to ANAAnalyzer
    __auto_type
    analyzer = (ANAAnalyzer *)[(id<ANAAnalyzerOwning>)tableView ana_analyzer];
    
    __auto_type const
    section = [delegate respondsToSelector:@selector(tableView:analyzerNameForSection:)] == NO ? nil :
    [delegate tableView:tableView
 analyzerNameForSection:indexPath.section];
    if (section) {
        analyzer = (ANAAnalyzer *)[analyzer resolvedSubAnalyzerNamed:section];
    }
    __auto_type const
    row = [delegate tableView:tableView
analyzerNameForRowAtIndexPath:indexPath];
    if (row) {
        analyzer = (ANAAnalyzer *)[analyzer resolvedSubAnalyzerNamed:row];
        if ([cell conformsToProtocol:@protocol(ANAAnalyzerHolding)]) {
            __auto_type const
            holder = (id<ANAAnalyzerHolding>)cell;
            if (holder.ana_analyzer) {
                [analyzer takePlaceOfAnalyzer:(ANAAnalyzer *)holder.ana_analyzer];
            }
            else {
                [analyzer hook:cell];
            }
            holder.ana_analyzer = analyzer;
        }
    }
    return cell;
}

@end
