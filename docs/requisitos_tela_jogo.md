# Requisitos — nova tela de jogo (palavras flutuantes)

Referência visual e de comportamento: [`mock_caderno.html`](../mock_caderno.html) (mock interativo, palavras e significados mockados). Paleta: `Caderno` em [`lib/theme.dart`](../lib/theme.dart).
Quando este documento e o mock divergirem, vale este documento. O mock ainda mostra nível e pontos (chip, "Faltam N pts", "+N" no selo); no app eles não existem.

## Contexto

Hoje a tela de jogo é: ícones de ajuda e menu; grade de 3 colunas com os pills "N letras"; barra de progresso; campo de input; botões Deletar / shuffle / Checar; flor de 7 círculos. A nova tela troca a grade e o campo de input por um céu de palavras flutuantes, com a palavra digitada no centro dele, e encosta os botões na colmeia.

## Decidido

- Paleta "Caderno", **só tema claro**. Não há tema escuro nem botão de trocar tema.
- Fontes: serifa de livro para palavras, wordmark e títulos (`"Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif`); sans do sistema para o resto da UI.
- Palavras encontradas aparecem com o significado, quando ele existe.
- **Sem pontuação e sem níveis.** O app atual não classifica o jogador por pontos, e a tela nova também não: o progresso é contado em palavras.
- A lista completa (Glossário) abre como bottom sheet: uma lista corrida com uma seção por tamanho de palavra, cada encontrada numa linha de verbete, e no fim de cada seção quantas faltam.
- Apagar, Enviar e Embaralhar ficam ao lado da colmeia; nada abaixo dela.
- Não existe campo de texto: a palavra digitada vive no céu, junto das flutuantes.
- Cursor vazio: versão 4 do mock (cursor teal que pisca e palavras que somem perto dele).

## Layout (de cima para baixo)

1. Header: wordmark "Letraço" e menu.
2. Trilha de progresso: barra + "X de Y palavras".
3. Céu: ocupa todo o espaço restante. Contém as palavras flutuantes, a palavra digitada no centro e, encostada na base, a linha "Últimas".
4. Linha de jogo: coluna esquerda (Embaralhar acima, Apagar abaixo), colmeia de hexágonos no centro, Enviar à direita na altura do Apagar.

## Requisitos

### Palavras flutuantes

- **AC-1** Dado um jogo com palavras encontradas, quando a tela abre, então cada palavra encontrada aparece no céu em minúsculas, numa posição e profundidade sorteadas a cada abertura, espalhadas pelo céu inteiro, sem sobrepor outra palavra de profundidade parecida, e totalmente dentro da área do céu. As posições só são sorteadas depois que o céu tem tamanho: nunca começam todas agrupadas num canto.
- **AC-2** Dado o céu aberto, quando o tempo passa, então cada palavra se move livremente com física de posição (velocidade, direção que muda devagar, quique suave nas bordas), sem sair da área do céu.
- **AC-3** Dado o céu aberto, quando o tempo passa, então a profundidade de cada palavra muda continuamente num ciclo próprio de 25–45 s, com ponto e sentido iniciais diferentes por palavra (umas se aproximam enquanto outras se afastam).
- **AC-4** Dada uma palavra numa profundidade z (0 longe, 1 perto), então: tamanho 12 px (longe) a 28 px (perto); opacidade 0,26 a 0,82; desfoque leve só nas mais distantes (z < 0,3); a mais perto fica na frente. A mudança de tamanho é em torno do centro da palavra.
- **AC-5** Dadas duas palavras com profundidades próximas (diferença ≤ 0,3), quando se encostam, então se afastam; com profundidades diferentes, uma passa na frente da outra.
- **AC-6** Cada palavra tem um tom fixo da paleta (variação de mais clara a mais escura); pangramas usam mel.
- **AC-7** Nenhuma palavra flutuante chega à camada do input: nunca fica do tamanho (46 px), da opacidade sólida ou da cor sólida da palavra digitada, nem por cima dela.
- **AC-8** Dado um celular inclinado, então as palavras mais próximas se deslocam mais que as distantes (paralaxe por inclinação). Não há paralaxe pelo mouse.
- **AC-9** Dado "reduzir movimento" ativo no sistema, então as palavras não vagueiam nem mudam de profundidade sozinhas.

### Tocar numa palavra flutuante

- **AC-10** Dada uma palavra flutuante, quando o jogador toca nela, então ela vai para a frente das outras flutuantes, fica preta (tinta), 30 px, 90% de opacidade, e um card com o significado aparece acima dela e a acompanha enquanto ela se move.
- **AC-11** Dado o card de significado aberto, quando passam 5 s, então ele some.
- **AC-12** Dado o card aberto, quando o jogador toca em qualquer lugar que não seja uma palavra flutuante, então o card fecha na hora; tocar em outra palavra troca o card para ela.
- **AC-13** A palavra tocada continua na frente até outra ser tocada; então volta ao seu ciclo de profundidade.
- **AC-14** Palavras que passam atrás da área do input continuam tocáveis: sem letras digitadas, a área do input não captura toque; com letras, só as próprias letras capturam (e enviam a palavra).

### Palavra digitada (sem campo de texto)

- **AC-15** Dado nenhum caractere digitado, então no centro do céu há só um cursor teal de 3 px × 48 px que pisca (500 ms aceso, 500 ms apagado), e a dica "Toque nas letras · toda palavra usa o R" embaixo.
- **AC-16** Dado nenhum caractere digitado, quando uma flutuante passa perto do cursor, então ela fica transparente proporcionalmente à proximidade (mínimo 8%) e volta ao normal ao se afastar. Sem glow, halo ou pulsação no cursor.
- **AC-17** Dado o jogador tocando letras, então a palavra aparece no centro do céu, grande (46 px, serifa), letras em tinta e a letra central em teal, com o cursor fino piscando no fim e a contagem "N letras" embaixo.
- **AC-18** Dado o jogador tocando uma letra, então sai da palavra uma onda (anel teal fraco que se expande) que empurra as flutuantes para fora de trás da palavra: mais forte nas mais próximas e um pouco depois nas mais distantes. Força da onda: 50 (constante do mock).
- **AC-19** Dadas letras digitadas, quando uma flutuante entra na área da palavra e do texto embaixo, então ela é empurrada de volta para fora com força contínua 1 (constante do mock).
- **AC-20** Um halo cor de papel discreto em volta das letras e do texto embaixo separa a palavra das flutuantes (sombras de 4/12/20 px nas letras e 5/10 px no texto), sem esconder as palavras atrás.
- **AC-21** Dadas 8 letras digitadas, quando o jogador toca outra letra, então ela não entra e aparece "Máximo de 8 letras".

### Enviar

- **AC-22** Dada uma palavra válida e nova, quando o jogador envia, então as letras ficam teal e pulam, o significado aparece embaixo ("palavra · significado", só se houver significado), um selo mel comemora sem pontos ("Boa!", "Ótima!" para 6+ letras, "Pangrama!"), a barra de progresso avança, e na linha "Últimas" a palavra nova entra pela esquerda, em teal (~450 ms), a mais antiga das três sai e o contador "Glossário · N" sobe.
- **AC-23** Dada uma palavra válida e nova, depois de ~650 ms, então ela vira uma flutuante **no mesmo lugar e no mesmo tamanho** em que foi digitada, sem velocidade inicial, e diminui em torno do centro até o tamanho e a opacidade da profundidade dela; só então passa a flutuar e ser empurrada como as outras.
- **AC-24** Dada uma palavra com menos de 4 letras, quando enviada, então fica vermelha, treme, mostra "Curta demais — mínimo 4 letras" e some (encolhe, desfoca e desaparece em ~0,5 s depois de ~650 ms).
- **AC-25** Dada uma palavra sem a letra central, quando enviada, então fica vermelha, treme, mostra "Falta o R, a letra do centro", o hexágono central pulsa duas vezes, e a palavra some como no AC-24.
- **AC-26** Dada uma palavra que não está na lista, quando enviada, então fica vermelha, treme, mostra "Não está na lista" e some como no AC-24.
- **AC-27** Dada uma palavra já encontrada, quando enviada, então fica cinza com "Já encontrada" e some, e a flutuante dessa palavra faz o mesmo que o toque do AC-10 (vai para a frente, fica preta, mostra o significado).
- **AC-28** Dado um resultado sendo exibido, quando o jogador toca uma letra, então o resultado é descartado e uma palavra nova começa com essa letra.
- **AC-29** Tocar na palavra digitada também envia. Acentos não importam.

### Botões

- **AC-30** Apagar, Enviar e Embaralhar têm o mesmo estilo: redondos, contorno fino, fundo transparente, ícone cinza, sem legenda; alvos de toque ≥ 40 px.
- **AC-31** Dado letras digitadas, quando o jogador toca Apagar, então a última letra sai; quando segura Apagar por 450 ms, então a palavra inteira é limpa.
- **AC-32** Quando o jogador toca Embaralhar, então as 6 letras externas trocam de lugar com animação (~320 ms) e a letra central não se move.

### Últimas e Glossário

- **AC-33** A linha "Últimas" fica parada na base do céu, sempre visível: um fio fino alinhado às margens da trilha de progresso (20 px) e, embaixo dele, as 3 palavras mais recentes em serifa, separadas por "·" (a mais nova primeiro, em teal), com "Glossário · N ›" em teal à direita, onde N é o total de palavras encontradas. Sem card, sombra, rótulo, botão ou ponto pulsando. A linha reserva 44 px na base do céu (as flutuantes não entram nessa faixa) e tem área de toque de 44 px de altura.
- **AC-34** Quando o jogador toca a linha "Últimas" ou a arrasta para cima (24 px), então o Glossário abre como bottom sheet, com fundo de folha (`card`, um branco quente mais claro que o papel da tela, para a folha parecer estar por cima): título "Glossário" e "X de Y palavras", e uma lista corrida (sem abas) com uma seção para cada tamanho de palavra que existe no jogo (4 a 8 letras). Cada seção abre com um fio teal de 2 px e o cabeçalho "N LETRAS" à esquerda e "F DE T" à direita.
- **AC-35** Dentro de cada seção, cada palavra encontrada é uma linha de verbete, em ordem alfabética: a palavra em minúsculas, serifa, negrito, teal, seguida do significado quando existir (sem significado, a linha mostra só a palavra). As linhas são separadas por pontilhado. Pangramas ficam em mel com o selo "pangrama"; a mais recente leva o selo "nova" e um fundo teal-claro que some aos poucos (~1,6 s).
- **AC-36** No fim de cada seção, uma faixa teal-clara cheia, sem borda, diz quantas faltam: "Faltam **N** palavras" ("Falta **1** palavra" no singular), com o número maior, na serifa. Seção completa mostra "Todas achadas" só com contorno. As palavras que faltam não aparecem, nem como vagas em branco.
- **AC-37** Dado o Glossário aberto, quando o jogador toca no X, no fundo escurecido ou aperta Esc, então ele fecha.

### Progresso

- **AC-38** A barra enche pela fração de palavras encontradas sobre o total do jogo, e o texto embaixo diz "X de Y palavras". Não há pontos por palavra, nível, chip de nível nem "Partida ganha!".

### Teclado físico

- **AC-39** Letras do jogo, Backspace e Enter funcionam como toque, Apagar e Enviar; Esc fecha o Glossário; outras teclas são ignoradas.

## Fora do escopo

- Tema escuro.
- Paralaxe pelo mouse.
- Pontuação e níveis.
- Dicas, ranking, estatísticas e onboarding (estão nas propostas, não neste pedido).
- O seletor de versões do cursor e a nota explicativa fora do celular (existem só no mock).

## Assumido (confirmar)

- **Origem dos significados.** O app não tem definições hoje. O mock usa 47 significados escritos à mão. Para o app é preciso uma definição curta por palavra do dicionário (~18 mil), por exemplo gerada a partir do Wiktionary pt (CC BY-SA, exige atribuição), guardada junto de `word_frequency.dart`. **Falha:** palavra sem significado mostra só a palavra, sem card vazio e sem texto "sem significado". No app, os significados vêm de `lib/definitions.dart`, que por enquanto está vazio.
- **Maiúsculas → minúsculas.** Ao virar flutuante (AC-23), a palavra troca de MAIÚSCULAS para minúsculas na hora.
- **Haptics.** Toque leve ao acertar e duplo ao errar, como no mock (`navigator.vibrate`); no app, `HapticFeedback`.
- **Constantes de física.** Força da onda 50, empurrão contínuo 1, ciclo de profundidade 25–45 s e encolhimento da palavra nova (~3 s até a profundidade) são os valores ajustados no mock; podem ser recalibrados no aparelho.
- **Fonte.** Iowan Old Style vem no iOS; no Android a serifa cai para a Noto Serif. Para ter a mesma letra nas duas plataformas, a fonte precisa ir junto com o app.
- **Persistência.** Palavras encontradas continuam salvas como hoje; a posição e a profundidade das flutuantes não são salvas e são sorteadas a cada abertura.
