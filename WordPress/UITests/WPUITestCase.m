#import "WPUITestCase.h"
#import <Foundation/Foundation.h>
#import "WordPressTestCredentials.h"

@implementation WPUITestCase

- (void) login
{
    [tester clearTextFromAndThenEnterText:oneStepUser intoViewWithAccessibilityIdentifier:@"Username / Email"];
    [tester clearTextFromAndThenEnterText:oneStepPassword intoViewWithAccessibilityIdentifier:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Sign In"];
    
    [tester waitForTimeInterval:3];
    
    if ([tester tryFindingViewWithAccessibilityLabel:@"Great, thanks!" error:nil]) {
        [tester tapViewWithAccessibilityLabel:@"Great, thanks!"];
    }
}

- (void) loginOther
{
    [tester clearTextFromAndThenEnterText:twoStepUser intoViewWithAccessibilityIdentifier:@"Username / Email"];
    [tester clearTextFromAndThenEnterText:twoStepPassword intoViewWithAccessibilityIdentifier:@"Password"];
    [tester tapViewWithAccessibilityLabel:@"Sign In"];
    
    [tester waitForTimeInterval:3];
    if ([tester tryFindingViewWithAccessibilityLabel:@"Great, thanks!" error:nil]) {
        [tester tapViewWithAccessibilityLabel:@"Great, thanks!"];
    }

}

- (void) logout
{
    [tester tapViewWithAccessibilityLabel:@"Me"];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"Disconnect from WordPress.com"];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"Sign Out"];
    [tester waitForTimeInterval:1];
}

- (void) logoutIfNeeded {
    if(![tester tryFindingViewWithAccessibilityIdentifier:@"Username / Email" error:nil]){
        [self logout];
    }
}


@end