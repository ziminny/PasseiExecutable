//
//  RecognizedCommands.swift
//  DocumentParser
//
//  Created by Vagner Oliveira on 09/09/24.
//

import Foundation

/// Enum que define os comandos reconhecidos que podem ser executados por `PEExecutable`.
///
/// Esta enumeração abrange comandos comuns como `unzip`, `bash`, e `sh`, além de permitir comandos personalizados por meio do caso `.custom`.
public enum RecognizedCommands: Equatable, Sendable {
    
    /// O comando `unzip`, utilizado para descompactar arquivos.
    case unzip
    
    /// O comando `bash`, utilizado para executar scripts no shell Bash.
    case bash
    
    /// O comando `sh`, utilizado para executar scripts no shell padrão.
    case sh
    
    /// Um comando personalizado definido pelo usuário.
    ///
    /// - Parameter String: O caminho ou comando a ser executado como string.
    case custom(String)
    
    /// Retorna o caminho completo do comando como uma string para ser executado pelo sistema.
    ///
    /// - Returns: O caminho do comando como string.
    internal var stringValue: String {
        switch self {
        case .unzip:
            return "/usr/bin/unzip"
        case .bash:
            return "/bin/bash"
        case .sh:
            return "/bin/sh"
        case .custom(let string):
            return string
        }
    }
}

