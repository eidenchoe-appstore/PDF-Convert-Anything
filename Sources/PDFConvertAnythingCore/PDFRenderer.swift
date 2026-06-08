import AppKit
import CoreGraphics
import Foundation

public struct ConversionResult {
    public let outputFolder: URL
    public let outputFiles: [URL]
}

public enum ConversionError: LocalizedError {
    case unreadablePDF
    case emptyPDF
    case pageRenderFailed(Int)
    case pngEncodingFailed(Int)

    public var errorDescription: String? {
        switch self {
        case .unreadablePDF:
            return "PDF를 열 수 없습니다."
        case .emptyPDF:
            return "PDF에 변환할 페이지가 없습니다."
        case .pageRenderFailed(let page):
            return "\(page)페이지를 렌더링할 수 없습니다."
        case .pngEncodingFailed(let page):
            return "\(page)페이지 PNG 인코딩에 실패했습니다."
        }
    }
}

public enum PDFRenderer {
    private static let renderScale: CGFloat = 2.0

    public static func pageCount(for pdfURL: URL) throws -> Int {
        guard let document = CGPDFDocument(pdfURL as CFURL) else {
            throw ConversionError.unreadablePDF
        }

        return document.numberOfPages
    }

    public static func convert(
        pdfURL: URL,
        progress: @escaping @Sendable (_ pageIndex: Int, _ outputURL: URL) async -> Void
    ) async throws -> ConversionResult {
        try await Task.detached(priority: .userInitiated) {
            guard let document = CGPDFDocument(pdfURL as CFURL) else {
                throw ConversionError.unreadablePDF
            }

            let pageCount = document.numberOfPages
            guard pageCount > 0 else {
                throw ConversionError.emptyPDF
            }

            let outputFolder = pdfURL.deletingLastPathComponent()
            let baseName = pdfURL.deletingPathExtension().lastPathComponent
            var outputFiles: [URL] = []

            for pageIndex in 1...pageCount {
                try Task.checkCancellation()

                guard let page = document.page(at: pageIndex) else {
                    throw ConversionError.pageRenderFailed(pageIndex)
                }

                let image = try render(page: page, pageIndex: pageIndex)
                let bitmap = NSBitmapImageRep(cgImage: image)

                guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
                    throw ConversionError.pngEncodingFailed(pageIndex)
                }

                let outputURL = outputFolder.appendingPathComponent("\(baseName)_slide_\(pageIndex)pages.png")
                try pngData.write(to: outputURL, options: .atomic)
                outputFiles.append(outputURL)
                await progress(pageIndex, outputURL)
            }

            return ConversionResult(outputFolder: outputFolder, outputFiles: outputFiles)
        }.value
    }

    private static func render(page: CGPDFPage, pageIndex: Int) throws -> CGImage {
        let pageBounds = page.getBoxRect(.mediaBox)
        let pixelWidth = max(1, Int((pageBounds.width * renderScale).rounded(.up)))
        let pixelHeight = max(1, Int((pageBounds.height * renderScale).rounded(.up)))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw ConversionError.pageRenderFailed(pageIndex)
        }

        let pixelRect = CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight)
        context.setFillColor(NSColor.white.cgColor)
        context.fill(pixelRect)

        context.saveGState()
        context.scaleBy(x: renderScale, y: renderScale)
        let destination = CGRect(origin: .zero, size: pageBounds.size)
        let transform = page.getDrawingTransform(
            .mediaBox,
            rect: destination,
            rotate: 0,
            preserveAspectRatio: true
        )
        context.concatenate(transform)
        context.drawPDFPage(page)
        context.restoreGState()

        guard let image = context.makeImage() else {
            throw ConversionError.pageRenderFailed(pageIndex)
        }

        return image
    }
}
