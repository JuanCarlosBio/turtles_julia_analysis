+++
title = "Estudio biométrico"
+++

# **Estudio biométrico de las tortugas marinas**

Las Islas Canarias es un lugar de paso para las tortugas marinas, habiendo principalmente individuos cuyo ciclo de vida se encuentra en la etapa juvenil.

El CRFS de la Tahonilla toma medidas biométricas estandarizadas de los ejemplares varados en las costas. En la base de datos estudiada, se pueden ver 5 parámetros anotados:

* Largo curvo del caparazón (*LCC*) en cm.
* Largo recto del caparazón (*LRC*) en cm.
* Ancho curvo del Caparazón (*ACC*) en cm.
* Ancho recto del caparazón (*ARC*) en cm.
* Peso de la tortuga en kilogramos.

## Estimación del ciclo de vida de la tortuga a partir de la LCC

Según el *"PROTOCOLO DE ACTUACIÓN FRENTE A VARAMIENTOS DE TORTUGAS MARINAS EN CANARIAS"*, redactado por el Gobierno de Canarias, las tortugas marinas no presentan caracteres morfológicos que indiquen su edad, pero su tamaño es un indicador de la fase del ciclo de vida en la que se encuentran. 

La medida más comúnmente utilizada por la comunidad científica y grupos de conservación es el *LCC*, siendo el la longitud curva del caparazón estándar (*LCCst*) la medida de referencia a nivel internacional. 

~~~<u>Estado del ciclo de vida de las tortugas segun su <i>LCC:</i></u>~~~ 

* *LCC* menor a 20 cm son crías.
* *LCC* entre 20 y 40 cm son juveniles pequeños.
* *LCC* entre 40 y 60 cm son juveniles grandes.
* *LCC* entre 60 y 80 cm son subadultas.
* *LCC* mayor a 80 cm son adultas.

Por ello, para este estudio, se calculará el ciclo de vida en el que se la tortuga boba (ya que es la más representada) según los datos del *LCC*. En concreto se presentan datos para 384 ejemplares.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/C.caretta_biometry_age.png">
    <p style="font-size: 14px" align="center">
   <strong><i>Figura 1.</strong> Análsis del LCC de las tortugas.</i>
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

Como era esperable los individuos de tortugas marinas varadas en las costas de Tenerife son principalmente juveniles. 

## Análisis Multivariante

Para ver si esta medida es útil para agrupar grupos de tortugas, se raliza un modelo análisis de componentes principales (PCA) para estudiar la información de todas las variables biométricos, en un análisis multivariante.

Para el modelo, un 70% de los datos serán usados como entrenamiento, mientras que el 30% de los tados serán para el test.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/PCA_biometry.png">
    <p style="font-size: 14px" align="center">
   <strong><i>Figura 2.</strong> Análsis multivariante (PCA) de las variables biométricas.</i>
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

~~~<u>Interpretación de los resultados del PCA:</u>~~~

* Componente Principal 1 (PC1): representa la mayoría de la varianza explicada, vemos que se ordenan en orden lógico según el ciclo de vida de las tortgas: cría, Juveniles pequeños y grandes y subadultos. No hay datos suficientes de adultos.

* Componente Principal 2 (PC2): explica la mayoría de la poca varianza restante, existe una diferencia entre los individuos subadultos y los juveniles. En cuanto a las crías, parecen estar la mayoría de los datos junto con los juveniles también.