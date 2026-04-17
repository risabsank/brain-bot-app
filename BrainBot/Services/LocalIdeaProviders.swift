//
//  LocalIdeaProviders.swift
//  BrainBot
//
//  Created by Codex on 4/17/26.
//

import Foundation
import OSLog
#if canImport(llama)
import llama
#endif

protocol LocalLLMEngine {
    func generateText(prompt: String, maxTokens: Int) async throws -> String
}

struct LocalLLMConfiguration: Hashable {
    var modelName = "Qwen3-0.6B Q4_0 GGUF"
    var bundledModelResource = "qwen3-0.6b-q4_0"
    var bundledModelExtension = "gguf"
    var bundledModelSubdirectory = "Resources/Models"
    var contextTokenCount: Int32 = 2048
    var batchTokenCount: Int32 = 512
    var maxOutputTokens = 220
}

struct BundledLlamaCppEngine: LocalLLMEngine {
    let configuration: LocalLLMConfiguration
    private let logger = Logger(subsystem: "risabsank.BrainBot", category: "LocalLLM")

    func generateText(prompt: String, maxTokens: Int) async throws -> String {
        logger.notice("Starting local LLM generation. model=\(configuration.modelName, privacy: .public), promptBytes=\(prompt.utf8.count), maxTokens=\(maxTokens)")

        guard let modelURL = modelURL() else {
            logger.error("Local LLM model file was not found. resource=\(configuration.bundledModelResource, privacy: .public).\(configuration.bundledModelExtension, privacy: .public), subdirectory=\(configuration.bundledModelSubdirectory, privacy: .public)")
            throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
        }

        logger.notice("Local LLM model file found at \(modelURL.path, privacy: .public)")
        try validateModelFile(at: modelURL)

        #if canImport(llama)
        logger.notice("llama module is available. Loading model through llama.cpp.")
        return try generateWithLlama(prompt: prompt, maxTokens: maxTokens, modelURL: modelURL)
        #else
        logger.error("llama module is not available at compile time.")
        throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
        #endif
    }

    private func modelURL() -> URL? {
        Bundle.main.url(
            forResource: configuration.bundledModelResource,
            withExtension: configuration.bundledModelExtension,
            subdirectory: configuration.bundledModelSubdirectory
        ) ?? Bundle.main.url(
            forResource: configuration.bundledModelResource,
            withExtension: configuration.bundledModelExtension
        )
    }

    private func validateModelFile(at url: URL) throws {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let byteCount = attributes[.size] as? NSNumber
            let fileSize = byteCount?.int64Value ?? 0

            guard fileSize > 1_000_000 else {
                logger.error("Local LLM model file is too small to be a GGUF model. bytes=\(fileSize), path=\(url.path, privacy: .public)")
                throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
            }

            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }

            let header = try handle.read(upToCount: 4) ?? Data()
            let expectedHeader = Data("GGUF".utf8)

            guard header == expectedHeader else {
                let preview = String(data: header, encoding: .utf8) ?? header.map { String(format: "%02x", $0) }.joined()
                logger.error("Local LLM model file has an invalid GGUF header. expected=GGUF, actual=\(preview, privacy: .public), path=\(url.path, privacy: .public)")
                throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
            }
        } catch let error as IdeaAssistantError {
            throw error
        } catch {
            logger.error("Unable to validate local LLM model file. error=\(error.localizedDescription, privacy: .public), path=\(url.path, privacy: .public)")
            throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
        }
    }
}

#if canImport(llama)
private extension BundledLlamaCppEngine {
    func generateWithLlama(prompt: String, maxTokens: Int, modelURL: URL) throws -> String {
        LlamaBackend.initialize()
        logger.notice("llama backend initialized.")

        var modelParams = llama_model_default_params()
        #if targetEnvironment(simulator)
        modelParams.n_gpu_layers = 0
        logger.notice("Running in simulator. GPU layer offload disabled for local LLM.")
        #else
        modelParams.n_gpu_layers = 99
        logger.notice("Running on device. GPU layer offload enabled for local LLM.")
        #endif

        guard let model = modelURL.path.withCString({ llama_model_load_from_file($0, modelParams) }) else {
            logger.error("llama_model_load_from_file failed for \(modelURL.path, privacy: .public)")
            throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
        }
        defer { llama_model_free(model) }
        logger.notice("llama model loaded.")

        let vocab = llama_model_get_vocab(model)
        var contextParams = llama_context_default_params()
        contextParams.n_ctx = UInt32(configuration.contextTokenCount)
        contextParams.n_batch = UInt32(configuration.batchTokenCount)

        guard let context = llama_init_from_model(model, contextParams) else {
            logger.error("llama_init_from_model failed. nCtx=\(configuration.contextTokenCount), nBatch=\(configuration.batchTokenCount)")
            throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
        }
        defer { llama_free(context) }
        logger.notice("llama context created. nCtx=\(configuration.contextTokenCount), nBatch=\(configuration.batchTokenCount)")

        let processorCount = max(1, ProcessInfo.processInfo.processorCount - 1)
        let threadCount = Int32(min(processorCount, 6))
        llama_set_n_threads(context, threadCount, threadCount)
        logger.notice("llama threads configured. threads=\(threadCount)")

        let promptTokens = try tokenize(prompt, vocab: vocab)
        guard !promptTokens.isEmpty else {
            logger.error("Prompt tokenization returned zero tokens.")
            throw IdeaAssistantError.emptyIdea
        }
        logger.notice("Prompt tokenized. tokenCount=\(promptTokens.count)")

        try decode(tokens: promptTokens, context: context, startPosition: 0, logitsOnLastToken: true)
        logger.notice("Prompt decode succeeded.")

        let sampler = makeSampler()
        defer { llama_sampler_free(sampler) }

        var generatedTokens: [llama_token] = []
        var nextPosition = Int32(promptTokens.count)

        for _ in 0..<maxTokens {
            let token = llama_sampler_sample(sampler, context, -1)
            if llama_vocab_is_eog(vocab, token) {
                break
            }

            llama_sampler_accept(sampler, token)
            generatedTokens.append(token)

            try decode(tokens: [token], context: context, startPosition: nextPosition, logitsOnLastToken: true)
            nextPosition += 1
        }

        let text = detokenize(generatedTokens, vocab: vocab)
        logger.notice("Generation finished. generatedTokens=\(generatedTokens.count), outputBytes=\(text.utf8.count)")
        return text
    }

    func tokenize(_ text: String, vocab: OpaquePointer?) throws -> [llama_token] {
        let byteCount = Int32(text.utf8.count)
        let estimatedCount = max(32, Int(byteCount) + 8)
        var tokens = Array<llama_token>(repeating: 0, count: estimatedCount)

        let tokenCount = text.withCString {
            llama_tokenize(vocab, $0, byteCount, &tokens, Int32(tokens.count), true, true)
        }

        if tokenCount < 0 {
            let requiredCount = Int(-tokenCount)
            logger.notice("Retrying tokenization with required token capacity=\(requiredCount)")
            tokens = Array<llama_token>(repeating: 0, count: requiredCount)
            let retryCount = text.withCString {
                llama_tokenize(vocab, $0, byteCount, &tokens, Int32(tokens.count), true, true)
            }
            guard retryCount >= 0 else {
                logger.error("Tokenization failed after retry. retryCode=\(retryCount)")
                throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
            }
            return Array(tokens.prefix(Int(retryCount)))
        }

        return Array(tokens.prefix(Int(tokenCount)))
    }

    func decode(
        tokens: [llama_token],
        context: OpaquePointer?,
        startPosition: Int32,
        logitsOnLastToken: Bool
    ) throws {
        var batch = llama_batch_init(Int32(tokens.count), 0, 1)
        defer { llama_batch_free(batch) }

        batch.n_tokens = Int32(tokens.count)

        for index in tokens.indices {
            batch.token[index] = tokens[index]
            batch.pos[index] = startPosition + Int32(index)
            batch.n_seq_id[index] = 1
            batch.seq_id[index]![0] = 0
            batch.logits[index] = logitsOnLastToken && index == tokens.count - 1 ? 1 : 0
        }

        let decodeStatus = llama_decode(context, batch)
        guard decodeStatus == 0 else {
            logger.error("llama_decode failed. status=\(decodeStatus), tokenCount=\(tokens.count), startPosition=\(startPosition)")
            throw IdeaAssistantError.localModelUnavailable(configuration.modelName)
        }
    }

    func detokenize(_ tokens: [llama_token], vocab: OpaquePointer?) -> String {
        var output = ""

        for token in tokens {
            var buffer = Array<CChar>(repeating: 0, count: 256)
            let length = llama_token_to_piece(vocab, token, &buffer, Int32(buffer.count), 0, false)

            if length > 0 {
                output += String(decoding: buffer.prefix(Int(length)).map { UInt8(bitPattern: $0) }, as: UTF8.self)
            }
        }

        return output
    }

    func makeSampler() -> UnsafeMutablePointer<llama_sampler> {
        let sampler = llama_sampler_chain_init(llama_sampler_chain_default_params())
        llama_sampler_chain_add(sampler, llama_sampler_init_top_k(20))
        llama_sampler_chain_add(sampler, llama_sampler_init_top_p(0.8, 1))
        llama_sampler_chain_add(sampler, llama_sampler_init_temp(0.2))
        llama_sampler_chain_add(sampler, llama_sampler_init_dist(UInt32.random(in: 1...UInt32.max)))
        return sampler!
    }
}

private enum LlamaBackend {
    static func initialize() {
        _ = initialized
    }

    private static let initialized: Void = {
        llama_backend_init()
    }()
}
#endif

struct LlamaCppLocalIdeaProvider: IdeaSuggestionProviding {
    let configuration: LocalLLMConfiguration
    let engine: LocalLLMEngine
    private let promptBuilder = BrainstormPromptBuilder()

    var modelName: String { configuration.modelName }

    init(
        configuration: LocalLLMConfiguration = LocalLLMConfiguration(),
        engine: LocalLLMEngine? = nil
    ) {
        self.configuration = configuration
        self.engine = engine ?? BundledLlamaCppEngine(configuration: configuration)
    }

    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult {
        let prompt = promptBuilder.prompt(for: request)
        let output = try await engine.generateText(prompt: prompt, maxTokens: configuration.maxOutputTokens)
        let suggestions = try Self.decodeSuggestions(from: output)

        return IdeaAssistanceResult(
            suggestions: suggestions,
            source: .local,
            assistanceLevel: request.assistanceLevel,
            modelName: modelName
        )
    }

    static func decodeSuggestions(from text: String) throws -> [IdeaSuggestion] {
        let logger = Logger(subsystem: "risabsank.BrainBot", category: "LocalLLM")
        logger.notice("Decoding local LLM JSON response. outputBytes=\(text.utf8.count)")

        let jsonText = extractJSONPayload(from: text)

        guard let data = jsonText.data(using: .utf8) else {
            logger.error("Unable to convert extracted local LLM JSON text to UTF-8 data.")
            throw IdeaAssistantError.cloudResponseInvalid
        }

        let payload: SuggestionPayload
        do {
            payload = try JSONDecoder().decode(SuggestionPayload.self, from: data)
        } catch {
            do {
                let suggestions = try JSONDecoder().decode([SuggestionItem].self, from: data)
                payload = SuggestionPayload(suggestions: suggestions)
            } catch {
                logger.error("Local LLM JSON decode failed. error=\(error.localizedDescription, privacy: .public), preview=\(preview(jsonText), privacy: .public)")
                throw error
            }
        }

        logger.notice("Local LLM JSON decode succeeded. suggestionCount=\(payload.suggestions.count)")
        return payload.suggestions.prefix(3).map {
            IdeaSuggestion(kind: $0.kind, text: $0.text)
        }
    }

    private static func extractJSONPayload(from text: String) -> String {
        let trimmed = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```JSON", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let object = extractBalancedPayload(from: trimmed, opening: "{", closing: "}") {
            return object
        }

        if let array = extractBalancedPayload(from: trimmed, opening: "[", closing: "]") {
            return array
        }

        return trimmed
    }

    private static func extractBalancedPayload(from text: String, opening: Character, closing: Character) -> String? {
        guard let start = text.firstIndex(of: opening) else { return nil }

        var depth = 0
        var isEscaped = false
        var isInsideString = false

        var index = start
        while index < text.endIndex {
            let character = text[index]

            if isEscaped {
                isEscaped = false
            } else if character == "\\" {
                isEscaped = true
            } else if character == "\"" {
                isInsideString.toggle()
            } else if !isInsideString {
                if character == opening {
                    depth += 1
                } else if character == closing {
                    depth -= 1
                    if depth == 0 {
                        return String(text[start...index])
                    }
                }
            }

            index = text.index(after: index)
        }

        return nil
    }

    private static func preview(_ text: String) -> String {
        let collapsed = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
        return String(collapsed.prefix(500))
    }
}

struct HeuristicIdeaProvider: IdeaSuggestionProviding {
    var modelName: String { "On-device brainstorm fallback" }

    func suggestions(for request: IdeaAssistanceRequest) async throws -> IdeaAssistanceResult {
        guard request.isReady else { throw IdeaAssistantError.emptyIdea }

        let focus = Self.focusPhrase(from: request)
        let suggestions: [IdeaSuggestion]

        switch request.assistanceLevel {
        case .minimal:
            suggestions = [
                IdeaSuggestion(kind: .question, text: "What would make \(focus) useful enough to try this week?"),
                IdeaSuggestion(kind: .question, text: "Who would care about this first, and what would they ask for next?"),
                IdeaSuggestion(kind: .question, text: "What part feels exciting, uncertain, or too vague right now?")
            ]
        case .standard:
            suggestions = [
                IdeaSuggestion(kind: .question, text: "What is the smallest version of \(focus) you could test quickly?"),
                IdeaSuggestion(kind: .pathway, text: "Turn it into a tiny experiment with one audience, one promise, and one success signal."),
                IdeaSuggestion(kind: .pathway, text: "Add a concrete next step: who tries it, what happens, and what you learn.")
            ]
        case .moreHelp:
            suggestions = [
                IdeaSuggestion(kind: .question, text: "What would someone misunderstand about \(focus) if they only heard the title?"),
                IdeaSuggestion(kind: .pathway, text: "Sketch two versions: the practical version people need and the weird version people remember."),
                IdeaSuggestion(kind: .assumption, text: "Check whether the main assumption is demand, timing, trust, or your ability to deliver it.")
            ]
        }

        return IdeaAssistanceResult(
            suggestions: suggestions,
            source: .localFallback,
            assistanceLevel: request.assistanceLevel,
            modelName: modelName
        )
    }

    private static func focusPhrase(from request: IdeaAssistanceRequest) -> String {
        let title = request.trimmedTitle
        if !title.isEmpty {
            return title
        }

        let words = request.trimmedBody
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .prefix(5)
            .joined(separator: " ")

        return words.isEmpty ? "this idea" : words
    }
}

private struct SuggestionPayload: Decodable {
    var suggestions: [SuggestionItem]
}

private struct SuggestionItem: Decodable {
    var kind: IdeaSuggestionKind
    var text: String

    enum CodingKeys: String, CodingKey {
        case type
        case kind
        case text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decodeIfPresent(String.self, forKey: .type)
            ?? container.decodeIfPresent(String.self, forKey: .kind)
            ?? "pathway"
        kind = IdeaSuggestionKind(rawValue: rawType) ?? .pathway
        text = try container.decode(String.self, forKey: .text)
    }
}
