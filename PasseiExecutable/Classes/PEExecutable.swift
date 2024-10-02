//
//  PEExecutable.swift
//  DocumentParser
//
//  Created by Vagner Oliveira on 09/09/24.
//

import Foundation

/// Uma classe que representa um processo executável de linha de comando. Esta classe é responsável por executar comandos de terminal em Swift
/// e opcionalmente capturar sua saída, gerenciar o término do processo e lidar com timeouts.
///
/// - Nota: Esta classe pode lidar com comandos como `.unzip` ou outros especificados na enum `RecognizedCommands`.
@available(macOS 13.0, *)
public class PEExecutable {
    
    // MARK: - Propriedades
    
    /// O comando a ser executado pelo processo, representado pela enumeração `RecognizedCommands`.
    private let command: RecognizedCommands
    
    /// O objeto `Process` que representa o processo do sistema a ser executado.
    private let process: Process
    
    /// Um pipe que captura as saídas padrão e erros do processo.
    private let pipe: Pipe
    
    /// Uma lista de strings que representa os argumentos a serem passados para o comando que está sendo executado.
    private let arguments: [String]
    
    /// Um tempo limite opcional para a execução do processo.
    private let timeout: TimeInterval?
    
    /// Uma file de despacho privada.
    private let privateQueue = DispatchQueue(label: "com.passei.pe-executable", qos: .background)
    
    // MARK: - Inicializadores
    
    /// Inicializa a classe `PEExecutable` com o comando a ser executado, seus argumentos e um tempo limite opcional.
    ///
    /// - Parameters:
    ///   - command: O comando a ser executado, representado pela enumeração `RecognizedCommands`.
    ///   - arguments: Os argumentos que serão passados para o comando.
    ///   - timeout: O tempo limite opcional para a execução do processo.
    ///
    /// - Throws: Lança uma exceção se o comando for `.unzip` e o número de argumentos for diferente de 3.
    public init(command: RecognizedCommands, arguments: [String], timeout: TimeInterval? = nil) throws {
        if command == .unzip && arguments.count != 3 {
            throw PEExecutableException.invalidZIPArgummentsCount
        }
        
        process = Process()
        pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        self.arguments = arguments
        self.command = command
        self.timeout = timeout
    }
    
    /// Inicializa a classe `PEExecutable` para o comando `.unzip` com os argumentos fornecidos.
    ///
    /// - Parameters:
    ///   - arguments: Os argumentos que serão passados para o comando `unzip`.
    ///
    /// - Throws: Lança uma exceção se ocorrer um erro durante a inicialização.
    public convenience init(arguments: [String]) throws {
        try self.init(command: RecognizedCommands.unzip, arguments: arguments)
    }
    
    // MARK: - Métodos
    
    /// Executa o comando e retorna a saída como uma string.
    ///
    /// - Returns: A saída do comando executado.
    ///
    /// - Throws: Lança uma exceção se houver um erro durante a execução do comando ou na conversão dos dados de saída.
    public func execute() throws -> String {
        try privateQueue.sync {
            try run()
            process.waitUntilExit()
            try checkTerminationStatus(terminationStatus: process.terminationStatus)
            let data = try parseData()
            return try outputString(data: data)
        }
    }
    
    /// Executa o comando de forma assíncrona e captura a saída continuamente.
    ///
    /// - Parameters:
    ///   - captureOutput: Um closure que captura a saída como `Result<String, Error>`, que é chamado durante a execução.
    ///
    /// - Nota: Este método não foi totalmente testado, portanto, use o método `execute()` síncrono para casos garantidos.
    public func execute(captureOutput: @Sendable @escaping (Result<String, Error>) -> Void) {
        do {
            try privateQueue.sync {
                try run()
                
                if let timeout = timeout {
                    let processTerminated = process.waitUntilExitOrTimeout(timeout: timeout)
                    if !processTerminated {
                        process.terminate()
                        throw PEExecutableException.timeout
                    }
                } else {
                    captureOutput(.failure(PEExecutableException.timeoutNotDefined))
                    return
                }
                
                captureContinuousOutput(captureOutput: captureOutput)
            }
        } catch {
            captureOutput(.failure(error))
        }
    }
    
    // MARK: - Métodos Privados
    
    /// Inicia a execução do processo.
    ///
    /// - Throws: Lança uma exceção se ocorrer um erro ao iniciar o processo.
    private func run() throws {
        process.executableURL = URL(filePath: command.stringValue)
        process.arguments = arguments
        try process.run()
        process.terminationHandler = { _ in
            // Limpar se necessario
        }
    }
    
    /// Verifica o status de término do processo.
    ///
    /// - Parameters:
    ///   - terminationStatus: O status de término do processo.
    ///
    /// - Throws: Lança uma exceção se o status de término não for 0 (sucesso).
    private func checkTerminationStatus(terminationStatus: Int32) throws {
        guard terminationStatus == 0 else {
            throw PEExecutableException.terminationStatus(terminationStatus)
        }
    }
    
    /// Analisa os dados da saída do processo.
    ///
    /// - Returns: Os dados capturados da saída do processo.
    ///
    /// - Throws: Lança uma exceção se ocorrer um erro ao ler os dados.
    private func parseData() throws -> Data {
        guard let data = try pipe.fileHandleForReading.readToEnd() else {
            throw PEExecutableException.parseData
        }
        
        return data
    }
    
    /// Converte os dados em uma string de saída.
    ///
    /// - Parameters:
    ///   - data: Os dados a serem convertidos.
    ///
    /// - Returns: A saída convertida como string.
    ///
    /// - Throws: Lança uma exceção se os dados não puderem ser convertidos para string.
    private func outputString(data: Data) throws -> String {
        guard let output = String(data: data, encoding: .utf8) else {
            throw PEExecutableException.output
        }
        
        return output
    }
    
    /// Captura a saída do processo continuamente.
    ///
    /// - Parameters:
    ///   - captureOutput: Um closure que recebe a saída capturada como `Result<String, Error>`.
    private func captureContinuousOutput(captureOutput: @Sendable @escaping (Result<String, Error>) -> Void) {
        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                captureOutput(.success(output))
            } else {
                captureOutput(.failure(PEExecutableException.output))
            }
        }
    }
    
}


fileprivate extension Process {
    // Função de tempo limite (timeout)
    func waitUntilExitOrTimeout(timeout: TimeInterval) -> Bool {
        let deadline = DispatchTime.now() + timeout
        let result = DispatchSemaphore(value: 0)
        
        DispatchQueue.global().async {
            self.waitUntilExit()
            result.signal()
        }
        
        return result.wait(timeout: deadline) == .success
    }
}
