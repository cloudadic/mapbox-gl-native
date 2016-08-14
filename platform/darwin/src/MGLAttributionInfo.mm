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

- (instancetype)initWithTitle:(NSAttributedString *)title URL:(NSURL *)URL {
    if (self = [super init]) {
        _title = title;
        _URL = URL;
    }
    return self;
}

NS_ARRAY_OF(MGLAttributionInfo *) *MGLAttributionInfosFromHTMLStrings(const std::vector<std::string> htmlStrings, NSString *css) {
    NSMutableArray *infos = [NSMutableArray array];
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
    };
    for (auto htmlString : htmlStrings) {
        NSString *styledHTML = [NSString stringWithFormat:@"<style type='text/css'>%@</style>%@", css ?: @"", @(htmlString.c_str())];
        NSData *htmlData = [styledHTML dataUsingEncoding:NSUTF8StringEncoding];
#if TARGET_OS_IPHONE
        NSError *error;
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData
                                                                                options:options
                                                                     documentAttributes:nil
                                                                                  error:&error];
        if (!attributedString || error) {
            continue;
        }
#else
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:htmlData
                                                                                options:options
                                                                     documentAttributes:nil];
        if (!attributedString) {
            continue;
        }
#endif
        [attributedString enumerateAttribute:NSLinkAttributeName
                                     inRange:attributedString.mgl_wholeRange
                                     options:0
                                  usingBlock:^(id _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            NSCAssert(!value || [value isKindOfClass:[NSURL class]], @"If present, URL attribute must be an NSURL.");
            
            // Omit the Map Feedback link because the SDK already provides the appropriate UI for giving feedback.
            // Ideally we’d look for class="mapbox-improve-map", but NSAttributedString loses that information.
            if ([value isEqual:[NSURL URLWithString:MGLAttributionFeedbackURLString]]) {
                return;
            }
            
            NSAttributedString *title = [attributedString attributedSubstringFromRange:range];
            
            // Omit whitespace-only strings.
            if (![title.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
                return;
            }
            
            // Omit redundant attribution strings.
            for (MGLAttributionInfo *info in infos) {
                if ([info.title.string containsString:title.string]) {
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
