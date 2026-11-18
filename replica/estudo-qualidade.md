# GOLPE — Estudo: como chegar ao nível visual e de jogo do ROB RUN (telemóvel, só recursos gratuitos)

Data: 18/11/2026 · Base: imagens oficiais do ROB RUN na página Steam (só referência), capturas do GOLPE v0.5, pesquisa de recursos livres.

## 1. Diagnóstico honesto (porque parece "Roblox")

| Área | ROB RUN | GOLPE hoje | Causa |
|---|---|---|---|
| Personagens | Humanos realistas, roupa urbana, coletes, tatuagens, ~20-40k tris | Bonecos KayKit cabeçudos, sem roupa | Pacote estilizado |
| Materiais | PBR: mármore, vidro, metal, reflexos | Cores lisas + texturas geradas | Sem texturas fotográficas nem reflexos |
| Luz | GI, oclusão ambiente, reflexos, HDR | Sol + céu procedimental | Renderer Compatibility (sem reflexos/probes eficientes) |
| Interiores | Densos (montras, plantas, notas, mobília) | Vazios, poucas peças | Poucos modelos |
| Carros | Modelos detalhados, luzes, sirenes | Formas geradas em código | Sem modelos |
| HUD | Fino, translúcido, cantos | Caixas grandes, texto enorme | Design (corrigido na v0.6) |
| Som | Completo | Nenhum | Falta tudo |

ROB RUN é um jogo de PC que pede RTX 2070. Num telemóvel, o objetivo realista é **o melhor nível dos jogos móveis do género**: mesmo estilo, mesmas mecânicas, materiais realistas, personagens humanos credíveis, HUD limpo, som completo.

## 2. Motor e renderização

- **Atualizar Godot 4.3 → 4.7** (estável desde 18-19/06/2026): melhor estabilidade em Android (taxas de crash de ~4% para <1% em jogos reais com as correções 4.5.2/4.6), Jolt físico por defeito desde 4.6, HDR. Sem custo.
- **Renderer Mobile (Vulkan)** como base, com recurso automático a OpenGL em telemóveis sem Vulkan. Dá: reflexos com *ReflectionProbe*, decals, sombras melhores, mais luzes. (SSAO/SSR/SDFGI são só Forward+, não servem para telemóvel.)
- **Realismo em telemóvel vem de**: texturas PBR fotográficas + céu HDRI para luz ambiente + sondas de reflexo nas ruas/interiores + luz pré-calculada (LightmapGI) nos interiores + pós-processo (tonemap filmic/AgX, cor) + oclusão ambiente "pintada" nos modelos.
- Orçamento: <150 draw calls na cidade, texturas ETC2/ASTC 1k (2k só no herói), personagens ≤15k tris, LOD + distância de visão por qualidade.

## 3. Recursos gratuitos escolhidos (os melhores por área)

| Área | Fonte | Licença | Porquê |
|---|---|---|---|
| Texturas PBR (alcatrão, calçada, reboco, mármore, metal, madeira) | **Poly Haven** + **ambientCG** | CC0 | Fotográficas, API pública, 1k chega para telemóvel |
| Céu / luz ambiente | **Poly Haven HDRIs** (cidade, fim de tarde, noite) | CC0 | Luz realista com um ficheiro |
| Adereços realistas (bancos, candeeiros, caixotes, plantas, mobília) | **Poly Haven Models** | CC0 | "Hyperreal", PBR |
| Personagens | **MPFB 2 (MakeHuman para Blender)** gerados em lote | CC0 | Humanos realistas com roupa urbana, várias idades/corpos, exporta glTF com esqueleto de jogo |
| Personagens (alternativa rápida) | **Quaternius Universal Base Characters** (proporção "Regular") | CC0 | 13k tris, já compatível com a biblioteca de animações que usamos |
| Animações | **Quaternius Universal Animation Library** (já no jogo) + **Mixamo** (conta Adobe gratuita) | CC0 / grátis | 120+ animações; Mixamo para extras (algemar, render-se, conduzir) |
| Carros | **rgsdev Free Low Poly Vehicles** (inclui 4 polícias) e **Kenney Car Kit** como base + pintura PBR com verniz e reflexos | CC0 | Leves; com material realista ficam credíveis. Sketchfab CC-BY para heróis (créditos no menu) |
| Sons de armas | **The Free Firearm Sound Library** | CC0 | Gravações reais |
| Sons gerais (UI, passos, impactos, portas) | **Kenney Audio** | CC0 | Limpos, leves |
| Motores, sirenes, ambiente urbano | **Sonniss GDC Game Audio Bundle** (ficheiros escolhidos) | Royalty-free, uso comercial | Qualidade profissional |
| Fontes | Barlow / Big Shoulders | OFL | Já em uso |

Regra: só CC0 ou licenças que permitem uso comercial; tudo registado em `CREDITS.md`. Nada do ROB RUN é copiado (modelos, imagens, UI exata, nomes) — só o nível e o estilo.

## 4. Como chegam ao projeto (sem depender do PC)

O workspace não consegue descarregar, mas o **GitHub Actions consegue**:
1. Workflow `assets.yml` (manual): descarrega da API do Poly Haven/ambientCG/OpenGameArt, reduz para 1k, comprime, gera `assets/LICENSES.md`, faz commit em `jogo/assets/`.
2. Workflow `chars.yml`: instala Blender + MPFB 2 sem ecrã, gera ~12 personagens (homens/mulheres, fato de treino, calças de ganga, capuz, colete, polícia) a partir de um script, exporta glTF com esqueleto humanoide.
3. Eu puxo do GitHub e envio para `Projetos\GOLPE` no PC; o Godot importa sozinho.
4. Mixamo e Sketchfab precisam de sessão do utilizador → só para extras, com o browser do PC.

## 5. Ordem de execução (cada passo com captura antes/depois)

1. **v0.6 HUD + Definições** (feito): HUD discreto, ícones, euros, menu de definições.
2. **Motor 4.7 + Mobile renderer + HDRI + texturas PBR** na cidade (alcatrão, calçada, fachadas, vidros com reflexo). Maior salto visual.
3. **Personagens humanos** (MPFB 2 / Quaternius) com roupa urbana + polícia com farda e colete; NPCs variados.
4. **Som**: armas, passos, motor com rotação, sirene com Doppler, portas/alarme, ambiente da cidade, música de menu. Volume nas Definições.
5. **Interiores densos** com adereços Poly Haven + luz pré-calculada; montras, notas, plantas.
6. **Carros**: modelos CC0 com pintura PBR/verniz, faróis, luzes de polícia reais.
7. **Menus completos ao nível do género**: ecrã inicial com cena 3D, personagem/aspeto, inventário de ecrã inteiro, mapa estilizado, loja.
8. Mecânicas que faltam (ver `parity.md`): colete/munições, prisão e suborno, base modular, assaltos encadeados, multijogador.

## 6. Riscos

- Personagens realistas + Mobile renderer podem pesar em telemóveis fracos → "Qualidade Baixa" troca para malhas/texturas mais leves e desliga sombras.
- MPFB em CI é o passo tecnicamente mais difícil; plano B = Quaternius Universal Base Characters.
- Godot 4.3 → 4.7: pequenas mudanças de API; o CI apanha os erros antes de chegar ao telemóvel. Precisas de instalar o Godot 4.7 no PC.
