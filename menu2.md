+++
title = "Estudio temporal"
hascode = true
rss = "A short description of the page which would serve as **blurb** in a `RSS` feed; you can use basic markdown here but the whole description string must be a single line (not a multiline string). Like this one for instance. Keep in mind that styling is minimal in RSS so for instance don't expect maths or fancy styling to work; images should be ok though: ![](https://upload.wikimedia.org/wikipedia/en/b/b0/Rick_and_Morty_characters.jpg)"
rss_title = "More goodies"
rss_pubdate = Date(2019, 5, 1)

tags = ["syntax", "code", "image"]
+++

# **Estudio temporal de los varamientos de tortugas marinas**

## Tortugas marinas varadas en del 2000 al 2021

Se empezará estudiando desde el año 2000 hasta el último mes del año 2021 del que data la base de datos.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/number_turtles_per_year.png">
    <p>
    Descripción del gráfico: La llegada de tortugas sufre variaciones en cada año. 
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

## Varamientos de las tortugas según la estación

### Observaciones por año

Existe un patrón obvio del rescate de tortugas marinas varadas en Tenerife según la estación. En verano es cuando más tortugas llegan al CRFS de la Tahonilla, mientras el paso de tortugas en las estaciones de otoño y primavera es similar, y por último cuando menos varamientos hay es en la estación de invierno.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/number_turtles_per_season.png">
    <p>
    Descripción del gráfico: La llegada de tortugas sufre variaciones en cada año según la estación. 
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

### Análisis estadístico

Mediante un análisis estadístico más exhaustivo mediante Kruskal-Wallis, se confirma que existen diferencias significativas entre los grupos (*p* < 0.05), y a partir de un post-doc de usando el test de Dunnet (ajustando *p* a la corrección de Bonferroni), vemos las sospechas anteriores.

~~~ 
<u>Resultados del test de Dunnet</u>
~~~

\tableinput{}{./tableinput/dunn_test_seasons.csv}

* La estación de verano presenta diferecnias significativas con el resto, siendo cuando más tortugas llegan al centro.
* No existen diferencias significativas de los varamientos en las estaciones de primavera y otoño. Por otro lado, otoño e invierno no presentan diferencias significativas entre si.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/boxplot_seasons.png">
    <p>
    Descripción del gráfico: Boxplot para comparar las llegadas de tortugas según la estación del año. Podemos comprobar de esta manera las diferencias anotadas anteriormente. 
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
