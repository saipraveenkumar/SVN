//
//  AddCommentModel.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 16/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "AddCommentModel.h"
#import "StringID.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define ADD_COMMENT_URL @"AgregarComentarioBlog?alias=%@&contrasenia=%@&idBlog=%@&idCoPropietario=%@&comentario=%@"

static AddCommentModel *sAddCommentModel = nil;


@implementation AddCommentModel




+ (AddCommentModel *)getAddCommentModel{

    @synchronized(self)
    {
        if(sAddCommentModel == nil)
        {
            sAddCommentModel = [[AddCommentModel alloc] init];
        }
        return sAddCommentModel;
    }

}
- (BOOL)callAddCommentWebservice:(AddCommentParam *)param{

    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    

    
    
    NSString *lLoginParams = [NSString stringWithFormat:ADD_COMMENT_URL,param.userName,param.userPassword,param.blogId,param.coPropId,param.userComments];
    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    NSLog(@"Add Comment: %@",lServiceURL1);
    
    mRecoveryConnection = [[Connection alloc] initWithURL: lURL];
    [mRecoveryConnection addJSONHeader];
    
    [mRecoveryConnection setOwner:self];
    [mRecoveryConnection ConnectionStart];
    
    return lResult;

}

- (void)resetConnection{
    if(mRecoveryConnection != nil)
    {
        [mRecoveryConnection setOwner:nil];
        mRecoveryConnection = nil;
    }
}

- (void)resetData{
}


#pragma mark -
#pragma mark - ConnectionDelegate Method

- (void)ConnectionFinished:(Connection *)connetion{
    if([connetion isEqual: mRecoveryConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_COMMENTS_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mRecoveryConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_COMMENTS_FAILED object:self];
        [self resetConnection];
    }
    
}
- (void)parseResultFromConnection:(Connection *)connection{
    
    NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
    lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
    lResponseBody = [lResponseBody substringFromIndex:1];
    NSData* data = [lResponseBody dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Response: %@",lResponseBody);
    
    NSError *error;
    NSDictionary *lJSONArray = [NSJSONSerialization
                                JSONObjectWithData:data
                                options:kNilOptions
                                error:&error];
    
    NSString *lMessage = lJSONArray[@"Mensaje"];
    NSLog(@"Message: %@",lMessage);
    
}

@end



@implementation AddCommentParam

@synthesize blogId = mBlogId;
@synthesize coPropId = mCoPropId;
@synthesize userComments = mUserComments;
@synthesize userName = mUserName;
@synthesize userPassword = mUserPassword;

@end