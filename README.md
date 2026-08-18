<div align="center">

# 🎮 Análise e Classificação da Relevância de Campeões no CBLOL

### Análise de dados · Classificação · Machine Learning · R + Quarto

![Status](https://img.shields.io/badge/status-concluído-brightgreen?style=for-the-badge)
![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Quarto](https://img.shields.io/badge/Quarto-39729E?style=for-the-badge&logo=quarto&logoColor=white)
![tidyverse](https://img.shields.io/badge/tidyverse-1F9E89?style=for-the-badge)
![Random Forest](https://img.shields.io/badge/Random%20Forest-Machine%20Learning-6A1B9A?style=for-the-badge)

</div>

---

> **Projeto de análise de dados e Machine Learning aplicado ao cenário competitivo de League of Legends** — desenvolvido para investigar quais características estão associadas à relevância dos campeões ao longo dos diferentes patches e construir um modelo capaz de classificá-los como "Mais Relevantes" ou "Menos Relevantes".

<br>

## 🧠 Skills Aplicadas

<table>
  <tr>
    <td valign="top" width="50%">

**📊 Análise de Dados**
- Limpeza e tratamento de dados
- Análise exploratória de dados (EDA)
- Estatística descritiva
- Manipulação e transformação de dados com `tidyverse`
- Criação e análise de variáveis derivadas
- Visualização de dados com `ggplot2`

**🤖 Machine Learning**
- Classificação binária
- Regressão Logística
- Árvore de Decisão
- Random Forest
- Support Vector Machine (SVM)
- Análise de importância das variáveis

**📐 Estatística**
- Definição da variável resposta
- Uso de percentis para classificação da relevância
- Avaliação de modelos
- Matriz de confusão
- Acurácia
- Sensibilidade
- Especificidade
- Precisão
- F1-score
- AUC / ROC

  </td>
  <td valign="top" width="50%">

**🎮 Contexto Competitivo**
- Análise de partidas profissionais de League of Legends
- Análise por campeão
- Análise por patch
- Picks e bans
- Presença competitiva
- Métricas individuais e coletivas
- Controle de objetivos

**📄 Documentação**
- Relatório desenvolvido em Quarto
- Organização modular dos scripts
- Referências bibliográficas em BibTeX
- Fluxogramas para documentação do processo
- Separação entre dados brutos e processados

**🛠️ Ferramentas**
- R
- RStudio
- Quarto
- tidyverse
- dplyr
- ggplot2
- randomForest
- Git
- GitHub

  </td>
  </tr>
</table>

<br>

---

## 📐 Metodologia Geral

O projeto foi desenvolvido seguindo um fluxo de preparação dos dados, análise exploratória e construção de modelos de classificação.

```text
┌─────────────────────────────┐
│      Dados competitivos     │
│       Oracle's Elixir       │
└──────────────┬──────────────┘
               │
               │ Dados de partidas
               ▼
┌─────────────────────────────┐
│      Limpeza e tratamento   │
│                             │
│  • Padronização             │
│  • Valores ausentes         │
│  • Transformação de dados   │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│    Análise exploratória     │
│                             │
│  • Distribuições            │
│  • Relações entre variáveis │
│  • Comportamento por patch  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ Definição da relevância     │
│                             │
│ Mais Relevante              │
│          ou                 │
│ Menos Relevante             │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│          Modelos de classificação       │
│                                         │
│  Regressão Logística                    │
│  Árvore de Decisão                      │
│  Random Forest                          │
│  SVM                                    │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────┐
│     Avaliação dos modelos   │
│                             │
│  Acurácia · AUC · ROC       │
│  Sensibilidade · F1-score   │
│  Importância das variáveis  │
└─────────────────────────────┘
