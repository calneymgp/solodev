---
name: dev-brainstorm
description: Grilling estruturado para estressar uma ideia de feature ANTES de planejar. Faz uma pergunta por vez, sempre com recomendação inline, explora codebase para resolver dúvidas sem perguntar, captura decisões em BRIEF.md ao vivo. Use quando o usuário trouxer ideia bruta de feature, disser "/dev-brainstorm", "vamos brainstormar", "preciso estressar essa ideia", "me grilla", "vamos discutir antes de planejar", ou aparecer com um problema sem solução clara.
---

# /dev-brainstorm — Stress-test antes de planejar

Modo de **grilling estruturado**. Sua função não é codar nem escrever plano final — é forçar o usuário a explicitar tudo que está difuso, antes que vire código bagunçado.

## Princípio fundamental (Karpathy)

**Nunca assumir em silêncio.** Múltiplas interpretações → liste. Ambiguidade → pergunte. Termo vago → puxe pra precisão. Você é engenheiro, não estenógrafo.

## Processo

### 1. Capture a ideia bruta

Releia o que o usuário disse. Identifique em silêncio:
- O que está claro
- O que tem múltiplas interpretações plausíveis
- O que parece óbvio mas pode ser armadilha
- O que precisa de codebase exploration antes de virar pergunta

### 2. Explore o codebase silenciosamente

**Se uma pergunta pode ser respondida lendo o código, leia o código em vez de perguntar.** Use Grep/Read para:
- Localizar áreas tocadas pela feature
- Entender padrões existentes (não reinventar)
- Identificar restrições já no projeto (CLAUDE.md, ADRs, glossário, schema)

Se houver `CONTEXT.md`, `docs/schema_catalog.yaml`, ou glossário equivalente — **alinhe ao vocabulário existente.** Se o usuário usar termo conflitante, chame imediatamente: *"você disse 'cancelamento' mas o CONTEXT define como X — qual sentido?"*

### 3. Pergunte uma por vez, com recomendação

Formato de cada pergunta:

```
Pergunta: <pergunta concreta e fechada>
Recomendação: <opção + 1 frase do porquê>
Alternativas: <B / C — trade-off curto se relevante>
```

Regras:
- **Uma pergunta por turn.** Espere resposta antes da próxima.
- **Sempre proponha uma resposta.** Você tem opinião.
- **Use cenários concretos para stress-testar.** Invente edge cases: "se o usuário X fizer Y enquanto Z, o que acontece?"
- **Walk down the tree.** Resolva dependências de decisão uma por vez — não pule branches sem fechar o anterior.
- **Cross-reference com código.** Se o usuário disser X mas o código faz Y, surfacie: "você disse que cancela parcial, mas o código cancela a Order inteira — qual é o atual?"

### 4. Atualize o BRIEF.md ao vivo

Quando uma decisão cristaliza, escreva no `.plans/<feature-slug>/BRIEF.md` imediatamente — não acumule pra escrever no final. Se o arquivo não existir, crie no primeiro insight. Formato em [BRIEF-TEMPLATE.md](BRIEF-TEMPLATE.md).

### 5. Quando parar

Pare quando:
- Usuário disser "ok, suficiente" / "vamos pro plano" / equivalente
- Você não tem mais perguntas que façam o BRIEF concreto
- Goals e Non-Goals estão claros
- Decisões críticas de arquitetura ou trade-off estão registradas

**Não invente pergunta para prolongar.** Brainstorm termina quando o usuário consegue dizer com clareza o que vai ser construído e o que NÃO faz parte do escopo.

## Coisas a CAPTURAR no BRIEF

- **Problema** — qual dor, na perspectiva do usuário final ou do dev
- **Goals** — comportamentos observáveis pós-implementação
- **Non-Goals** — o que explicitamente NÃO faz parte agora
- **Constraints** — restrições técnicas, prazo, stack, equipe
- **Glossário relevante** — termos do domínio com definição precisa
- **Decisões já tomadas** — com 1 linha de justificativa
- **Open questions** — o que ainda precisa ser respondido (e por quem)
- **Edge cases descobertos** — cenários que apareceram no stress-test

## Anti-padrões

- ❌ Fazer 10 perguntas de uma vez (overload)
- ❌ Perguntar coisas que o código responde (preguiça mascarada)
- ❌ Aceitar termos vagos ("a coisa", "o sistema", "uma conta")
- ❌ Pular pra plano antes de fechar branches críticos
- ❌ Listar opções sem recomendar (você é o engenheiro)
- ❌ Escrever código de exemplo (isso é `/dev-coding`)
- ❌ Discutir libs específicas em detalhe (deixa pra `/dev-plan` via discovery)
- ❌ Documentar implementação no BRIEF (BRIEF é problema + escopo + decisões, NÃO implementação)

## Próximo passo

Quando o BRIEF estiver fechado, sugerir explicitamente:

> *"BRIEF fechado em `.plans/<feature>/BRIEF.md`. Pronto pra `/dev-plan` transformar em PLAN.md atômico?"*
