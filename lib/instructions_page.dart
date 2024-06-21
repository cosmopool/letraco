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
              Text('O jogo', style: titleStyle),
              titleSpace,
              Text(
                'Descubra as palavras contidas na lista utilizando a letra '
                'central e as que estão ao redor.',
                style: contentStyle,
              ),
              titleSpace,
              Text(
                'Após usar as letras para escrever uma palavra, clique no '
                'botão "Checar" para verificar se a palavra existe na lista.',
                style: contentStyle,
              ),
              titleSpace,
              Text(
                'Pressione uma vez o botão "Deletar" para deletar a letra '
                'mais recente e segure pressionado para deletar todas as '
                'letras.',
                style: contentStyle,
              ),
              SizedBox(height: 32),
              Text('Regras', style: titleStyle),
              titleSpace,
              BulletPoint(
                'Nem todas as palavras que existem '
                'estão listadas no jogo',
              ),
              BulletPoint('As palavras devem conter no mínimo 4 letras'),
              BulletPoint(
                'As palavras devem, obrigatoriamente, '
                'conter a letra do centro',
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
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: '\u2022 ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
