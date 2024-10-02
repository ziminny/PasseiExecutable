//
//  PEExceptions.swift
//  DocumentParser
//
//  Created by Vagner Oliveira on 09/09/24.
//

import Foundation

/// Enum que define os diferentes tipos de exceções que podem ocorrer durante a execução do processo `PEExecutable`.
///
/// - Note: Cada caso de erro possui uma descrição associada que pode ser usada para fornecer mensagens localizadas.
public enum PEExecutableException: LocalizedError {
    
    /// Erro ao analisar os dados de saída do processo.
    case parseData
    
    /// Erro ao converter os dados de saída para uma string.
    case output
    
    /// Número de argumentos inválido para o comando `unzip`.
    case invalidZIPArgummentsCount
    
    /// O tempo limite foi atingido durante a execução do processo.
    case timeout
    
    /// A execução assíncrona foi utilizada, mas o tempo limite não foi definido.
    case timeoutNotDefined
    
    /// O processo terminou com um código de status diferente de zero.
    case terminationStatus(Int32)
    
    /// Fornece a descrição localizada para cada tipo de erro.
    ///
    /// - Returns: Uma string descrevendo o erro ocorrido.
    public var errorDescription: String? {
        switch self {
        case .parseData:
            return "Erro ao analisar os dados"
        case .output:
            return "Erro ao obter a saída do processo"
        case .invalidZIPArgummentsCount:
            return "O número de argumentos necessários para o comando unzip deve ser 3"
        case .timeoutNotDefined:
            return "Você está usando uma closure e o tempo limite não foi definido"
        case .timeout:
            return "O tempo limite foi atingido"
        case .terminationStatus(let code):
            return "Erro de término do processo com código \(code)"
        }
    }
}

/// Enum que define os diferentes tipos de exceções que podem ocorrer durante o processo de extração em `PEExtract`.
///
/// - Note: Cada caso de erro possui uma descrição associada que pode ser usada para fornecer mensagens localizadas.
public enum PEExtractException: LocalizedError {
    
    /// A propriedade `pathProperties` necessária não foi configurada corretamente.
    case pathProperties
    
    /// O arquivo `document.xml` necessário não foi encontrado no processo de extração.
    case xmlDocumentNotFound
    
    /// Fornece a descrição localizada para cada tipo de erro.
    ///
    /// - Returns: Uma string descrevendo o erro ocorrido.
    public var errorDescription: String? {
        switch self {
        case .pathProperties:
            return "A propriedade pathProperties não foi configurada corretamente"
        case .xmlDocumentNotFound:
            return "O arquivo document.xml não foi encontrado"
        }
    }
}

