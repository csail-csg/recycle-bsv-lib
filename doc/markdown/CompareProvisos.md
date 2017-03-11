# CompareProvisos


This package is a collection of human readable provisos for comparing
values of numeric types. For example, the standard proviso for `a > b`
is the following:

```
Add#(_n, TAdd#(b,1), a)
```

This package introduces human readable typeclasses that can be used as
provisos. The `GT` typeclass can be used to rewrite the above proviso as
the following:

```
GT#(a, b)
```


### [GT](../../src/bsv/CompareProvisos.bsv#L44)
```bluespec
typeclass GT#(numeric type a, numeric type b);
endtypeclass

```

### [GT](../../src/bsv/CompareProvisos.bsv#L46)
```bluespec
instance GT#(a, b) provisos (Add#(_n, TAdd#(b,1), a));
endinstance


```

### [GTE](../../src/bsv/CompareProvisos.bsv#L50)
```bluespec
typeclass GTE#(numeric type a, numeric type b);
endtypeclass

```

### [GTE](../../src/bsv/CompareProvisos.bsv#L52)
```bluespec
instance GTE#(a, b) provisos (Add#(_n, b, a));
endinstance


```

### [LT](../../src/bsv/CompareProvisos.bsv#L56)
```bluespec
typeclass LT#(numeric type a, numeric type b);
endtypeclass

```

### [LT](../../src/bsv/CompareProvisos.bsv#L58)
```bluespec
instance LT#(a, b) provisos (Add#(_n, TAdd#(a,1), b));
endinstance


```

### [LTE](../../src/bsv/CompareProvisos.bsv#L62)
```bluespec
typeclass LTE#(numeric type a, numeric type b);
endtypeclass

```

### [LTE](../../src/bsv/CompareProvisos.bsv#L64)
```bluespec
instance LTE#(a, b) provisos (Add#(_n, a, b));
endinstance


```

### [EQ](../../src/bsv/CompareProvisos.bsv#L68)
```bluespec
typeclass EQ#(numeric type a, numeric type b);
endtypeclass

```

### [EQ](../../src/bsv/CompareProvisos.bsv#L70)
```bluespec
instance EQ#(a, b) provisos (Add#(0, a, b));
endinstance


```

