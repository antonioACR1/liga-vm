#SETTING THE ENVIRONMENT
#los nombres de los archivos en excel iniciales son octavos.csv, cuartos.csv, etc. y octavos_partidos.csv,cuartos_partidos.csv, etc.
#los nombres en R que estare usando son octavos_primer_aviso,octavos_segundo_aviso,octavos_definitivo,cuartos_primer_aviso,etc.
#y octavos_partidos_primer_aviso,octavos_partidos_segundo_aviso,octavos_partidos_definitivo,cuartos_partidos_primer_aviso,etc.
library(RODBC) 

connection <- odbcDriverConnect('driver={SQL Server};uid=*****;pwd=*****;server=*****;database=*****;trusted_connection=true')

#el siguiente contiene a los ganadores de la fase correspondiente (o la fase inicial)
df<-read.csv("C:/Users/*****/Documents/octavos.csv",header=TRUE,sep=",")

#el formato del dataframe anterior debe ser como sigue:

##> head(df)
##  Asesor Equipo Id_Tienda Color_Tienda_Ventas   Segmento
##1      1      2       781                 AAA Mini Super
##2      1      2      2374                 AAA Mini Super
##3      1      2      2357                 AAA Mini Super
##4      1      2      2824                 AAA Mini Super



#nombre de la fase en cuestion y el aviso correspondiente
nombre="octavos_definitivo"

#el siguiente code es para insertar el dataframe anterior en SQL

#primero crear la tabla en SQL
sqlQuery(connection,paste0("CREATE TABLE Dunnhumby.dbo.",nombre," (Asesor varchar(255), Equipo int, Id_Tienda int, Color_Tienda_Ventas varchar(255), Segmento varchar(255))"))

#numero de filas en df
n=length(df$Id_Tienda)


#ahora insertarla en SQL
for (i in 1:n){
sqlQuery(connection, paste0("INSERT INTO Dunnhumby.dbo.",nombre," (Asesor, Equipo, Id_Tienda, Color_Tienda_Ventas, Segmento) VALUES ('",df[i,1],"','",df[i,2],"',",df[i,3],",'",df[i,4],"','",df[i,5],"')"))
}

#la tabla en SQL se llama Dunnhumby.dbo.nombre




#PRIMER PERIODO


#fechas de inicio y termino del periodo en cuestion (para medir el crecimiento se necesitan dos periodos)

#fecha de inicio
f1=20170102

#fecha de termino
f2=20170108

#ahora debo elegir una identificacion para las tablas que voy a crear hoy
#las identificaciones son para evitar crear dos tablas con el mismo nombre
identificacion ="_1"

identificacion1= identificacion


#clientes, la tabla se llama Dunnnhumby.dbo.clientes + nombre + identificacion
sqlQuery(connection,paste0("SELECT ID_TIENDA,COALESCE(COUNT(DISTINCT TIKET),0) AS numero_clientes INTO Dunnhumby.dbo.clientes_",nombre,identificacion," FROM FACT_General_Hist WHERE ID_FECHA_VENTA BETWEEN ",f1," AND ",f2," GROUP BY ID_TIENDA"))


#ahora pongo en una sola tabla el Dunnhumby.dbo.nombre junto el KPI utilizando LEFT JOIN 
#la tabla se va a llamr Dunnhumby.dbo.nombre_KPI + identificacion

sqlQuery(connection,paste0("SELECT Dunnhumby.dbo.",nombre,".Asesor,
Dunnhumby.dbo.",nombre,".Equipo,
Dunnhumby.dbo.",nombre,".Id_Tienda,
Dunnhumby.dbo.",nombre,".Color_Tienda_Ventas,
Dunnhumby.dbo.",nombre,".Segmento, 
Dunnhumby.dbo.clientes_",nombre,identificacion,".numero_clientes
INTO Dunnhumby.dbo.",nombre,"_KPI",identificacion," FROM Dunnhumby.dbo.",nombre,"  
LEFT JOIN Dunnhumby.dbo.clientes_",nombre,identificacion," ON Dunnhumby.dbo.",nombre,".Id_Tienda=Dunnhumby.dbo.clientes_",nombre,identificacion,".ID_TIENDA 
ORDER BY Asesor, Equipo, Color_Tienda_Ventas"))


#ahora convierto los valores NULL de la tabla anterior en 0's 

#clientes
sqlQuery(connection,paste0("UPDATE Dunnhumby.dbo.",nombre,"_KPI",identificacion,"  
SET numero_clientes = 0 WHERE numero_clientes IS NULL"))


#tomo la suma del KPI de clientes ordenado por equipo y asesor (con GROUP BY)
#esta tabla contiene la suma de clientes de cada jugador en cada equipo
#la tabla se va a llamar Dunnhumby.dbo.resultados_equipos + nombre + identificacion
sqlQuery(connection,paste0("SELECT Asesor,Equipo, SUM(numero_clientes) AS total_clientes INTO Dunnhumby.dbo.resultados_equipos_",nombre,identificacion," FROM Dunnhumby.dbo.",nombre,"_KPI",identificacion," GROUP BY Equipo, Asesor"))



#para seleccionar clientes desde la tabla Dunnhumby.dbo.resultados_equipos_ + nombre +identificacion

#elijo el kpi (esta parte tiene sentido cuando considero mas KPI's, ahora es redundante pero necesaria)
kpi="total_clientes"



#este es el periodo antiguo
#la tabla se va a llamar Dunnhumby.dbo.equipos_semana1_ + nombre + identificacion

sqlQuery(connection,paste0("SELECT Asesor,Equipo,",kpi," INTO Dunnhumby.dbo.equipos_semana1_",nombre,identificacion,"   
FROM Dunnhumby.dbo.resultados_equipos_",nombre,identificacion))





#SEGUNDO PERIODO

#fechas de inicio y termino del periodo en cuestion (para medir el crecimiento se necesitan dos periodos)

#fecha de inicio
f1=20170109

#fecha de termino
f2=20170115

#ahora debo elegir una identificacion para las tablas que voy a crear hoy
#las identificaciones son para evitar crear dos tablas con el mismo nombre
identificacion ="_2"

identificacion2 = identificacion

#clientes, la tabla se llama Dunnnhumby.dbo.clientes + nombre + identificacion
sqlQuery(connection,paste0("SELECT ID_TIENDA,COALESCE(COUNT(DISTINCT TIKET),0) AS numero_clientes INTO Dunnhumby.dbo.clientes_",nombre,identificacion," FROM FACT_General_Hist WHERE ID_FECHA_VENTA BETWEEN ",f1," AND ",f2," GROUP BY ID_TIENDA"))


#ahora pongo en una sola tabla el Dunnhumby.dbo.nombre junto el KPI utilizando LEFT JOIN 
#la tabla se va a llamr Dunnhumby.dbo.nombre_KPI + identificacion

sqlQuery(connection,paste0("SELECT Dunnhumby.dbo.",nombre,".Asesor,
Dunnhumby.dbo.",nombre,".Equipo,
Dunnhumby.dbo.",nombre,".Id_Tienda,
Dunnhumby.dbo.",nombre,".Color_Tienda_Ventas,
Dunnhumby.dbo.",nombre,".Segmento, 
Dunnhumby.dbo.clientes_",nombre,identificacion,".numero_clientes
INTO Dunnhumby.dbo.",nombre,"_KPI",identificacion," FROM Dunnhumby.dbo.",nombre,"  
LEFT JOIN Dunnhumby.dbo.clientes_",nombre,identificacion," ON Dunnhumby.dbo.",nombre,".Id_Tienda=Dunnhumby.dbo.clientes_",nombre,identificacion,".ID_TIENDA 
ORDER BY Asesor, Equipo, Color_Tienda_Ventas"))


#ahora convierto los valores NULL de la tabla anterior en 0's 

#clientes
sqlQuery(connection,paste0("UPDATE Dunnhumby.dbo.",nombre,"_KPI",identificacion,"  
SET numero_clientes = 0 WHERE numero_clientes IS NULL"))


#tomo la suma del KPI de clientes ordenado por equipo y asesor (con GROUP BY)
#la tabla se va a llamar Dunnhumby.dbo.resultados_equipos + nombre + identificacion
sqlQuery(connection,paste0("SELECT Asesor,Equipo, SUM(numero_clientes) AS total_clientes INTO Dunnhumby.dbo.resultados_equipos_",nombre,identificacion," FROM Dunnhumby.dbo.",nombre,"_KPI",identificacion," GROUP BY Equipo, Asesor"))



#para seleccionar clientes desde la tabla Dunnhumby.dbo.resultados_equipos_ + nombre +identificacion

#elijo el kpi (esta parte tiene sentido cuando considero mas KPI's, ahora es redundante pero necesaria)
kpi="total_clientes"

#este es el periodo nuevo

#semana nueva
sqlQuery(connection,paste0("SELECT Asesor,Equipo,",kpi," INTO Dunnhumby.dbo.equipos_semana2_",nombre,identificacion1,"   
FROM Dunnhumby.dbo.resultados_equipos_",nombre,identificacion2))





#CRECIMIENTO


#para calcular el crecimiento por equipo
#la tabla se va a llamar Dunnhumby.dbo.juntas_ + nombre + identificacion1 

identificacion = identificacion1
sqlQuery(connection,paste0("SELECT A.Asesor, A.Equipo, CASE A.total_clientes WHEN 0 THEN -9999 ELSE CONVERT(DECIMAL(10,5),CONVERT(DECIMAL(10,5),B.total_clientes)/CONVERT(DECIMAL(10,5),A.total_clientes)-1) END AS variation INTO Dunnhumby.dbo.juntas_",nombre,identificacion," FROM Dunnhumby.dbo.equipos_semana1_",nombre,identificacion," A LEFT JOIN Dunnhumby.dbo.equipos_semana2_",nombre,identificacion," B ON A.Asesor=B.Asesor AND A.Equipo=B.Equipo ORDER BY A.Asesor,A.Equipo"))


#la tabla anterior la abro en SQL (y agrego un ORDER BY) 


#ahora para calcular el crecimiento por jugador
#la tabla se llama Dunnhumby.dbo.todas + nombre + identificacion1

sqlQuery(connection,paste0("SELECT A.Asesor, A.Equipo, A.Id_Tienda,A.Color_Tienda_Ventas,A.Segmento, CASE A.numero_clientes WHEN 0 THEN -9999 ELSE CONVERT(DECIMAL(10,5),CONVERT(DECIMAL(10,5),B.numero_clientes)/CONVERT(DECIMAL(10,5),A.numero_clientes)-1) END AS variation INTO Dunnhumby.dbo.todas_",nombre,identificacion1," FROM Dunnhumby.dbo.",nombre,"_KPI",identificacion1," A LEFT JOIN Dunnhumby.dbo.",nombre,"_KPI",identificacion2," B ON A.Asesor=B.Asesor AND A.Equipo=B.Equipo AND A.Id_Tienda=B.Id_Tienda ORDER BY A.Asesor,A.Equipo"))

#la tabla anterior la abro en SQL (y agrego un ORDER BY)





#GANADORES AL MOMENTO


#crear tabla para decidir los ganadores al momento
#la tabla incluye ahora el partido a disputarse. 
nombre1="octavos_partidos_definitivo"
#la tabla se llamara "Dunnhumby.dbo." + nombre1
sqlQuery(connection,paste0("CREATE TABLE Dunnhumby.dbo.",nombre1," (Asesor varchar(255), Partido int, Equipo int)"))
df<-read.csv("C:/Users/Claudia Rodríguez/Documents/octavos_partidos.csv",header=TRUE,sep=",")

#numero de filas en df
n=length(df$equipo)


#ahora insertarla en SQL
#el formato debe ser como
##    asesor partido equipo
##1 Vacante        1     10
##2 Vacante        1     10
##3 Vacante        1     10
##4 Vacante        1     10
##5 Vacante        1     10
##6 Vacante        1     10


for (i in 1:n){
sqlQuery(connection, paste0("INSERT INTO Dunnhumby.dbo.",nombre1," (Asesor, Partido, Equipo) VALUES ('",df[i,1],"',",df[i,2],",",df[i,3],")"))
}

#ahora un join de entre "Dunnhumby.dbo." + nombre1 y "Dunnhumby.dbo.juntas_" + nombre + identificacion1
#la tabla se llamara "dunnhumby.dbo." + nombre1 + "_variation"

sqlQuery(connection,paste0("select b.Asesor,b.Equipo,b.variation,a.partido 
into dunnhumby.dbo.",nombre1,"_variation 
from dunnhumby.dbo.",nombre1," a
inner join dunnhumby.dbo.juntas_",nombre,identificacion1," b
on a.asesor=b.Asesor and a.equipo=b.Equipo"))

#ahora seleccionar a los ganadores por equipo
#la tabla se llama Dunnhumby.dbo.ganadores_ + nombre1 + identificacion1

sqlQuery(connection,paste0("Select A.Asesor,
A.Equipo INTO Dunnhumby.dbo.ganadores_",nombre1,identificacion1,"
FROM Dunnhumby.dbo.",nombre1,"_variation A
inner join 
(SELECT Asesor, 
       Partido, 
	   MAX(variation) AS winner_value 
FROM Dunnhumby.dbo.",nombre1,"_variation 
GROUP BY Asesor, Partido) B
on A.variation = B.winner_value
and A.Asesor = B.Asesor
and A.Partido = B.Partido
order by asesor ,equipo"))

#y a los ganadores incluyendo crecimiento por jugador
#estos no incluyen a los jugadores de equipos que perdieron
#esto sirve para repetir desde el principio para la siguiente fase (cuartos)
#la tabla se llama Dunnhumby.dbo.ganadores_todos_ + nombre1 + identificacion1

sqlQuery(connection,paste0("SELECT A.Asesor, A.Equipo, A.Id_Tienda,A.Color_Tienda_Ventas,A.Segmento 
INTO Dunnhumby.dbo.ganadores_todos_",nombre1,identificacion1," 
FROM Dunnhumby.dbo.todas_",nombre,identificacion1," A INNER JOIN Dunnhumby.dbo.ganadores_",nombre1,identificacion1," B
ON A.Asesor=B.Asesor AND A.Equipo=B.Equipo"))

#guardar los participantes para la siguiente fase en excel
fase<-sqlQuery(connection,paste0("select * from Dunnhumby.dbo.ganadores_todos_",nombre1,identificacion1))

nombre2="octavos_definitivo.csv"
write.csv(x=fase,file=nombre2,row.names=FALSE)

#VISUALIZACION


#para aplicar pivot table


g1<-sqlQuery(connection,paste0("select a.asesor,a.equipo,a.variation as crecimiento,b.partido from
(select * from Dunnhumby.dbo.juntas_",nombre,identificacion1,") a
inner join
(select * from dunnhumby.dbo.",nombre1,") b
on
a.equipo=b.equipo and a.asesor=b.asesor"))

g2<-sqlQuery(connection,paste0("select a.asesor,a.equipo,a.id_tienda,a.variation as crecimiento,b.partido from
(select * from Dunnhumby.dbo.todas_",nombre,identificacion1,") a
inner join
(select * from dunnhumby.dbo.",nombre1,") b
on
a.equipo=b.equipo and a.asesor=b.asesor"))

g1$crecimiento<-mapply(paste0,g1$crecimiento,'%')
g1$equipo<-mapply(paste0,"Equipo ",g1$equipo)
g1$partido<-mapply(paste0,"Partido ",g1$partido)
g1$id_tienda <- ""
g1$tipo <- "Equipo"


g2$crecimiento<-mapply(paste0,g2$crecimiento,'%')
g2$equipo<-mapply(paste0,"Equipo ",g2$equipo)
g2$partido<-mapply(paste0,"Partido ",g2$partido)
g2$tipo <- "Jugador"

j<-rbind(g1,g2)

write.csv(x=j,file="j.csv",row.names=FALSE)





