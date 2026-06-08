import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var converter = ConversionViewModel()
    @State private var isDropTargeted = false
    @State private var isImporterPresented = false

    var body: some View {
        VStack(spacing: 14) {
            header
            dropZone
            progressArea
            actionBar
        }
        .padding(20)
        .background(Color(nsColor: .windowBackgroundColor))
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                converter.convert(urls)
            case .failure(let error):
                converter.report(error)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 2) {
                Text("PDF Convert Anything")
                    .font(.system(size: 18, weight: .semibold))
                Text("PDF를 PNG 슬라이드 이미지로 변환")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var dropZone: some View {
        VStack(spacing: 12) {
            Image(systemName: isDropTargeted ? "arrow.down.doc.fill" : "arrow.down.doc")
                .font(.system(size: 46, weight: .regular))
                .foregroundStyle(isDropTargeted ? .red : .secondary)

            Text(isDropTargeted ? "여기에 놓으면 바로 변환합니다" : "PDF 파일을 여기에 드래그하세요")
                .font(.system(size: 15, weight: .medium))

            Text("{파일명}_slide_1pages.png 형식으로 원본 PDF와 같은 폴더에 저장")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isDropTargeted ? Color.red.opacity(0.08) : Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isDropTargeted ? Color.red : Color(nsColor: .separatorColor),
                    style: StrokeStyle(lineWidth: 1.5, dash: [7, 5])
                )
        )
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            converter.handleDrop(providers)
        }
    }

    private var progressArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(converter.statusText)
                    .font(.system(size: 12))
                    .foregroundStyle(converter.hasError ? .red : .secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                if converter.isConverting {
                    Text(converter.progressLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: converter.progress)
                .progressViewStyle(.linear)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            Button {
                isImporterPresented = true
            } label: {
                Label("PDF 선택", systemImage: "plus")
            }
            .disabled(converter.isConverting)

            Button {
                converter.openLastOutputFolder()
            } label: {
                Label("출력 폴더", systemImage: "folder")
            }
            .disabled(converter.lastOutputFolder == nil)

            Spacer()

            if converter.convertedPageCount > 0 {
                Label("\(converter.convertedPageCount) pages", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.green)
            }
        }
    }
}
