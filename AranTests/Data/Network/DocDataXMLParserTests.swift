import XCTest
@testable import Aran
import AranDomain
import AranData

final class DocDataXMLParserTests: XCTestCase {
    func test_extractText_fromSelfClosingArticles_returnsTitles() {
        let xml = "<DOC title=\"효능효과\"><SECTION title=\"\"><ARTICLE title=\"1. 고칼륨혈증\" /><ARTICLE title=\"2. 저혈당\" /></SECTION></DOC>"

        let text = DocDataXMLParser.extractText(from: xml)

        XCTAssertEqual(text, "1. 고칼륨혈증\n2. 저혈당")
    }

    func test_extractText_fromParagraphCDATA_returnsBody() {
        let xml = "<DOC title=\"용법용량\"><SECTION title=\"\"><ARTICLE title=\"\"><PARAGRAPH><![CDATA[성인 : 1회 20~500 mL 정맥주사한다.]]></PARAGRAPH></ARTICLE></SECTION></DOC>"

        let text = DocDataXMLParser.extractText(from: xml)

        XCTAssertEqual(text, "성인 : 1회 20~500 mL 정맥주사한다.")
    }

    func test_extractText_stripsInlineTagsInsideCDATA() {
        let xml = "<DOC><SECTION><ARTICLE title=\"\"><PARAGRAPH><![CDATA[비타민 B<sub>1</sub> 결핍]]></PARAGRAPH></ARTICLE></SECTION></DOC>"

        let text = DocDataXMLParser.extractText(from: xml)

        XCTAssertEqual(text, "비타민 B1 결핍")
    }

    func test_extractArticles_titleContaining_returnsOnlyMatching() {
        let xml = "<DOC><SECTION><ARTICLE title=\"1. 경고\"><PARAGRAPH><![CDATA[유리파편 주의]]></PARAGRAPH></ARTICLE><ARTICLE title=\"2. 금기\"><PARAGRAPH><![CDATA[고혈당 환자]]></PARAGRAPH></ARTICLE></SECTION></DOC>"

        let warning = DocDataXMLParser.extractArticles(from: xml, titleContaining: "경고")

        XCTAssertEqual(warning?.contains("유리파편"), true)
        XCTAssertEqual(warning?.contains("고혈당"), false)
    }

    func test_extractArticles_titleExcluding_returnsOthers() {
        let xml = "<DOC><SECTION><ARTICLE title=\"1. 경고\"><PARAGRAPH><![CDATA[유리파편 주의]]></PARAGRAPH></ARTICLE><ARTICLE title=\"2. 금기\"><PARAGRAPH><![CDATA[고혈당 환자]]></PARAGRAPH></ARTICLE></SECTION></DOC>"

        let rest = DocDataXMLParser.extractArticles(from: xml, titleExcluding: "경고")

        XCTAssertEqual(rest?.contains("고혈당"), true)
        XCTAssertEqual(rest?.contains("유리파편"), false)
    }

    func test_extractText_returnsNil_forEmptyOrInvalid() {
        XCTAssertNil(DocDataXMLParser.extractText(from: ""))
    }
}
