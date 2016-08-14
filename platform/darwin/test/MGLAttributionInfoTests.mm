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
        R"!(<a href="http://www.openstreetmap.org/about/" target="_blank">©️ OpenStreetMap</a> )!"
        R"!(CC&nbsp;BY-SA )!"
        R"!(<a class="mapbox-improve-map" href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a>)!",
    };
    
    NS_ARRAY_OF(MGLAttributionInfo *) *attributions = MGLAttributionInfosFromHTMLStrings(htmlSources, nil);
    XCTAssertEqual(attributions.count, 3);
    
    XCTAssertEqualObjects(attributions[0].title.string, @"© Mapbox");
    XCTAssertEqualObjects(attributions[0].URL, [NSURL URLWithString:@"https://www.mapbox.com/about/maps/"]);
    
    XCTAssertEqualObjects(attributions[1].title.string, @"©️ OpenStreetMap");
    XCTAssertEqualObjects(attributions[1].URL, [NSURL URLWithString:@"http://www.openstreetmap.org/about/"]);
    
    XCTAssertEqualObjects(attributions[2].title.string, @"CC\u00a0BY-SA");
    XCTAssertNil(attributions[2].URL);
}

- (void)testStyle {
    std::vector<std::string> htmlSources = {
        R"!(<a href="https://www.mapbox.com/">Mapbox</a>)!",
    };
    
    CGFloat fontSize = 72;
    NSString *css = [NSString stringWithFormat:@"html { font-size: %.1fpx; } a:link { color: red; }", fontSize];
    NS_ARRAY_OF(MGLAttributionInfo *) *attributions = MGLAttributionInfosFromHTMLStrings(htmlSources, css);
    XCTAssertEqual(attributions.count, 1);
    
    XCTAssertEqualObjects(attributions[0].title.string, @"Mapbox");
    XCTAssertEqualObjects([attributions[0].title attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil], [NSURL URLWithString:@"https://www.mapbox.com/"]);
    XCTAssertEqualObjects([attributions[0].title attribute:NSUnderlineStyleAttributeName atIndex:0 effectiveRange:nil], @(NSUnderlineStyleSingle));
    
#if TARGET_OS_IPHONE
    UIFont *font;
#else
    NSFont *font;
#endif
    font = [attributions[0].title attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
    XCTAssertEqual(font.pointSize, fontSize);
    
    MGLColor *red = [MGLColor redColor];
    CGFloat r, g, b, a;
    [red getRed:&r green:&g blue:&b alpha:&a];
    MGLColor *linkColor = [attributions[0].title attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
    CGFloat linkR, linkG, linkB, linkA;
    [linkColor getRed:&linkR green:&linkG blue:&linkB alpha:&linkA];
    XCTAssertEqual(r, linkR);
    XCTAssertEqual(g, linkG);
    XCTAssertEqual(b, linkB);
    XCTAssertEqual(a, linkA);
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
