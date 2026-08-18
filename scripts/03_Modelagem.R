#############################
#         MODELAGEM
#############################

install.packages("randomForest")
install.packages("pROC")
install.packages("rpart.plot")


library(tidyverse)
library(randomForest)
library(pROC)
library(rpart)
library(rpart.plot)

## ---- 1. Base final pro modelo ----
#Antes de tudo, filtraremos as linhas sem dados
champion_stats <- read_csv("dados/processed/champion_stats.csv")
champion_model <- champion_stats %>%
  filter(!is.na(avg_kda), !is.na(relevancia_bin)) %>%
  mutate(patch = factor(patch))


#Para a separação entre teste e treino, deixaremos o conjunto de teste como o último patch como volume de dados comparável ao resto da temporada

#OBS PARA RELATÓRIO: O padrão é exatamente o mesmo que a gente já tinha visto acontecer no fim de 2025 — aqui se repete: 16.10 ainda tem volume robusto (727 jogos, na mesma faixa dos patches "grandes" do ano), 16.11 já cai pela metade (383), e 16.12 desaba pra só 27 jogos com pouco mais de 100 campeões registrados — quase certamente o patch "trancado" de fim de temporada (Mundial ou torneio de encerramento), do mesmo jeito que 15.21-15.24 eram.

## ---- 2. Split treino/teste ----
patches_teste_x <- c("16.1")
treino_x <- champion_model %>% filter(!patch %in% patches_teste_x)
teste_x  <- champion_model %>% filter(patch %in% patches_teste_x)

nrow(treino_x); nrow(teste_x)   # confere: deve bater ~4705 / ~160

## ---- 3. Fórmula única, reaproveitada nos dois modelos ----
formula_modelo <- relevancia_bin ~ winrate + avg_kda + avg_gold + avg_gpm + avg_dpm +
  avg_xp15 + avg_goldat15 + avg_csat15 + avg_cspm +
  avg_firstblood + avg_firstdragon + avg_firsttower + avg_towers +
  avg_void_grubs + avg_barons + avg_infernals + avg_mountains +
  avg_clouds + avg_oceans + avg_chemtechs + avg_hextechs + avg_elders +
  patch

## ---- 4. Random Forest ----
set.seed(123)
modelo_rf_x <- randomForest(
  update(formula_modelo, factor(relevancia_bin) ~ .),
  data = treino_x,
  importance = TRUE,
  ntree = 500
)

print(modelo_rf_x)
importance(modelo_rf_x, type = 1)

## ---- 5. Rodando modelo no teste (nunca visto pelo modelo) ---

#aplica o modelo no conjunto teste
pred_rf_x <- predict(modelo_rf_x, newdata = teste_x, type = "class") 

#retorna a proporção de arvores que votaram em cada classe
prob_rf_x <- predict(modelo_rf_x, newdata = teste_x, type = "prob")[, "1"] 

#criando vetores (real e previsto)
real_x <- factor(teste_x$relevancia_bin, levels = c(0, 1))
pred_x <- factor(pred_rf_x, levels = c(0, 1))

#Matriz de confusão do conjunto teste
matriz_confusao_x <- table(Predito = pred_x, Real = real_x)
matriz_confusao_x


## ---- 6. Avaliando modelo ----
VP_x <- matriz_confusao_x["1", "1"]
FP_x <- matriz_confusao_x["1", "0"]
VN_x <- matriz_confusao_x["0", "0"]
FN_x <- matriz_confusao_x["0", "1"]

acuracia_x       <- (VP_x + VN_x) / sum(matriz_confusao_x)
sensibilidade_x  <- VP_x / (VP_x + FN_x)   # dos "Mais Relevante" reais, quantos o modelo capturou
especificidade_x <- VN_x / (VN_x + FP_x)   # dos "Menos Relevante" reais, quantos o modelo acertou
precisao_x       <- VP_x / (VP_x + FP_x)   # dos que o modelo chamou de "Mais Relevante", quantos de fato eram
f1_x             <- 2 * (precisao_x * sensibilidade_x) / (precisao_x + sensibilidade_x)

tibble::tibble(acuracia_x, sensibilidade_x, especificidade_x, precisao_x, f1_x)

#OBS: Tamanho de amostra pequeno. São só 40 casos positivos no teste. Acertar todos os 40 por acaso não é tão improvável quanto parece — com uma taxa "real" de acerto de, digamos, 90%, a chance de acertar os 40 de uma vez ainda seria razoável. Um único falso negativo a mais já derrubaria a sensibilidade de 100% pra 97,5%. Números com base tão pequena têm intervalo de confiança largo — vale reportar isso com cautela, não como "o modelo é perfeito em recall".

## ---- 6.1 CURVA ROC E AUC ----
roc_rf_x <- roc(response = teste_x$relevancia_bin, predictor = prob_rf_x)
auc(roc_rf_x)

plot(roc_rf_x,
     main = "Curva ROC — Random Forest (conjunto de teste)",
     xlab = "1 - Especificidade", ylab = "Sensibilidade")








#-----------------------------------
#ALTERANDO A DIVISAO TREINO/TESTE
#-----------------------------------

#Como visto, devido a amostra pequena de teste, obtemos uma sensibilidade perfeita ao custo da precisão baixa. Por isso, rodaremos o modelo novamente, mas alterando a divisão entre conjunto e teste

#Nesta divisão, deixaremos os patches de 15.01 - 16.05 para o treino e 16.01 - 16.12 para teste, seguindo uma divisão de 80-20

patches_teste_y <- c(
  "16.06", "16.07", "16.08",
  "16.09", "16.1", "16.11", "16.12"
)

treino_y <- champion_model %>% filter(!patch %in% patches_teste_y)
teste_y  <- champion_model %>% filter(patch %in% patches_teste_y)

nrow(treino_y); nrow(teste_y)

## ---- 7. Modelo com nova divisão ----
set.seed(123)
modelo_rf_y <- randomForest(
  update(formula_modelo, factor(relevancia_bin) ~ .),
  data = treino_y,
  importance = TRUE,
  ntree = 500
)

print(modelo_rf_y)
importance(modelo_rf_y, type = 1)

## ---- 8. Testando no conjunto de teste ---- 
#aplica o modelo no conjunto teste
pred_rf_y <- predict(modelo_rf_y, newdata = teste_y, type = "class") 

#retorna a proporção de arvores que votaram em cada classe
prob_rf_y <- predict(modelo_rf_y, newdata = teste_y, type = "prob")[, "1"] 

#criando vetores (real e previsto)
real_y <- factor(teste_y$relevancia_bin, levels = c(0, 1))
pred_y <- factor(pred_rf_y, levels = c(0, 1))

#Matriz de confusão do conjunto teste
matriz_confusao_y <- table(Predito = pred_y, Real = real_y)
matriz_confusao_y

## ---- 9. Avaliando modelo (80-20) ----
VP_y <- matriz_confusao_y["1", "1"]
FP_y <- matriz_confusao_y["1", "0"]
VN_y <- matriz_confusao_y["0", "0"]
FN_y <- matriz_confusao_y["0", "1"]

acuracia_y       <- (VP_y + VN_y) / sum(matriz_confusao_y)
sensibilidade_y  <- VP_y / (VP_y + FN_y)   
especificidade_y <- VN_y / (VN_y + FP_y)
precisao_y       <- VP_y / (VP_y + FP_y)   
f1_y             <- 2 * (precisao_y * sensibilidade_y) / (precisao_y + sensibilidade_y)

tibble::tibble(acuracia_y, sensibilidade_y, especificidade_y, precisao_y, f1_y)


## ---- 9.1 Curva ROC e AUC (80-20) ----
roc_rf_y <- roc(response = teste_y$relevancia_bin, predictor = prob_rf_y)
auc(roc_rf_y)

plot(roc_rf_y,
     main = "Curva ROC — Random Forest (conjunto de teste)",
     xlab = "1 - Especificidade", ylab = "Sensibilidade")






#########################################
# VALIDAÇÃO CRUZADA (PERCENTIS 75/80/85)
#########################################

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

set.seed(123)
resultados_percentil <- purrr::map_dfr(c(0.75, 0.80, 0.85), avaliar_corte_cv)
resultados_percentil
