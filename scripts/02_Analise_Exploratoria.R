#####################################
#      ANÁLISE EXPLORATÓRIA
#####################################

#Instalando pacotes novamente
library(tidyverse)

champion_stats <- read_csv("dados/processed/champion_stats.csv")


#----------------------------------------------------------
#CRIANDO TABELA SOBRE A BASE DE DADOS PARA O RELATÓRIO
#----------------------------------------------------------

#Tabela sobre num de variáveis, observações, patchs
caracterizacao <- tibble(
  Medida = c(
    "Número de observações",
    "Número de variáveis",
    "Número de patches",
    "Número de campeões"
  ),
  Valor = c(
    nrow(champion_stats),
    ncol(champion_stats),
    n_distinct(champion_stats$patch),
    n_distinct(champion_stats$champion)
  )
)

caracterizacao


#TABELA SOBRE VALORES AUSENTES
na_table <- champion_stats %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  tidyr::pivot_longer(
    everything(),
    names_to = "Variavel",
    values_to = "Valores_Ausentes"
  )

na_table %>%
  filter(Valores_Ausentes > 0)



#TABELA SOBRE ESTATÍSTICAS DESCRITIVAS
estatisticas <-
  champion_stats %>%
  summarise(
    across(
      c(winrate, avg_kda, avg_gold, avg_dpm, presence, n_games),
      list(
        Média = ~mean(.x, na.rm = TRUE),
        Mediana = ~median(.x, na.rm = TRUE),
        DP = ~sd(.x, na.rm = TRUE),
        Mínimo = ~min(.x, na.rm = TRUE),
        Máximo = ~max(.x, na.rm = TRUE)
      )
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to = c("Variavel", "Estatistica"),
    names_sep = "_(?=[^_]+$)",
    values_to = "Valor"
  ) %>%
  pivot_wider(
    names_from = Estatistica,
    values_from = Valor
  )

estatisticas





#######################################################
#--------VISUALIZANDO INTERAÇÕES DAS VARIÁVEIS--------
#######################################################


#Visualizando a Distribuição da classe

table(champion_stats$relevancia_bin)

prop.table(table(champion_stats$relevancia_bin))


#Visualizando distribuição da presença como histograma

ggplot(champion_stats, aes(x = presence)) +
  geom_histogram(bins = 30)


#Visualizando com gráfico a distribuição das classes
ggplot(champion_stats,
       aes(factor(relevancia_bin)))+
  geom_bar()


#Número de campeões relevantes por patch
champion_stats %>%
  group_by(patch) %>%
  summarise(
    relevantes=sum(relevancia_bin)
  )

#Tabela de estatísticas descritivas para várias variáveis do seu conjunto
resumo <- champion_stats %>%
  summarise(across(c(winrate, avg_kda, avg_gold, avg_dpm, presence, n_games),
                   list(media = ~mean(.x, na.rm=TRUE), mediana = ~median(.x, na.rm=TRUE),
                        dp = ~sd(.x, na.rm=TRUE), min = ~min(.x, na.rm=TRUE), max = ~max(.x, na.rm=TRUE))))

print(resumo, width = Inf)



#-----Plotando as presence em relação as variáveis-----

#Selecionando quais estarão de fora
variaveis <- champion_stats %>%
  select(where(is.numeric)) %>%
  select(
    -presence,
    -n_picks,
    -n_bans,
    -pick_rate,
    -ban_rate,
    -total_games,
    -n_games,
    -corte,
    -relevancia_bin,
    -n_presence_games
  ) %>%
  names()

for(v in variaveis){
  
  g <- ggplot(champion_stats,
              aes(x = .data[[v]], y = presence)) +
    geom_point(alpha = 0.6, color = "#2C7FB8") +
    geom_smooth(method = "lm", se = TRUE, color = "red") +
    labs(
      title = paste("Presence ×", v),
      x = v,
      y = "Presence"
    ) +
    theme_minimal(base_size = 13)
  
  print(g)
  
}



