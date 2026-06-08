import AppKit
import Foundation
import PDFConvertAnythingCore
import UniformTypeIdentifiers

@MainActor
final class ConversionViewModel: ObservableObject {
    @Published var statusText = "대기 중"
    @Published var progress = 0.0
    @Published var progressLabel = ""
    @Published var isConverting = false
    @Published var hasError = false
    @Published var lastOutputFolder: URL?
    @Published var convertedPageCount = 0

    private var totalPageCount = 0

    func convert(_ urls: [URL]) {
        let pdfURLs = urls.filter { $0.pathExtension.lowercased() == "pdf" }

        guard !pdfURLs.isEmpty else {
            statusText = "PDF 파일만 변환할 수 있습니다."
            hasError = true
            return
        }

        isConverting = true
        hasError = false
        progress = 0
        progressLabel = "0%"
        convertedPageCount = 0
        statusText = "\(pdfURLs.count)개 PDF 변환 준비 중"

        Task {
            do {
                var totalPages = 0
                var lastFolder: URL?

                for url in pdfURLs {
                    let accessGranted = url.startAccessingSecurityScopedResource()
                    defer {
                        if accessGranted {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }

                    let pageCount = try PDFRenderer.pageCount(for: url)
                    totalPages += pageCount
                }

                guard totalPages > 0 else {
                    throw ConversionError.emptyPDF
                }

                totalPageCount = totalPages

                for url in pdfURLs {
                    statusText = "\(url.lastPathComponent) 변환 중"
                    let accessGranted = url.startAccessingSecurityScopedResource()

                    do {
                        let fileName = url.lastPathComponent
                        let result = try await PDFRenderer.convert(pdfURL: url) { [weak self] pageIndex, _ in
                            await self?.markPageCompleted(fileName: fileName, pageIndex: pageIndex)
                        }

                        lastFolder = result.outputFolder
                    } catch {
                        if accessGranted {
                            url.stopAccessingSecurityScopedResource()
                        }
                        throw error
                    }

                    if accessGranted {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                progress = 1
                progressLabel = "100%"
                lastOutputFolder = lastFolder
                statusText = "\(convertedPageCount)페이지 변환 완료"
                hasError = false
            } catch {
                report(error)
            }

            isConverting = false
        }
    }

    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        let fileProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }

        guard !fileProviders.isEmpty else {
            return false
        }

        Task {
            var urls: [URL] = []

            for provider in fileProviders {
                if let url = await Self.fileURL(from: provider) {
                    urls.append(url)
                }
            }

            self.convert(urls)
        }

        return true
    }

    private static func fileURL(from provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                if let data = item as? Data {
                    continuation.resume(returning: URL(dataRepresentation: data, relativeTo: nil))
                } else if let url = item as? URL {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func markPageCompleted(fileName: String, pageIndex: Int) {
        convertedPageCount += 1
        progress = Double(convertedPageCount) / Double(max(totalPageCount, 1))
        progressLabel = "\(Int(progress * 100))%"
        statusText = "\(fileName) \(pageIndex)페이지 저장 완료"
    }

    func openLastOutputFolder() {
        guard let lastOutputFolder else {
            return
        }

        NSWorkspace.shared.open(lastOutputFolder)
    }

    func report(_ error: Error) {
        statusText = error.localizedDescription
        hasError = true
        progressLabel = ""
    }
}
