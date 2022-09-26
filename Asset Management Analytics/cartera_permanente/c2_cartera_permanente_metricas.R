

options(scipen = 999)
library(dplyr)
#metricas= select(tabla_60_40,Date,VTI,TLT,IEI,GLD,GSG,carteraevol_conreb)

metricas= select(tabla,Date,carteraevol_conreb)

metricas=metricas[order(metricas$Date,decreasing = TRUE ),]

metricas$year=year(metricas$Date)


# Adelantos
metricas$cartera_LEAD1m=lead(metricas$carteraevol_conreb,n=1)
metricas$cartera_LEAD3m=lead(metricas$carteraevol_conreb,n=3)
metricas$cartera_LEAD6m=lead(metricas$carteraevol_conreb,n=6)
metricas$cartera_LEAD1y=lead(metricas$carteraevol_conreb,n=12)
metricas$cartera_LEAD3y=lead(metricas$carteraevol_conreb,n=48)
metricas$cartera_LEAD5y=lead(metricas$carteraevol_conreb,n=60)
metricas$cartera_LEAD10y=lead(metricas$carteraevol_conreb,n=120)
metricas$cartera_LEADmax=lead(metricas$carteraevol_conreb,n=182)#poner num de ultima fila menos uno del fichero de metricas


# Rentabilidad total para los distintos periodos

metricas$rent_1M=(metricas$carteraevol_conreb-metricas$cartera_LEAD1m)/metricas$cartera_LEAD1m
metricas$rent_3M=(metricas$carteraevol_conreb-metricas$cartera_LEAD3m)/metricas$cartera_LEAD3m
metricas$rent_6M=(metricas$carteraevol_conreb-metricas$cartera_LEAD6m)/metricas$cartera_LEAD6m

metricas$rent_1y=(metricas$carteraevol_conreb-metricas$cartera_LEAD1y)/metricas$cartera_LEAD1y
metricas$rent_3y=(metricas$carteraevol_conreb-metricas$cartera_LEAD3y)/metricas$cartera_LEAD3y
metricas$rent_5y=(metricas$carteraevol_conreb-metricas$cartera_LEAD5y)/metricas$cartera_LEAD5y
metricas$rent_10y=(metricas$carteraevol_conreb-metricas$cartera_LEAD10y)/metricas$cartera_LEAD10y
metricas$rent_max=(metricas$carteraevol_conreb-metricas$cartera_LEADmax)/metricas$cartera_LEADmax


#CALCULO DE LAS RENTABILIDADES MENSUALES
    var_rent1m=grep("Date|year|rent_1M",names(metricas),value=TRUE)
    #vars <-c(  "Date","rent_1M")
    
    
    #aux1 <- metricas[,(names(metricas) %in% c(var_rent1m))]
    aux1= metricas[,c("Date","year","rent_1M")]
    
    vector_meses= c("DIC","NOV","OCT","SEP","AGO","JUL","JUN","MAY","ABR","MAR","FEB","ENE")
    vector_fechas= c("2007","2008","2009","2010","2011",
                     "2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022")
    
    for (i in 1:length(vector_fechas)) {
      
      #i=1
      #nombre=paste("aux2_",vector_fechas[i]) 
      #Cogemos el vector de rentabilidades mensuales correspondientes a todos los meses del año del bucle
      aux2=aux1[aux1$year==vector_fechas[i],]
      aux2$Date=NULL
      #aux1$year=NULL
      #Renombramos la variable de rentabilidad mensual al nombre correspondiente al año del bucle
      names(aux2)[names(aux2)=="rent_1M"]=vector_fechas[i]
      #Transponemos la tabla
      tab <- t(aux2[,2:2])
      # Al nombre de la fila le ponemos el año correspondiente al paso del bucle 
      rownames(tab) <- aux2$year[1]
      # Transformamos la tabla a data.frame
      tab=as.data.frame(tab)
      
      #El año 2007 con nuestros datos no tiene una extensión de 12, solo de 7:
      if (i == 1){
        #i=2
        colnames(tab) <- vector_meses[1:7]
        tab_f <- tab
        
      }
      
      else if (i < length(vector_fechas) ) {
        # A las columnas del vector le damos el nombre del mes correspondiente
        colnames(tab) <- vector_meses[1:12]
        # La tabla generada para 2007 tenia una extensión de 7. Ampliamos su extensión para que tenga los primeros
        #seis meses del año como columnas y asi normalizamos la extensión para el resto de años excepto el ultimo
        
        tab_f[setdiff(names(tab),names(tab_f))]<- NA
        #Fusión entre la tabla acumulada (con 2007) y la del nuevo año
        tab_f <- rbind(tab_f,tab)
      }#cierre del Else
      # Bucle para el último año
      else if (i == length(vector_fechas)){
        # A las columnas del vector le damos el nombre del mes correspondiente para aquellos meses que tenemos de 2022
        colnames(tab) <- vector_meses[5:12]
        # Misma sentencia que en el bucle anterior pero al revés: con los meses que nos faltan los meses de septiembre en adelante
        tab[setdiff(names(tab_f),names(tab))]<- NA
        #Fusión entre la tabla acumulada con todos los años y la del nuevo año
        tab_f <- rbind(tab_f,tab)
      }#cierre del Else
      
      rm(tab)
      
    }




# tab_f$year=vector_fechas
# tab_f$year=NULL


#Cálculos
    # Rentabilidad máxima, mínima y promedio de todos los Eneros, Febreros, etc
    max=as.data.frame(apply(tab_f, 2, max, na.rm = TRUE))
    max <- t(max[,1:1])
    colnames(max) <- vector_meses
    #rownames(max) <- "Máximo"
    
    
    prom=as.data.frame(apply(tab_f, 2, mean, na.rm = TRUE))
    prom <- t(prom[,1:1])
    colnames(prom) <- vector_meses
    #rownames(prom) <- "Promedio"
    
    min=as.data.frame(apply(tab_f, 2, min, na.rm = TRUE))
    min <- t(min[,1:1])
    colnames(min) <- vector_meses
    #rownames(min) <- "Mínimo"
    
    calculos=rbind(min,prom,max)


#tabla_rentmens=rbind(tab_f,calculos)
#Fusión de la tabla con las rentabilidades mensuales con la de los cálculos
  tabla_rentmens=rbind(calculos,tab_f)

# Creamos vector de metricas para ubicarlas en la tabla
vector_metricas= c("Minimo","Promedio","Maximo")

#vector_conjunto= c (vector_fechas,vector_metricas)
#Fusion de los vectores de etiquetas de metricas y de fechas
vector_conjunto= c (vector_metricas,vector_fechas)
tabla_rentmens$year=vector_conjunto


# Salida1
S1_rentmens=tabla_rentmens[nrow(tabla_rentmens):1, c(13, 12:1)]

#-----------------------------------

# RENTABILIDADES ANUALES
# Creamos variable que indica numero de mes
metricas$month=month(metricas$Date)

# Con la variable creada previamente nos creamos una tabla con los finales de año
# excepto el último mes para 2022 que no es Diciembre sino Agosto
Tabla_rentan_aux1=metricas[metricas$month=="12" | metricas$Date=="2022-08-03", ] 
# Nos quedamos con las variables de interés
var_rent_an=grep("Date|year|rent",names(Tabla_rentan_aux1),value=TRUE)
#Salida2

S2_rentanuales <- Tabla_rentan_aux1[,(names(Tabla_rentan_aux1) %in% c(var_rent_an))]

#----------------------------------
# RENTABILIDADES ANUALIZADAS

Tabla_rentan_aux2=metricas[metricas$Date=="2022-08-03", ] 
# Nos quedamos con los valores de la cartera a diferentes horizontes temporales. Eliminamos
# las variables de rentabilidad (ahora no nos sirven)
var_rent_an2=grep("rent|month",names(Tabla_rentan_aux2),value=TRUE,invert=TRUE)
Tabla_rentan_aux2 <- Tabla_rentan_aux2[,(names(Tabla_rentan_aux2) %in% c(var_rent_an2))]

# Calculamos las rentabilidades anualizadas aplicando la fórmula
    # Para la rentabilidad anualizada máxima sabemos que el punto de partida coincide con el origen de
    # la inversión cuyo valor es de 100
    rent_an_max=(Tabla_rentan_aux2$carteraevol_conreb[1]/100)^(1/16)-1
    # En el resto de rentabilidades anualizadas medimos contra el valor de la cartera en el momento 
    # correspondiente: 10 años, 5 años o tres años
    rent_an_10y=(Tabla_rentan_aux2$carteraevol_conreb[1]/Tabla_rentan_aux2$cartera_LEAD10y[1])^(1/10)-1
    rent_an_5y=(Tabla_rentan_aux2$carteraevol_conreb[1]/Tabla_rentan_aux2$cartera_LEAD5y[1])^(1/5)-1
    rent_an_3y=(Tabla_rentan_aux2$carteraevol_conreb[1]/Tabla_rentan_aux2$cartera_LEAD3y[1])^(1/3)-1

# Ponemos en un vector los valores obtenidos previamente
vector_rent_anualizadas=c(rent_an_max,rent_an_10y,rent_an_5y,rent_an_3y)
# les ponemos los nombres correspondientes
vector_rent_anualizadas_etiq=c("rent_an_max","rent_an_10y","rent_an_5y","rent_an_3y")

rent_anualizadas=as.data.frame(vector_rent_anualizadas)
# Transponemos el vector
Tabla_rentanualizadas <- t(rent_anualizadas[,1:1])
#Salida3
colnames(Tabla_rentanualizadas) <- vector_rent_anualizadas_etiq[1:4]
S3_rentanualizadas=Tabla_rentanualizadas

#------------------------
#Salida4. CALCULO DE LA VOLATILIDAD Y SHARPE
# Nos quedamos con las variables que necesitamos
vol_sharpe=as.data.frame(S2_rentanuales[,c("rent_1y")])

# Calculamos el promedio de rentabilidad (el dos de la formula indica que la funcion
#hay que aplicarla por filas, el na.rm que no tenga en cuenta valores missings y asi pueda funcionar
#la fórmula)
prom_rent=as.data.frame(apply(vol_sharpe, 2, mean, na.rm = TRUE))
# calculo de la volatilidad: desviacion estandar de las rentabilidades anuales
vol=as.data.frame(apply(vol_sharpe, 2, sd, na.rm = TRUE))
# El sharpe es el cociente entre las dos metricas anteriores
sharpe=prom_rent/vol

vector_metricas=as.data.frame(c(prom_rent,vol,sharpe))

nombres= c("rentab","volatilidad","sharpe")
colnames(vector_metricas) = nombres
S4_rent_vol_sharpe=vector_metricas

rm(aux1,aux2,calculos,
   max,min,prom,prom_rent,rent_anualizadas,sharpe,tab_f,
   tabla_plot,Tabla_rentan_aux1,Tabla_rentan_aux2,Tabla_rentanualizadas,
   tabla_rentmens,
   vol,vol_sharpe,vector_metricas)



rm(BIL,ETFS,GLD,SPY,TLT,VTI)

write.csv2(S1_rentmens,"/cloud/project/2022-2023/modulo3/cartera_permanente/S1_rentmens.csv")
write.csv2(S2_rentanuales,"/cloud/project/2022-2023/modulo3/cartera_permanente/S2_rentanuales.csv")
write.csv2(S3_rentanualizadas,"/cloud/project/2022-2023/modulo3/cartera_permanente/S3_rentanualizadas.csv")
write.csv2(S4_rent_vol_sharpe,"/cloud/project/2022-2023/modulo3/cartera_permanente/S4_rent_vol_sharpe.csv")

write.csv2(tabla,"/cloud/project/2022-2023/modulo3/cartera_permanente/tabla_estrategia.csv")
