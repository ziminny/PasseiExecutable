//
//  PEDocXDocumentReader.swift
//  DocumentParser
//
//  Created by Vagner Oliveira on 09/09/24.
//

import Foundation

/// Uma estrutura que lida com a extração e leitura do conteúdo de documentos `.docx`, convertendo-os em texto formatado.
///
/// A estrutura `PEDocXDocumentReader` utiliza um painel de seleção de arquivos para permitir que o usuário selecione um arquivo `.docx`,
/// extrai o conteúdo XML do documento e o processa para gerar uma string com o texto formatado.
///
/// - Note: O texto extraído do arquivo `.docx` é processado e pode incluir formatações básicas como negrito, itálico e sublinhado.
public struct PEDocXDocumentReader {
    
    // MARK: - Propriedades
    
    /// Propriedades do caminho do arquivo selecionado, incluindo o último nome do arquivo, a URL e o diretório temporário.
    private let pathProperties: PEDocumentPanel.PathProperties
    
    // MARK: - Inicializador
    
    /// Inicializa um novo leitor de documentos `.docx` com um painel de seleção de documentos.
    ///
    /// - Parameter documentPanel: O painel de seleção de documentos usado para selecionar o arquivo `.docx`.
    public init(withPathProperties pathProperties: PEDocumentPanel.PathProperties) {
        self.pathProperties = pathProperties
    }
    
    // MARK: - Método Público
    
    /// Gera e retorna o conteúdo do documento `.docx` selecionado como uma string formatada.
    ///
    /// Este método realiza os seguintes passos:
    /// - Verifica as propriedades do caminho.
    /// - Cria um diretório temporário para armazenar o conteúdo extraído.
    /// - Executa o processo de extração usando a classe `PEExecutable`.
    /// - Localiza e lê o arquivo XML extraído do documento `.docx`.
    /// - Usa o `PEWordDocumentParser` para processar o XML e gerar uma string com o texto formatado.
    ///
    /// - Throws: Lança exceções de `PEExtractException` se ocorrerem erros durante o processo, como a ausência do arquivo XML.
    ///
    /// - Returns: O conteúdo do documento `.docx` como uma string formatada.
    @available(macOS 13.0, *)
    public func generate<RuleConformable: PERulesProtocol>(of type: RuleConformable.Type) throws -> [RuleConformable.Searcheable]? {
        
        let fileManager = FileManager.default 

        // Cria o diretório temporário
        try fileManager.createDirectory(at: pathProperties.tempDirectory, withIntermediateDirectories: true, attributes: nil)
        
        // Executa o comando para extrair o conteúdo do documento .docx
        try executable(pathProperties: pathProperties)

        // Caminho para o arquivo XML `word/document.xml` extraído
        let documentXMLPath = pathProperties.tempDirectory.appendingPathComponent(PEConstants.DocumentReader.appendingDestinationFile)

        // Verifica se o arquivo XML existe
        guard fileManager.fileExists(atPath: documentXMLPath.path) else {
            throw PEExtractException.xmlDocumentNotFound
        }
        
        // Processa o conteúdo do arquivo XML e retorna o texto formatado
        return try documentParser(documentXMLPath: documentXMLPath, of: RuleConformable.self)
    }
    
    // MARK: - Métodos Privados
    
    /// Executa o processo de extração do conteúdo do documento `.docx`.
    ///
    /// - Parameter pathProperties: As propriedades do caminho do documento selecionado.
    /// - Throws: Lança exceções se ocorrerem erros durante a execução do processo.
    private func executable(pathProperties: PEDocumentPanel.PathProperties) throws {
        let executable = try PEExecutable(arguments: [
            pathProperties.url.path(),
            PEConstants.DocumentReader.directoryFlag,
            pathProperties.tempDirectory.path()
        ])
        
        _ = try executable.execute()
    }
    
    /// Processa o conteúdo do arquivo XML extraído e gera uma string formatada.
    ///
    /// - Parameter documentXMLPath: O caminho para o arquivo XML `word/document.xml`.
    /// - Throws: Lança exceções se ocorrerem erros durante a leitura do conteúdo XML.
    ///
    /// - Returns: O conteúdo formatado do documento `.docx` como uma string.
    private func documentParser<RuleConformable: PERulesProtocol>(documentXMLPath: URL, of type: RuleConformable.Type) throws -> [RuleConformable.Searcheable]? {
        let xmlContent = try String(contentsOf: documentXMLPath, encoding: .utf8)
        let documentParser = PEDocXDocumentParser<RuleConformable>()
        let resultString = documentParser.parse(xmlContent: xmlContent)
        return resultString
    }
}

