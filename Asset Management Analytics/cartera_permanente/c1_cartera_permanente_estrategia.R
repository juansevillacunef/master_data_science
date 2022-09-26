
#path <- "~/"

# ETFS <- read.xlsx(file.path(path,"ETFS.xlsx"),sheetName = "series")

# Librerias
library(quantmod)
library(lubridate)
library(dplyr)
library(ggplot2)
library(reshape)
library(grid)

# Obtención de los instrumentos

stocks<- c("VTI","TLT","BIL","GLD","SPY")# Se coge el SPY como benchamark

#VTI: Large-, mid-, and small-cap equity diversified across growth and value styles.
#TLT: Bonos USA a Largo plazo
#GLD: Oro
#BIL: Renta fija USA a corto plazo (efectivo)

# Selección del marco temporal
date_begin <- as.Date("2007-06-29")
#date_begin <- as.Date("2007-06-01")
date_end <- as.Date("2022-08-04")

# Obtención de los datos de los stocks
tickers <- getSymbols(stocks, from=date_begin, to=date_end, auto.assign=TRUE)

# Combinar los valores ajustados al cierre en una sola tabla con datos diarios
  #Primero se crea una tabla cpn el primer activo
    ETFS <- Cl(to.daily(Ad(get(tickers[1]))))
  # Se unen el resto de activos
    for (i in 2:length(tickers)) { ETFS <- merge(ETFS, Cl(to.daily(Ad(get(tickers[i]))))) }

# Se le da nombre a las variables
colnames(ETFS) <- stocks


# Se pasa a Data frame y se crea la variable fecha (hasta ahora estaba en el nombre de las filas)
ETFS=as.data.frame(ETFS)
ETFS$Date <- rownames(ETFS)
# Se eliminan valores missing (si en algun dia algun activo
#los tuviera provocaría fallos posteriores en los cálculos)
ETFS <- na.omit(ETFS)


#Creación de una variable fecha que contenga año y mes
library(lubridate)
ETFS$Date <- ymd(ETFS$Date)
ETFS$Date_aux <- format(ETFS$Date,"%Y-%m")

# Filtro para quedarnos con datos mensuales
ETFS=ETFS[order(ETFS$Date,decreasing = TRUE ),]
ETFS=ETFS[!duplicated(ETFS$Date_aux),]
#(al ordenar en orden decreciente la primera fecha que aparece es la última de cada mes.
# De esta forma nos quitamos todos los registros del mes que no correspondan al último dia)

# CALCULO DE LA EVOLUCION DE LA CARTERA

# Con la función arrange de dplyr volvemos a ordenar para que empiece en el mes mas antiguo
library(dplyr)
tabla <- ETFS %>% arrange(Date_aux)

#Activos y ponderaciones
# Los activos que conforman la cartera permanente estan equiponderados al 25%
#Se crea una variable para cada activo con la evolución de precios correspondiente
Activo1=tabla$VTI
Activo2=tabla$TLT
Activo3=tabla$BIL
Activo4=tabla$GLD
Activo5=tabla$SPY

Pondactivo1=25
Pondactivo2=25
Pondactivo3=25
Pondactivo4=25
Pondactivo5=0


# cantidades (num titulos) de partida buy&hold
# 100 eur de partida se reparten en:
# (Denominador: precio del Activo 1 en el primer instante de tiempo)
Cantini_Activo1=Pondactivo1/Activo1[1]
Cantini_Activo2=Pondactivo2/Activo2[1]
Cantini_Activo3=Pondactivo3/Activo3[1]
Cantini_Activo4=Pondactivo4/Activo4[1]
Cantini_Activo5=Pondactivo5/Activo5[1]

# cantidades (eur) buy&hold (Precio por cantidades iniciales (titulos) adquiridos)
 #()
tabla$carteraevol_sinreb_Activo1=Activo1*Cantini_Activo1
tabla$carteraevol_sinreb_Activo2=Activo2*Cantini_Activo2
tabla$carteraevol_sinreb_Activo3=Activo3*Cantini_Activo3
tabla$carteraevol_sinreb_Activo4=Activo4*Cantini_Activo4
tabla$carteraevol_sinreb_Activo5=Activo5*Cantini_Activo5

#valoración de la cartera en cada instante de tiempo: suma de todas las valoraciones de los activos en cada instante
tabla$carteraevol_sinreb=tabla$carteraevol_sinreb_Activo1+
                         tabla$carteraevol_sinreb_Activo2+
                         tabla$carteraevol_sinreb_Activo3+
                         tabla$carteraevol_sinreb_Activo4+
                         tabla$carteraevol_sinreb_Activo5

#ponderaciones que van teniendo los activos en cada instante de tiempo 
#en función de la evolución de sus respectivos precios: 
#valor de la inversión en cada activo entre el valor total de la cartera

tabla$pond_sinreb_Activo1=tabla$carteraevol_sinreb_Activo1/tabla$carteraevol_sinreb
tabla$pond_sinreb_Activo2=tabla$carteraevol_sinreb_Activo2/tabla$carteraevol_sinreb
tabla$pond_sinreb_Activo3=tabla$carteraevol_sinreb_Activo3/tabla$carteraevol_sinreb
tabla$pond_sinreb_Activo4=tabla$carteraevol_sinreb_Activo4/tabla$carteraevol_sinreb
tabla$pond_sinreb_Activo5=tabla$carteraevol_sinreb_Activo5/tabla$carteraevol_sinreb

# Se crea la variable mes (variable auxiliar) para poder hacer los rebalanceos
tabla$month=month(tabla$Date)

#Rebalanceo. se rebalancea en los meses de diciembre
for (i in 1:nrow(tabla)) {
  #for (i in 1:6) {
  #i=7
  
  #bucle para la  primera observacion (no es mes de Diciembre y es la primera observación)
  if (tabla$month[i]!=12 & i==1){
    #Cantidad inicial a invertir en cada activo: 25eur/precio activo en instante 1
    tabla$Cantreb_Activo1[i]=Pondactivo1/Activo1[i]
    tabla$Cantreb_Activo2[i]=Pondactivo2/Activo2[i]
    tabla$Cantreb_Activo3[i]=Pondactivo3/Activo3[i]
    tabla$Cantreb_Activo4[i]=Pondactivo4/Activo4[i]
    tabla$Cantreb_Activo5[i]=Pondactivo5/Activo5[i]
    # Cantidad total invertida en el activo en el instante 1
    tabla$carteraevol_conreb_Activo1[i]=tabla$Cantreb_Activo1[i]*Activo1[i]
    tabla$carteraevol_conreb_Activo2[i]=tabla$Cantreb_Activo2[i]*Activo2[i]
    tabla$carteraevol_conreb_Activo3[i]=tabla$Cantreb_Activo3[i]*Activo3[i]
    tabla$carteraevol_conreb_Activo4[i]=tabla$Cantreb_Activo4[i]*Activo4[i]
    tabla$carteraevol_conreb_Activo5[i]=tabla$Cantreb_Activo5[i]*Activo5[i]
    
    # Cantidad total invertida en la cartera en el instante 1
    tabla$carteraevol_conreb[i]=tabla$carteraevol_conreb_Activo1[i]+
                                tabla$carteraevol_conreb_Activo2[i]+
                                tabla$carteraevol_conreb_Activo3[i]+
                                tabla$carteraevol_conreb_Activo4[i]+
                                tabla$carteraevol_conreb_Activo5[i]
    
    
  }
  
  #bucle para el primer año excluyendo diciembre. el primer mes de diciembre es el paso 7 del bucle
  if (tabla$month[i]!=12 & i<7){
    # Aqui ya no es necesario calcular la cantidad de titulos de partida, solamente la evolución
    #de la cartera en cada activo y la total que es la suma de las individuales
    #tabla$aux[i]=0
    
    tabla$carteraevol_conreb_Activo1[i]=tabla$Cantreb_Activo1[i]*Activo1[i]
    tabla$carteraevol_conreb_Activo2[i]=tabla$Cantreb_Activo2[i]*Activo2[i]
    tabla$carteraevol_conreb_Activo3[i]=tabla$Cantreb_Activo3[i]*Activo3[i]
    tabla$carteraevol_conreb_Activo4[i]=tabla$Cantreb_Activo4[i]*Activo4[i]
    tabla$carteraevol_conreb_Activo5[i]=tabla$Cantreb_Activo5[i]*Activo5[i]
    
    
    
    tabla$carteraevol_conreb[i]=tabla$carteraevol_conreb_Activo1[i]+
                                tabla$carteraevol_conreb_Activo2[i]+
                                tabla$carteraevol_conreb_Activo3[i]+
                                tabla$carteraevol_conreb_Activo4[i]+
                                tabla$carteraevol_conreb_Activo5[i]
    
  }
  
  # bucle para los diciembres
  else if (i>=7 & tabla$month[i]==12) {
    
    #Por aqui entra el 7
    
    #tabla$aux[i]=1
    # Primero calculamos el valor de la cartera antes del rebalanceo
    Cartera_antesreb=(tabla$Cantreb_Activo1[i]*Activo1[i])+
                     (tabla$Cantreb_Activo2[i]*Activo2[i])+
                     (tabla$Cantreb_Activo3[i]*Activo3[i])+
                     (tabla$Cantreb_Activo4[i]*Activo4[i])+
                     (tabla$Cantreb_Activo5[i]*Activo5[i])
    
    # Calculo de la Cantidad de titulos necesaria en cada activo para reequilibrar la cartera
    tabla$Cantreb_Activo1=(Cartera_antesreb*(Pondactivo1/100))/Activo1[i]

    tabla$Cantreb_Activo2=(Cartera_antesreb*(Pondactivo2/100))/Activo2[i]
    tabla$Cantreb_Activo3=(Cartera_antesreb*(Pondactivo3/100))/Activo3[i]
    tabla$Cantreb_Activo4=(Cartera_antesreb*(Pondactivo4/100))/Activo4[i]
    tabla$Cantreb_Activo5=(Cartera_antesreb*(Pondactivo5/100))/Activo5[i]
    # Numerador: Cantidad en eur que hay que destinar al activo 1 para que vuelva a pesar un 25% en la cartera
    # Denominador: precio del activo en el instante que estamos evaluando
    
    # valoración de la cartera en cada instante de acuerdo con el reequilibrio que se ha llevado a cabo
    # (número de titulos por su precio)
        # primero de cada activo
    tabla$carteraevol_conreb_Activo1[i]=tabla$Cantreb_Activo1[i]*Activo1[i]
    tabla$carteraevol_conreb_Activo2[i]=tabla$Cantreb_Activo2[i]*Activo2[i]
    tabla$carteraevol_conreb_Activo3[i]=tabla$Cantreb_Activo3[i]*Activo3[i]
    tabla$carteraevol_conreb_Activo4[i]=tabla$Cantreb_Activo4[i]*Activo4[i]
    tabla$carteraevol_conreb_Activo5[i]=tabla$Cantreb_Activo5[i]*Activo5[i]
    
        # después de toda la cartera
    tabla$carteraevol_conreb[i]=tabla$carteraevol_conreb_Activo1[i]+
                                tabla$carteraevol_conreb_Activo2[i]+
                                tabla$carteraevol_conreb_Activo3[i]+
                                tabla$carteraevol_conreb_Activo4[i]+
                                tabla$carteraevol_conreb_Activo5[i]
    
    
  }#cierre del Else
  
  
  # bucle para el resto de meses que no son dicembre y que no estan en el primer año
  else if (i>=7 & tabla$month[i]!=12){
    # En este bucle como no son meses de Diciembre, simplemente se hace la valoración de cada activo y del total 
    # de la cartera
    
    tabla$carteraevol_conreb_Activo1[i]=tabla$Cantreb_Activo1[i]*Activo1[i]
    tabla$carteraevol_conreb_Activo2[i]=tabla$Cantreb_Activo2[i]*Activo2[i]
    tabla$carteraevol_conreb_Activo3[i]=tabla$Cantreb_Activo3[i]*Activo3[i]
    tabla$carteraevol_conreb_Activo4[i]=tabla$Cantreb_Activo4[i]*Activo4[i]
    tabla$carteraevol_conreb_Activo5[i]=tabla$Cantreb_Activo5[i]*Activo5[i]
    
    
    tabla$carteraevol_conreb[i]=tabla$carteraevol_conreb_Activo1[i]+
                                tabla$carteraevol_conreb_Activo2[i]+
                                tabla$carteraevol_conreb_Activo3[i]+
                                tabla$carteraevol_conreb_Activo4[i]+
                                tabla$carteraevol_conreb_Activo5[i]
    
  }#cierre del Else
  
}#cierre del For



# Gráfico con las series

library(ggplot2)
library(reshape)
library(grid)

# Se seleccionan las series necesarias para hacer el gráfico
tabla_plot=select(tabla,Date,carteraevol_sinreb,carteraevol_conreb)
tabla_plot <- melt(tabla_plot, c(1))



ggplot(tabla_plot, aes(x = Date, y = value)) +
  geom_line(aes(color = variable), size = 0.5) +
  scale_color_manual(values=c("#0000B8", "#BF0000"))+
  theme(legend.position = "bottom")+
  
 theme(panel.background = element_rect(fill = "transparent"))+

scale_y_continuous(breaks = seq(0, 300, len = 4))




####################################
library(dplyr)


tabla_plot[grepl("*-12-31", tabla_plot$Date), "anio"] <- as.character(tabla_plot[grepl("*-12-31", tabla_plot$Date),]$Date)
tabla_plot[grepl("*-12-29", tabla_plot$Date), "anio"] <- as.character(tabla_plot[grepl("*-12-29", tabla_plot$Date),]$Date)
tabla_plot[grepl("*-12-30", tabla_plot$Date), "anio"] <- as.character(tabla_plot[grepl("*-12-30", tabla_plot$Date),]$Date)
tabla_plot[grepl("2022-08-03", tabla_plot$Date), "anio"] <- as.character(tabla_plot[grepl("2022-08-03", tabla_plot$Date),]$Date)

#####################################
set.seed(123)
ggplot(tabla_plot, aes(x = Date, y = value)) +
  ggtitle("Cartera_equiponderada") +
  geom_line(aes(color = variable), size = 0.5) +
  scale_color_manual(values=c("#0000B8", "#BF0000"))+
  theme(legend.position = "bottom")+
  
  theme(panel.background = element_rect(fill = "transparent"))+
  scale_x_date(breaks= as.Date(tabla_plot$anio),date_labels="%Y-%m")+
  scale_y_continuous(breaks = seq(0, 400, by=50))+
 geom_label(data=tabla_plot[c(366,183), ], aes(label=round(value,2)),position=position_jitter(width=30,height=50))


