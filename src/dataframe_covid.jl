module dataframe_covid

export datos_covid
using Dates
using ZipFile, HTTP, DataFrames, CSV, StringEncodings,Statistics,XLSX

"""
esta funcion descomprime lee la direccion de un
archivo .zip y lo descomprime
ejemplo
descomprimir("C:\\Users\\luism\\Documents\\datos.zip")
"""
function descomprimir(path::String)
  zarchive = ZipFile.Reader(path)
  f=zarchive.files[1]
  write(f.name,read(f,String))
  close(zarchive)
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
function fechahoy()::String
  string(Dates.format(DateTime(Dates.today()), "yyyymmdd"))
end

#devuele un DataFrame  con el IDH por municipio
function ObtIDH()
  if !isfile("IDH 10 NM sitioweb.xlsx")
    data_check("https://www.mx.undp.org/content/dam/mexico/docs/Publicaciones/PublicacionesReduccionPobreza/InformesDesarrolloHumano/UNDP-MX-IDH-Municipal-basedatos.zip")
    descomprimir("UNDP-MX-IDH-Municipal-basedatos.zip")
  end
  idh=XLSX.readdata("IDH 10 NM sitioweb.xlsx","IDH 2010 NM","B5:M2460")
  idh=idh[1:end,1:end.!=3]
  idh=idh[1:end,1:end.!=3]
  idh=convert(DataFrame,idh)
  nam=["ENTIDAD_RES","MUNICIPIO_RES","Años_promedio_de_escolaridad","Años_esperados_de_escolarización","Ingreso_per_cápita_anual(dólares_PPC)","Tasa_de_Mortalidad_Infantil","Índice_de_educación","Índice_de_ingreso","Índice_de_salud","valor_del_IDH"]
  rename!(idh,nam)
  return idh
end

#devuelve un Dataframe con el indice de intensidad migratoria por Municipio
function ObtIIM()
  if !isfile("IIM2010_BASEMUN.xls")
    data_check("https://raw.githubusercontent.com/luismanuel2/dataframe_covid/main/src/IIM2010_BASEMUN.csv")
  end
  iim=CSV.read("IIM2010_BASEMUN.csv",DataFrame)
  iim=DataFrame(ENTIDAD_RES=iim.ENT,MUNICIPIO_RES=iim.MUN,IIM=iim.IIM_2010,GIM=iim.GIM_2010)
  return iim
end

function ObtIPb()
  x=0
end

# un  DataFrame  con  el primer, segundo y tercer quartile de las edades por municipio
function Obtquartile(date::DataFrame)
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:EDAD=>Statistics.median,:EDAD=>quantile1,:EDAD=>quantile3)
  return datagroup
end

function ObtTasas(args)
  x=0
end

#devuelve un DataFrame con la proporcion de hombres y mujeres por municipio
function ObtSexo(date::DataFrame)
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:SEXO=>prop_2,:SEXO=>prop_1)
  return datagroup
end

#devuelve un DataFrame con la proporcion de pobacion indigen
function ObtIndigena(date::DataFrame)
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:INDIGENA=>prop_1)
  return datagroup
end

"""sin terminar
actualmente devuelve un DataFrame con la poblacion total por municipio
datos del 2015"""
function ObtExt()
  if !isfile("estructura_00.xlsx")
    data_check("https://www.inegi.org.mx/contenidos/masiva/indicadores/temas/estructura/estructura_00_xlsx.zip")
    descomprimir("estructura_00_tsv.zip")
  end
  data_check("https://www.inegi.org.mx/app/ageeml/#")
  pob1=XLSX.readdata("estructura_00.xlsx","valor","A2:C29641")
  pob2=XLSX.readdata("estructura_00.xlsx","valor","AN2:AN29641")
  pob3=XLSX.readdata("estructura_00.xlsx","valor","F2:F29641")
  pob1=pob1[1:end,1:end.!=2]
  pob1=convert(DataFrame,pob1)
  pob2=convert(DataFrame,pob2)
  pob3=convert(DataFrame,pob3)
  pob=DataFrame(ENTIDAD_RES=pob1.x1,MUNICIPIO_RES=pob1.x2,poblacion=pob2.x1)
  pob=pob[findall(x->(x=="Población total en viviendas particulares habitadas"),pob3.x1),:]
  pob[!,:ENTIDAD_RES]=parse.([Int],pob[!,:ENTIDAD_RES])
  pob[!,:MUNICIPIO_RES]=parse.([Int],pob[!,:MUNICIPIO_RES])
  pob[!,:poblacion]=parse.([Int],pob[!,:poblacion])
  return pob
end
function datos_covid(path::String)
  cdw=pwd()
  cd(path)

  archivo=fechahoy()
  arcivo=archivo[3:end]*"COVID19MEXICO"*".csv"
  if !isfile(archivo)
     data_check("http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip")
     descomprimir("datos_abiertos_covid19.zip")
  end



  data=CSV.read(archivo,DataFrame)
  data=leftjoin(data,ObtIDH(),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtIIM(),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,Obtquartile(data),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtSexo(data),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtIndigena(data),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtExt(),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  return data

end



end # module
