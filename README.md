# IA

Notas Algoritmo Evolutivo:


Ruleta: Todos tienen chance. Individuos malos igual pueden ser elegidos (raramente). Más diversidad, converge más lento.

Torneo: Solo compiten K individuos. Más agresivo. Converge más rápido pero puede perder diversidad si K es alto.

---

Cruzamiento: El hijo siempre queda entre los dos padres. No puede explorar fuera de su rango. Por eso existe la mutación.

Mutación: randomGaussian() da valores cercanos a 0 la mayoría del tiempo - saltos pequeños frecuentes, saltos grandes raros.

---

Para mas exploración subir MUT_RANGO y bajar K
Para que converja más rapido suber N y K
Para comparar selección cambia RULETA entre true y false (con T)