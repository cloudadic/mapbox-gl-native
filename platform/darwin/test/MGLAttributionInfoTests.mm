#import <Mapbox/Mapbox.h>
#import <XCTest/XCTest.h>

#import "MGLAttributionInfo.h"

#include <string>

@interface MGLAttributionInfoTests : XCTestCase

@end

@implementation MGLAttributionInfoTests

- (void)testParsing {
    std::vector<std::string> htmlSources = {
        R"!(<a href="https://www.mapbox.com/about/maps/" target="_blank">&copy; Mapbox</a> )!"
        R"!(<a href="http://www.openstreetmap.org/about/" target="_blank">&copy; OpenStreetMap</a> )!"
        R"!(CC&nbsp;BY-SA )!"
        R"!(<a class="mapbox-improve-map" href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a>)!",
    };
    
    NS_ARRAY_OF(MGLAttributionInfo *) *attributions = MGLAttributionInfosFromHTMLStrings(htmlSources, nil);
    XCTAssertEqual(attributions.count, 3);
    
    XCTAssertEqualObjects(attributions[0].title.string, @"© Mapbox");
    XCTAssertEqualObjects(attributions[0].URL, [NSURL URLWithString:@"https://www.mapbox.com/about/maps/"]);
    
    XCTAssertEqualObjects(attributions[1].title.string, @"© OpenStreetMap");
    XCTAssertEqualObjects(attributions[1].URL, [NSURL URLWithString:@"http://www.openstreetmap.org/about/"]);
    
    XCTAssertEqualObjects(attributions[2].title.string, @"CC\u00a0BY-SA");
    XCTAssertNil(attributions[2].URL);
}

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
