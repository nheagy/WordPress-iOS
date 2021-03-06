#import "JetpackService.h"
#import "AccountService.h"
#import "BlogService.h"
#import "JetpackServiceRemote.h"
#import "WordPressComOAuthClient.h"
#import "ContextManager.h"
#import "WPAccount.h"
#import "Blog.h"

@implementation JetpackService

- (void)validateAndLoginWithUsername:(NSString *)username
                            password:(NSString *)password
                     multifactorCode:(NSString *)multifactorCode
                              siteID:(NSNumber *)siteID
                             success:(void (^)(WPAccount *account))success
                             failure:(void (^)(NSError *error))failure
{
    void (^successBlock)(WPAccount *) = ^(WPAccount *account) {
        if (success) {
            [self.managedObjectContext performBlock:^{
                success(account);
            }];
        }
    };

    void (^failureBlock)(NSError *) = ^(NSError *error) {
        if (failure) {
            [self.managedObjectContext performBlock:^{
                failure(error);
            }];
        }
    };

    JetpackServiceRemote *remote = [JetpackServiceRemote new];
    [remote validateJetpackUsername:username
                           password:password
                          forSiteID:siteID
                            success:^(NSArray *blogs){
                                [self loginWithUsername:username
                                               password:password
                                        multifactorCode:multifactorCode
                                                  blogs:blogs
                                                success:successBlock
                                                failure:failureBlock];
                            }
                            failure:failureBlock];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
          multifactorCode:(NSString *)multifactorCode
                    blogs:(NSArray *)blogIDs
                  success:(void (^)(WPAccount *account))success
                  failure:(void (^)(NSError *error))failure
{
    WordPressComOAuthClient *client = [WordPressComOAuthClient client];
    [client authenticateWithUsername:username
                            password:password
                     multifactorCode:multifactorCode
                             success:^(NSString *authToken) {
                                 [self.managedObjectContext performBlock:^{
                                     AccountService *accountService = [[AccountService alloc] initWithManagedObjectContext:self.managedObjectContext];
                                     WPAccount *account = [accountService createOrUpdateAccountWithUsername:username authToken:authToken];
                                     BlogService *blogService = [[BlogService alloc] initWithManagedObjectContext:self.managedObjectContext];
                                     [self associateBlogIDs:blogIDs withJetpackAccount:account];
                                     if ([[accountService defaultWordPressComAccount] isEqual:account]) {
                                         // Note I:
                                         // Sync the blogs first, so that Update User Details doesn't fail setting the
                                         // primary blog.
                                         //
                                         // Note II:
                                         // We want this to show the user's gravatar in the Me tab
                                         // It should only matter for the default account, but feel free to take it
                                         // out of the `if` if it's needed for something else
                                         //
                                         [blogService syncBlogsForAccount:account success:^{
                                             [accountService updateUserDetailsForAccount:account success:nil failure:nil];
                                         } failure:nil];
                                     }
                                     if (success) {
                                         success(account);
                                     }
                                 }];
                             }
                             failure:failure];
}

- (void)associateBlogIDs:(NSArray *)blogIDs withJetpackAccount:(WPAccount *)account
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Blog class])];
    request.predicate = [NSPredicate predicateWithFormat:@"account = NULL AND jetpackAccount = NULL"];
    NSArray *blogs = [self.managedObjectContext executeFetchRequest:request error:nil];
    NSSet *accountBlogIDs = [NSSet setWithArray:blogIDs];
    blogs = [blogs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Blog *blog = (Blog *)evaluatedObject;
        NSNumber *jetpackBlogID = blog.jetpack.siteID;
        return jetpackBlogID && [accountBlogIDs containsObject:jetpackBlogID];
    }]];
    [account addJetpackBlogs:[NSSet setWithArray:blogs]];
}

@end