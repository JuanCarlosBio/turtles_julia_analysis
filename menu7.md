+++
title = "Localización"
hascode = true
date = Date(2019, 3, 22)
tags = ["syntax", "code"]
+++

# **Observaciones**

Observaciones de los trabajadores del CRFS La Tahonilla de las tortugas.

Se ha usado un algorítmo escrito en R, con el objetivo de analizar los datos pertenecientes a un campo de la base de datos, en el cual los trabajadores de la Tahonilla intentan explicar cómo se encuentra la toprtuga al llegar al centro.

Algorítmo de R:

```
## R parse function:
R"""
selec <-data_tortugas_tfg.xlsxselec <-function(ord,lista_tokens,var) {
  paste(lista_tokens[-ord],collapse="|")
  if(!is.na(ord)) return(grepl(lista_tokens[ord],tolower(var)) & !grepl(paste(lista_tokens[-ord],collapse="|"),tolower(var)))
  else return(grepl(paste(lista_tokens,collapse="|"),tolower(var)))
}
"""
```

A partir de este algrítmo se pretende extraer la información:

1. Lesiones de las tortugas.
2. Parte del cuerpo lesionada.
3. Estado en el que llega al centro.

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/injury_body.png">
    <p>
    Descripción del gráfico: Comparación entre las observacioes de las lesiones frente a la localización del cuerpo afectada.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/state_body.png">
    <p>
    Descripción del gráfico: Comparación entre las observacioes del estado en el que las tortugas llegan al centro, frente a la localización del cuerpo afectada.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~

~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/figures/plots/state_injury.png">
    <p>
    Descripción del gráfico: Comparación entre las observacioes del estado en el que las tortugas llegan al centro, frente al tipo de lesión.
    </p>
    <div style="clear: both"></div>      
  </div>
</div>
~~~
