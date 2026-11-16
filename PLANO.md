# GOLPE — Plano mestre (ler isto primeiro)

Jogo original de crime multijogador para Android/iOS. Referência de GÉNERO: ROB RUN / Last Day on Earth.
REGRA: nada copiado (mapa, itens, personagens, arte, sons, UI). Só mecânicas genéricas, tudo nosso.

## Estado
- v0.1 (web 2D) DESCARTADA: utilizador quer app nativa 3D.
- v0.2 (2026-11-16): Godot 4.3, 3D low-poly procedural, app Android nativa, auto-update por PCK.
- v0.3: cidade única Vila Rubra (420x300m, canal+pontes, mar a sul, 4 bairros), mapa da REGIÃO (Esconderijo/Bar O Farol/Vila Rubra),
  câmara 3ª pessoa (arrastar à direita roda), interiores com contentores para vasculhar + janela de saque em grelha, refém,
  polícia a invadir (contagem), minimapa, mapa completo com destino/GPS, bússola, barra de armas, registo de eventos,
  trânsito, peões, carros estacionados. Referência visual do utilizador: capturas do ROB RUN (só mecânicas, visual nosso).
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
- Agora: Godot 4.3 (GL Compatibility), GDScript, tudo gerado por código (main.gd), CI GitHub Actions.
- Produção: Unity (URP mobile) + Photon Fusion ou FishNet (servidor autoritativo) + Edgegap/Hathora/GameLift (EU + Brasil).
- Backend contas/economia: Nakama ou PlayFab. Updates nativos: Unity Addressables (conteúdo) + loja (binário).
- Monetização: cosméticos, carros skin, passe de temporada. NUNCA vender armas (sem pay-to-win).

## Auto-update (como funciona)
- CI publica no Release 'latest': golpe.apk, game.pck, version.json {content, app}.
- boot.gd: lê version.json → se content > instalado, descarrega game.pck → load_resource_pack → abre jogo.
- content = 0.2.<run_number> (automático). app = jogo/boot/app_version.txt (subir só se mudar motor/permissões).
- Para lançar update: push em jogo/. Mais nada.
- Não posso descarregar o Godot no workspace (bloqueado) → testes só no CI (check-only + arranque headless).

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
- jogo/ projeto Godot · .github/workflows/build.yml · keys/golpe-test.keystore (SÓ teste; Play Store → chave em Secrets).
- Ficheiros: boot/boot.gd (update), game/main.gd (jogo inteiro), game/data.gd (dados).
- Unidades em metros. Zona 128x92, estradas RX=[22,90] RY=[19,64], porta do edifício principal virada a sul (câmara olha para norte).

## Próximos passos pedidos pelo utilizador (por prioridade)
- Qualidade visual: modelos 3D a sério (personagens animados, carros) → packs CC0 (Quaternius/Kenney/KayKit) descarregados no CI.
- Mais funcionalidades dentro dos edifícios; menus com ar profissional; polícia jogável/multijogador mais tarde.

## PLANO v0.4 (pedido 16/11, ordem de execução)
Revisão visual: o CI tira capturas (ramo `capturas`) → Claude vê e corrige. Problemas vistos: paredes do interior tapam a câmara,
móveis = caixas, janela de saque vazia e com texto, bússola/nome da zona por cima de letreiros, botão de ação "—" inútil, demasiado texto no arranque.
1. UI limpa: arranque = logo + barra; login = logo + nome + JOGAR; HUD sem textos redundantes; ação só aparece quando há ação.
2. Itens a sério: catálogo ITEMS (id, nome, categoria, kg, valor, ícone PNG próprio). DINHEIRO É UM ITEM (maços de notas no saco).
   Cofre do esconderijo guarda dinheiro em segurança; detido/hospital = perdes o saco (incluindo dinheiro). Compras pagam com o saco e depois o cofre.
   Inventário e saque em grelha de ícones (quantidade + valor), sem "redação".
3. Interiores com mobília KayKit (Furniture + Restaurant, CC0), paredes em corte (a do lado da câmara é baixa), sala dos fundos trancada.
   Lojas: café, bomba, farmácia, garrafeira, hotel, joalharia, museu, banco.
4. Mini-tarefas: funcionário (ameaçar com a arma / amarrar com abraçadeiras, senão liga à polícia), câmaras (destruir a tiro ou usar máscara,
   senão +1 estrela à saída), porta dos fundos (arrombar: pé-de-cabra rápido, gazuas silenciosas), cofres (precisam de berbequim).
5. Carrinhas de receptação (3 ativas na cidade, rodam a cada 10 min, cada uma paga mais por uma categoria): vender → dinheiro vai para a mesa
   → recolher maço a maço → risco de rivais (tentam levar o dinheiro) e patrulha.
6. Bar O Farol = HISTÓRIA (já não compra saque): Cap.1 "A fotografia" (encontrar foto no cofre do hotel) → desbloqueia joalharia + gazuas;
   Cap.2 "A dívida" (pagar $1 000 000) → desbloqueia banco + saco XL; Cap.3 "O livro de contas" (roubar do banco) → contratos de elite. Contratos continuam.
7. Economia ×10 (para $1 000 000 fazer sentido). Saves antigos são reiniciados (protótipo).

## Estado v0.4 (feito 16/11)
Pontos 1–7 do plano v0.4 implementados e verificados por capturas (ramo `capturas`) + autoteste no CI. App 2.2.0 (mobília nova vai no APK).
Código: game/main.gd (secções: ITENS E DINHEIRO, JANELA DE ITENS, INTERIORES, CARRINHAS, MENUS), game/data.gd (ITEMS, INTERIORS, STORY, VAN_*), game/icons/*.png.
Save com "ver": 4 (saves antigos reiniciam). Por fazer: personagens mais realistas (Quaternius Universal Base Characters + Animation Library, CC0),
física de carros (VehicleBody3D), texturas PBR/HDRI, renderizador móvel, som, multijogador.
