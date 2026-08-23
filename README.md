# Space Invaders

**Universidade de Fortaleza - UNIFOR**
**Centro de Ciências Tecnológicas - CCT**

**Disciplina:** T166 - Experimentação de Protótipos
**Professor:** Prof. M. David Martins Leite

---

Um clone do clássico jogo **Space Invaders** desenvolvido utilizando a **Godot Engine 4** para a disciplina de Experimentação de Protótipos.

## 👾 Sobre o Projeto

Este projeto é uma recriação do famoso jogo arcade *Space Invaders*. O objetivo do jogo é controlar uma nave na parte inferior da tela, atirar e destruir as ondas de alienígenas que se aproximam progressivamente, evitando ser atingido por eles ou que eles alcancem o limite inferior da tela.

O projeto foi construído com uma estética *pixel art* retrô, utilizando as configurações de filtro de textura e viewport adequadas para manter o visual clássico.

## 🚀 Tecnologias e Ferramentas

- **Godot Engine 4** (Forward Plus)
- **GDScript** (para toda a lógica e programação)

## 📁 Estrutura do Projeto

As principais cenas e scripts do jogo (localizados na pasta `cenas/`) incluem:

- `main.tscn`: A cena principal que gerencia o estado do jogo.
- `jogador.tscn` / `jogador.gd`: O jogador (nave), com movimentação e lógica de tiro.
- `alien.tscn` / `alien.gd`: O inimigo base do jogo.
- `groupAliens.tscn` / `groupAliens.gd`: Gerenciador responsável por controlar a movimentação em grupo e os ataques das hordas de alienígenas.
- `laser.tscn` / `laser.gd`: O projétil atirado pela nave do jogador.

## 🎮 Como Jogar

1. Baixe a [Godot Engine 4](https://godotengine.org/download/).
2. Clone este repositório ou baixe o código fonte.
3. Abra o **Godot Engine** e clique em **Import** (Importar).
4. Navegue até a pasta do projeto, selecione o arquivo `project.godot` e clique em **Import & Edit**.
5. Pressione `F5` ou clique no botão de **Play** no canto superior direito do editor para iniciar o jogo.

**Controles Básicos:**
- **Movimentação:** Setas direcionais / A e D (verificar as configurações de input do projeto)
- **Atirar:** Espaço (`Espaço` configurado no Input Map como `shoot`)

## 📝 Licença

Desenvolvido para fins de estudo e prática de desenvolvimento de jogos com Godot. Sinta-se livre para usar o código como referência.
