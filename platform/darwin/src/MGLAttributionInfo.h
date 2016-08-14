#import <Foundation/Foundation.h>

#import "MGLTypes.h"

#include <vector>

NS_ASSUME_NONNULL_BEGIN

/**
 Information about an attribution statement, usually a copyright or trademark
 statement, associated with a map source.
 */
@interface MGLAttributionInfo : NSObject

- (instancetype)initWithTitle:(NSAttributedString *)title URL:(NSURL *)URL;

@property (nonatomic) NSAttributedString *title;
@property (nonatomic) NSURL *URL;

@end

/// Parses and returns the attribution infos contained in the given HTML source code strings.
NS_ARRAY_OF(MGLAttributionInfo *) *MGLAttributionInfosFromHTMLStrings(const std::vector<std::string> htmlStrings, NSString * _Nullable css);

NS_ASSUME_NONNULL_END
