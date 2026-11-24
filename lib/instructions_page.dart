import 'package:flutter/material.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({
    super.key,
    this.showClose = false,
  });

  final bool showClose;

  @override
  Widget build(BuildContext context) {
    final goBackButton = IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => Navigator.of(context).pop(),
    );

    final closeButton = IconButton(
      icon: const Icon(Icons.close_rounded),
      onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
    );

    const titleStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    const contentStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    const titleSpace = SizedBox(height: 8);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Como jogar', style: titleStyle)),
        leading: goBackButton,
        actions: [
          if (showClose) closeButton,
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Objetivo', style: titleStyle),
              titleSpace,
              Text(
                'Encontre todas as palavras válidas que podem ser formadas '
                'com as 7 letras do dia. A letra do centro é obrigatória em '
                'todas as palavras.',
                style: contentStyle,
              ),
              SizedBox(height: 32),
              Text('Como jogar', style: titleStyle),
              titleSpace,
              Text(
                'Toque nas letras (a central e as ao redor) para montar uma '
                'palavra no centro da tela. Você pode usar a mesma letra '
                'várias vezes. Para enviar, toque no botão de confirmar ou '
                'na própria palavra.',
                style: contentStyle,
              ),
              titleSpace,
              Text(
                'Se a palavra for válida, ela passa a flutuar no céu e a '
                'barra de progresso avança.',
                style: contentStyle,
              ),
              titleSpace,
              Text(
                'Toque em apagar uma vez para tirar a última letra. '
                'Segure para limpar tudo.',
                style: contentStyle,
              ),
              titleSpace,
              Text(
                'Toque no ícone de embaralhar para reorganizar as letras ao '
                'redor e enxergar novas combinações.',
                style: contentStyle,
              ),
              titleSpace,
              Text(
                'Toque numa palavra flutuante para ver o significado, quando '
                'houver. Toque na linha das últimas palavras, ou arraste-a '
                'para cima, para abrir o Glossário com todas as que você '
                'achou.',
                style: contentStyle,
              ),
              SizedBox(height: 32),
              Text('Dicas', style: titleStyle),
              titleSpace,
              BulletPoint(
                'Toda palavra conta igual para o progresso, curta ou longa.',
              ),
              BulletPoint(
                'Palavras que usam todas as 7 letras ao menos uma vez '
                'são raras: são os pangramas.',
              ),
              SizedBox(height: 32),
              Text('Regras', style: titleStyle),
              titleSpace,
              BulletPoint('As palavras devem ter de 4 a 8 letras'),
              BulletPoint(
                'Todas as palavras devem conter a letra do centro',
              ),
              BulletPoint('As letras podem ser usadas mais de uma vez'),
              BulletPoint(
                'Algumas palavras podem não estar listadas '
                '(preposições e conjunções)',
              ),
              BulletPoint(
                'Somente os verbos no infinitivo são válidos. '
                'Exemplo: “subir”, “correr”, “jogar”...',
              ),
              BulletPoint(
                'Ambos os gêneros de uma palavra são válidos. '
                'Exemplo: “aluno”, “aluna”...',
              ),
              BulletPoint(
                'Plurais não são válidos. '
                'Exemplo: “laranjas”, “uvas”, “goiabas”... ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  const BulletPoint(
    this.content, {
    super.key,
  });

  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: '\u2022 ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
