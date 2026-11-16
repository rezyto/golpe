# GOLPE — Plano mestre (ler isto primeiro)

Jogo original de crime multijogador para Android/iOS. Referência de GÉNERO: ROB RUN / Last Day on Earth.
REGRA: nada copiado (mapa, itens, personagens, arte, sons, UI). Só mecânicas genéricas, tudo nosso.

## Estado
- v0.1.0 (2026-11-16): protótipo web single-player (index.html), PWA instalável, auto-update no login.
- Nome provisório: GOLPE · Cidade: Vila Rubra · Contacto: Zé Faísca (Bar O Farol).

## Núcleo de jogo (v0.1)
- Login → Esconderijo (zona base) → sair → Mapa da cidade → escolher destino → spawn com carro → conduzir → agir → fugir.
- Assaltos (nível min / duração / cooldown): Café L1 6s 2min · Bomba L1 8s 3min · Hotel L3 12s 5min · Museu L5 18s 8min.
- Loot com peso → mochila (capacidade upgradável) → vender no Bar. Dinheiro sujo lava a 80%.
- Polícia: estrelas 0–5, viaturas IA perseguem; apanhado a pé = perde loot + multa 10%. Fugir pela borda da zona = escapa.
- Armeiro (armas), Stand (carros: velocidade/HP), Imobiliária (comprar + arrendar = renda passiva tempo real).
- Territórios: limpar gangue IA → território teu → rendimento/min.
- XP/nível desbloqueia destinos. Gravação em localStorage.

## Escala multijogador (alvo)
- 100/200/300 jogadores por servidor; cada destino = zona (instância) → só sincroniza a zona.
- Wipe por temporada 6–8 semanas; clãs, territórios PvP, polícia jogável (salário, patentes, prémio por detenção).

## Stack
- Agora: HTML5 Canvas + JS puro, PWA, GitHub Pages, version.json (auto-update).
- Produção: Unity (URP mobile) + Photon Fusion ou FishNet (servidor autoritativo) + Edgegap/Hathora/GameLift (EU + Brasil).
- Backend contas/economia: Nakama ou PlayFab. Updates nativos: Unity Addressables (conteúdo) + loja (binário).
- Monetização: cosméticos, carros skin, passe de temporada. NUNCA vender armas (sem pay-to-win).

## Auto-update (como funciona)
- version.json no repositório. Login lê version.json?t=… ; se versão > GAME_VERSION → mostra notas → recarrega.
- sw.js network-first: online vai sempre buscar a nova; offline usa cache.
- Para lançar update: mudar GAME_VERSION em index.html + version.json, commit, push. Pronto.

## Ferramentas / skills Claude úteis
- app-cloning: SÓ em modo clean-room (mapa de mecânicas, conteúdo original).
- frontend-design (UI/menus), dataviz (painel de economia), economia-de-tokens (sessões longas),
  vibe-security (antes de backend/pagamentos), docs (GDD), artifacts (testar no telemóvel).

## Roadmap de atualizações
- 0.2 Ciclo dia/noite (noite = menos polícia, mais recompensa) · minimapa · sons originais (sfxr).
- 0.3 Missões do Zé Faísca encadeadas · equipamento (máscara, broca, saco grande) · mini-jogo de cofre.
- 0.4 Banco (assalto em fases: entrar, cofre, fuga) · helicóptero a 5 estrelas · upgrades de carro.
- 0.5 Esconderijo evolutivo (oficina, cofre, garagem) · inventário em grelha · mercado negro com preços dinâmicos.
- 0.6 Multijogador LAN/teste (WebSocket, 20–30 jogadores) · chat · clãs básicos.
- 0.7 Polícia jogável · prisão · fiança.
- 1.0 Port Unity · servidores 100–300 · soft launch Android PT/BR · iOS a seguir.

## Ideias soltas
- Informadores vendem pistas (cofre aberto, menos guardas). Leilão de loot raro. Eventos semanais (camião blindado).
- Reputação por bairro; tréguas entre clãs; seguro de carro; carros roubados com GPS.

## Repositório (rezyto/golpe)
- web/ → GitHub Pages (workflow pages.yml). app/ → APK via workflow android.yml → Releases (golpe.apk).
- APK = casca que abre https://rezyto.github.io/golpe/?shell=X. Jogo atualiza sem reinstalar.
- Nova APK só se mudar app/: subir version em app/package.json + apk.version em web/version.json.
- Chave app/golpe-test.keystore é SÓ de teste. Antes da Play Store: chave nova em GitHub Secrets.
- iOS: PWA pelo Safari até haver conta Apple Developer (99€/ano) → depois Capacitor iOS + TestFlight.
