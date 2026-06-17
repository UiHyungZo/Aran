import Foundation
import AranDomain

/// 의약품 허가정보 API의 `EE_DOC_DATA` / `UD_DOC_DATA` / `NB_DOC_DATA`는
/// JSON 안에 XML 문자열로 들어온다. 이 XML에서 사람이 읽을 텍스트만 추출한다.
enum DocDataXMLParser {
    /// 모든 ARTICLE의 제목·본문을 합쳐 반환 (효능·용법 등 전체용)
    static func extractText(from xml: String) -> String? {
        format(parse(xml))
    }

    /// 제목에 `keyword`가 포함된 ARTICLE만 추출 (예: "경고")
    static func extractArticles(from xml: String, titleContaining keyword: String) -> String? {
        format(parse(xml).filter { $0.title.contains(keyword) })
    }

    /// 제목에 `keyword`가 포함되지 않은 ARTICLE만 추출
    static func extractArticles(from xml: String, titleExcluding keyword: String) -> String? {
        format(parse(xml).filter { !$0.title.contains(keyword) })
    }

    // MARK: - Private

    private struct Article {
        var title: String
        var paragraphs: [String]
    }

    private static func parse(_ xml: String) -> [Article] {
        guard let data = xml.data(using: .utf8) else { return [] }
        let delegate = Delegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        return delegate.articles
    }

    private static func format(_ articles: [Article]) -> String? {
        let blocks: [String] = articles.compactMap { article in
            var lines: [String] = []
            let title = article.title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !title.isEmpty { lines.append(title) }
            lines.append(contentsOf: article.paragraphs)
            let block = lines.joined(separator: "\n")
            return block.isEmpty ? nil : block
        }
        let joined = blocks.joined(separator: "\n")
        return joined.isEmpty ? nil : joined
    }

    private final class Delegate: NSObject, XMLParserDelegate {
        var articles: [Article] = []
        private var currentParagraph: String?

        func parser(
            _ parser: XMLParser,
            didStartElement elementName: String,
            namespaceURI: String?,
            qualifiedName qName: String?,
            attributes attributeDict: [String: String] = [:]
        ) {
            switch elementName {
            case "ARTICLE":
                articles.append(Article(title: attributeDict["title"] ?? "", paragraphs: []))
            case "PARAGRAPH":
                currentParagraph = ""
            default:
                break
            }
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if currentParagraph != nil { currentParagraph? += string }
        }

        func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
            guard currentParagraph != nil,
                  let text = String(data: CDATABlock, encoding: .utf8) else { return }
            currentParagraph? += text
        }

        func parser(
            _ parser: XMLParser,
            didEndElement elementName: String,
            namespaceURI: String?,
            qualifiedName qName: String?
        ) {
            guard elementName == "PARAGRAPH" else { return }
            defer { currentParagraph = nil }
            guard let paragraph = currentParagraph else { return }
            // CDATA 안에 섞인 <sub> 등 인라인 태그 제거
            let cleaned = paragraph
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty else { return }
            if articles.isEmpty { articles.append(Article(title: "", paragraphs: [])) }
            articles[articles.count - 1].paragraphs.append(cleaned)
        }
    }
}
