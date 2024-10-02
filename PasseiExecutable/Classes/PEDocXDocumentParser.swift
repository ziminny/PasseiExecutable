//
//  PEDocXDocumentParser.swift
//  DocumentParser
//
//  Created by Vagner Oliveira on 09/09/24.
//

import Foundation
import AppKit

/// Uma classe que analisa o conteúdo XML de um documento do Word e aplica formatações básicas de texto como negrito, itálico e sublinhado.
///
/// A classe `PEWordDocumentParser` implementa o protocolo `XMLParserDelegate` para analisar documentos Word em formato XML,
/// convertendo o conteúdo em texto enriquecido com formatação HTML-like.
///
/// - Note: As formatações suportadas incluem negrito (`<b>`), itálico (`<i>`) e sublinhado (`<u>`).
public class PEDocXDocumentParser<RuleConformable: PERulesProtocol>: NSObject, XMLParserDelegate {
    
    // MARK: - Propriedades
    
    /// A tag XML atualmente sendo processada.
    private var currentElement = ""
    
    /// O texto formatado encontrado durante a análise do documento.
    private var foundText = ""
    
    /// O texto atual acumulado entre as chamadas de `foundCharacters`.
    private var currentText = ""
    
    /// Regras.
    private var rules = RuleConformable()
    
    // MARK: - Métodos do XMLParserDelegate
    
    /// Método chamado no início de um elemento XML. Identifica e marca os elementos de formatação (`w:b`, `w:i`, `w:u`).
    ///
    /// - Parameters:
    ///   - parser: O objeto `XMLParser` que está executando a análise.
    ///   - elementName: O nome do elemento XML encontrado.
    ///   - namespaceURI: O URI do namespace associado ao elemento.
    ///   - qName: O nome qualificado do elemento XML.
    ///   - attributeDict: Os atributos associados ao elemento XML.
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        // Verificar formatação
        rules.predefinedValues(ofKey: elementName)
        
        // Resetar o texto acumulado
        if elementName == "w:t" {
            currentText = ""
        }
        
    }
    
    /// Método chamado quando o parser encontra caracteres entre tags XML. Aplica formatação ao texto encontrado (`w:t`).
    ///
    /// - Parameters:
    ///   - parser: O objeto `XMLParser` que está executando a análise.
    ///   - string: O texto encontrado entre as tags XML.
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "w:t" { // `w:t` representa o texto no XML do Word
            
            // Acumular o texto
            if currentElement == "w:t" {
                currentText += string
            }
            
        }
    }
    
    /// Método chamado no fim de um elemento XML. Reseta as flags de formatação quando o elemento `w:r` termina.
    ///
    /// - Parameters:
    ///   - parser: O objeto `XMLParser` que está executando a análise.
    ///   - elementName: O nome do elemento XML que está sendo fechado.
    ///   - namespaceURI: O URI do namespace associado ao elemento.
    ///   - qName: O nome qualificado do elemento XML.
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // Se terminamos de processar uma tag de texto (`w:t`), aplicar a formatação e adicionar ao texto final
        if elementName == "w:t" {
            var text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Aplicar formatação ao texto
            text = rules.search(foundtext: text)
            
            foundText += text
        }
        
        // Resetar as flags de formatação ao fim do `w:r`
        if elementName == "w:r" {
            rules.reset()
        }
        
        currentElement = ""
    }
    
    // MARK: - Método de Parsing
    
    /// Inicia o processo de análise do conteúdo XML fornecido e retorna o texto encontrado com a formatação aplicada.
    ///
    /// - Parameter xmlContent: O conteúdo XML do documento Word a ser analisado.
    /// - Returns: Uma string contendo o texto formatado.
    public func parse(xmlContent: String) -> [RuleConformable.Searcheable]? {
        let data = xmlContent.data(using: .utf8)!
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        return rules.result
    }
}

public protocol PERulesProtocol {
    
    associatedtype Searcheable: Codable & Sendable
    
    var result: Array<Searcheable> { get set }
    
    mutating func predefinedValues(ofKey key: String)
    mutating func search(foundtext: String) -> String
    mutating func reset()
    
    init()
}


