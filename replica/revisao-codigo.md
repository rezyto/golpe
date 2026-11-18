# GOLPE — Revisão técnica do código (Godot 4.3, GL Compatibility, Android)

Âmbito: `jogo/game/main.gd` (6490 linhas), `game/data.gd`, `game/grid.gd`, `boot/boot.gd`, `project.godot`, `export_presets.cfg` e `.github/workflows/build.yml`. Revisão só de leitura: não alterei nenhum ficheiro. Os números de linha referem-se ao estado atual dos ficheiros.

Os números de desempenho são **estimativas** feitas a partir do código (contagem de nós, iterações e passes). Não houve medição no dispositivo. Validar com o *profiler* e o *monitor* de *draw calls* (`Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME`) num Android de gama média antes de dar prioridade final.

---

## 0. Resumo executivo

- **Risco n.º 1 para o jogador: perder o progresso.** A gravação não é atómica e corre a cada 5 s. O carregamento apaga o progresso sem aviso quando o JSON falha ou a versão muda (secção 1.1).
- **Risco n.º 1 para o produto: a auto-atualização pode partir o jogo de vez.** Não há verificação de integridade nem gate de versão mínima da app, e o *timeout* de 10 s cobre o download inteiro. Não existe modo de recuperação se um PCK mau for carregado (1.2).
- **Desempenho:** o maior custo provável são os **draw calls**. Cada prédio tem cerca de 7 a 8 `MeshInstance3D`, cada carro procedimental cerca de 22, e as estantes dos interiores chegam a centenas de garrafas/caixas individuais. Juntam-se o sol com sombra e os ciclos de colisão em GDScript que percorrem todos os blocos várias vezes por frame (secção 2).
- **Arquitetura:** o monólito pode ser dividido sem partir o PCK, desde que se respeitem três regras: **sem *autoloads*, sem `class_name`, caminhos `res://game/main.tscn` e `res://game/main.gd` estáveis** (secção 3).
- **Multijogador:** o estado global `S`, os sorteios de loot no cliente, o relógio do dispositivo, a pausa do mundo quando se abre um menu e as entidades guardadas como `Dictionary` com nós dentro bloqueiam um servidor autoritativo. Há refactors baratos a fazer já (secção 4).

---

## 1. Bugs e erros prováveis em runtime (por gravidade)

### 1.1 [CRÍTICO] Perda total de progresso: gravação não atómica e carregamento destrutivo
- **Onde:** `save_game()` main.gd:597-602; `load_game()` main.gd:584-594; chamada a cada 5 s em `_process` main.gd:4223-4226, mais dezenas de chamadas ad hoc.
- **Porquê:** `FileAccess.open(SAVE_PATH, WRITE)` trunca o ficheiro antes de escrever. Se o Android matar o processo a meio, o que é frequente em `APPLICATION_PAUSED`, o `save.json` fica vazio ou truncado. No arranque seguinte, `JSON.parse_string` devolve `null`, a verificação `typeof(j) == TYPE_DICTIONARY` falha e o jogo arranca com `default_save()`. Na gravação seguinte (≤5 s) o save antigo desaparece de vez. O mesmo acontece com `int(j.get("ver",0)) == 4`: qualquer mudança de esquema apaga o progresso de toda a gente.
- **Correção:**
  1. Escrever para `user://save.tmp`, `f.flush()`, fechar e depois `DirAccess.rename_absolute(tmp, save)`. Manter `save.bak` (rodar o anterior antes do rename).
  2. No carregamento, tentar `save.json`, depois `save.bak`. Se ambos falharem, **não** gravar por cima: guardar o ficheiro corrupto como `save.corrupt.<ts>`.
  3. Trocar o `== 4` por migrações: `while ver < CUR: S = MIGRATIONS[ver].call(S); ver += 1`.
  4. Gravar com *dirty flag* (só quando `S` muda) em vez de a cada 5 s. São 720 escritas por hora em flash por nada.

### 1.2 [CRÍTICO] Auto-atualização: timeout, integridade, compatibilidade e ausência de recuperação
- **Onde:** boot.gd:25, 109-115, 121-136, 147-157; build.yml (passos "Exportar" e "Publicar").
- **Problemas concretos:**
  1. `http.timeout = 10.0` (boot.gd:25) é o tempo **total** do pedido no `HTTPRequest`, e o mesmo objeto é reutilizado para o `game.pck`. Em 3G/4G fraco, um PCK de vários MB não chega em 10 s: o download falha **sempre** e o jogador nunca recebe a atualização, sem qualquer mensagem. Correção: `http.timeout = 0` (ou cerca de 120 s) no pedido do PCK, e mensagem "Sem rede: a jogar versão X".
  2. **Sem integridade:** basta um `RESULT_SUCCESS` com código 200. Não se verifica tamanho nem hash. Um PCK truncado ou trocado é carregado com `replace_files=true` e passa a ser o código executado. É uma forma de execução de código remoto se o repositório ou o *token* do CI forem comprometidos. Correção: `version.json` passa a incluir `"sha256"` e `"size"` do PCK, e o cliente valida com `FileAccess.get_sha256(PCK_NEW)` antes do rename. A prazo, assinar o hash (Ed25519 com a chave pública embutida na APK).
  3. **Corrida no Release `latest`:** `softprops/action-gh-release` substitui os assets de uma release que já existe, e há `cancel-in-progress: true`. Um cliente pode ler um `version.json` novo e descarregar o `game.pck` antigo (ou um 404). Grava `content_version` novo e fica com conteúdo velho até à build seguinte. O hash do ponto 2 resolve isto. Em alternativa, publicar `game-<cv>.pck` com nome versionado e apontar no JSON.
  4. **Sem gate de versão mínima da app:** o campo `app` só mostra um botão. Um PCK feito para uma APK nova (novas permissões, novos assets em `assets/`, que o preset "Patch" **exclui**: `exclude_filter="assets/*"`, ou novas definições no `project.godot`) é carregado numa APK antiga. Correção: `version.json` passa a ter `"min_app"`. Se `app_version < min_app`, não carregar o PCK e mostrar só o botão da APK.
  5. **Sem modo de segurança:** se o PCK novo tiver um erro de script em `main.gd`, o jogo fica inutilizável e cada arranque volta a carregar o mesmo PCK. O boot só o substitui quando sai versão mais nova. Correção: antes de `load_resource_pack`, gravar `user://boot_pending=<cv>`. O `main.gd` apaga-o quando chega ao menu de login. No arranque seguinte, se `boot_pending` ainda existir, apagar o PCK e arrancar com o conteúdo embutido.
  6. `DirAccess.rename_absolute` (boot.gd:128) não verifica o erro. Se falhar, `content_version.txt` é escrito na mesma.
  7. Menor: o `Label` `ver` (boot.gd:87-91) é criado mas nunca recebe `add_child`, por isso a versão nunca aparece no ecrã de arranque.
- **Limitação a documentar:** o PCK não altera o `project.godot` já carregado (autoloads, input map, definições de renderização, permissões). Essas mudanças só chegam por APK. Isto condiciona a arquitetura (secção 3).

### 1.3 [ALTO] Abrir inventário, menu ou mapa congela o mundo (exploit de jogabilidade)
- **Onde:** `_process` main.gd:4199-4226. `update_game` e `update_interior` só correm com `mode == "play"`. `open_inventory` (tecla ESC e botão "menu" do HUD, main.gd:3884 e 3915), `open_fullmap`, `open_loot` e os menus mudam o `mode`.
- **Porquê:** com a polícia à porta, o jogador abre a mochila e o contador de invasão (`I["raid"]`), o `bust`, as balas e as patrulhas param. Também se pode pausar a meio de uma perseguição. Em multijogador esta semântica é impossível.
- **Correção:** separar o "estado do ecrã" do "estado da simulação". A simulação corre sempre que há uma zona ativa; o UI apenas bloqueia o input de movimento. Se se quiser manter uma pausa para single-player, limitá-la ao menu de opções e só fora de perigo (`wanted == 0`).

### 1.4 [ALTO] Mala do carro contorna a detenção e o hospital
- **Onde:** `busted()` main.gd:4074-4081 e `hospital()` 4084-4092 limpam `S["inv"]`. `S["trunks"]` (main.gd:2725-2730) fica intocada.
- **Porquê:** guardar o loot **e o dinheiro** na mala do carro (arrastar entre grelhas em `_grid_dropped`) torna-o imune à perda. Isto anula o risco que é o centro do ciclo de jogo.
- **Correção:** decidir a regra: perder a mala quando se é detido perto do carro, ou proibir `cash` na mala, ou tratar a mala como um "saco 2" exposto enquanto se está na cidade. Implementar em `busted()`/`hospital()`.

### 1.5 [MÉDIO] Trânsito civil a andar sobre o mar
- **Onde:** `update_life` main.gd:2411. O carro civil só é removido quando `y > Z["h"] + 5`, ou seja 305 m. As estradas verticais acabam nos 254 m e o mar começa nos 254-256 m (`make_city` main.gd:1779-1787). `spawn_civ` faz clamp ao *spawn* (250 m), mas não ao movimento.
- **Correção:** na cidade, remover ou inverter o carro quando `y > 250` (usar o mesmo `vmax` de `build_world`), ou fazê-lo virar na última intersecção.

### 1.6 [MÉDIO] Materiais em cache partilhados são mutados
- **Onde:** `make_proc_car` main.gd:2632-2637. `mat("#3a4c5e",0.04,0.85)` e `mat("#151618",0.8)` vêm de `mat_cache` e recebem `cull_mode = CULL_DISABLED`. Qualquer outra utilização futura da mesma cor/rugosidade herda o *culling* desligado, e isso dobra o custo de fragmento.
- **Correção:** criar materiais próprios dos carros (`car_glass_mat`, `car_dark_mat`) em cache separada, ou `mat(...).duplicate()` uma vez.

### 1.7 [MÉDIO] Rendas e cooldowns dependem do relógio do dispositivo
- **Onde:** `offline_income` main.gd:605-611, `S["cds"]` (main.gd:3577, 4028), `spawn_vans` (seed por `Time.get_unix_time_from_system()/600`, main.gd:3734).
- **Porquê:** adiantar o relógio do telemóvel dá 8 h de rendas e acaba com todos os cooldowns. Atrasar o relógio dá um `el` negativo; não rebenta, mas os cooldowns ficam gigantes. Com a app em segundo plano (pausada, não morta), nem `_process` nem `offline_income` correm, e o tempo em pausa perde-se (não há tratamento de `NOTIFICATION_APPLICATION_RESUMED` em main.gd:614).
- **Correção agora:** centralizar num `Clock` (secção 4) e tratar o `RESUMED`. Em multijogador a única fonte válida é o servidor.

### 1.8 [BAIXO] Pagamento da história ignora o resultado de `spend()`
- **Onde:** `menu_bar` main.gd:6253-6258. `spend(can)` não é verificado e `S["paid"] += can` é aplicado na mesma. O `can` é calculado quando o menu é desenhado. Hoje é difícil de explorar, mas basta que o dinheiro mude entre o desenho e o toque (por exemplo com rendas automáticas no futuro) para pagar sem ter dinheiro.
- **Correção:** `if spend(can): S["paid"] += can`.

### 1.9 [BAIXO] Comprar mochila que não serve: dinheiro gasto sem aviso
- **Onde:** `menu_arm` main.gd:6329-6334. `spend()` já correu (em `buy_row`) e `S["bags"].append(bid)` também. Se `grid_pack` falha, a mochila fica comprada mas não equipada e o jogador não recebe nenhum aviso.
- **Correção:** fazer o `grid_pack` antes do `spend` (validar primeiro) ou mostrar um toast "Comprada; esvazia o saco para a equipar".

### 1.10 [BAIXO] Revelação de loot contornável
- **Onde:** `close_loot` main.gd:6123-6125 põe `hid=false` em todos os itens. Fechar e reabrir o contentor revela tudo de imediato. Se a revelação lenta for intencional (suspense e tempo de exposição), guardar o `rev` em vez de revelar.

### 1.11 [BAIXO] Igualdade de `Dictionary` usada como identidade
- **Onde:** main.gd:3639 `near_cont() == search["c"]`, main.gd:3682 `c == nc`, grid.gd:82-83 `it == selected`, `src.items.erase(it)` em vários sítios.
- **Porquê:** em Godot 4 o `==` entre `Dictionary` compara o **conteúdo** recursivamente, incluindo o array `items` de cada contentor, a cada frame. Hoje funciona porque os itens diferem em `x`/`y`, mas é frágil: dois contentores ou pilhas idênticos são tratados como o mesmo, e o `erase` remove o primeiro igual.
- **Correção:** `is_same(a, b)` para identidade, ou IDs inteiros nas entidades (secção 4).

### 1.12 [BAIXO] Código morto e avisos
- `make_car` main.gd:893-941: o ramo `if pol:` em 894 devolve antes, e os ramos KayKit e "caixa" já não correm. `make_simple_car` main.gd:943-963 tem código inalcançável depois do `return`, e o parâmetro `col` é ignorado (os carros estacionados têm `col: "#ffffff"`, que nunca é usado). Gera avisos `UNREACHABLE_CODE`, que o CI não apanha porque só procura `SCRIPT ERROR|Parse Error`.
- `place_proc_building` main.gd:1544-1546 faz `outline_size = 6` e logo a seguir `outline_size = 0`.
- `update_life` main.gd:2387-2389: `others = [P]` repetido sem efeito. Os carros civis não reagem à polícia nem a carros estacionados.
- `menu_bar` main.gd:6270: `opts[randi() % opts.size()]` dá divisão por zero se algum dia todos os assaltos ficarem bloqueados (hoje o Café é sempre nível 1). Proteger com `if opts.is_empty()`.
- `story_advance` main.gd:6228-6236 não verifica `ch < D.STORY.size()` (só o autotest a chama diretamente).

### 1.13 [BAIXO] Tipos depois do JSON
- `load_game` só converte `lvl/money/story/ties` para `int`. Tudo o resto vem como `float` (coordenadas `x/y` dos itens, `q`, `v`, `reward`). Hoje funciona porque o código não tem tipos. Quando se tiparem as variáveis no refactor, aparecem erros de atribuição. Normalizar no carregamento (função `sanitize()` com o esquema).

### 1.14 Notas de CI e publicação
- A APK publicada é **debug** (`--export-debug`): leva o *template* de debug, com verificações extra no GDScript e no motor. É mais lenta que a release e é assinada com a *keystore* de teste que está no repositório (`keys/golpe-test.keystore`). Para medir desempenho e para jogadores reais: `--export-release` com a chave em *Secrets*.
- O `grep -v "mesh_storage.h\|Parameter \"m\" is null"` no teste *headless* é razoável, mas convém tratar avisos `UNREACHABLE_CODE`/`UNUSED_*` como erros num passo opcional.
- O autotest é uma boa base, mas não cobre gravação e carregamento corrompidos, mochila trocada, venda nem morte dentro de interiores.

---

## 2. Riscos de desempenho em mobile

Contexto: com o **Compatibility** (OpenGL ES 3), o Godot 4.3 não faz *batching* automático de `MeshInstance3D` em 3D. Cada instância visível × cada superfície gera pelo menos um draw call, mais os passes de sombra. Num Android de gama média, o orçamento razoável fica entre 200 e 500 draw calls por frame a 30-60 fps.

### 2.1 [MUITO ALTO] Draw calls da cidade
Contagem estimada a partir do gerador (seed 4242): cerca de 83 prédios procedimentais, 11 edifícios POI, cerca de 25 caixotes de território, 34 carros estacionados, 9 civis, 10 peões e entre 6 e 9 polícias/gangues em ação.

| Fonte | Nós por unidade | Total estimado |
|---|---|---|
| `place_proc_building` (main.gd:1510-1573): loja, corpo, 2 cornijas, laje, placa, toldo, `Label3D` | ~7-8 | ~650 |
| POI principal (main.gd:2122-2145) | ~7 + Label3D | ~90 |
| `make_proc_car` (main.gd:2623-2697): carroçaria com 3 superfícies, ~10 caixas, 4 rodas × 3 malhas | **~22-25** | **~1000** (34 estacionados + 9 civis + polícia) |
| Personagens `make_char` (main.gd:1042-1114): corpo + 4-8 acessórios (cada `ball()` cria um `SphereMesh` novo) | ~8-10 | ~200 |
| Candeeiros/semáforos/adereços KayKit (`place_street_props`, main.gd:1259-1317) | 1-3 superfícies | ~250-400 |
| Passeios, estradas, saídas, *skyline* (70 caixas), pontes | 1 | ~180 |

Os *visibility ranges* de 230-290 m (main.gd:1527-1556, 2117-2126) numa cidade de 420×300 m, com `cam.far = 400` (main.gd:782) e nevoeiro exponencial de 0.0045 (64 % a 230 m), deixam quase tudo dentro do alcance. Em cenas típicas, depois do *frustum culling*, ficam provavelmente **800-1500 draw calls** só no passe de cor, antes das sombras. É a causa mais provável de quedas de fps no telemóvel.

**Correções, por ordem de retorno:**
1. **Carros estacionados e civis numa só malha.** Na geração, juntar carroçaria, luzes, para-choques e rodas num único `ArrayMesh` por `spec` (com `SurfaceTool.append_from`), com 3-4 superfícies (tinta, vidro, escuro, luz) e cor por instância. Os estacionados ficam como `MultiMesh` por `spec` com `use_colors=true`. Só o carro do jogador e a polícia mantêm rodas animadas. Impacto: de cerca de 1000 para cerca de 60 draw calls.
2. **Prédios por *chunks*.** Juntar todos os prédios de um quarteirão num `ArrayMesh` por material (atlas de fachadas, ver 2.5). Impacto: de cerca de 650 para cerca de 40-80.
3. **Adereços KayKit em `MultiMesh`.** Extrair a `Mesh` do glTF uma vez (`find_children("*","MeshInstance3D")[0].mesh`) e instanciar candeeiros, semáforos, bancos e caixotes do lixo por `MultiMeshInstance3D`. Impacto: de 300 para cerca de 10.
4. **Alcances e nevoeiro coerentes:** prédios a cerca de 140 m, adereços a 60-80 m, `Label3D` a 40 m, `cam.far` a 220 m, e nevoeiro ajustado para tapar o corte (densidade perto de 0.012, ou nevoeiro de profundidade se o Compatibility 4.3 o suportar). A *skyline* como uma só malha sem sombra.
5. **Partilhar recursos:** `box()` (main.gd:866) e `cyl()` (878) criam um `BoxMesh`/`CylinderMesh` **novo por chamada**, e `ball()` (1117) faz o mesmo. Com milhares de recursos únicos não há hipótese de instanciação. Criar uma cache por `size`.

### 2.2 [ALTO] Sombras
- `sun.shadow_enabled = true` (main.gd:775) com o modo por omissão `SHADOW_PARALLEL_4_SPLITS`: todos os emissores de sombra até 55 m são desenhados até 4 vezes no mapa de sombras. No Compatibility, a luz com sombra também implica um passe de iluminação adicional por objeto iluminado (o comportamento aditivo das luzes com sombra), o que multiplica ainda mais os draw calls da secção 2.1.
- Muitos emissores desnecessários: `cyl()` deixa `cast_shadow` ligado por omissão, por isso pneus e jantes (8 por carro, cerca de 350 na cidade), garrafas e mostradores projetam sombra. O mesmo acontece com as bolas da cabeça das personagens, as `MultiMesh` de varandas e ar condicionado espalhadas por toda a cidade (o AABB enorme da MultiMesh impede o *culling*) e as árvores.
- **Correção:** `sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL` (ou 2 *splits*), `directional_shadow_max_distance = 30-35`, `rendering/lights_and_shadows/directional_shadow/size.mobile = 1024`, sombra só nos corpos dos prédios próximos, nos carros e nas personagens. Para carros e peões, usar uma *blob shadow* (quad com textura radial) e desligar a sombra real. Opção de qualidade "Sombras: desligadas / baixas" no menu de opções.

### 2.3 [ALTO] Física em GDScript: ciclos sobre todos os blocos várias vezes por frame
- `push_out` (main.gd:1890-1924), `in_block` (1927-1933) e `solid_at` (1936-1944) percorrem `blocks_now` inteiro, cerca de 170 entradas na cidade (prédios, água, carros estacionados, carrinhas). Cada iteração lê 4-6 chaves de `Dictionary` (hash de string) **antes** do teste de rejeição.
- Chamadas por frame na cidade: jogador 1, polícia até 6, gangue até 12, peões 10 (`push_out`); `cam_clip` 12 × `solid_at` (main.gd:4649-4656); cada bala × `in_block` (main.gd:4462). Com 20 balas no ar dá cerca de **8-12 mil iterações por frame**, ou mais de 40 mil acessos a dicionário. Estimativa: **3-10 ms por frame** num ARM de gama média, a juntar ao orçamento de 16-33 ms.
- **Correção:**
  1. Grelha espacial uniforme (células de 8-16 m) construída uma vez por zona: `PackedInt32Array` de índices por célula. Cada consulta testa 1-4 células, ou seja 3-10 blocos.
  2. Guardar os blocos como `PackedFloat32Array` (x, y, w, h, hgt) ou `Array[Rect2]` em vez de `Dictionary`.
  3. `cam_clip`: 4-6 amostras em vez de 12, e só quando a câmara mexe.
  4. Balas: `segment vs grid` (DDA) em vez de ponto por frame.
  Ganho esperado: mais de 90 % deste custo. É também o código que o servidor vai precisar (secção 4).

### 2.4 [ALTO] Interiores com centenas de objetos individuais
- `make_shelf` (main.gd:3201-3229) cria um `MeshInstance3D` + `CylinderMesh`/`BoxMesh` por garrafa ou caixa: 2 lados × 4 níveis × (comprimento / 0.2 m). A Garrafeira (3 estantes de garrafas com 5.0, 2.8 e 2.8 m) dá cerca de **420 garrafas**. A Farmácia e a Bomba têm entre 250 e 330 caixas. Junta-se 1 luz omni a cada 7 m, mais o sol com sombra ainda ativo (o mundo exterior só fica `visible=false`), e o interior pode facilmente ultrapassar os 1000 draw calls.
- **Correção:** uma `MultiMeshInstance3D` por estante e por tipo de produto, com `use_colors=true` para as cores (ou a estante inteira numa só malha). Desligar `sun.shadow_enabled` dentro dos interiores (ou pôr `sun.visible=false` e usar ambiente + omni sem sombra).

### 2.5 [MÉDIO] Texturas procedimentais e *triplanar*
- Na primeira entrada na cidade gera cerca de 21 imagens de 256² RGBA8 com *mipmaps* em GDScript: `tex_facade` (main.gd:1381-1433), `tex_shop`, `tex_ground` e `noisy` (cerca de 2000 `get_pixel`/`fill_rect` por imagem), mais `window_px` com gradiente linha a linha. Estimativa: **100-300 ms de pico** num telemóvel médio. Depois ficam cerca de 7 MB de VRAM **sem compressão** (o ETC2/ASTC do projeto não se aplica a `ImageTexture` criada em runtime). A filtragem é anisotrópica (main.gd:1354), cara em largura de banda no mobile.
- Todos os materiais de fachada e de chão usam **triplanar em coordenadas do mundo** (main.gd:858-860, 1350-1352): 3 amostras de textura + mistura por fragmento, e o chão ocupa quase o ecrã inteiro. Num GPU *tiled* é custo de fill-rate puro.
- **Correção:**
  1. Gerar as texturas **no CI** (script `--headless --script tools/bake_textures.gd` que grava PNG em `game/tex/`, importados com compressão VRAM), ou pelo menos gravar em `user://tex_cache/*.res` no primeiro arranque.
  2. Um **atlas** de fachadas (por exemplo 1024×1024 com 16 estilos) para permitir juntar prédios na mesma malha (2.1-2).
  3. UV normais (as `BoxMesh`/`PlaneMesh` já têm UV; usar `uv1_scale` por tamanho) em vez de triplanar.
  4. `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` sem anisotropia.

### 2.6 [MÉDIO] `Label3D`
- Cerca de 62 letreiros de loja (75 % dos 83 prédios, main.gd:1538-1551), mais 11 nomes de POI sem alcance de visibilidade (main.gd:2134-2143), mais 3 carrinhas *billboard*, mais 5-7 por interior. Cada `Label3D` é um draw call **transparente** (sem *batching*, ordenado por profundidade) e os tamanhos 64, 110 e 46 de uma fonte *bitmap* geram atlas de glifos por tamanho.
- **Correção:** baixar o alcance para 35-40 m. Usar um tamanho de fonte único (por exemplo 48) e ajustar com `pixel_size`. Ativar `multichannel_signed_distance_field` no import da fonte (um atlas serve para qualquer escala). Para os letreiros das lojas, o melhor é **cozer o texto na textura da montra** (é estático) e eliminar os Label3D.

### 2.7 [MÉDIO] Luz da sirene sempre ativa
- `siren` (main.gd:785-788, 4570-4574) é uma `OmniLight3D` permanente com `light_energy = 0`. Com energia 0 continua a contar para a seleção de luzes por objeto e para o custo de *shading* dos objetos dentro do raio de 16 m.
- **Correção:** `siren.visible = false` quando não há polícia, e `visible = true` só durante a perseguição. Alternativa barata: dispensar a luz e usar só o *flash* emissivo nas barras do carro mais o vermelho/azul no ecrã que já existe.

### 2.8 [MÉDIO] Personagens animadas e *spawn* em runtime
- Cada peão, gangue, empregado ou receptador instancia o glTF completo da Universal Animation Library (`make_char`, main.gd:1042): esqueleto + `AnimationPlayer` + 4-8 malhas extra presas a ossos. Com cerca de 25 personagens ativas, todas avaliam animação a cada frame, mesmo a 80 m.
- `spawn_ped`/`spawn_civ` correm **durante o jogo** (`randf() < dt*3.0`, main.gd:2491-2493). Um `instantiate()` de um glTF com esqueleto custa vários ms em mobile e provoca soluços periódicos.
- **Correção:** *pool* de 12 peões e 10 carros criados no `enter_place`, reutilizados (reposicionar, trocar material). Para peões a mais de 30 m: `AnimationPlayer.callback_mode_process = MANUAL` e avançar a 10 Hz, ou pausar. Juntar as bolas da cabeça e o cabelo numa malha única partilhada.

### 2.9 [MÉDIO] Alocações e trabalho por frame
- `police + gang` e `police + gang + extra` criam um array novo **por bala e por frame** (main.gd:4116, 4468).
- `update_act_button()` chama `ctx_action()` em todos os frames (main.gd:4489, 3696). Cada chamada cria `Dictionary` e **lambdas** (`func(): ...`) novos, e percorre os POI. Correção: calcular o contexto a cerca de 10 Hz, ou só quando o jogador muda de célula, e devolver um ID de ação em vez de um *closure*.
- `update_hud()` (main.gd:5214) formata 5-6 strings e percorre o inventário (`bag_cash`, `cells_used`) a cada frame. Correção: atualizar por sinal (`money_changed`, `inventory_changed`).
- O minimapa (`_draw_minimap`, main.gd:5378) redesenha **todos os lotes e blocos** a cada frame através de `Callable.call` (cerca de 200-300 comandos de canvas). Correção: pré-renderizar o mapa da zona para uma `ImageTexture` (ou `SubViewport` com `UPDATE_ONCE`) no `enter_place` e desenhar só a textura com *offset*, mais ícones e polícia, a 15 Hz.
- `overlay.queue_redraw()` corre sempre, mesmo no login (main.gd:4218).
- `grid.gd:36-39`: `_process` faz `queue_redraw()` se `visible`, mas `visible` é a flag local e é `true` mesmo com a janela fechada. Usar `is_visible_in_tree()` e redesenhar só durante animações (`rev`/`flash`).
- Partículas: 120 `MeshInstance3D` com 120 `SphereMesh` e 120 materiais distintos, e escrita de `albedo_color` em cada frame (main.gd:4608-4619). Correção: uma `MultiMeshInstance3D` com `use_colors` e um único material `vertex_color_use_as_albedo`. O mesmo para as balas (60) e as marcas de pneu (160).
- Entidades como `Dictionary` sem tipos: o GDScript tipado (classes internas `class Car extends RefCounted` com `var x: float`) costuma ser bastante mais rápido nestes ciclos e apanha erros na compilação.

### 2.10 [BAIXO/MÉDIO] Pós-processamento e ecrãs sobrepostos
- `glow`, `adjustment`, *tonemapping filmic* e nevoeiro (main.gd:758-769), mais `msaa_3d=1` (2x) no `project.godot`: o *glow* e os ajustes obrigam a renderizar para um *buffer* intermédio e a um passe de ecrã inteiro. Num GPU *tiled* isto é caro. Correção: opção de qualidade "Baixa", com *glow* e ajustes desligados por omissão em dispositivos fracos.
- Com o mapa da região, a mochila, os menus ou o ecrã de viagem abertos em ecrã inteiro, o 3D continua a renderizar por trás (`render()` corre sempre que `mode != "login"`). A pré-visualização do Stand acrescenta um `SubViewport` com **MSAA 4x** recriado a cada toque (`stand_preview`, main.gd:6343-6397, via `refresh_menu`). Correção: `get_viewport().disable_3d = true` (ou `cam.current=false` + `world.visible=false`) enquanto houver UI opaca. Construir o `SubViewport` do Stand uma vez e trocar só o carro.
- `make_city()` e `build_world()` voltam a gerar tudo em cada `enter_place` (cerca de 2000 nós). Guardar `Z` da cidade em cache e, depois da junção por *chunks*, a geração fica muito mais barata.

**Metas sugeridas** (medir em Android de gama média, release): ≤ 300 draw calls na cidade, ≤ 150 nos interiores, ≤ 4 ms de script por frame, sem picos acima de 50 ms ao fazer *spawn*.

---

## 3. Arquitetura: partir o monólito sem partir o PCK

### 3.1 Restrições impostas pela auto-atualização (não negociáveis)
1. **Caminhos estáveis:** o `boot.gd` da APK abre `res://game/main.tscn` (boot.gd:157) e `main.tscn` aponta para `res://game/main.gd`. Esses dois caminhos não podem mudar sem APK nova. O `main.gd` passa a ser apenas a *composition root*.
2. **Sem *autoloads*:** são definidos no `project.godot` e criados no arranque do motor, **antes** do boot carregar o PCK. Um *autoload* novo vindo por PCK não existe em APKs antigas. Criar os serviços como nós filhos do `main` (ou objetos `RefCounted` guardados num contexto).
3. **Sem `class_name` em scripts novos:** o registo de classes globais é lido no arranque, e as classes que só existem no PCK podem não ficar registadas numa APK antiga (o risco é dar erro de "identificador não declarado"). Usar sempre `const Inventory = preload("res://game/core/inventory.gd")`. Se se quiser mesmo usar `class_name`, validar primeiro num APK antigo com o PCK novo.
4. **Tudo em `res://game/`:** o preset "Patch" inclui tudo menos `assets/*` (export_presets.cfg). Os novos scripts e `.tscn` em `game/` entram no PCK. Os novos modelos em `assets/` **não** entram, e só chegam por APK (ou mudar o filtro e aceitar um PCK maior).
5. **Mudanças ao `project.godot`** (input map, camadas, renderização) só chegam por APK. Preferir definir em código (`InputMap.add_action` no arranque, `RenderingServer`/`Viewport` em runtime).
6. **Protocolo de versões:** acrescentar `min_app` ao `version.json` (secção 1.2). Cada passo de migração que dependa de uma APK nova deve subir `app_version.txt`.

### 3.2 Estrutura proposta

```
game/
  main.tscn                 (inalterado)
  main.gd                   composition root (~200 linhas): cria contexto, serviços, ecrãs; liga sinais; ciclo _process/_physics_process
  ctx.gd                    objeto de contexto (RefCounted): referências a state, services, world, ui (substitui as ~130 vars globais)
  core/
    state.gd                PlayerState tipado + to_dict()/from_dict() + sanitize()  (substitui S)
    save.gd                 gravação atómica, .bak, migrações por versão
    clock.gd                now_ms() único (local hoje, servidor amanhã)
    rng.gd                  RandomNumberGenerator por "stream" (loot, mundo, cosmético) com seed explícita
    events.gd               sinais: money_changed, inv_changed, wanted_changed, toast, feed
    economy.gd              ações: buy_weapon/tool/bag/car/prop, spend, add_money, rent_collect, story_pay, mission_*
    inventory.gd            item_def, item_size, grid_fits/spot/add/pack, stacks (funções estáticas puras)
    loot.gd                 roll_loot(table, rng, story) -> Array (puro)
    progression.gd          xp/nível, heist_locked, cooldowns
  data/
    data.gd                 (atual; a prazo JSON em data/*.json para servidor e cliente partilharem)
  world/
    zone_gen.gd             make_city, make_small, fill_lot, poi_building, finish_zone -> ZoneData (dados puros, determinístico)
    zone_data.gd            estrutura estática da zona (blocos, lotes, POIs, estradas) + ZoneState dinâmico (alarmes, portas, malas)
    collision.gd            grelha espacial; push_out, in_block, solid_at, segment_hit (puro, sem nós)  <- reutilizável no servidor
    world_builder.gd        build_world, streets, skyline, chunks juntos por material
    textures.gd             tex_facade/shop/ground (ou carregar PNG cozidos)
    materials.gd            caches mat/unshaded/paint (sem mutação de partilhados)
  actors/
    car_mesh.gd             car_body_mesh, make_proc_car, versão "estática" junta, spin_wheels
    characters.gd           make_char, play_anim, animate_char, pool de peões
  sim/                      (sem nós; cada módulo: step(dt) sobre entidades tipadas com id)
    entities.gd             classes internas Car, Ped, Cop, Ganger, Bullet; registo id->entidade
    player_ctrl.gd          a pé / drive_player
    traffic.gd              civis e peões
    police.gd               wanted, spawn, perseguição, bust
    gang.gd                 territórios + rivais das carrinhas
    combat.gd               balas, dano, partículas (eventos para a vista)
    interior.gd             enter/exit/update, empregado, câmaras, pesquisa, porta
    vans.gd                 receptadores, mesa, risco
    minigame.gd             lógica do mini-jogo (sem UI)
  view/
    world_view.gd           sincroniza entidades -> nós (pools), interpolação
    camera_rig.gd           câmara 3ª pessoa + cam_clip
    fx.gd                   MultiMesh de partículas, balas, marcas de pneu
  ui/
    kit.gd                  lbl, flat, panel_style, ui_button, pbar, place, full… (estático)
    hud.gd + overlay.gd + minimap.gd
    login.gd, region_map.gd, fullmap.gd, travel.gd, toasts.gd
    loot_window.gd + grid.gd (atual)
    menus/bar.gd, armeiro.gd, stand.gd, imob.gd, home.gd, options.gd
    minigame_ui.gd
  dev/
    autotest.gd, shots.gd   (fora do main; carregados só com --autotest/--shots)
```

Regras de dependência: `core/` e `sim/` **não** conhecem nós nem UI (o servidor só precisa destes); `view/` lê `sim/` e emite nós; `ui/` chama ações de `core/economy.gd` e ouve `events.gd`. Os `.tscn` de UI são opcionais (podem continuar a ser construídos em código), mas uma cena por ecrã torna a iteração visual mais fácil e entra no PCK sem problemas.

### 3.3 Ordem de migração (jogável e com CI verde em cada passo)
Cada passo é um *push* com o autotest a passar. Durante a transição, o `main.gd` mantém funções "fachada" com o mesmo nome que delegam para o módulo novo, para não ter de mudar todas as chamadas de uma vez (o `grid.gd` chama `game.item_size`, `game.fmt`, etc.).

1. **Rede de segurança:** gravação atómica com migrações (1.1), *safe mode* e hash do PCK (1.2). Alargar o autotest a save corrompido, venda e morte em interior. *(Não mexe na arquitetura e protege os jogadores durante o resto.)*
2. **Mover `autotest`/`shots`** para `dev/` (cerca de 400 linhas fora do main, risco zero).
3. **`ui/kit.gd`:** helpers de UI estáticos. O main passa a usar `Kit.lbl(...)`.
4. **`core/inventory.gd` e `core/loot.gd`:** funções puras com testes no autotest. Fachadas no main.
5. **Builders sem estado:** `world/materials.gd`, `textures.gd`, `actors/car_mesh.gd`, `actors/characters.gd`. Aproveitar para partilhar malhas (2.1-5) e não mutar materiais (1.6).
6. **`world/zone_gen.gd` + `world/collision.gd` com grelha espacial** (2.3). Primeiro ganho de desempenho visível.
7. **`world/world_builder.gd`** com junção por *chunks* e carros estacionados como MultiMesh (2.1). Segundo ganho, o maior.
8. **`core/state.gd` + `economy.gd` + `events.gd`:** `S` passa a ser `ctx.state`. Primeiro com `var S: Dictionary: get: return ctx.state.data` para compatibilidade, depois substituir os acessos módulo a módulo. A UI passa a ouvir sinais em vez de atualizar a cada frame (2.9).
9. **`sim/*`:** extrair um sistema de cada vez (vans, depois traffic, police, gang, combat, interior). As entidades passam a classes tipadas com `id`, e os nós saem das entidades para `view/world_view.gd`.
10. **`ui/*`:** um ecrã de cada vez (loot, menus, mapas, HUD).
11. **Tick fixo e fim da pausa:** simulação em `_physics_process` a 30 Hz, *render* interpolado, menus sem parar o mundo (1.3).

---

## 4. Prontidão para multijogador (servidor autoritativo, 100-300 jogadores)

### 4.1 O que bloqueia hoje
| Bloqueio | Onde | Porque impede servidor autoritativo |
|---|---|---|
| Estado global `S` mutado em ~200 sítios | todo o main.gd (`S["money"]`, `S["inv"]`, `S["terr"]`…) | Não há fronteira entre "pedir" e "aplicar"; qualquer UI escreve dinheiro diretamente. |
| Sorteios de loot no cliente | `roll_loot` main.gd:3525, `open_parked_trunk` 2742, preços `van_price` 3801, recompensa de contrato 6272 | O cliente decide o que ganha. Tabelas e RNG têm de correr no servidor. |
| Relógio do dispositivo | `now_ms()` main.gd:570 em cooldowns, rendas, seed das carrinhas | Manipulável; servidores e clientes discordam. |
| Save local em JSON simples | `user://save.json` | Editável à mão (dinheiro e nível). |
| Decisões de jogo no cliente | `busted` 4074, `hospital` 4084, captura de território 4436-4451, `wanted`, dano das balas 4460-4478 | Têm de ser decididas pelo servidor; o cliente só prevê. |
| Simulação a dt variável dentro de `_process` com pausa por `mode` | main.gd:4199-4226 | Precisa de tick fixo e de um mundo que nunca pára. |
| Entidades `Dictionary` sem ID e com nó dentro (`"mesh"`) | `police`, `gang`, `civ`, `peds`, `vans` | Não há como serializar, replicar ou referenciar entre máquinas. |
| `Z` mistura mapa estático e estado dinâmico | `alarm_off`, `rear_open`, `alarm_trip`, `parked[].items`, blocos das carrinhas acrescentados a `Z["blocks"]` (3754-3755) | O servidor tem de possuir o estado dinâmico da zona; o mapa estático deve ser idêntico em todos a partir de uma seed. |
| Geração com RNG global não semeado | `make_simple_car` usa `randi()` (main.gd:944), `make_char` cores | Os carros estacionados (que são colisores e têm malas) diferem entre clientes. |
| Interiores na origem com `world.visible=false` e `blocks_now` global | `enter_interior` 3115-3183 | Em multijogador os interiores são instâncias (sub-zonas) com o seu próprio conjunto de jogadores e não podem "esconder o mundo" de toda a gente. |
| Ações como *closures* | `ctx_action()` devolve `func(): ...` | Não se serializam. É preciso um ID de ação + alvo. |
| Uma única variável `wanted`/`bust`/`cap` | main.gd:84-87 | Passam a ser estado por jogador no servidor. |

### 4.2 Refactors mínimos a fazer **já** (baratos, evitam reescrever depois)
1. **Camada de comandos.** Toda a mutação de estado passa por `economy.gd`/`progression.gd` com a forma `func request(cmd: StringName, args: Dictionary) -> Result`. Hoje executa localmente; amanhã a mesma assinatura vira RPC. A UI nunca escreve em `state`.
2. **Separar regras de apresentação:** `core/` e `sim/` sem nós (secção 3), com entradas e saídas em dados. Esse código corre num Godot *headless* como servidor, e a lógica fica portável se avançar o plano de porte para Unity do PLANO.md. Nesse caso, passar `data.gd` para **JSON** partilhado.
3. **IDs inteiros e estado serializável:** cada entidade tem um `id: int`, um `owner` e `to_dict()`. A vista mapeia `id → Node`.
4. **`Clock` e `Rng` injetados:** nenhuma chamada direta a `Time.*`, `randf()` ou `randi()` fora de `core/clock.gd`/`core/rng.gd`. Mundo estático só com uma seed por versão do mapa. Loot só pelo stream do servidor.
5. **Zona = dados estáticos (seed + versão) + estado dinâmico (`ZoneState`)** com eventos (`alarm_disabled`, `door_opened`, `trunk_looted`). Isto é exatamente o que o servidor replica.
6. **Tick fixo (20-30 Hz)** em `sim.step()`, com o *render* a interpolar. O input do jogador passa a **intenções** (`move: Vector2`, `fire: bool`, `action: id+alvo`) guardadas por tick. Esta é a base da previsão e reconciliação.
7. **Mundo nunca pausa** (1.3). Os menus são *overlays*.
8. **Colisão em grelha espacial pura** (2.3): também é o que o servidor usa para *interest management* (células de 32-64 m → quem recebe o quê).
9. **Versão de protocolo:** `version.json` passa a ter `protocol`/`min_app`, e o cliente envia `content_version` no *handshake*. O servidor recusa clientes incompatíveis (a auto-atualização por PCK ajuda aqui).
10. **Esquema de save versionado** (1.1), pensado para migrar para o *backend* (Nakama/PlayFab, como previsto no PLANO.md). Na primeira ligação o save local deve ser **descartado ou confirmado pelo servidor**, nunca importado às cegas.

### 4.3 Notas de escala
- 100-300 jogadores por servidor, com NPC (trânsito, peões, polícia) simulados, é viável **se** o servidor só simular a física 2D simplificada atual (que é uma boa decisão: AABB e círculos, sem física 3D) com grelha espacial, e se o trânsito e os peões cosméticos ficarem do lado do cliente (determinísticos por célula e tempo). Polícia, gangues e carrinhas são autoritativos.
- Os interiores (assaltos) devem ser **instâncias** com 1-4 jogadores. É aí que está o loot, e é barato isolar.
- GDScript num servidor com 300 jogadores e centenas de NPC é apertado. Medir cedo com um *bot client* *headless*. A arquitetura acima permite mover os sistemas quentes (colisão, *interest management*) para C#/GDExtension sem mexer na UI.

---

## 5. Top 10 tarefas de engenharia (por ordem)

1. **Gravação segura:** escrita atómica + `.bak` + migrações + *dirty flag*; nunca sobrescrever um save ilegível (1.1).
2. **Atualização robusta:** `timeout` do PCK, `sha256`/`size`/`min_app` no `version.json`, *safe mode* com `boot_pending`, verificação do rename; mostrar a versão (1.2). Nota: a correção do *timeout* em si só chega com APK nova, porque o `boot.gd` vem embutido.
3. **Medir antes de otimizar:** build `--export-release`, HUD de debug com fps, draw calls e tempo de script, numa sessão de referência (cidade, perseguição, Garrafeira) num Android de gama média.
4. **Grelha espacial para colisão e câmara** e blocos em arrays compactos (2.3). Extrair `world/collision.gd`.
5. **Juntar geometria estática:** carros estacionados e civis numa malha/MultiMesh por `spec`, prédios por *chunk* com atlas, adereços KayKit e estantes dos interiores em MultiMesh (2.1, 2.4).
6. **Sombras e luzes:** sombra ortogonal ou 2 *splits* a 30-35 m, sombras só onde importam, *blob shadows*, sirene com `visible`, sol sem sombra nos interiores, opção de qualidade (2.2, 2.7, 2.10).
7. **Pools e cadência:** pool de peões e carros, animação a cadência reduzida ao longe, `ctx_action`/HUD/minimapa a 10-15 Hz ou por evento, partículas e balas em MultiMesh (2.8, 2.9).
8. **Texturas cozidas no CI** com compressão VRAM, atlas de fachadas, fim do triplanar no chão e nas fachadas (2.5), menos Label3D (2.6).
9. **Dividir o monólito** pela ordem da secção 3.3, começando por `dev/`, `ui/kit`, `core/inventory`, `core/loot`, e depois `state` + `economy` + `events`. Sem *autoloads* nem `class_name`.
10. **Fundações de multijogador:** camada de comandos, `Clock`/`Rng` injetados, entidades com ID, `ZoneState` separado, tick fixo e fim da pausa do mundo (1.3, 4.2). Em paralelo, corrigir os bugs de jogo 1.4 (mala imune) e 1.5 (trânsito sobre o mar).
