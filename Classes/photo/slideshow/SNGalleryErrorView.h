//
//  SNGalleryErrorView.h
//  sohunews
//
//  Created by qi pei on 4/23/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//


#import "SNEmptyView.h"

@protocol SNGalleryErrorViewDelegate <NSObject>

-(void)reloadForError;

@end

@interface SNGalleryErrorView : SNEmptyView {
    id<SNGalleryErrorViewDelegate> errorDelegate;
}

@property (assign) id errorDelegate;

@end
