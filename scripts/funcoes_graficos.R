
# funcoes_graficos.R
library(tidyverse)
library(randomForest)
champion_stats <- read_csv("dados/processed/champion_stats.csv")


plot_presence_hist <- function(dados) {
  ggplot(dados, aes(x = presence)) +
    geom_histogram(bins = 30, fill = "#2C7FB8", color = "white") +
    labs(title = "Distribuição da presença dos campeões no draft",
         x = "Presença",
         y = "Número de observações (campeão × patch)") +
    theme_minimal(base_size = 13)
}




plot_classe_bar <- function(dados) {
  dados %>%
    mutate(relevancia_bin = factor(relevancia_bin, labels = c("Menos Relevante", "Mais Relevante"))) %>%
    ggplot(aes(x = relevancia_bin, fill = relevancia_bin)) +
    geom_bar() +
    geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5) +
    labs(title = "Distribuição da variável resposta", x = "Classe", y = "Número de observações") +
    theme_minimal(base_size = 11) +
    theme(legend.position = "none")
}



plot_presence_scatter_facet <- function(dados, variaveis) {
  dados %>%
    select(presence, position, all_of(variaveis)) %>%
    pivot_longer(-c(presence, position), names_to = "variavel", values_to = "valor") %>%
    ggplot(aes(x = valor, y = presence, color = position)) +
    geom_point(alpha = 0.5, size = 0.8) +
    geom_smooth(method = "lm", se = FALSE, linewidth = 0.6) +
    facet_wrap(~variavel, scales = "free_x") +
    labs(title = "Relação entre presença e variáveis explicativas, por posição",
         x = "Valor da variável", y = "Presença", color = "Posição") +
    theme_minimal(base_size = 11) +
    theme(legend.position = "bottom") +
    guides(color = guide_legend(nrow = 1))
}



## Nova função: presence diretamente por posição
plot_presence_por_posicao <- function(dados) {
  ggplot(dados, aes(x = position, y = presence, fill = position)) +
    geom_boxplot() +
    labs(title = "Distribuição da presença por posição",
         x = "Posição", y = "Presença") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "none")
}



plot_corr_heatmap <- function(dados, variaveis) {
  dados %>%
    select(all_of(variaveis)) %>%
    cor(use = "pairwise.complete.obs") %>%
    as.data.frame() %>%
    rownames_to_column("var1") %>%
    pivot_longer(-var1, names_to = "var2", values_to = "correlacao") %>%
    ggplot(aes(var1, var2, fill = correlacao)) +
    geom_tile() +
    geom_text(aes(label = round(correlacao, 2)), size = 2.5) +
    scale_fill_gradient2(limits = c(-1, 1), low = "#2166AC", mid = "white", high = "#B2182B") +
    labs(title = "Matriz de correlação entre presença e variáveis explicativas", x = NULL, y = NULL, fill = "Correlação") +
    theme_minimal(base_size = 10) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}



plot_evolucao_temporal <- function(dados) {
  dados %>%
    group_by(patch) %>%
    summarise(presenca_media = mean(presence, na.rm = TRUE)) %>%
    ggplot(aes(x = patch, y = presenca_media, group = 1)) +
    geom_line(color = "#2C7FB8") +
    geom_point(color = "#2C7FB8") +
    labs(title = "Evolução da presença média dos campeões por patch", x = "Patch", y = "Presença média") +
    theme_minimal(base_size = 12) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}



plot_boxplot_classe <- function(dados, variaveis) {
  dados %>%
    select(relevancia_bin, all_of(variaveis)) %>%
    mutate(relevancia_bin = factor(relevancia_bin, labels = c("Menos Relevante", "Mais Relevante"))) %>%
    pivot_longer(-relevancia_bin, names_to = "variavel", values_to = "valor") %>%
    ggplot(aes(x = relevancia_bin, y = valor, fill = relevancia_bin)) +
    geom_boxplot() +
    facet_wrap(~variavel, scales = "free_y") +
    labs(title = "Distribuição das variáveis explicativas por classe de relevância", x = "Classe", y = "Valor") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "none")
}



## FUNÇÃO DA VALIDAÇÃO CRUZADA
avaliar_corte_cv <- function(percentil, k = 5, seed = 123) {
  base <- champion_stats %>%
    group_by(patch) %>%
    mutate(corte = quantile(presence, percentil, na.rm = TRUE),
           relevancia_bin = if_else(presence >= corte, 1, 0)) %>%
    ungroup() %>%
    filter(!is.na(avg_kda), !is.na(relevancia_bin)) %>%
    mutate(patch = factor(patch)) %>%
    filter(!patch %in% patches_teste_y)   # nunca toca no teste_y
  
  set.seed(seed)
  dobras <- sample(rep(1:k, length.out = nrow(base)))
  
  aucs <- purrr::map_dbl(1:k, function(i) {
    treino_cv <- base[dobras != i, ]
    valid_cv  <- base[dobras == i, ]
    modelo_cv <- randomForest(update(formula_modelo, factor(relevancia_bin) ~ .),
                              data = treino_cv, ntree = 500)
    prob_cv   <- predict(modelo_cv, newdata = valid_cv, type = "prob")[, "1"]
    as.numeric(pROC::auc(valid_cv$relevancia_bin, prob_cv))
  })
  
  tibble::tibble(percentil = percentil, auc_medio = mean(aucs), auc_dp = sd(aucs))
}


plot_pdp_grid <- function(modelo, dados, variaveis) {
  pdps <- purrr::map_dfr(variaveis, function(v) {
    pd <- pdp::partial(modelo, pred.var = v, train = dados, prob = TRUE, which.class = "1")
    names(pd)[1] <- "valor"
    pd$variavel <- v
    pd
  })
  
  ggplot(pdps, aes(x = valor, y = yhat)) +
    geom_line(color = "#2C7FB8", linewidth = 0.8) +
    facet_wrap(~variavel, scales = "free_x") +
    labs(title = "Dependência parcial das principais variáveis",
         x = "Valor da variável",
         y = "Probabilidade estimada de ser \"Mais Relevante\"") +
    theme_minimal(base_size = 11)
}







## OUTRAS FUNÇÕES QUE SERÃO UTILIZADAS
patches_teste_y <- c("16.06", "16.07", "16.08", "16.09", "16.1", "16.11", "16.12")


formula_modelo <- relevancia_bin ~ winrate + avg_kda + avg_gold + avg_gpm + avg_dpm +
  avg_xp15 + avg_goldat15 + avg_csat15 + avg_cspm +
  avg_firstblood + avg_firstdragon + avg_firsttower + avg_towers +
  avg_void_grubs + avg_barons + avg_infernals + avg_mountains +
  avg_clouds + avg_oceans + avg_chemtechs + avg_hextechs + avg_elders +
  patch


champion_model <- champion_stats %>%
  filter(!is.na(avg_kda), !is.na(relevancia_bin)) %>%
  mutate(patch = factor(patch))



treino_y <- champion_model %>% filter(!patch %in% patches_teste_y)
teste_y  <- champion_model %>% filter(patch %in% patches_teste_y)




set.seed(123)
modelo_rf_y <- randomForest(
  update(formula_modelo, factor(relevancia_bin) ~ .),
  data = treino_y,
  importance = TRUE,
  ntree = 500
)


pred_rf_y <- predict(modelo_rf_y, newdata = teste_y, type = "class") 
#retorna a proporção de arvores que votaram em cada classe
prob_rf_y <- predict(modelo_rf_y, newdata = teste_y, type = "prob")[, "1"] 

#criando vetores (real e previsto)
real_y <- factor(teste_y$relevancia_bin, levels = c(0, 1))
pred_y <- factor(pred_rf_y, levels = c(0, 1))

#Matriz de confusão do conjunto teste
matriz_confusao_y <- table(Predito = pred_y, Real = real_y)




VP_y <- matriz_confusao_y["1", "1"]
FP_y <- matriz_confusao_y["1", "0"]
VN_y <- matriz_confusao_y["0", "0"]
FN_y <- matriz_confusao_y["0", "1"]


acuracia_y       <- (VP_y + VN_y) / sum(matriz_confusao_y)
sensibilidade_y  <- VP_y / (VP_y + FN_y)   
especificidade_y <- VN_y / (VN_y + FP_y)
precisao_y       <- VP_y / (VP_y + FP_y)   
f1_y             <- 2 * (precisao_y * sensibilidade_y) / (precisao_y + sensibilidade_y)