# 🕐 Sistema de Verificação de Pontos

Um aplicativo Flutter interativo e didático para verificação de pontos não batidos, desenvolvido para facilitar a identificação de problemas na movimentação de funcionários.

## ✨ Funcionalidades

### 📊 Dashboard Inteligente
- **Visão Geral**: Estatísticas completas dos funcionários e problemas
- **Filtros Avançados**: Busca por crachá e filtro por status (com/sem problemas)
- **Interface Intuitiva**: Cards coloridos e informativos

### 📁 Upload de Arquivo
- **Seleção de Arquivo**: Upload direto de arquivos .txt
- **Colar Conteúdo**: Opção para colar o conteúdo diretamente
- **Prévia**: Visualização do arquivo antes do processamento
- **Validação**: Verificação automática do formato dos dados

### 👤 Detalhes por Funcionário
- **Resumo Completo**: Estatísticas individuais de cada funcionário
- **Histórico de Pontos**: Visualização cronológica dos pontos batidos
- **Identificação de Problemas**: Destaque visual para dias com problemas
- **Filtros por Data**: Visualizar apenas dias com ou sem problemas

### 🔧 Correção de Pontos
- **Adição de Pontos**: Para funcionários com pontos faltantes
- **Remoção de Pontos**: Para funcionários com pontos em excesso
- **Validação**: Verificação automática de horários válidos
- **Interface Guiada**: Processo passo a passo para correção

## 🎨 Design e UX

### 🎯 Interface Moderna
- **Material Design 3**: Seguindo as últimas diretrizes do Material Design
- **Cores Temáticas**: Paleta verde profissional e confiável
- **Gradientes**: Efeitos visuais atrativos e modernos
- **Cards Elevados**: Hierarquia visual clara

### 📱 Responsividade
- **Adaptável**: Funciona em diferentes tamanhos de tela
- **Navegação Intuitiva**: Fluxo lógico entre telas
- **Feedback Visual**: Indicadores claros de status e ações
- **Acessibilidade**: Contraste adequado e tamanhos de fonte legíveis

## 🚀 Como Usar

### 1. **Início**
- Abra o aplicativo
- Na tela inicial, você verá opções para upload de arquivo

### 2. **Upload do Arquivo**
- **Opção 1**: Clique em "Selecionar Arquivo" e escolha seu arquivo .txt
- **Opção 2**: Clique em "Colar Conteúdo" e cole o conteúdo do arquivo
- Visualize a prévia do arquivo
- Clique em "Processar Arquivo"

### 3. **Dashboard**
- Visualize estatísticas gerais
- Use os filtros para encontrar funcionários específicos
- Clique em um funcionário para ver detalhes

### 4. **Detalhes do Funcionário**
- Veja o resumo completo do funcionário
- Use filtros para focar em dias com problemas
- Clique no botão de correção (se houver problemas)

### 5. **Correção de Pontos**
- Selecione a data com problemas
- Adicione pontos faltantes ou remova pontos em excesso
- Siga as instruções na tela

## 📋 Formato do Arquivo

O arquivo deve seguir o formato:
```
000000000122092509000001
000000000122092515000001
000000000122092516000001
000000000122092522100001
```

**Estrutura**: `CRACHA(10) + DIA(2) + MES(2) + ANO(2) + HORARIO(4) + FIXO(4)`

- **CRACHA**: 10 dígitos (ex: 0000000001)
- **DIA**: 2 dígitos (ex: 22)
- **MES**: 2 dígitos (ex: 09)
- **ANO**: 2 dígitos (ex: 25 para 2025)
- **HORARIO**: 4 dígitos no formato HHMM (ex: 0900)
- **FIXO**: 4 dígitos fixos (ex: 0001)

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework multiplataforma
- **Dart**: Linguagem de programação
- **Material Design 3**: Design system moderno
- **File Picker**: Seleção de arquivos
- **Path Provider**: Gerenciamento de caminhos
- **Intl**: Internacionalização e formatação

## 📦 Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  file_picker: ^8.0.0+1
  path_provider: ^2.1.2
  intl: ^0.19.0
  flutter_colorpicker: ^1.1.0
```

## 🎯 Benefícios

### Para Gestores
- **Visão Clara**: Identificação rápida de problemas
- **Economia de Tempo**: Processo automatizado
- **Relatórios Visuais**: Dashboards informativos
- **Correção Fácil**: Interface intuitiva para ajustes

### Para Funcionários
- **Transparência**: Acesso aos próprios dados
- **Clareza**: Visualização clara dos pontos
- **Correção Rápida**: Processo simplificado para ajustes

## 🔮 Próximas Funcionalidades

- [ ] Exportação de relatórios
- [ ] Notificações push
- [ ] Sincronização em nuvem
- [ ] Histórico de correções
- [ ] Relatórios personalizados
- [ ] Integração com sistemas externos

## 📱 Compatibilidade

- **Android**: 5.0+ (API 21+)
- **iOS**: 11.0+
- **Web**: Navegadores modernos
- **Desktop**: Windows, macOS, Linux

---

**Desenvolvido com ❤️ para facilitar a gestão de pontos e melhorar a experiência dos usuários.**

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
