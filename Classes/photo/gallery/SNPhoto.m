//
//  SNPhoto.m
//  sohunews
//
//  Created by Dan on 6/23/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPhoto.h"


@implementation SNPhoto

@synthesize photoSource = _photoSource, size = _size, index = _index, caption = title, url, serverUrl, info, link, newsId = _newsId, termId = _termId;

- (void)dealloc {
    
	TT_RELEASE_SAFELY(title);
	TT_RELEASE_SAFELY(url);
    TT_RELEASE_SAFELY(serverUrl);
	TT_RELEASE_SAFELY(info);
	TT_RELEASE_SAFELY(link);
    TT_RELEASE_SAFELY(_newsId);
    TT_RELEASE_SAFELY(_termId);
	
	[super dealloc];
}

- (void)setPhotoSource:(id<TTPhotoSource>)photoSource {
    _photoSource = photoSource;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhoto

/**
 * Gets the URL of one of the differently sized versions of the photo.
 */
- (NSString*)URLForVersion:(TTPhotoVersion)version {
	if (version == TTPhotoVersionLarge) {
		return url;
	} else if (version == TTPhotoVersionMedium) {
		return url;
	} else if (version == TTPhotoVersionSmall) {
		return url;
	} else if (version == TTPhotoVersionThumbnail) {
		return url;
	} else {
		return nil;
	}
}

- (NSString *)info {
	//return [@"" isEqualToString:info] ? ([@"" isEqualToString:title] ? NSLocalizedString(@"NoPhotoInfo", @"(暂无简介)") : title) : info;
    return [info length] > 0 ? info : @"";
}

@end
