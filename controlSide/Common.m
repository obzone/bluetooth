//
//  Common.m
//  controlSide
//
//  Created by 邵业程 on 16/1/12.
//  Copyright © 2016年 obzone. All rights reserved.
//

#import "Common.h"

@implementation Common

@end

NSString* ConvertURL2FilePath(NSString * path){
    
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    path = [path stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    NSString * homePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    homePath = [homePath stringByAppendingString:@"/"];
    
    return [homePath stringByAppendingString:path];
    
}

UIImage* OZGetImageInDocumentByPath(NSString *path){
    
    path = ConvertURL2FilePath(path);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSLog(@"find a image in doc by path%@",path);
        
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
        
    } else {
        
        return nil;
        
    }
    
}

BOOL OZWriteImage2Document(UIImage *image, NSString *path){
    
    path = ConvertURL2FilePath(path);
    
    NSData * data = UIImageJPEGRepresentation(image, 1);
    
    NSLog(@"one image has written 2 document%@",path);
    
    return [data writeToFile:path atomically:YES];
    
}