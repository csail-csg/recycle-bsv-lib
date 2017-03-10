### [GT](../../src/bsv/CompareProvisos.bsv#L28)
```bluespec
typeclass GT#(numeric type a, numeric type b);
endtypeclass

```

### [GT](../../src/bsv/CompareProvisos.bsv#L30)
```bluespec
instance GT#(a, b) provisos (Add#(_n, TAdd#(b,1), a));
endinstance


```

### [GTE](../../src/bsv/CompareProvisos.bsv#L34)
```bluespec
typeclass GTE#(numeric type a, numeric type b);
endtypeclass

```

### [GTE](../../src/bsv/CompareProvisos.bsv#L36)
```bluespec
instance GTE#(a, b) provisos (Add#(_n, b, a));
endinstance


```

### [LT](../../src/bsv/CompareProvisos.bsv#L40)
```bluespec
typeclass LT#(numeric type a, numeric type b);
endtypeclass

```

### [LT](../../src/bsv/CompareProvisos.bsv#L42)
```bluespec
instance LT#(a, b) provisos (Add#(_n, TAdd#(a,1), b));
endinstance


```

### [LTE](../../src/bsv/CompareProvisos.bsv#L46)
```bluespec
typeclass LTE#(numeric type a, numeric type b);
endtypeclass

```

### [LTE](../../src/bsv/CompareProvisos.bsv#L48)
```bluespec
instance LTE#(a, b) provisos (Add#(_n, a, b));
endinstance


```

### [EQ](../../src/bsv/CompareProvisos.bsv#L52)
```bluespec
typeclass EQ#(numeric type a, numeric type b);
endtypeclass

```

### [EQ](../../src/bsv/CompareProvisos.bsv#L54)
```bluespec
instance EQ#(a, b) provisos (Add#(0, a, b));
endinstance

```

