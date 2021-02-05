module dataframe_covid

export datos_covid,ObtIDH,ObtIIM,ObtIPb,ObtTasas,ObtExt,ObtUbi
using InfoZIP
using Dates , HTTP, DataFrames, CSV, StringEncodings,Statistics,XLSX,Query

"""
esta funcion descomprime lee la direccion de un
archivo .zip y lo descomprime
ejemplo
descomprimir("C:\\Users\\luism\\Documents\\datos.zip")
"""
function descomprimir(path::String)
   InfoZIP.unzip(path, pwd())
end

#calcula el primer quantile de un vector
function quantile1(x)
  return Statistics.quantile(x,0.25)
end

#calcula el tercer quantile de un vector
function quantile3(x)
  return Statistics.quantile(x,0.75)
end

"""calcula la proporcion de datos que son iguales a 1 en un vecor x
se usa para la proporcion de poblacion indigena"""
function prop_1(x)
  return count(i->(i==1),x)/length(x)
end

"""calcula la proporcion de datos que son iguales a 2 en un vecor x
"""
function prop_2(x)
return count(i->(i==2),x)/length(x)
end

"""descarga los datos de una direccion dada
ejemplo
data_check("http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip")
"""
function data_check(path_url::String)
  path = HTTP.download(path_url, pwd())
end

#devulve la fecha actual
function fechaayer()::String
  d=Dates.today()-Dates.Day(1)
  string(Dates.format(d, "yyyymmdd"))
end

#hace las pruenas necesarias y devuelve un subconjunto de datos con las columnas y filas espeficicadas
function sub(dat::DataFrame,clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  nam=names(dat)
  #selecciona las columnas necesarias
  if col!=[""]
    colsel=["ENTIDAD_RES","MUNICIPIO_RES"]
    for i in col
      if (i in nam)
        push!(colsel,i)
      else
        println("No existe colummna $i ")
      end
    end
    select!(dat,unique(colsel))
  end
  #selecciona las municiopios y Entidades necesarias
  if clave_e!=[0]  && clave_m != [0]
    dat=@from i in dat begin
       @where i.MUNICIPIO_RES in clave_m && i.ENTIDAD_RES in clave_e
       @select i
       @collect DataFrame
     end
  elseif clave_e!=[0]
    dat=@from i in dat begin
       @where i.ENTIDAD_RES in clave_e
       @select i
       @collect DataFrame
     end
  elseif clave_m!=[0]
    dat=@from i in dat begin
       @where i.MUNICIPIO_RES in clave_m
       @select i
       @collect DataFrame
     end
  end
  return dat
end

#devuele un DataFrame  con el IDH por municipio
function ObtIDH(;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  if !isfile("IDH 10 NM sitioweb.xlsx")
    data_check("https://www.mx.undp.org/content/dam/mexico/docs/Publicaciones/PublicacionesReduccionPobreza/InformesDesarrolloHumano/UNDP-MX-IDH-Municipal-basedatos.zip")
    descomprimir("UNDP-MX-IDH-Municipal-basedatos.zip")
  end
  idh=XLSX.readdata("IDH 10 NM sitioweb.xlsx","IDH 2010 NM","B5:M2460")
  idh=idh[1:end,1:end.!=3]
  idh=idh[1:end,1:end.!=3]
  idh=convert(DataFrame,idh)
  nam=["ENTIDAD_RES","MUNICIPIO_RES","AME","AEE","IPCA","TMI","IE","II","IS","VIDH"]
  rename!(idh,nam)

  return sub(idh,clave_e,clave_m,col)
end

#devuelve un Dataframe con el indice de intensidad migratoria por Municipio
function ObtIIM(;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  if !isfile("IIM2010_BASEMUN.csv")
    data_check("https://raw.githubusercontent.com/luismanuel2/dataframe_covid/main/datos/IIM2010_BASEMUN.csv")
  end
  iim=CSV.read("IIM2010_BASEMUN.csv",DataFrame)
  iim=DataFrame(ENTIDAD_RES=iim.ENT,MUNICIPIO_RES=iim.MUN,IIM=iim.IIM_2010,GIM=iim.GIM_2010)
  return sub(iim,clave_e,clave_m,col)
end

function ObtIPb(;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  #Busqueda y descarga del archivo
  if !isfile("indicadores de pobreza municipal, 2015.xls")
    data_check("https://www.coneval.org.mx/Informes/Pobreza/Datos_abiertos/pobreza_municipal/indicadores%20de%20pobreza%20municipal,%202015.csv")
  end
  #asignación del .csv
  ipb=CSV.read("indicadores%20de%20pobreza%20municipal,%202015.csv",DataFrame)
  #ciclo para asignar los valores correctos a los municipios
  for i in 1:nrow(ipb)
     if ipb[i,:3]>1000
       ipb[i,:3]=ipb[i,:3]-(ipb[i,:1]*1000)
     end
  end  #Quita las "," y cambia el tipo de dato a Int64
  for i in 5:2:37
    for j in 1:nrow(ipb)
       ipb[j,i]=replace(ipb[j,i], "," => "")
    end
    ipb[!,i] = map(x->begin val = tryparse(Int, x)
                                ifelse(typeof(val) == Nothing, missing, val)
                          end, ipb[!,i])
  end
  #Cambia el tipo de dato a Float64
  for i in 6:2:36
    ipb[!,i] = map(x->begin val = tryparse(Float64, x)
                               ifelse(typeof(val) == Nothing, missing, val)
                          end, ipb[!,i])
  end
  ipb=select(ipb,Not([:entidad_federativa,:municipio,:poblacion]))
  rename!(ipb,"clave_entidad"=>"ENTIDAD_RES","clave_municipio"=>"MUNICIPIO_RES")
  return sub(ipb,clave_e,clave_m,col)
end

# un  DataFrame  con  el primer, segundo y tercer quartile de las edades por municipio
function Obtquartile(date::DataFrame;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:EDAD=>Statistics.median,:EDAD=>quantile1,:EDAD=>quantile3)
  return sub(datagroup,clave_e,clave_m,col)
end

#regresa los datos de tasas de natalidad y fecundidad
function ObtTasas(;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  if !isfile("tasas.csv")
    data_check("https://raw.githubusercontent.com/luismanuel2/dataframe_covid/main/datos/tasas.csv")
  end
  tasa=CSV.read("tasas.csv",DataFrame)
  return sub(tasa,clave_e,clave_m,col)
end

#devuelve un DataFrame con la proporcion de hombres y mujeres por municipio
function ObtSexo(date::DataFrame;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:SEXO=>prop_2,:SEXO=>prop_1)
  nam=["ENTIDAD_RES","MUNICIPIO_RES","SEXO_2","SEXO_1"]
  rename!(datagroup,nam)
  return sub(datagroup,clave_e,clave_m,col)
end

#devuelve un DataFrame con la proporcion de pobacion indigen
function ObtIndigena(date::DataFrame;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""])
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:INDIGENA=>prop_1)
  nam=["ENTIDAD_RES","MUNICIPIO_RES","POR_INDIGENA"]
  rename!(datagroup,nam)
  return sub(datagroup,clave_e,clave_m)
end

# devuelve los datos de poblacion y extencion territorial
function ObtExt(;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""],wr::Bool=false)
    if !isfile("Poblaci%C3%B3n.csv")
      data_check("https://raw.githubusercontent.com/luismanuel2/dataframe_covid/main/datos/Poblaci%C3%B3n.csv")
    end
    pob=CSV.read("Poblaci%C3%B3n.csv",DataFrame)
    return sub(pob,clave_e,clave_m,col)
end

function ObtUbi(;clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""],wr::Bool=false)
    if !isfile("ubicacion.csv")
      data_check("https://raw.githubusercontent.com/luismanuel2/dataframe_covid/main/datos/ubicacion.csv")
    end
    pob=CSV.read("ubicacion.csv",DataFrame)
    return sub(pob,clave_e,clave_m,col)
end



function datos_covid(dir::String;subc::Array{String}=[""],clave_e::Array{Int}=[0],clave_m::Array{Int}=[0],col::Array{String}=[""],wr::Bool=false)
  dw=pwd()
  try
    cd(dir)
  catch
    cd(dw)
    error("ingresa una direccion correcta")
  end



  archivo=fechaayer()
  archivo=archivo[3:end]*"COVID19MEXICO"*".csv"

  if isfile("datos_abiertos_covid19.zip")
    rm("datos_abiertos_covid19.zip")
  end
  if !isfile(archivo)
     data_check("http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip")
     descomprimir("datos_abiertos_covid19.zip")
  end

  data=CSV.read(archivo,DataFrame)
  data1=select(data,["MUNICIPIO_RES","ENTIDAD_RES","INDIGENA","EDAD","SEXO"])

  nidh=["AME","AEE","IPCA","TMI","IE","II","IS","VIDH"]
  niim=["IIM","GIM"]
  nipb=["pobreza", "pobreza_pob", "pobreza_e", "pobreza_e_pob", "pobreza_m", "pobreza_m_pob", "vul_car", "vul_car_pob", "vul_ing", "vul_ing_pob", "npnv", "npnv_pob", "ic_rezedu", "ic_rezedu_pob", "ic_asalud","ic_asalud_pob","ic_segsoc","ic_segsoc_pob", "ic_cv", "ic_cv_pob", "ic_sbv", "ic_sbv_pob", "ic_ali", "ic_ali_pob", "carencias", "carencias_pob", "carencias3", "carencias3_pob", "plb", "plb_pob", "plbm", "plbm_pob"]
  ntas=["naci_19", "tasa_nat", "muer_19", "tasa_mor"]
  nquar=["EDAD_median","EDAD_quantile1","EDAD_quantile3"]
  nse=["SEXO_1","SEXO_2"]
  nin=["POR_INDIGENA"]
  npob=["area", "pob", "pob_h", "pob_m", "densidad"]
  ndat=names(data)
  nubi=["codigo_Postal","coordenada_lateral","coordenada_longitudinal","altitud"]

  eidh=Vector{String}()
  eiim=Vector{String}()
  eipb=Vector{String}()
  etas=Vector{String}()
  equar=Vector{String}()
  ese=Vector{String}()
  ein=Vector{String}()
  edat=Vector{String}()
  epob=Vector{String}()
  eubi=Vector{String}()

  if col!=[""]
  for i in col
    if i in nidh
      push!(eidh,i)
    elseif i in niim
      push!(eiim,i)
    elseif i in nipb
      push!(eipb,i)
    elseif i in nquar
      push!(equar,i)
    elseif i in ntas
      push!(etas,i)
    elseif i in nse
      push!(ese,i)
    elseif i in nin
      push!(ein,i)
    elseif i in ndat
      push!(edat,i)
    elseif i in npob
      push!(epob,i)
    elseif i in nubi
      push!(eubi,i)
    else
      println("No se encontro columna $i")
    end
  end
  else
    eidh=eiim=eipb=equar=etas=ese=ein=edat=epob=eubi=[""]
  end

  if clave_e!=[0] || clave_m!=[0] || col!=[""]
    if edat==[]
      data=sub(data,clave_e,clave_m,["ID_REGISTRO"])
    elseif col!=[""]
      println(append!(["ID_REGISTRO"],edat))
      data=sub(data,clave_e,clave_m,append!(["ID_REGISTRO"],edat))
    else
      data=sub(data,clave_e,clave_m,edat)
    end
  end


  if subc==[""]
    subc=["IDH","IIM","IP","EDAD","NAT","GEN","IND","POB","UBI"]
  end
  for i in subc
    if i=="IDH" && eidh!=[]
      data=leftjoin(data,ObtIDH(clave_e=clave_e,clave_m=clave_m,col=eidh),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="IIM" && eiim!=[]
      data=leftjoin(data,ObtIIM(clave_e=clave_e,clave_m=clave_m,col=eiim),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="IP" && eipb!=[]
      data=leftjoin(data,ObtIPb(clave_e=clave_e,clave_m=clave_m,col=eipb),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="EDAD" && equar!=[]
      data=leftjoin(data,Obtquartile(data1,clave_e=clave_e,clave_m=clave_m,col=equar),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="NAT" && etas!=[]
      data=leftjoin(data,ObtTasas(clave_e=clave_e,clave_m=clave_m,col=etas),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="GEN" && ese!=[]
      data=leftjoin(data,ObtSexo(data1,clave_e=clave_e,clave_m=clave_m,col=ese),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="IND" && ein!=[]
      data=leftjoin(data,ObtIndigena(data1,clave_e=clave_e,clave_m=clave_m,col=ein),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="POB" && epob!=[]
      data=leftjoin(data,ObtExt(clave_e=clave_e,clave_m=clave_m,col=epob),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    elseif i=="POB" && epob!=[]
      data=leftjoin(data,ObtUbi(clave_e=clave_e,clave_m=clave_m,col=eubi),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
    end
  end
  if wr
    CSV.write("data"*fechaayer()*".csv",data)
  end
  cd(dw)
  return data

end



end # module
