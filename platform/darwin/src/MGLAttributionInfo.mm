#import "MGLAttributionInfo.h"
#import "NSString+MGLAdditions.h"

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#else
    #import <Cocoa/Cocoa.h>
#endif

#include <string>

/**
 Absolute string of the URL to the Map Feedback tool.
 */
static NSString * const MGLAttributionFeedbackURLString = @"https://www.mapbox.com/map-feedback/";

@implementation MGLAttributionInfo

- (instancetype)initWithTitle:(NSString *)title URL:(NSURL *)URL {
    if (self = [super init]) {
        _title = title;
        _URL = URL;
    }
    return self;
}

NS_ARRAY_OF(MGLAttributionInfo *) *MGLAttributionInfosFromHTMLStrings(const std::vector<std::string> htmlStrings) {
    NSMutableArray *infos = [NSMutableArray array];
    for (auto htmlString : htmlStrings) {
        NSData *htmlData = [@(htmlString.c_str()) dataUsingEncoding:NSUTF8StringEncoding];
#if TARGET_OS_IPHONE
        NSError *error;
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData
                                                                                options:@{
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
        }
                                                                     documentAttributes:nil
                                                                                  error:&error];
        if (!attributedString || error) {
            continue;
        }
#else
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:htmlData documentAttributes:nil];
#endif
        NSString *string = attributedString.string;
        [attributedString enumerateAttribute:NSLinkAttributeName
                                     inRange:attributedString.mgl_wholeRange
                                     options:0
                                  usingBlock:^(id _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (!value) {
                return;
            }
            
            NSCAssert([value isKindOfClass:[NSURL class]], @"URL attribute must be an NSURL.");
            
            // Omit the Map Feedback link because the SDK already provides the appropriate UI for giving feedback.
            if ([value isEqual:[NSURL URLWithString:MGLAttributionFeedbackURLString]]) {
                return;
            }
            
            // Omit redundant attribution strings.
            NSString *title = [[string substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            for (MGLAttributionInfo *info in infos) {
                if ([info.title containsString:title]) {
                    return;
                }
            }
            
            MGLAttributionInfo *info = [[MGLAttributionInfo alloc] initWithTitle:title URL:value];
            [infos addObject:info];
        }];
    }
    return infos;
}

@end
