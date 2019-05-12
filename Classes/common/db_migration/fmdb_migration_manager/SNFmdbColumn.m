//
//  SNFmdbColumn.m
//  sohunews
//
//  Created by handy wang on 9/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNFmdbColumn.h"

@implementation SNFmdbColumn

@synthesize cid = _cid;
@synthesize name = _name;
@synthesize type = _type;
@synthesize notnull = _notnull;
@synthesize dflt_value = _dflt_value;
@synthesize pk = _pk;

- (NSString *)description {

    NSMutableString *_descString = [NSMutableString string];
    
    [_descString appendFormat:@"cid:%d", _cid];
    
    [_descString appendFormat:@", name:%@", _name];
    
    [_descString appendFormat:@", type:%@", _type];
    
    [_descString appendFormat:@", notnull:%d", _notnull];
    
    [_descString appendFormat:@", defaultValue:%@", _dflt_value];
    
    [_descString appendFormat:@", primaryKey:%d", _pk];
    
    return _descString;

}

- (void)dealloc {
    
     //(_name);
    
     //(_type);


}

@end
