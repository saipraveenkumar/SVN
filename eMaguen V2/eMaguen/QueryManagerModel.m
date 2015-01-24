//
//  QueryManagerModel.m
//  BharatEstates
//
//  Created by Rohit Yermalkar on 26/09/13.
//  Copyright (c) 2013 Rohit Yermalkar. All rights reserved.
//

#import "QueryManagerModel.h"
#import "FMDatabase.h"


#define DATABASE_NAME @"eMaguen_localUsers.sqlite"

@implementation QueryManagerModel


// Singleton Object
static FMDatabase *database = nil;
static QueryManagerModel *sQueryManagerModel = nil;

#pragma mark -

+ (QueryManagerModel *)getQueryManagerModel
{
    @synchronized(self)
    {
        if(sQueryManagerModel == nil)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            NSString *dbPath = [self getDBPath];
            BOOL success = [fileManager fileExistsAtPath:dbPath];

            if(!success)
            {
                NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
                success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
            }
            
            sQueryManagerModel = [[QueryManagerModel alloc] init];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsPath = [paths objectAtIndex:0];
            NSString *path = [docsPath stringByAppendingPathComponent:DATABASE_NAME];
            NSLog(@"Path: %@",path);
            database  = [FMDatabase databaseWithPath:path];
            
            
            if (![database open]) {
                [database setTraceExecution:TRUE];
                NSLog(@"Error %@ - %d", [database lastErrorMessage], [database lastErrorCode]);
            }
            else{
                //NSLog(@"Database opened successfully...");
                //[self executeTableCreationQueries];
            }
        }
        return sQueryManagerModel;
    }
}

+ (NSString *) getDBPath
{
    NSString *dbName1 = DATABASE_NAME;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"Database Path: %@",documentsDir);
	return [documentsDir stringByAppendingPathComponent:dbName1];
}




//This function is to carry out any INSERT, UPDATE, DELETE queries.
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
- (BOOL)executeQuery:(NSString *)sqlQuery{
    //NSLog(@"Query:  %@",sqlQuery);
    BOOL res1 = [database executeUpdate:sqlQuery];
    if(!res1)
        [self showErrorMessage];
    return res1;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//Error Handling
- (void) showErrorMessage{
    NSLog(@"Error %@ - %d", [database lastErrorMessage], [database lastErrorCode]);
}


- (int) getResultsCountFromDBForQuery:(NSString *)sqlQuery{
    FMResultSet *results = [database executeQuery:sqlQuery];
    int counter = 0;
    for(int i = 0; i < [results next]; i++){
        counter++;
    }
    return counter;
}


- (FMResultSet*) getResultsFromDBForQuery:(NSString *)sqlQuery{
    FMResultSet *results = [database executeQuery:sqlQuery];
    return results;
}

- (BOOL)getRecordExistsORNot:(NSString *)sqlQuery{
//    FMResultSet *results = [database executeQuery:sqlQuery];
//    int value = [results intForColumn:@"nid"];
    return 1;
}

//This function is to fetch RESULTS from DB.
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
- (FMResultSet *) getResultsFromDB:(NSString*)sqlQuery{
    FMResultSet *results = [database executeQuery:sqlQuery];
    /*
    while([results next]) {
        
        //Following are dummy statements to retrieve values from db query.
        ///They will return null if columns or table does not exits.
    
        NSString *name = [results stringForColumn:@"name"];
        NSInteger age  = [results intForColumn:@"age"];
        
        
        
//        //Important Methods
//        - (int)columnCount;
//        
//        - (int)columnIndexForName:(NSString*)columnName;
//        - (NSString*)columnNameForIndex:(int)columnIdx;
//        
//        - (int)intForColumn:(NSString*)columnName;
//        - (int)intForColumnIndex:(int)columnIdx;
//        
//        - (long)longForColumn:(NSString*)columnName;
//        - (long)longForColumnIndex:(int)columnIdx;
//        
//        - (long long int)longLongIntForColumn:(NSString*)columnName;
//        - (long long int)longLongIntForColumnIndex:(int)columnIdx;
//        
//        - (BOOL)boolForColumn:(NSString*)columnName;
//        - (BOOL)boolForColumnIndex:(int)columnIdx;
//        
//        - (double)doubleForColumn:(NSString*)columnName;
//        - (double)doubleForColumnIndex:(int)columnIdx;
//        
//        - (NSString*)stringForColumn:(NSString*)columnName;
//        - (NSString*)stringForColumnIndex:(int)columnIdx;
//        
//        - (NSDate*)dateForColumn:(NSString*)columnName;
//        - (NSDate*)dateForColumnIndex:(int)columnIdx;
//        
//        - (NSData*)dataForColumn:(NSString*)columnName;
//        - (NSData*)dataForColumnIndex:(int)columnIdx;
//        
//        - (const unsigned char *)UTF8StringForColumnIndex:(int)columnIdx;
//        - (const unsigned char *)UTF8StringForColumnName:(NSString*)columnName;
//        
//        // returns one of NSNumber, NSString, NSData, or NSNull
//        - (id)objectForColumnName:(NSString*)columnName;
//        - (id)objectForColumnIndex:(int)columnIdx;

        
        
        NSLog(@"User: %@ - %d",name, age);
    }
     */
    return results;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



//This function is to close connection with DB, whenever required.
//This function may not be used frequently since we have a singleton class. But can be called when user want to forcefully close the connection.
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
- (BOOL)closeConnectionWithDB{
    [database close];
    return YES;
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++












@end
