module dataframe_covid

export datos_covid
using InfoZIP

using Dates , HTTP, DataFrames, CSV, StringEncodings,Statistics,XLSX

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
  nam=["ENTIDAD_RES","MUNICIPIO_RES","AME","AEE","IPCA","TMI","IE","II","Is","VIDH"]
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
  end
  ipb=select(ipb,Not([:entidad_federativa,:municipio]))
  return ipb
end

# un  DataFrame  con  el primer, segundo y tercer quartile de las edades por municipio
function Obtquartile(date::DataFrame)
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:EDAD=>Statistics.median,:EDAD=>quantile1,:EDAD=>quantile3)
  nam=["ENTIDAD_RES","MUNICIPIO_RES","Edad_median","Edad_quantile1","Edad_quantile3"]
  rename!(datagroup,nam)
  return datagroup
end


#devuelve un DataFrame con la proporcion de hombres y mujeres por municipio
function ObtSexo(date::DataFrame)
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:SEXO=>prop_2,:SEXO=>prop_1)
  nam=["ENTIDAD_RES","MUNICIPIO_RES","Sexo1","Sexo2"]
  rename!(datagroup,nam)
  return datagroup
end

#devuelve un DataFrame con la proporcion de pobacion indigen
function ObtIndigena(date::DataFrame)
  datagroup=groupby(date,[:ENTIDAD_RES,:MUNICIPIO_RES])
  datagroup=combine(datagroup,:INDIGENA=>prop_1)
  nam=["ENTIDAD_RES","MUNICIPIO_RES","por_indigena"]
  rename!(datagroup,nam)
  return datagroup
end



function datos_covid(path::String)
  try
    cdw=pwd()
  catch
    error("ingresa una direccion correcta")
  end
  cd(path)

  archivo=fechahoy()
  arcivo=archivo[3:end]*"COVID19MEXICO"*".csv"
  if isfile("datos_abiertos_covid19.zip")
    rm("datos_abiertos_covid19.zip")
  end
  if !isfile(archivo)
     data_check("http://datosabiertos.salud.gob.mx/gobmx/salud/datos_abiertos/datos_abiertos_covid19.zip")
     descomprimir("datos_abiertos_covid19.zip")
  end

  data=CSV.read(archivo,DataFrame)
  data=leftjoin(data,ObtIDH(),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtIIM(),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtIPb(),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,Obtquartile(data),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtSexo(data),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  data=leftjoin(data,ObtIndigena(data),on=[:ENTIDAD_RES,:MUNICIPIO_RES])
  cd(cwd)
  return data

end



end # module
