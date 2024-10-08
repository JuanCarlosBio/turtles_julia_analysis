# **Análisis de tortugas marinas usando Julia**

---

El objetivo de este repositorio es el uso del [lenguaje de programación Julia](https://julialang.org/) para analizar una base de datos de tortugas marinas varadas en Tenerife, isla de Gran Canaria, de un repositorio de datos de la Universidad de la Laguna ([Datasets - ULL](https://data.mendeley.com/datasets/p6wmtv6t5g/2)).

Además se combinará con otros lenguajes de programación como R y Python para labores en los que Julia siga siendo bajo mi punto de vista más débil.

A partir de los resultados, crearé un <u><strong>artículo web</strong></u> exponiéndolos. Para ello usaré el paquete [Franklin.jl](https://franklinjl.org/), que tiene frameworks para realizar sitios webs estáticcos sencillos.

---

### ¿Por qué queireo aprender julia?

* <u><strong>Rapidez</strong></u>: a diferencia de R y Python, presenta un JIT, lo que lo hace muy rápido.
* <u><strong>Alto nivel</strong></u>: Fácil de leer debido y su sintaxis me parece bonita.
* <u><strong>Es un lenguaje scripting</strong></u> 
* <u><strong>Un soplo de aire nuevo</strong></u>  
* <u><strong>Comunidad</strong></u>: es un lenguaje relativamente nuevo y sin una comunidad tan potente como R o Python, pero comprometida y con gran interés en la <u>computación científica</u>.

---

Los Programas para el análisis de datos consisten se encuentran en la carpeta [code](code/):

  |         **SCRIPT**             | **FUNCIÓN** | 
  | :--------------------------: | :-----------------: | 
  | [01create_dirs.jl](code/01create_dirs.jl) | Crear los directorios para el análsis (almacena datos, resultrados...) |  
  | [02download_data.jl](code/02download_data.jl) | Descargar los datos de los registros de las tortugas marinas del repositorio de la ULL |   
  | [03process_turtle_data.jl](code/03process_turtle_data.jl) | Los datos están preprocesados, pero le he dado un procesado también para ajustarlo a mis necesidades|   
  | [04time_study.jl](code/04time_study.jl) | Estudio temporal de los regitros de las tortugas marinas |   
  | [05biometria.jl](code/05biometria.jl) | Estudio biométrico de los ejemplares de tortugas marinas |   
  | [06causes.jl](code/06causes.jl) | Estudio de las causas de tortugas marinas |   
  | [07conditions.jl](code/07conditions.jl) | Aálsis de la condición de las tortugas al llegar y destino de las tortugas en la Tahonilla |   
  | [08observations.jl](code/08observations.jl) | Análsis de las observaciones oportunas de los trabajadores del centro a las tortugas |   
  | [01location_stranded.R](code) | Script de R para la localización de los varamientos de las tortugas en Tenerife |   
  | [01process_shp.py](code) | Script de Python para procesas archivos SHP del IDECanrias GRAPHCAN |   
