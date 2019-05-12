//
//  SNFmdbColumn.h
//  sohunews
//
//  Created by handy wang on 9/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNFmdbColumn : NSObject {
    
    int _cid;
    
    NSString *_name;
    
    NSString *_type;
    
    BOOL _notnull;
    
    id __weak _dflt_value;
    
    BOOL _pk;
    
}

@property(nonatomic, assign)int cid;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *type;
@property(nonatomic, assign)BOOL notnull;
@property(nonatomic, weak)id dflt_value;
@property(nonatomic, assign)BOOL pk;

@end
