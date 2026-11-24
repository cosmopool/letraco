# Acervos e Meu acervo · decisões

As telas, componentes e textos estão no livro (`docs/design_system.html`, seção **Acervos**). A proposta visual completa, com todos os estados e o celular ao vivo, está em `docs/feature.html`. Este arquivo guarda só o que cabe em texto: as decisões, o que mudou no livro e o que ainda está em aberto.

## Implementação

- **Duas features no pipeline**, cada uma com o seu MR (`/req-gather` → `/dev-run`):
  1. **Dicionário:** script em `tool/`, arquivo em `assets/` e leitura no app. O jogo de hoje vira a Estante.
  2. **Acervos e Meu acervo:** folha Novo jogo, Montar acervo e linha de retorno.
- **Livro antes do código:** a seção Acervos já está no `docs/design_system.html`.

## Dicionário

- **Formato:** um arquivo só em `assets/`, gerado pelo script em `tool/` e lido uma vez na abertura para arrays planos. Saem `lib/words.dart`, `lib/word_frequency.dart` e `lib/definitions.dart`.
- **Fontes:** Wikcionário (pt, via kaikki.org), wordfreq e FrequencyWords (pt_br, feito com legendas do OpenSubtitles).
- **Cortes das paradas:** são calculados no build pela quantidade de palavras. O script acha o Zipf que dá cada tamanho-alvo e grava o corte no arquivo.

  | Parada | Alvo | Usada por |
  |---|---|---|
  | do dia a dia | ~5 mil | Bolso |
  | comuns | ~8 mil | — |
  | de leitor | ~11 mil (a Estante de hoje) | Estante |
  | raras | ~13 mil | — |
  | raríssimas | tudo com Zipf > 0 (~15 mil) | Sebo |

- **Diminutivo e aumentativo:** são separados. O Wikcionário diz qual é na própria definição ("diminutivo de …", "aumentativo de …"; no dump: 361 e 146).
- **Palavrão:** nunca entra no arquivo.

## Licença e crédito

- Os dados do Wikcionário, do wordfreq e do FrequencyWords são CC BY-SA 4.0.
- Só o arquivo do dicionário sai como CC BY-SA 4.0, com um `NOTICE` ao lado (fontes, datas dos dumps, licença). O código do app não muda de licença.
- **Onde aparece o crédito:**
  - **Como jogar › Fontes:** Wikcionário (via kaikki.org), wordfreq, FrequencyWords e OpenSubtitles.
  - **Loja** (`store_listing/listing_pt-BR.md`): "Significados do Wikcionário (via kaikki.org). Frequências: wordfreq e FrequencyWords (OpenSubtitles). Dados sob CC BY-SA 4.0."

## Os acervos

- **Nomes:** Bolso, Estante, Sebo e Meu acervo. A palavra "acervo" aparece só no código, no livro e no "Meu acervo"; a folha pergunta "De onde vêm as palavras?".
- **O que separa os fixos:** só a raridade.
  - Os três usam a regra da Estante de hoje: substantivo, adjetivo, verbo e advérbio; forma base e feminino; sem palavras de Portugal nem antigas; 4 a 8 letras.
  - Bolso ⊂ Estante ⊂ Sebo.
  - Plurais, conjugações, as outras formas e classes e as palavras de Portugal ou antigas só existem no Meu acervo.
- **Palavrão:** nunca, em nenhum acervo, nem no Meu acervo. Não há controle para isso.
- **Primeira abertura:** não pergunta nada; o primeiro jogo é na Estante.
- **Mudar de acervo:** só ao começar um jogo novo, pela folha Novo jogo. O jogo em andamento nunca muda.
- **Selo "novo":** não existe. A folha é sempre a mesma.

## Folha Novo jogo

- **Linha Meu acervo:** sempre "Você escolhe o que entra.". Nunca um resumo da regra, sem exemplos e sem contagem.
- **Letras antes de começar:** Bolso, Estante e Sebo não mostram nem sorteiam letras. Só o Meu acervo.

## Montar acervo

- **Um só Meu acervo,** editado no lugar. Começa como cópia da Estante.
- **Salvar:** cada toque salva. Não há Desfazer nem Cancelar; para voltar, use "Copiar".
- **Copiar:** três pílulas sempre iguais, só com o nome: "Bolso", "Estante", "Sebo".
- **Resultado sempre visível:**
  - Fica preso no topo: as letras do próximo jogo, o número de palavras com estas letras e "Sortear outras".
  - Nenhuma opção mostra quanto vai mudar antes do toque. O número muda logo depois do toque, sem dizer quanto era antes.
- **Contagem do acervo:** na faixa teal clara do livro, como primeira coisa da lista. Não fica presa; rola com a lista. O rodapé tem só "Pronto".
- **Quão raras:** slider com 5 paradas.
  - Cada parada tem uma descrição curta e 3 exemplos fixos, nunca filtrados pelas letras. Um exemplo pode, raramente, ser palavra do jogo sorteado.
  - **Descrições:** Todo mundo conhece. · Quase todo mundo conhece. · Quem lê bastante conhece. · Pouca gente conhece. · Quase ninguém conhece.
  - A palavra "frequência" nunca aparece na tela.
- **Classes e formas:** grade de 2 colunas iguais. O nome que não cabe quebra em 2 linhas dentro da célula, sem reticências.
- **Última classe:** pode desligar. Com tudo desligado, o acervo fica vazio ("Nenhuma palavra · passa pelos seus filtros. Solte algum para poder jogar.").
- **Tamanho:** "De 4 a 8 letras"; a seção se chama "Tamanho".

## Letras e geração do jogo

- **Filtros e letras:** um filtro nunca troca as letras; só "Sortear outras" troca.
- **Sorteio guardado:** depois que um jogo começa com as letras salvas, o próximo Montar acervo sorteia outras.
- **Menos de 50:** só avisa. O "9" aparece grande em vermelho, com "palavras com estas letras. O jogo vai ter menos de 50.". Não há piso: de 1 a 49 palavras, o jogo começa.
- **0 palavras com estas letras:** o jogo não começa, e a tela pede outro sorteio.
- **Acervo vazio:** a linha diz "Nenhuma palavra com estas letras.", sem "Sorteie outras". O botão "Sortear outras" fica a 45% e sem toque.
- **Teto por jogo:** 150 palavras. O gerador procura um sorteio com 50 a 150 palavras; se não achar nenhum, fica com o mais perto da faixa. O build falha se algum acervo fixo tiver menos de 500 conjuntos de letras nessa faixa.
- **Letras de exemplo no livro:**
  - R + E H A L O C só para o jogo em andamento (palavra fora, card de significado, Glossário, tela de jogo).
  - O Montar acervo usa P + A R T E I L.

## Linha de retorno

- **Nos fixos, palavra rara demais:** "Existe, mas mora na Estante / no Sebo". Num pangrama: "**Pangrama**, mas mora no …", com "Pangrama" em `--honey-ink`.
- **Nos fixos, palavra fora por forma, classe ou uso:** diz o motivo, sem tremida, e que aquele tipo só entra no Meu acervo, em até 2 linhas. Ex.: "Existe, mas é plural. Plurais só entram no Meu acervo."
- **No Meu acervo:** só o motivo. Ex.: "Existe, mas é plural".
- **Palavra com Zipf 0:** está no dicionário, mas em nenhum acervo. Em qualquer acervo, a linha diz "Existe, mas é rara demais", antes de qualquer outro motivo.
- **Ordem do motivo:** tamanho › classe › forma › uso › raridade. A exceção é o Zipf 0.
- **Significado de palavra fora:** não se mostra; só o motivo.
- **Nome da lista:** "Glossário".

## O que mudou em textos que já estavam no livro

| Onde | Antes | Agora |
|---|---|---|
| Selo do topo | Sem pontos e sem níveis | Sem pontos e sem ranking |
| Princípio "Progresso em palavras" | Não há nível, ranking nem "partida ganha". | Não há ranking nem "partida ganha". O acervo diz de onde vêm as palavras, não quanto vale quem joga. |
| Cabeçalho e trilha | Não existe pontuação nem nível. | Não existe pontuação. À direita da contagem, o acervo do jogo. |
| Menu | Novo jogo abre o diálogo de confirmação | Novo jogo abre a folha Novo jogo; o Montar acervo é a rota `/acervo`, aberta só pela folha |
| Diálogo | Hoje só confirma um novo jogo. | Sai do livro |
| Fazer e não fazer | Pontos, níveis, ranking ou "partida ganha". | Pontos, ranking ou "partida ganha"; acervo com cara de nível; mostrar quanto uma opção vai mudar antes do toque. |
| Como jogar · Regras | Algumas palavras podem não estar listadas (preposições e conjunções) · Somente os verbos no infinitivo são válidos · Plurais não são válidos | As regras valem para Bolso, Estante e Sebo; no Meu acervo, vale o que estiver ligado. Sai a linha de preposições e conjunções. |

Ainda falta atualizar `docs/requisitos_tela_jogo.md`, que diz "sem níveis" em três lugares. Isso vai junto com a feature.

## Em aberto

- **Quantos sorteios usar:** 200 sorteios fixos decidem o aviso de pouca palavra, e até 1 000 geram o jogo. Medir num aparelho lento na implementação; se passar de ~100 ms, baixar.
