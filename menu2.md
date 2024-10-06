+++
title = "Estudio temporal"
hascode = true
rss = ""
rss_title = "Estudio temporal"
rss_pubdate = Date(2019, 5, 1)

tags = ["syntax", "code", "image"]
+++

# **Estudio temporal de los varamientos de tortugas marinas**

## Tortugas marinas varadas en del 2000 al 2021

En Tenerife se registran números elevados de varamientos de tortugas marinas en el intervalo de los años 2000 al 2001. Sin embargo, no se detecta un patrón de incremento o decrecimiento del número de registros.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/number_turtles_per_year.png">
    <figcaption>
    <p style="font-size: 14px;" align="center">
    <strong><i>Figura 1.</strong> Distribución temporal de los registros de tortugas marinas.</i>
    </p>
    </figcaption>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

## Varamientos de las tortugas según la estación.

Por otra parte, si que parece haber un patrón singular en los registros según la estación. En verano es cuando más tortugas llegan al CRFS de la Tahonilla, mientras el paso de tortugas en las estaciones de otoño y primavera es similar, y por último cuando menos varamientos hay es en la estación de invierno.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/number_turtles_per_season.png">
    <p style="font-size: 14px;" align="center">
    <strong><i>Figura 2.</strong> Distribución temporal de los registros de tortugas marinas según la estación.</i>
    </p>
    </figcaption>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

### Análisis estadístico

Para ver si de verdad existen diferencias significativas de los registros de tortugas marinas, es necesario realizar un análisis estadístico. Debido a que los datos no siguen una distribución normal (test de Shapiro - Wilks), mediante Kruskal-Wallis, se confirma que existen diferencias significativas entre los grupos (*p* < 0.05). 

Se prosigue con un análisis post-hoc de usando el test de Dunnet, ajustando *p* a la corrección de Bonferroni, vemos los resultados en la siguiente tabla.

~~~ 
<p style="font-size: 14px" align="center"><i><strong>Tabla 1.</strong> Resultados del test de Dunnet</i></p> 
~~~

\tableinput{}{./tableinput/dunn_test_seasons.csv}

~~~<u>Interpretación de los resultados del análisis estadístico:</u>~~~ 

* La estación de verano presenta diferecnias significativas con el resto, siendo cuando más tortugas llegan al centro.

* No existen diferencias significativas de los varamientos en las estaciones de primavera y otoño. Por otro lado, otoño e invierno no presentan diferencias significativas entre si.

En este sentido el número de tortugas marinas varadas en Tenerife se dan en los meses más calidos.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/boxplot_seasons.png">
    <p style="font-size: 14px;" align="center">
    <strong><i>Figura 3.</strong> Boxplot para comparar las estaciones.</i>
    </p>
    </figcaption>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
