# dataframe_covid
crea un subconjunto de datos que agregue a los datos abiertos del COVID-19 de la secretaria de salud, datos adicionales

Este NO es (todavía) un paquete registrado por Julia:
* instalarlo con `] add https://github.com/luismanuel2/dataframe_covid`
* importarlo con `using dataframe_covid`

## ObtIDH()
Esta función retorna un DataFrame de el Indice de desarrollo humano y sus componentes desagregados por municipio,tiene 3 parametros opcionales:
* `clave_e::Array{Int}`->toma como entrada un vetor Int con las clave de los estados deseados
* `clave_m::Array{Int}`->Toma como entrada un vetor Int con las clave de los estados deseados
* `col::Array{String}`->Toma como parametro de entrada un vector String con los nombres de las columnas deseadas  
* ejemplo
   * `ObtIDH()`-> obtiene todos los datos
   * `ObtIDH(clave_e=[3],clave_m=[1,2,3],col=["AME","AEE"])`
   * `ObtIDH(clave_e=[6])`


## ObtIIM()
 Esta función retorna un DataFrame de el Indice de Intensidad Migratoria por Municipio,tiene 3 parametros opcionales:
 * `clave_e::Array{Int}`->toma como entrada un vetor Int con las clave de los estados deseados
 * `clave_m::Array{Int}`->Toma como entrada un vetor Int con las clave de los estados deseados
 * `col::Array{String}`->Toma como parametro de entrada un vector String con los nombres de las columnas deseadas  
 * ejemplo
   * `ObtIIM()`-> obtiene todos los datos
   * `ObtIIM(clave_e=[8],clave_m=[1,2,3,4],col=["IIM"])`
   * `ObtIIM(clave_m=[1])`

## ObtIPb()
Esta función retorna un DataFrame con los Indicadores de Pobreza del coneval por municipio,tiene 3 parametros opcionales:
* `clave_e::Array{Int}`->toma como entrada un vetor Int con las clave de los estados deseados
* `clave_m::Array{Int}`->Toma como entrada un vetor Int con las clave de los estados deseados
* `col::Array{String}`->Toma como parametro de entrada un vector String con los nombres de las columnas deseadas  
* ejemplo
   * `ObtIPb()`-> obtiene todos los datos
   * `ObtIPb(clave_e=[12,13],clave_m=[3,4],col=["pobreza","pobreza_e"])`
   * `OObtIPb(col=["pobreza_pob"])`

## ObtTasas()
Esta función retorna un DataFrame con las Tasas de natalidad, fecundidad y mortalidad,tiene 3 parametros opcionales:
* `clave_e::Array{Int}`->toma como entrada un vetor Int con las clave de los estados deseados
* `clave_m::Array{Int}`->Toma como entrada un vetor Int con las clave de los estados deseados
* `col::Array{String}`->Toma como parametro de entrada un vector String con los nombres de las columnas deseadas  
* ejemplo
   * `ObtTasas()`-> obtiene todos los datos
   * `ObtTasas(clave_e=[12,13],clave_m=[3,4],col=["tasa_nat"])`
   * `ObtTasas(clave_e=[6,2,3])`

## ObtExt()
Esta función retorna un DataFrame de la Población total, extensión territorial y densidad de población,tiene 3 parametros opcionales:
   * `clave_e::Array{Int}`->toma como entrada un vetor Int con las clave de los estados deseados
   * `clave_m::Array{Int}`->Toma como entrada un vetor Int con las clave de los estados deseados
   * `col::Array{String}`->Toma como parametro de entrada un vector String con los nombres de las columnas deseadas  
   * ejemplo
      * `ObtExt()`-> obtiene todos los datos
      * `ObtExt(clave_e=[30,20],clave_m=[1,2],col=["area"])`
      * `ObtExt(clave_m=[1,2,3,4,5])`
      
## ObtUbi()
Esta función retorna un DataFrame de datos sobre la ubicacion de cada municipal, se obtuvieron datos de la ubicacion de cada colonia y luego se escogio la que tenia mayor población para representar sus datos como si fueran los de el municipio, tiene 3 parametros opcionales:
* `clave_e::Array{Int}`->toma como entrada un vetor Int con las clave de los estados deseados
* `clave_m::Array{Int}`->Toma como entrada un vetor Int con las clave de los estados deseados
* `col::Array{String}`->Toma como parametro de entrada un vector String con los nombres de las columnas deseadas  
* ejemplo
   * `ObtUbi()`-> obtiene todos los datos
   * `ObtUbi(clave_e=[30,20],clave_m=[1,2],col=["codigo_Postal"])`
   * `ObtUbi(clave_m=[1,2,3,4,5])`



## datos_covid()
Esa función retorna el DataFrame de los datos de casos de personas con covid obtenidos en coronavirus.gob junto con los datos por municipio  de
* Indice de Desarrollo Humano
* Intensidad de intensidad Migratoria
* Indicaores de pobreza del CONEVAL
* Mediana, primer y tercer cuartil de la edad
* Tasa de natalidad y mortalidad
* Porcentaje de hombres y mujeres
* Porcentaje de población indígena
* Población total, extensión territorial y densidad de población

Tiene como parametro oblicadorio `dir::String`,es un String con la direccon de la carpeta donde se descargaran los archivos necesarios,tiene 5 parametros opcionales:
* `wr::Bool`-> toma un valor booleano, si es verdadero guarda los datos en un archivo csv, es false por default
* `clave_e::Array{Int}`->toma como entrada un vetor Int con las clave de los estados deseados
* `clave_m::Array{Int}`->Toma como entrada un vetor Int con las clave de los estados deseados
* `col::Array{String}`->Toma como parametro de entrada un vector String con los nombres de las columnas deseadas
* `subc::Array{String}`-> Toma como entrada un vector String con los subconjuntos deseados, las posibles entradas son:
   * "IDH"->datos de Indice de Desarrollo Dumano
   * "IIM"->datos de Indice de Intensidad Migratoria
   * "IP"->datos de Indice de Pobreza
   * "EDAD"->cuantiles de la edad
   * "NAT"->datos de natalidad y mortalidad
   * "GEN"->proporcion de hombres y mujeres
   * "IND"->proporcion de indigenas
   * "POB"->datos de poblacion y territorio
   * "UBI"->datos de ubicacion
* ejemplo
   * `datos_covid("C:/Users/luism/github/dataframe_covid/sro",wr=true)`-> obtiene todos los datos
   * `datos_covid("C:/Users/luism/github/dataframe_covid/sro",subc=["IDH"])`  En este ejemplo solo se agregan los datos del IDH
   * `datos_covid("C:/Users/luism/github/dataframe_covid/sro",clave_e=[1],clave_m=[2],col=["pob","IIM"])`
**NOTA: _subc_ y _col_ no pueden usarse al mismo tiempo**
