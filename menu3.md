+++
title = "Estudio biométrico"
+++

# Estudio biométrico de las tortugas marinas

Las Islas Canarias es un lugar de paso para las tortugas marinas, habiendo principalmente individuos cuyo ciclo de vida se encuentra en la etapa juvenil.

El CRFS de la Tahonilla toma medidas biométricas de los especímenes varados en las costas. Toman principalmente medidas de 5 parámetros citados a continuación:


* Curvatura Recta del caparazón (CRC), en centímetros
* Curvatura Ancha del caparazón (CAC), en centímetros 
* Longitud Recta del Caparazón (LRC), en centímetros 
* Longitud Ancha del caparazón (LAC), en centímetros 
* Peso de la tortuga en kilogramos.

## Estimación del ciclo de vida de la tortuga a partir de la CRC

Algunos autores han estimado el estado del ciclo de vida de especies como *Caretta caretta* y *Chelonia mydas*, estimándola a partir de su CRC. 

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/C.caretta_biometry_age.png">
    <p>
    Descripción del gráfico: Para este estudio se han comprobado los datos de un total de 384 tortugas. Los individuos de tortugas marinas varadas en la costa de las Islas Canarias son principalmente juveniles. 
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

## Análisis Multivariante

Se raliza un modelo análisis de componentes principales (PCA) para estudiar la información de las variables en su conjunto.

Se usa:

* 70% de los datos como entrenamiento para entrenar al modelo.
* 30% restante serán los datos de test.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/PCA_biometry.png">
    <p>
    Descripción del gráfico: Al estudiar la varianza de los datos en un número reducido de dimensiones vemos que se forman grupos, los cuales nos dan información. 
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

* Componente Principal 1 (PC1): representa la mayoría de la varianza explicada, vemos que se ordenan en orden lógico según el ciclo de vida de las tortgas: cría, Juveniles pequeños y grandes y subadultos. No hay datos suficientes de adultos.


* Componente Principal 2 (PC2): explica la mayoría de la poca varianza restante, existe una diferencia entre los individuos subadultos y los juveniles. En cuanto a las crías, parecen estar la mayoría de los datos junto con los juveniles también, pero el tamaño muestral no es tan representativo como en el resto de grupos.