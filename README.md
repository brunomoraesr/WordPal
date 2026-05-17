# WordPal 📚

Aplicativo mobile de dicionário inteligente de inglês desenvolvido em **Flutter/Dart** como projeto final da disciplina de Desenvolvimento Mobile.

---

## Sobre o projeto

A **WordPal** nasceu de uma necessidade real de escolas de idiomas: os alunos usam o Google Tradutor para tudo, mas ele apenas traduz — não ensina. O app resolve isso oferecendo definições completas, pronúncia em áudio, exemplos de uso em contexto e um caderno pessoal de vocabulário, incentivando o aprendizado real da língua inglesa.

---

## Funcionalidades

### 🔍 Busca de palavras
- Campo de pesquisa com sugestões em tempo real
- Histórico das últimas 20 buscas (salvo com SharedPreferences)
- Preview das palavras salvas na tela inicial

### 📖 Tela de resultado
- Definições completas vindas da [Free Dictionary API](https://dictionaryapi.dev/)
- Classe gramatical (noun, verb, adjective…)
- Transcrição fonética
- Botão de reprodução de áudio com a pronúncia nativa
- Sinônimos e antônimos
- Exemplos de uso em frases reais
- **Radio buttons** para filtrar definições por classe gramatical
- **Switch** para modo "somente exemplos" (oculta definições para autoavaliação)

### 📓 Caderno de vocabulário
- Lista de todas as palavras salvas com definição, fonética e data
- **Checkbox** para marcar palavras como "dominadas"
- Filtro entre "Aprendendo" e "Dominadas"
- Swipe para deletar
- Armazenado localmente com **SQLite** (operações CRUD completas)

### 🃏 Flashcards
- Cards animados com flip 3D
- Frente: palavra + fonética
- Verso: definição + tradução PT
- Botões "Review again" e "Got it"

### 🧠 Quiz (Practice)
- Perguntas de múltipla escolha geradas automaticamente das palavras salvas
- Feedback visual imediato (verde = acerto, laranja = erro)
- Placar em tempo real.
- Tela de resultado com porcentagem de acerto

### 👤 Perfil
- Estatísticas do aluno (palavras salvas, dominadas, buscas)
- Gráfico de atividade semanal
- Conquistas desbloqueáveis
- Configurações de preferências

---

## Requisitos do projeto atendidos

| Requisito | Como foi implementado |
|---|---|
| Layout responsivo | `Row`, `Column`, `ListView`, `Wrap`, `SliverList` em todas as telas |
| Formulário com validação | Campo de busca com validação + `SnackBar` de erro |
| Radio Button | Filtro de classe gramatical na tela de resultado |
| Switch | Modo "somente exemplos" para autoavaliação |
| Checkbox | Marcar palavra como dominada no caderno |
| Navegação com rotas nomeadas | `/` → `/word` → `/flashcards` com passagem de dados |
| Consumo de API REST | Free Dictionary API com `Future`/`async-await`, loading e tratamento de erro |
| SQLite (CRUD) | Criar, listar, atualizar status e deletar palavras do caderno |
| SharedPreferences | Histórico de buscas e preferências de filtro |
| Gerenciamento de estado | `Provider` + `ChangeNotifier` + `StatefulWidget` |
| Simulação de publicação | Nome "WordPal", package `br.com.wordpal`, ícone personalizado, splash screen |
| Áudio (diferencial) | Reprodução da pronúncia nativa via URL da API com `audioplayers` |

---

## Arquitetura do projeto

```
lib/
├── main.dart                  # Entry point + navegação + bottom nav
├── theme/
│   └── app_theme.dart         # Cores e tema global
├── models/
│   ├── word_entry.dart        # Modelo da resposta da API
│   └── saved_word.dart        # Modelo do banco de dados local
├── services/
│   ├── dictionary_service.dart   # Requisições HTTP à Free Dictionary API
│   ├── database_service.dart     # SQLite — CRUD do caderno
│   └── preferences_service.dart  # SharedPreferences — histórico e filtros
├── providers/
│   └── app_provider.dart      # Estado global com ChangeNotifier
└── screens/
    ├── search_screen.dart     # Tela de busca
    ├── word_detail_screen.dart # Tela de resultado
    ├── notebook_screen.dart   # Caderno de vocabulário
    ├── flashcards_screen.dart # Flashcards com animação 3D
    ├── practice_screen.dart   # Quiz de múltipla escolha
    └── profile_screen.dart    # Perfil e estatísticas
```

---

## API utilizada

**Free Dictionary API** — [dictionaryapi.dev](https://dictionaryapi.dev/)
- Gratuita, sem necessidade de cadastro ou chave de API.
- Retorna definições, fonética, áudio, sinônimos, antônimos e exemplos

---

## Como rodar

**Pré-requisitos:** Flutter SDK instalado ([flutter.dev](https://flutter.dev))

```bash
# Instalar dependências
flutter pub get

# Rodar no emulador ou dispositivo conectado
flutter run
```

---

## Dependências principais

| Pacote | Uso |
|---|---|
| `http` | Requisições à Dictionary API |
| `sqflite` | Banco de dados SQLite local |
| `shared_preferences` | Armazenamento de preferências |
| `provider` | Gerenciamento de estado |
| `audioplayers` | Reprodução de áudio da pronúncia |
| `intl` | Formatação de datas |

---

## Equipe

Projeto desenvolvido para a disciplina de **Desenvolvimento Mobile**.  

