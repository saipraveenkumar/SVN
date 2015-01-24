//
//  QueryManagerModel.h
//  BharatEstates
//
//  Created by Rohit Yermalkar on 26/09/13.
//  Copyright (c) 2013 Rohit Yermalkar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

@interface QueryManagerModel : NSObject

+ (QueryManagerModel *) getQueryManagerModel;
- (BOOL) executeQuery:(NSString *)sqlQuery;
- (FMResultSet *) getResultsFromDB:(NSString*)sqlQuery;
- (BOOL) closeConnectionWithDB;
- (int) getResultsCountFromDBForQuery:(NSString *)sqlQuery;
- (FMResultSet*) getResultsFromDBForQuery:(NSString *)sqlQuery;
- (BOOL)getRecordExistsORNot:(NSString *)sqlQuery;
@end
