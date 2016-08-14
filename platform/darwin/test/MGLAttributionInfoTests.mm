#import <Mapbox/Mapbox.h>
#import <XCTest/XCTest.h>

#import "MGLAttributionInfo.h"

#include <string>

@interface MGLAttributionInfoTests : XCTestCase

@end

@implementation MGLAttributionInfoTests

- (void)testDedupe {
    std::vector<std::string> htmlSources = {
        "World",
        "Hello World",
        "Another Source",
        "Hello",
        "Hello World",
    };
    
    NS_ARRAY_OF(MGLAttributionInfo *) *attributions = MGLAttributionInfosFromHTMLStrings(htmlSources, nil);
    XCTAssertEqual(attributions.count, 2);
    XCTAssertEqualObjects(attributions[0].title.string, @"Hello World");
    XCTAssertEqualObjects(attributions[1].title.string, @"Another Source");
}

@end
