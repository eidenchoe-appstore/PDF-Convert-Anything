import AppKit
import CoreGraphics
import PDFConvertAnythingCore
import XCTest

final class PDFRendererTests: XCTestCase {
    func testConvertsEachPDFPageToExpectedPNGName() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PDFConvertAnythingTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let pdfURL = directory.appendingPathComponent("lecture.pdf")
        try makePDF(at: pdfURL, pageCount: 2)

        let result = try await PDFRenderer.convert(pdfURL: pdfURL) { _, _ in }
        let outputNames = result.outputFiles.map(\.lastPathComponent)

        XCTAssertEqual(outputNames, [
            "lecture_slide_1pages.png",
            "lecture_slide_2pages.png"
        ])

        for outputURL in result.outputFiles {
            XCTAssertTrue(FileManager.default.fileExists(atPath: outputURL.path))
            let data = try Data(contentsOf: outputURL)
            let image = try XCTUnwrap(NSBitmapImageRep(data: data))
            XCTAssertEqual(image.pixelsWide, 240)
            XCTAssertEqual(image.pixelsHigh, 160)
        }
    }

    private func makePDF(at url: URL, pageCount: Int) throws {
        var mediaBox = CGRect(x: 0, y: 0, width: 120, height: 80)
        let consumer = try XCTUnwrap(CGDataConsumer(url: url as CFURL))
        let context = try XCTUnwrap(CGContext(consumer: consumer, mediaBox: &mediaBox, nil))

        for pageIndex in 1...pageCount {
            context.beginPDFPage(nil)
            context.setFillColor(NSColor.white.cgColor)
            context.fill(mediaBox)
            context.setFillColor(NSColor(calibratedRed: CGFloat(pageIndex) / 3.0, green: 0.2, blue: 0.3, alpha: 1).cgColor)
            context.fill(CGRect(x: 12, y: 12, width: 48, height: 32))
            context.endPDFPage()
        }

        context.closePDF()
    }
}
