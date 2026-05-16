---
name: dev-coding
description: Executa um PLAN.md task por task — lê read_first, aplica a action, verifica acceptance, marca [x], faz commit atômico se aplicável. Suporta TDD vertical (tracer bullet red-green-refactor), checkpoints HITL, diagnose loop quando bug aparece. Roda Must-Haves no fim. Use quando o usuário disser "/dev-coding", "executa o plano", "implementa o PLAN.md", "next task", "continua do task-XX", ou pedir para começar/continuar implementação a partir de um PLAN.md existente.
---

# /dev-coding — Executar PLAN.md task por task

Esta skill assume que existe `.plans/<feature>/PLAN.md` produzido por `/dev-plan` (ou compatível). Executa uma task por vez, com verificação dura no fim de cada uma.

## Pré-condições

- Existe `<workspace>/.plans/<feature>/PLAN.md` (ou usuário aponta o path)
- Você pode escrever e executar comandos no projeto

Se não houver PLAN.md, **pare e sugira `/dev-plan` antes**.

## Processo por task

### 1. Carregue o contexto mínimo

Em cada execução (especialmente após reset de contexto):

1. **Read** `.plans/<feature>/PLAN.md` integralmente
2. **Read** `CLAUDE.md` do projeto + sub-CLAUDEs citados em `## Affected Areas`
3. Identifique a próxima task com `status: [ ]` cuja dependência (`depends_on`) já está `[x]`
4. **Read** todos os `read_first` da task escolhida ANTES de qualquer edit

### 2. Despache pelo tipo

#### `type: auto` (execução direta)

1. Anuncie em 1 frase: *"task-XX: <título> — vou tocar <files>."*
2. Execute as subtasks da `action` em ordem
3. Rode o `must_pass` (typecheck, build, test, lint conforme aplicável)
4. Cheque cada `acceptance` — grep / curl / output esperado
5. Marque `[x]` em cada acceptance no PLAN.md
6. Atualize `## Status Log` com timestamp + identificador (commit hash se for committar)
7. Reporte ao usuário em 2-3 linhas: o que mudou, o que verificou, próxima task

#### `type: tdd` (red-green-refactor vertical)

**Princípio:** tracer bullets, NÃO horizontal slicing. UM teste → UMA implementação → REPETE. Nunca escrever todos os testes primeiro.

Por subtask:
```
RED:   escreva 1 teste para 1 behavior — rode → vê falhar
GREEN: código mínimo para passar — rode → vê passar
       (não antecipe próximos testes; não adicione features especulativas)
[Após todas as subtasks GREEN: REFACTOR — só quando GREEN, nunca quando RED]
```

Regras de teste:
- Testar **behavior** via interface pública, não implementação interna
- Sem mocks de colaboradores internos (mock só boundary externo — DB, HTTP)
- Teste deve sobreviver a refactor que não muda behavior
- Se renomear função interna quebra o teste, o teste estava errado

#### `type: checkpoint:decision`

1. Pare a execução
2. Apresente ao usuário (1 mensagem):
   - O que precisa decidir (`decision`)
   - Por que importa
   - Opções com pros/cons
3. **Espere resposta.** Não escolha sozinho.
4. Após escolha, registre no PLAN.md → seção `## Decisions` (adicionar entrada) e siga para próxima task.

#### `type: checkpoint:human-verify`

1. Execute o setup (start dev server, run command, etc.)
2. Confirme que o ambiente está pronto (HTTP 200, port aberta, build ok)
3. Apresente ao usuário:
   - URL/comando para verificar
   - 2-4 checks visuais/funcionais específicos
4. **Espere "approved" ou descrição do problema.**
5. Se aprovado → marque `[x]`, mata o server se for o caso
6. Se reprovado → entre em **diagnose loop** (seção abaixo)

### 3. Quando algo falha (diagnose loop)

Não tente "ajeitar e ver se passa". Siga disciplina:

**Phase 1 — Build feedback loop:** o teste/script que reproduz o bug em <10s e dá pass/fail determinístico. Isso é 90% do trabalho. Se o seu único loop é "rodar o app e clicar", invista em melhorá-lo.

**Phase 2 — Reproduzir:** rode o loop, observe a falha, confirme que é a MESMA que o usuário descreveu (não uma vizinha).

**Phase 3 — Hipóteses ranqueadas:** 3-5 hipóteses, cada uma com predição falsificável ("se X é a causa, mexer em Y faz desaparecer"). Mostre a lista ao user antes de testar — eles ranqueiam mais rápido com domain knowledge.

**Phase 4 — Instrumentar:** um probe por hipótese. Prefira debugger > log direcionado > log everything. Logs de debug com prefixo único (`[DEBUG-a4f2]`) pra cleanup grep no fim.

**Phase 5 — Fix + regression test:** se há seam correto, escreva o teste de regressão ANTES do fix. Veja falhar → aplica fix → veja passar.

**Phase 6 — Cleanup:** remova logs `[DEBUG-*]`, delete probes, confirme que o repro original não reproduz mais.

### 4. Atualize o PLAN.md ao vivo

Cada task completed → mark `[x]` em cada `acceptance` + adicione entrada no `## Status Log`. Não acumule pra escrever no fim.

### 5. Ao terminar a última task — Must-Haves verification

Antes de declarar a feature done:

1. **Truths:** cheque cada behavior listado (idealmente via smoke test, não inspeção visual)
2. **Artifacts:** cheque cada arquivo (existe? min_lines? exports/contains corretos?)
3. **Key Links:** rode os regex declarados — devem casar

Se qualquer Must-Have falhar:
- **Diagnosticar:** por que essa task "completed" não satisfez o goal?
- **Criar fix-task ad-hoc** no PLAN.md (não mascarar)
- Executar a fix-task → re-verify
- Loop até todas Must-Haves passarem

### 6. SUMMARY final

Após Must-Haves verdes, opcionalmente escrever `.plans/<feature>/SUMMARY.md`:
- O que foi entregue (1 parágrafo)
- Commits envolvidos
- Decisões tomadas durante execução que não estavam no plano
- Coisas que apareceram e foram deferidas (open follow-ups)

## Princípios de execução (Karpathy)

- **Cirurgia, não reforma.** Toque só o que a task pede. Não refatore código adjacente, não "melhore" formatação, não adicione tipos onde não havia. Se notar algo, mencione — não delete.
- **Mínimo necessário.** Resolva a task. Não adicione abstração para uso único. Não preveja features futuras. Não engineering por hipotético.
- **Critério de sucesso primeiro.** Antes de codar, releia `acceptance` e `must_pass`. Sua execução tem como meta acender esses verdes.
- **Verify before done.** Rode o `must_pass`. Cheque cada `acceptance`. Não declare done com base em vibes.
- **Sem error handling especulativo.** Só valide em boundary (input externo). Confie em garantias internas.

## Anti-padrões

- ❌ Pular `read_first` ("é rápido, sei o que tem ali")
- ❌ Escrever todos os testes TDD juntos antes de qualquer implementação
- ❌ Refatorar enquanto está RED
- ❌ Marcar `[x]` sem rodar a verificação
- ❌ "Vou rodar o teste pra ver se passa" sem ter o critério claro do que deveria acontecer
- ❌ Reescrever arquivo inteiro quando 5 linhas resolvem
- ❌ Skip de hooks/lint/typecheck para "ir mais rápido"
- ❌ Esconder falha mudando o teste em vez de corrigir o código
- ❌ Mockar colaborador interno (vai dar verde com behavior quebrado)
- ❌ Auto-aprovar checkpoint HITL ("não vou perguntar, já sei a resposta")

## Comunicação com o usuário

**Antes de cada task:** 1 frase — "task-XX: vou tocar X, Y. Rode commit no fim? (y/n)" se ambíguo.

**Durante:** silêncio relativo. Não narre tool calls. Comunique só obstáculo ou descoberta surpreendente.

**Depois de cada task:** 2-3 linhas — o que mudou, o que verificou, próxima task ID.

**No fim da feature:** SUMMARY conciso + opção de `/loop` se houver follow-ups que precisem virar nova feature.

## Quando parar e perguntar (mesmo em modo auto)

- A task tem `acceptance` ambíguo na prática
- A mudança implica decisão de design não prevista no plano
- O `must_pass` falha de forma que sugere problema arquitetural (não bug local)
- Vai tocar arquivo sensível não listado em `files_modified`
- Vai rodar comando destrutivo (force push, drop table, rm -rf)

**Não improvise nessas.** Pare, reporte, pergunte.
