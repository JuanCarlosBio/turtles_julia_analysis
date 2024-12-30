+++
title = "Causas de los varamientos"
hascode = true
rss = ""
rss_title = "More goodies"
rss_pubdate = Date(2019, 5, 1)

tags = ["syntax", "code", "image"]
+++

# **Causas y Subcausas de los varamientos**

## Causas de los varamientos en Tenerife 

De las causas que más afectan a las tortugas marinas, casi in 50% Son las relacionadas con afecciones ocasionadas por los equipos de pesca. Le sigue las tortugas que quedan varadas o flotando a la deriva por encontrarse enfermedad, y en menor medida, por traumatismos, ingestión o enredamiento en plásticos, petróleo y en pocas ocasiones llegan por muerte natural.

Alguna de ellas quedan varadas por otras causas muy variadas, menos comunes o en ocasiones no se puede determinar la causa en concreto del varamiento. Durante mi Trabajo de Fin de Grado en La Laguna, visité el Centro de Recuperación de Fauna Silvestre de La Tahonilla, al hablar con el personal de las instalaciones, en ocasiones, se capturan tortugas a la deriva, pensando que están enfermas o heridas, pero tras inspeccionarlas en el centro se comprueba que se encuentran en buen estado.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/barplot_causes.png">
    <figcaption; style="font-size: 12px;" align="center">
    <i><strong>Figura 1</strong>. Gráfico con el porcentaje de  de las causas por las que las tortugas marinas han varado en Tenerife.</i>
    </figcaption>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

### Evolución de las causas en el transcurso de los años

Revisando estos porcentajes en cada unode los años, vemos que por lo general los Equipos de Pesca presentan un mayor peso como vimos en el gráfico anterior, sin embargo, parece que en los últimos años hay una espeice de disminución de estas causas comparado con los periodos 2008 - 2011, pero si es verdad que puede tratarse de un ciclo. Sin embargo parece que las tortugas varadas por enfermedades se mantienen constantes o incluso con un incremento de esta causa en los últimos años. 

Por lo general el resto de causas presentan porcentajes más bajos que las dos anteriores.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/year_causes_percentage_barplot.png">
    <figcaption; style="font-size: 12px;" align="center">
    <i><strong>Figura 2</strong>. Gráfico con los porcentajes de  de las causas del periódo del 2000 al 2021.</i>
    </figcaption>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

## Relación entre las causas con sus subcausas

En la base de datos existen también subcausas, lo que puede ser interesante para analizar la relación de estas con las causas principales y ver si forman grupos. Para ello he creado el la **Figura 3**, podemos ver que efectivamente muchas de las relaciones tienen sentido:

* La relación de causas y subcausas con valores más altos son los equipos de pesca y de los que se registran principalmente las redes de pesca y los anzuelos como el principal causante de varamientos de tortugas marinas en la isla de Tenerife.

* En cuanto a las tortugas varadas por enfermedad, la segunada causa más prevalente que vimos en los apartados anteriores, se encuentra relacionada principalmente con la infección por organismos, y por otro lado, con desnutrición (caquexia) o agotamiento extremo y problemas de para flotar:
  * ~~~<u>Afección de epizoitos</u>~~~, que sin un grupo de organismos que parasitan a las tortugas marinas, en cuanto a la tortuga boba pueden ser organismos generalistas, y otro gran grupo de especialistas ([referencia](https://roderic.uv.es/items/b9843896-5a4b-4219-8904-f95dda309e26)).

* Como comenté al principio de esta sección, en los datos podemos ver que un número elevado de tortugas han llegado al centro, seguramentte por que se encontraban a la dreiva, pero resultan estar "aparentemente sana".

* Cabe mencionar además otras relaciones con números importantes, son las tortugas enredadas debido a plásticos abandonados en el mar, y tortugas que presentan traumatismos por choque con botes.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/causes_tile.png">
    <figcaption; style="font-size: 12px;" align="center">
    <i><strong>Figura 3</strong>. Este gráfico busca ver las relaciones entre las causas y subcausas de los varamientos de tortugas marinas.</i>
    </figcaption>
    <div style="clear: both"></div>      
  </div>
</div>
~~~


