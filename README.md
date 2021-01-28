# dataframe_covid
crea un subconjunto de datos que agregue a los datos abiertos del COVID-19 de la secretaria de salud, datos adicionales

## ObtIDH
Esta función retorna un DataFrame de el Indice de desarrollo humano y sus componentes desagregadospor municipio :
julia> ObtIDH()
2456×10 DataFrame
  Row │ ENTIDAD_RES  MUNICIPIO_RES  AME      AEE      IPCA     TMI      IE        II        IS        VIDH     
      │ Any          Any            Any      Any      Any      Any      Any       Any       Any       Any      
──────┼────────────────────────────────────────────────────────────────────────────────────────────────────────
    1 │ 1            1              9.55307  12.8703  17848.3  10.2962  0.738336  0.742537  0.897369  0.789432
    2 │ 1            2              6.22975  11.1364  6877.03  13.2106  0.554621  0.605943  0.861315  0.6615
    3 │ 1            3              5.95726  10.8926  8764.94  12.2292  0.536386  0.640685  0.873456  0.669557
  ⋮   │      ⋮             ⋮           ⋮        ⋮        ⋮        ⋮        ⋮         ⋮         ⋮         ⋮
 2455 │ 32           57             6.24331  10.8909  7555.7   10.1997  0.54907   0.619422  0.898563  0.673578
 2456 │ 32           58             5.86283  12.143   8092.09  14.4484  0.561832  0.629245  0.846003  0.668754

Tiene 3 parametros opcionales:

clave_e:Toma como entrada un vetor Int con las clave de los estados
clave_m:Toma como entrada un vetor Int con las clave de los estados
col:Toma como parametro de entrada un vector String con los nombres de las columnas

julia> ObtIDH(clave_e=[3],clave_m=[1,2,3],col=["AME","AEE"])
3×4 DataFrame
 Row │ ENTIDAD_RES  MUNICIPIO_RES  AME      AEE     
     │ Any          Any            Any      Any     
─────┼──────────────────────────────────────────────
   1 │ 3            1              7.8801   12.5007
   2 │ 3            2              7.41641  11.2824
   3 │ 3            3              10.1018  13.6419

 ##ObtIIM
 Esta función retorna un DataFrame de el Indice de Intensidad Migratoria por Municipio :
julia> ObtIIM()
2456×4 DataFrame
 Row │ ENTIDAD_RES  MUNICIPIO_RES  IIM      GIM        
     │ Int64        Int64          Float64  String     
──────┼─────────────────────────────────────────────────
   1 │           1              1  -0.516   2 Bajo
   2 │           1              2   0.5245  3 Medio
   3 │           1              3   3.1019  5 Muy Alto
 ⋮   │      ⋮             ⋮           ⋮         ⋮
2455 │          32             57   0.6809  4 Alto
2456 │          32             58   1.5644  4 Alto

Tiene 3 parametros opcionales:

clave_e:Toma como entrada un vetor Int con las clave de los estados
clave_m:Toma como entrada un vetor Int con las clave de los estados
col:Toma como parametro de entrada un vector String con los nombres de las columnas

julia> ObtIIM(clave_e=[8],clave_m=[1,2,3,4],col=["IIM"])
4×3 DataFrame
 Row │ ENTIDAD_RES  MUNICIPIO_RES  IIM     
     │ Int64        Int64          Float64
─────┼─────────────────────────────────────
   1 │           8              1  -0.6672
   2 │           8              2  -0.0713
   3 │           8              3  -0.0543
   4 │           8              4  -1.0134

##ObtIPb
Esta función retorna un DataFrame con los Indicadores de Pobreza del coneval por municipio
julia> ObtIPb()
2457×34 DataFrame
  Row │ ENTIDAD_RES  MUNICIPIO_RES  pobreza   pobreza_pob  pobreza_e  pobreza_e_pob  pobreza_m  pobreza_m_pob  ⋯      │ Int64        Int64          Float64?  Int32?       Float64?   Int32?         Float64?   Int32?         ⋯──────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────    1 │           1              1      26.1       224949        1.6          13650       24.5         211299  ⋯    2 │           1              2      54.0        25169        4.4           2067       49.5          23101   
    3 │           1              3      56.8        29951        3.1           1650       53.6          28301   
  ⋮   │      ⋮             ⋮           ⋮           ⋮           ⋮            ⋮            ⋮            ⋮        ⋱ 2456 │          32             57      63.1        11815        7.7           1439       55.4          10376   
 2457 │          32             58      57.4         1525        5.9            156       51.5           1369  ⋯     

Tiene 3 parametros opcionales:

clave_e:Toma como entrada un vetor Int con las clave de los estados
clave_m:Toma como entrada un vetor Int con las clave de los estados
col:Toma como parametro de entrada un vector String con los nombres de las columnas

julia> ObtIPb(clave_e=[12,13],clave_m=[3,4],col=["pobreza","pobreza_e"])
4×4 DataFrame
 Row │ ENTIDAD_RES  MUNICIPIO_RES  pobreza   pobreza_e
     │ Int64        Int64          Float64?  Float64?  
─────┼─────────────────────────────────────────────────
   1 │          12              3      84.3       38.0
   2 │          12              4      96.2       69.6
   3 │          13              3      55.0        5.6
   4 │          13              4      68.7       13.0

##ObtTasas
Esta función retorna un DataFrame con las Tasas de natalidad, fecundidad y mortalidad
julia> ObtTasas()
2469×6 DataFrame
  Row │ ENTIDAD_RES  MUNICIPIO_RES  naci_19  tasa_nat  muer_19  tasa_mor
      │ Int64        Int64          Int64?   Float64   Int64?   Float64  
──────┼──────────────────────────────────────────────────────────────────
    1 │           1              1    15682   19.676      5415   6.79414
    2 │           1              2     1058   23.2568      161   3.53908
    3 │           1              3     1052   19.4325      323   5.96645
  ⋮   │      ⋮             ⋮           ⋮        ⋮         ⋮        ⋮
 2468 │          32             57      421   24.8612       69   4.07464
 2469 │          32             58       37   13.1159       19   6.7352

 Tiene 3 parametros opcionales:

 clave_e:Toma como entrada un vetor Int con las clave de los estados
 clave_m:Toma como entrada un vetor Int con las clave de los estados
 col:Toma como parametro de entrada un vector String con los nombres de las columnas

 julia> ObtTasas(clave_e=[12,13],clave_m=[3,4],col=["tasa_nat"])
4×3 DataFrame
 Row │ ENTIDAD_RES  MUNICIPIO_RES  tasa_nat
     │ Int64        Int64          Float64  
─────┼──────────────────────────────────────
   1 │          12              3   23.2442
   2 │          12              4   42.0642
   3 │          13              3   17.0353
   4 │          13              4   20.4581

##ObtExt
Esta función retorna un DataFrame de la Población total, extensión territorial y densidad de población
julia> ObtExt()
2463×7 DataFrame
  Row │ ENTIDAD_RES  MUNICIPIO_RES  area        pob     pob_h   pob_m   densidad     
      │ Int64        Int64          Float64?    Int64   Int64   Int64   Float64?     
──────┼──────────────────────────────────────────────────────────────────────────────
    1 │           1              1  missing     797010  386429  410581  missing      
    2 │           1              2  missing      45492   22512   22980  missing      
    3 │           1              3  missing      54136   26250   27886  missing      
  ⋮   │      ⋮             ⋮            ⋮         ⋮       ⋮       ⋮          ⋮
 2462 │          32             57      220.95   16934    8358    8576       76.6418
 2463 │          32             58      279.77    2821    1402    1419       10.0833

 Tiene 3 parametros opcionales:

 clave_e:Toma como entrada un vetor Int con las clave de los estados
 clave_m:Toma como entrada un vetor Int con las clave de los estados
 col:Toma como parametro de entrada un vector String con los nombres de las columnas

 julia> ObtExt(clave_e=[30,20],clave_m=[1,2],col=["area"])
 4×3 DataFrame
  Row │ ENTIDAD_RES  MUNICIPIO_RES  area       
      │ Int64        Int64          Float64?   
 ─────┼────────────────────────────────────────
    1 │          20              1  missing    
    2 │          20              2  missing    
    3 │          30              1       97.69
    4 │          30              2       18.14

##datos_covid
Esa función retorna el DataFrame de los datos de casos de personas con covid obtenidos en coronavirus.gob junto con los datos por municipio  de
*Indice de Desarrollo Humano
*Intensidad de intensidad Migratoria
*Indicaores de pobreza del CONEVAL
*Mediana, primer y tercer cuartil de la edad
*Tasa de natalidad y mortalidad
*Porcentaje de hombres y mujeres
*Porcentaje de población indígena
*Población total, extensión territorial y densidad de población
Tiene como parametro oblicadorio 'dir', que es un String con la direccon de la carpeta donde se descargaran los archivos necesarios

julia> datos_covid("C:/Users/luism/github/dataframe_covid/sro")
   Row │ FECHA_ACTUALIZACION  ID_REGISTRO  ORIGEN  SECTOR  ENTIDAD_UM  SEXO   ENTIDAD_NAC  ENTIDAD_RES  M ⋯       │ Date                 String       Int64   Int64   Int64       Int64  Int64        Int64        I ⋯───────┼───────────────────────────────────────────────────────────────────────────────────────────────────     1 │ 2021-01-13           19adbb            1      13          19      1           19           19    ⋯     2 │ 2021-01-13           096478            2       4          15      2           15           15     
     3 │ 2021-01-13           1a9f12            2      12           1      1            1            1     
   ⋮   │          ⋮                ⋮         ⋮       ⋮         ⋮         ⋮         ⋮            ⋮         ⋱ 12123 │ 2021-01-13           1be809            1      12           9      1            9            9     
 12124 │ 2021-01-13           0aca88            1      12          14      2           14           14    ⋯ 12125 │ 2021-01-13           1c9368            2      12          15      2           15           15    

 Tiene 4 parametros opcionales:

subc:Toma como entrada un vector String con los subconjuntos deseados, las posibles entradas son:
   *"IDH"->datos de Indice de Desarrollo Dumano
   *"IIM"->datos de Indice de Intensidad Migratoria
   *"IP"->datos de Indice de Pobreza
   *"EDAD"->cuantiles de la edad
   *"NAT"->datos de natalidad y mortalidad
   *"GEN"->proporcion de hombres y mujeres
   *"IND"->proporcion de indigenas
   *"POB"->datos de poblacion y territorio

clave_e:Toma como entrada un vetor Int con las clave de los estados
clave_m:Toma como entrada un vetor Int con las clave de los estados
col:Toma como parametro de entrada un vector String con los nombres de las columnas
wr:toma un valor booleano, si es verdadero guarda los datos en un archivo csv, es false por default

datos_covid("C:/Users/luism/github/dataframe_covid/sro",subc=["IDH"])

dat=datos_covid("C:/Users/luism/github/dataframe_covid/sro",subc=["IDH"])
pri
12125×48 DataFrame
  Row │ FECHA_ACTUALIZACION  ID_REGISTRO  ORIGEN  SECTOR  ENTIDAD_UM  SEXO   ENTIDAD_NAC  ENTIDA ⋯       │ Date                 String       Int64   Int64   Int64       Int64  Int64        Int64  ⋯───────┼───────────────────────────────────────────────────────────────────────────────────────────     1 │ 2021-01-13           19adbb            1      13          19      1           19         ⋯     2 │ 2021-01-13           096478            2       4          15      2           15
    3 │ 2021-01-13           1a9f12            2      12           1      1            1
  ⋮   │          ⋮                ⋮         ⋮       ⋮         ⋮         ⋮         ⋮            ⋮ ⋱ 12123 │ 2021-01-13           1be809            1      12           9      1            9
12124 │ 2021-01-13           0aca88            1      12          14      2           14         ⋯ 12125 │ 2021-01-13           1c9368            2      12          15      2           15

julia> names(dat)
48-element Array{String,1}:
 "FECHA_ACTUALIZACION"
 "ID_REGISTRO"
 "ORIGEN"
 "SECTOR"
 "ENTIDAD_UM"
 ⋮
 "TMI"
 "IE"
 "II"
 "IS"
 "VIDH"
 En el ejemplo anterior podemos ver que se han agregado solo los datos del IDH
 si queremos solo algunas columnas y algunos estados y municios:

julia> datos_covid("C:/Users/luism/github/dataframe_covid/sro",clave_e=[1],clave_m=[2],col=["pob","IIM"])
6×5 DataFrame
 Row │ ENTIDAD_RES  MUNICIPIO_RES  ID_REGISTRO  IIM       pob    
     │ Int64        Int64          String       Float64?  Int64?
─────┼───────────────────────────────────────────────────────────
   1 │           1              2  1058f4         0.5245   45492
   2 │           1              2  16a3f0         0.5245   45492
   3 │           1              2  0f3fa0         0.5245   45492
   4 │           1              2  0ec7de         0.5245   45492
   5 │           1              2  179c59         0.5245   45492
