//
//  PEDocumentPanel.swift
//  DocumentParser
//
//  Created by Vagner Oliveira on 09/09/24.
//

import Foundation
import AppKit
import UniformTypeIdentifiers.UTType

/// Uma classe personalizada que herda de `NSOpenPanel` e facilita a seleção de arquivos pelo usuário.
///
/// A classe `PEDocumentPanel` encapsula a configuração de uma janela de seleção de arquivos (open panel)
/// e retorna informações sobre o arquivo selecionado, como o caminho e diretório temporário associados.
public class PEDocumentPanel: NSOpenPanel {
    
    // MARK: - Métodos Públicos
    
    /// Abre o painel de seleção de arquivos com um título personalizado e retorna as propriedades do caminho selecionado.
    ///
    /// - Parameter title: O título do painel de seleção de arquivos. O valor padrão é "Selecione um arquivo".
    /// - Returns: Um objeto `PathProperties` contendo o último caminho do arquivo, a URL, e o diretório temporário, ou `nil` se a seleção foi cancelada.
    public func openPanel(acceptedExtensions extensions: String... ,withTitle title: String = "Selecione um arquivo") -> PathProperties? {
        
        setPanelProperties(acceptedExtensions: extensions, withTitle: title)
        
        let response = runModal()
        
        guard response == .OK, let url = url else {
            return nil
        }
        
        let lastPath = String(url.lastPathComponent)
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        return PathProperties(lastPath: lastPath, url: url, tempDirectory: tempDirectory)
        
    }
    
    // MARK: - Métodos Privados
    
    /// Configura as propriedades do painel de seleção de arquivos.
    ///
    /// - Parameter title: O título a ser exibido no painel de seleção de arquivos.
    private func setPanelProperties(acceptedExtensions extensions: [String] ,withTitle title: String) {
        self.title           = title
        isExtensionHidden    = false
        canChooseDirectories = false
        canChooseFiles       = true
        allowsMultipleSelection = false
        
        var uiTypes: [UTType] = []
        
        for `extension` in extensions {
            if let ext = UTType(filenameExtension: `extension`) {
                uiTypes.append(ext)
            }
        }
        
        allowedContentTypes = uiTypes
         
    }
    
}

// MARK: - Extensão de PEDocumentPanel

public extension PEDocumentPanel {
    
    /// Uma estrutura que contém as propriedades do caminho selecionado no painel.
    ///
    /// A estrutura `PathProperties` armazena o último nome do arquivo, sua URL, e o diretório temporário associado.
    struct PathProperties: Hashable, Equatable {
        
        /// O último nome do arquivo selecionado.
        public let lastPath: String
        
        /// A URL completa do arquivo selecionado.
        public let url: URL
        
        /// Um diretório temporário associado ao arquivo.
        public let tempDirectory: URL
        
        /// Inicializa uma nova instância de `PathProperties`.
        ///
        /// - Parameters:
        ///   - lastPath: O último nome do arquivo.
        ///   - url: A URL do arquivo.
        ///   - tempDirectory: O diretório temporário associado.
        public init(lastPath: String, url: URL, tempDirectory: URL) {
            self.lastPath = lastPath
            self.url = url
            self.tempDirectory = tempDirectory
        }
        
        /// Compara dois objetos `PathProperties` para verificar se são iguais.
        ///
        /// - Parameters:
        ///   - lhs: O primeiro objeto `PathProperties`.
        ///   - rhs: O segundo objeto `PathProperties`.
        /// - Returns: `true` se ambos os objetos tiverem o mesmo `lastPath` e `url`, caso contrário, `false`.
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.lastPath == rhs.lastPath && lhs.url == rhs.url
        }
        
    }
    
}


