#import <Foundation/Foundation.h>
#import <WordPress-iOS-Shared/WPStyleGuide.h>

@interface WPStyleGuide (Posts)

+ (UIColor *)postListSearchBarTextColor;

+ (void)applyPostAuthorFilterStyle:(UISegmentedControl *)segmentControl;

+ (void)applyPostCardStyle:(UITableViewCell *)cell;

+ (void)applyPostAuthorSiteStyle:(UILabel *)label;

+ (void)applyPostAuthorNameStyle:(UILabel *)label;

+ (void)applyPostTitleStyle:(UILabel *)label;

+ (void)applyPostSnippetStyle:(UILabel *)label;

+ (void)applyPostDateStyle:(UILabel *)label;

+ (void)applyPostStatusStyle:(UILabel *)label;

+ (void)applyPostMetaButtonStyle:(UIButton *)button;



+ (NSDictionary *)postCardAuthorSiteAttributes;

+ (NSDictionary *)postCardAuthorNameAttributes;

+ (NSDictionary *)postCardTitleAttributes;

+ (NSDictionary *)postCardSnippetAttributes;

+ (NSDictionary *)postCardDateAttributes;

+ (NSDictionary *)postCardStatusAttributes;

@end