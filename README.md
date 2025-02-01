
# 🛠️ PasseiExecutable

[![CI Status](https://img.shields.io/travis/Vagner%20Reis/PasseiExecutable.svg?style=flat)](https://travis-ci.org/Vagner%20Reis/PasseiExecutable)
[![Version](https://img.shields.io/cocoapods/v/PasseiExecutable.svg?style=flat)](https://cocoapods.org/pods/PasseiExecutable)
[![License](https://img.shields.io/cocoapods/l/PasseiExecutable.svg?style=flat)](https://cocoapods.org/pods/PasseiExecutable)
[![Platform](https://img.shields.io/cocoapods/p/PasseiExecutable.svg?style=flat)](https://cocoapods.org/pods/PasseiExecutable)

O **PasseiExecutable** é uma biblioteca em Swift desenvolvida para execução e gerenciamento de comandos de terminal em aplicações macOS.

---

## **Descrição**

Esta biblioteca fornece uma interface para trabalhar com processos executáveis no terminal. Ideal para aplicações que precisam executar comandos de forma programática, capturar saídas e gerenciar exceções.

---

## **Exemplo de Uso**

Para rodar o projeto de exemplo, siga os passos abaixo:

1. Clone o repositório.
2. Navegue até o diretório `Example`.
3. Execute o comando `pod install`.
4. Abra o projeto no Xcode e rode o exemplo.

---

## **Requisitos**

- **Swift**: 6.0 ou superior
- **macOS**: Compatível com macOS 10.13+
- **CocoaPods** instalado

---

## **Instalação**

### **Usando CocoaPods**

PasseiExecutable está disponível no [CocoaPods](https://cocoapods.org). Para instalar, adicione a seguinte linha ao seu `Podfile`:

```ruby
pod 'PasseiExecutable'
```

Depois, execute o comando:

```bash
pod install
```

### **Manual**

Você também pode importar o projeto diretamente ao clonar o repositório e adicionar os arquivos necessários ao seu projeto.

---

## **Como Usar**

### **Exemplo Básico em Swift:**

```swift
import PasseiExecutable

let executable = PEExecutable(command: "/usr/bin/env")
executable.run { output, error in
    if let output = output {
        print("Saída:", output)
    }

    if let error = error {
        print("Erro:", error)
    }
}
```

---

## **Contribuição**

Contribuições são bem-vindas! Siga os passos abaixo para colaborar:

1. Faça um fork do projeto.
2. Crie uma branch para suas alterações (`git checkout -b minha-feature`).
3. Faça commit das alterações (`git commit -m 'Minha nova feature'`).
4. Envie as alterações para o seu fork (`git push origin minha-feature`).
5. Abra um Pull Request para revisão.

---

## **Licença**

PasseiExecutable está disponível sob a licença **MIT**. Consulte o arquivo `LICENSE` para mais informações.

---

## **Autor**

Desenvolvido por **Vagner Oliveira**  
E-mail: ziminny@gmail.com

---

## **Recursos úteis**

- [Documentação do Swift](https://swift.org/documentation/)
- [Core Foundation](https://developer.apple.com/documentation/corefoundation/)
- [Documentação CocoaPods](https://guides.cocoapods.org/)
