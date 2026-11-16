# GOLPE

Jogo 3D original de crime em mundo aberto (Vila Rubra), feito em **Godot 4.3**, app nativa Android.

- **Instalar (Android):** descarregar `golpe.apk` em [Releases → latest](https://github.com/rezyto/golpe/releases/tag/latest) e instalar.
- **Atualizações:** automáticas no arranque. A app lê `version.json` dos Releases e descarrega `game.pck` se houver versão nova.
- **iPhone:** precisa de conta Apple Developer (99€/ano) para TestFlight.

Estrutura: `jogo/` projeto Godot · `jogo/boot/` arranque + auto-update · `jogo/game/` jogo · `keys/` chave de TESTE · `PLANO.md` plano.

Cada push em `jogo/` → GitHub Actions verifica scripts, compila APK + game.pck e publica. Nova APK só é pedida ao jogador quando `jogo/boot/app_version.txt` sobe.
