# 🎮 Análise e Classificação da Relevância de Campeões no CBLOL

Projeto de **análise de dados e classificação** aplicado ao cenário competitivo de *League of Legends*, com o objetivo de identificar fatores associados à relevância dos campeões em diferentes patches e classificá-los como **relevantes ou não relevantes**.

---

## 🎯 Objetivo

O projeto busca analisar o comportamento dos campeões no cenário competitivo de *League of Legends* e identificar variáveis relacionadas à sua relevância durante cada patch.

A partir dessa análise, foi desenvolvido um problema de **classificação binária**, no qual cada campeão é classificado como:

* **Relevante**
* **Não relevante**

A definição de relevância foi realizada considerando a presença dos campeões nas partidas competitivas dentro de cada patch.

---

## 📊 Dados

Foram utilizados dados de partidas profissionais de *League of Legends* referentes às temporadas de **2025 e 2026**, obtidos a partir dos dados disponibilizados pelo **Oracle's Elixir**.

Os dados contêm informações relacionadas a:

* Campeões utilizados;
* Picks e bans;
* Vitórias e derrotas;
* Estatísticas individuais dos jogadores;
* Estatísticas das equipes;
* KDA;
* Presença dos campeões;
* Patch da partida;
* Outras métricas de desempenho competitivo.

Os dados foram divididos em duas etapas:

```text
dados/
├── raw/
│   ├── 2025_LoL_esports_match_data.csv
│   └── 2026_LoL_esports_match_data.csv
│
└── processed/
    └── dados processados utilizados nas análises
```

---

## 🔎 Metodologia

O desenvolvimento do projeto foi dividido nas seguintes etapas:

### 1. Coleta e organização dos dados

Os dados das partidas competitivas foram reunidos e organizados para permitir a análise conjunta das temporadas de 2025 e 2026.

### 2. Limpeza e tratamento

Foram realizados procedimentos de:

* Padronização das variáveis;
* Tratamento de valores ausentes;
* Organização das informações por campeão, jogador e equipe;
* Criação de variáveis derivadas;
* Preparação dos dados para análise estatística e modelagem.

### 3. Análise exploratória

Foi realizada uma análise exploratória para investigar a distribuição das variáveis e compreender possíveis relações entre desempenho, presença e relevância dos campeões.

Entre as variáveis analisadas estão métricas como:

* Presença;
* KDA;
* Picks;
* Bans;
* Vitórias;
* Derrotas;
* Patch;
* Estatísticas de desempenho.

### 4. Classificação da relevância

A variável resposta foi construída como uma variável binária.

Para cada patch, a presença dos campeões foi utilizada para determinar quais deles pertenciam ao grupo de maior relevância competitiva.

Dessa forma, o problema foi estruturado como uma tarefa de **classificação binária**.

### 5. Modelagem

Foram estudadas diferentes abordagens de classificação, com destaque para modelos de **Machine Learning**.

Entre as abordagens consideradas estão:

* Regressão Logística;
* Árvore de Decisão;
* Random Forest;
* Support Vector Machine (SVM).

O **Random Forest** foi utilizado para a modelagem final e avaliação da classificação.

---

## 🌲 Modelo Random Forest

O modelo Random Forest foi construído utilizando **500 árvores de decisão**.

Foram avaliadas diferentes estratégias de divisão dos dados para treinamento e teste.

Na divisão utilizada para avaliação, o modelo apresentou os seguintes resultados:

| Métrica        | Resultado |
| -------------- | --------: |
| Acurácia       | **81,8%** |
| Sensibilidade  | **86,6%** |
| Especificidade | **80,1%** |
| Precisão       | **60,9%** |
| F1-score       | **71,5%** |

O modelo apresentou um bom desempenho geral na classificação, especialmente em relação à capacidade de identificar os campeões pertencentes à classe relevante.

---

## 📈 Principais resultados

Os resultados indicam que as informações disponíveis na base do **Oracle's Elixir** permitem construir um modelo capaz de classificar os campeões de acordo com a definição de relevância adotada neste trabalho.

O **Random Forest final** apresentou:

| Métrica      | Resultado |
| ------------ | --------: |
| **AUC**      | **0,906** |
| **Acurácia** | **81,8%** |

O valor de **AUC = 0,906** indica uma boa capacidade do modelo de distinguir entre as classes **"Mais Relevante"** e **"Menos Relevante"**.

### 🔎 Importância das variáveis

A análise de importância das variáveis indicou que características relacionadas ao **controle de objetivos estruturais e de dragões** apresentaram a maior contribuição para a classificação, com destaque para:

* `avg_elders`
* `avg_firstdragon`
* `avg_firsttower`

Esse resultado foi consistente entre as duas divisões de treino e teste avaliadas no projeto.

Entretanto, é importante destacar que essas variáveis refletem principalmente o **desempenho coletivo da equipe**, e não exclusivamente o desempenho individual do campeão. Portanto, sua importância não deve ser interpretada como uma relação causal direta entre o campeão e o controle desses objetivos.

Por outro lado, variáveis relacionadas ao **desempenho econômico individual**, como ouro, dano por minuto e farm, apresentaram menor contribuição relativa entre as variáveis analisadas. Embora esse resultado possa parecer inicialmente contraintuitivo, ele se mostrou consistente entre os dois modelos avaliados.

> **Conclusão:** o modelo apresentou boa capacidade de classificação da relevância dos campeões, enquanto a análise das variáveis sugere que aspectos relacionados ao contexto coletivo e ao controle de objetivos tiveram maior importância para a classificação do que métricas individuais de desempenho econômico.


---

## 🗂️ Estrutura do projeto

```text
📦 projeto-analise-cblol
│
├── 📂 dados
│   ├── 📂 raw
│   └── 📂 processed
│
├── 📂 scripts
│   ├── scripts de limpeza
│   ├── scripts de análise
│   └── scripts de modelagem
│
├── 📂 imagens
│   └── gráficos e fluxogramas
│
├── 📄 Relatorio_Projeto_CBLOL.qmd
├── 📄 Projeto_Analise_CBLOL.Rproj
├── 📄 referencias.bib
├── 📄 .gitignore
└── 📄 README.md
```

---

## 🛠️ Tecnologias utilizadas

* **R**
* **RStudio**
* **Quarto**
* **tidyverse**
* **dplyr**
* **ggplot2**
* **Machine Learning**
* **Random Forest**
* **Git/GitHub**

---

## 📚 Referências

Os dados utilizados no projeto foram obtidos a partir de bases de partidas competitivas de *League of Legends* disponibilizadas pelo **Oracle's Elixir**.

As demais referências utilizadas na análise encontram-se no arquivo [`referencias.bib`](referencias.bib).

---

## 👤 Autor

**Cauã Batista**

Estudante de **Ciência de Dados e Estatística — UFU**.

Este projeto foi desenvolvido como parte da formação acadêmica e tem como objetivo aplicar conceitos de estatística, análise de dados e Machine Learning a um problema real do cenário competitivo de *League of Legends*.
