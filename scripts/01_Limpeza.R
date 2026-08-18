#Instalando os pacotes necessários
install.packages("tidyverse")
library(tidyverse)


#VISUALIZANDO DADOS
#Utilizaremos o histórico de partidas do competitivo de LOL durante o ano de 2025 e 2026
dados_2025 <- read_csv("dados/raw/2025_LoL_esports_match_data.csv")
dados_2026 <- read_csv("dados/raw/2026_LoL_esports_match_data.csv")


#-------------------------------------------------------------------
#ANALISANDO DADOS DE 2025
head(dados_2025)
glimpse(dados_2025)


#num observações
nrow(dados_2025)
#Temos 120.456 observações(jogos registrados em 2025)

#num variáveis
names(dados_2025)
ncol(dados_2025)
View(dados_2025)
#Nosso banco de dados possui 165 variáveis

#DESCRIÇÃO BREVE DAS PRINCIPAIS VARIÁVEIS:
#Após uma breve análise das observações e variáveis descobrimos que se trata de todas as estatísticas presentes durante uma partida de league of legends. Temos informações desde o período em que essa partida foi executada, até o numero de gold que o jogador obteve aos 15 minutos de jogo

#----------------------------------------------------------------------------------

#VERIFICANDO SE A BASE DE 2025 = 2026
identical(names(dados_2025), names(dados_2026))
#R: TRUE, são iguais

#ANALISANDO BASE 2026
nrow(dados_2026)
#Temos 71232 observações(partidas), motivo: Estamos apenas na metade do ano

ncol(dados_2026)
#Temos as mesmas variáveis: 165
View(dados_2026)

#----------------------------------------------------------------------------------

#JUNTANDO AS BASES
dados_completos <- bind_rows(dados_2025, dados_2026)
nrow(dados_completos)
#R: 191688

view(dados_completos)


#-----------------------------------------------
#SELECIONANDO AS VARIAVEIS
#-----------------------------------------------

#Primeiro, vamos utilizar apenas o jogos completos
dados_completos <- dados_completos %>% 
  filter(datacompleteness == "complete")


#Observamos que as NAs seguem um padrão. Os NAs que estão nas linhas dos jogadores estão nas linhas do time, e vice-versa. Por isso, separaremos em mais duas bases
dados_jogadores <- dados_completos %>% 
  filter(position != "team")

dados_time <- dados_completos %>% 
  filter(position == "team")


#Definindo total de partidas por PATCH (uma tabela com o total de partidas)
total_games_patch <- dados_time %>% 
  distinct(gameid, patch) %>% 
  count(patch, name = "total_games")


#-----------------------------------------------
#ISOLANDO ESTATÍSTICAS
#-----------------------------------------------

#---------DRAFT(Picks e bans)---------
draft <- dados_time %>% 
  select(gameid, teamname, side, patch, starts_with("ban"), starts_with("pick"))


#Achatando bans: no df, cada ban está representado por uma coluna, vamos empilhar as 5 colunas em uma só. Slot será qual ban(ban1, ban2...) e removeremos casos que o não tenha ban
bans <- draft %>% 
  select(gameid, patch, starts_with("ban")) %>% 
  pivot_longer(starts_with("ban"), names_to = "slot", values_to = "champion") %>% 
  filter(!is.na(champion))

#Mesma coisa 
picks <- draft %>%
  select(gameid, patch, starts_with("pick")) %>%
  pivot_longer(starts_with("pick"), names_to = "slot", values_to = "champion") %>%
  filter(!is.na(champion))

#Criando estatísticas
picks_stats <- picks %>% count(champion, patch, name = "n_picks")
bans_stats <- bans %>% count(champion, patch, name = "n_bans")

#Criando a variável presença (Relação entre pick e bans durante o draft)
presence_games <- bind_rows(bans, picks) %>%
  distinct(gameid, patch, champion) %>%
  count(champion, patch, name = "n_presence_games")

#Criando a tabela geral com as métricas de draft(Criando a taxa de pick, ban e presença)
draft_metrics <- picks_stats %>% 
  full_join(bans_stats, by = c("champion", "patch")) %>% 
  full_join(presence_games, by = c("champion", "patch")) %>% 
  full_join(total_games_patch, by = "patch") %>% 
  mutate(across(starts_with("n_"), ~replace_na(.x, 0)),
         pick_rate = n_picks / total_games,
         ban_rate = n_bans / total_games,
         presence  = n_presence_games / total_games) %>%
  arrange(patch, desc(presence))

#O que fizemos acima? Criamos as tabelas com cada métrica e então juntamos todas em uma tabela só utilizando o full_join e então tornamos as tabelas pick, ban e presença em taxas





#-------OBJETIVOS--------
#Vamos também criar variáveis dos objetivos do jogo (torres, dragões, barão, etc)


# ---- Objetivos de time (só existem em base_time) ----
objetivos_time <- dados_time %>%
  select(gameid, teamname,
         firstdragon, firsttower, towers, void_grubs, barons,
         infernals, mountains, clouds, oceans, chemtechs, hextechs, elders)

#---- Junta de volta nas linhas de jogador ----
jogadores_com_objetivos <- dados_jogadores %>%
  select(-firstdragon, -firsttower, -towers, -void_grubs, -barons,
         -infernals, -mountains, -clouds, -oceans, -chemtechs, -hextechs, -elders) %>%
  left_join(objetivos_time, by = c("gameid", "teamname"))


#---------PERFORMANCE---------
#Tabela com as métricas individuais de cada campeão (gold, kda, win rate..) + objetivos de time
perf_metrics <- jogadores_com_objetivos %>%
  group_by(champion, patch) %>%
  summarise(
    n_games         = n(),
    avg_kda         = mean((kills + assists) / pmax(deaths, 1), na.rm = TRUE),
    avg_gold        = mean(totalgold, na.rm = TRUE),
    avg_gpm         = mean(`earned gpm`, na.rm = TRUE),
    avg_dpm         = mean(dpm, na.rm = TRUE),
    avg_xp15        = mean(xpat15, na.rm = TRUE),
    winrate         = mean(result, na.rm = TRUE),
    avg_firstblood  = mean(firstblood, na.rm = TRUE),
    avg_goldat15    = mean(goldat15, na.rm = TRUE),
    avg_csat15      = mean(csat15, na.rm = TRUE),
    avg_cspm        = mean(cspm, na.rm = TRUE),
    avg_firstdragon = mean(firstdragon, na.rm = TRUE),
    avg_firsttower  = mean(firsttower, na.rm = TRUE),
    avg_towers      = mean(towers, na.rm = TRUE),
    avg_void_grubs  = mean(void_grubs, na.rm = TRUE),
    avg_barons      = mean(barons, na.rm = TRUE),
    avg_infernals   = mean(infernals, na.rm = TRUE),
    avg_mountains   = mean(mountains, na.rm = TRUE),
    avg_clouds      = mean(clouds, na.rm = TRUE),
    avg_oceans      = mean(oceans, na.rm = TRUE),
    avg_chemtechs   = mean(chemtechs, na.rm = TRUE),
    avg_hextechs    = mean(hextechs, na.rm = TRUE),
    avg_elders      = mean(elders, na.rm = TRUE),
    .groups = "drop"
  )



#----JUNTANDO DRAFT E PERFORMANCE------
champion_stats <- draft_metrics %>% 
  full_join(perf_metrics, by = c("champion", "patch"))



#------DEFININDO A VARIÁVEL RESPOSTA-------------

#Para cada patch separadamente, o R ordena os campeões pela presence.
#Calcula o percentil 75 dessa distribuição.
#Todos os campeões com presença maior ou igual a esse valor recebem 1.
#Os demais recebem 0.
champion_stats <- champion_stats %>%
  group_by(patch) %>%
  mutate(corte = quantile(presence, 0.75, na.rm = TRUE),
         relevancia_bin = if_else(presence >= corte, 1, 0)) %>%
  ungroup()


#Tornando patch como um fator
champion_stats <- champion_stats %>% mutate(patch = factor(patch))


#-----COLOCANDO AS POSIÇÕES DOS CAMPEÕES----------
champion_positions <- read_csv("dados/processed/metricas_especificas/champions_position.csv")
champion_stats <- champion_stats %>%
  left_join(champion_positions, by = "champion")


#--------------------------------------------------
# Salvar a base limpa
#--------------------------------------------------

# Base completa
write_csv(
  dados_completos,
  "dados/processed/dados_completos.csv"
)

# Base dos jogadores
write_csv(
  dados_jogadores,
  "dados/processed/dados_jogadores.csv"
)

# Base dos times
write_csv(
  dados_time,
  "dados/processed/dados_time.csv"
)

#Champion stats
write_csv(
  champion_stats, "dados/processed/champion_stats.csv"
)

# Total de partidas por patch
write_csv(
  total_games_patch,
  "dados/processed/total_games_patch.csv"
)

# Draft (picks e bans por partida)
write_csv(
  draft,
  "dados/processed/draft.csv"
)

# Bans em formato longo
write_csv(
  bans,
  "dados/processed/bans.csv"
)

# Picks em formato longo
write_csv(
  picks,
  "dados/processed/picks.csv"
)

# Estatísticas de picks
write_csv(
  picks_stats,
  "dados/processed/picks_stats.csv"
)

# Estatísticas de bans
write_csv(
  bans_stats,
  "dados/processed/bans_stats.csv"
)

# Presença dos campeões
write_csv(
  presence_games,
  "dados/processed/presence_games.csv"
)

# Métricas de draft
write_csv(
  draft_metrics,
  "dados/processed/draft_metrics.csv"
)

# Objetivos dos times
write_csv(
  objetivos_time,
  "dados/processed/objetivos_time.csv"
)

# Jogadores com objetivos do time
write_csv(
  jogadores_com_objetivos,
  "dados/processed/jogadores_com_objetivos.csv"
)

# Métricas de performance
write_csv(
  perf_metrics,
  "dados/processed/perf_metrics.csv"
)




