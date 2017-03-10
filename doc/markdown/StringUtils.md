# StringUtils

### splitStringAtComma
```bluespec
function Tuple2#(String, String) splitStringAtComma(String in);
    List#(Char) charList = stringToCharList(in);
    function Bool notComma(Char c);
        return c != ",";
    endfunction
    
```

### parseCSV
```bluespec
function List#(String) parseCSV(String inStr);
    String restOfString = inStr;
    List#(String) parsedResult = tagged Nil;
    while (restOfString != "") begin
        match {.newElement, .newRestOfString} = splitStringAtComma(restOfString);
        parsedResult = List::cons(newElement, parsedResult);
        restOfString = newRestOfString;
    end
    return reverse(parsedResult);
endfunction


```

### decStringToInteger
```bluespec
function Integer decStringToInteger(String inStr);
    List#(Char) inCharList = stringToCharList(inStr);
    // sanity check 1
    if (!List::all(isDigit, inCharList)) begin
        let x = error("decStringToInteger used on non decString string: " + doubleQuote(inStr));
    end
    // recursion helper function
    function Tuple2#(Integer, List#(Char)) decStringToIntegerHelper(Integer i, List#(Char) in);
        if (in == tagged Nil) begin
            return tuple2(i, in);
        end else begin
            return decStringToIntegerHelper(10*i + digitToInteger(head(in)), tail(in));
        end
    endfunction
    
```

### hexStringToInteger
```bluespec
function Integer hexStringToInteger(String inStr);
    List#(Char) inCharList = stringToCharList(inStr);
    // possibly chop off "0x"
    if (length(inCharList) >= 2) begin
        let firstTwoChars = charListToString(take(2, inCharList));
        if (firstTwoChars == "0x") begin
            inCharList = drop(2, inCharList);
        end
    end
    // sanity check 1
    if (!List::all(isHexDigit, inCharList)) begin
        let x = error("hexStringToInteger used on non hexString string: " + doubleQuote(inStr));
    end
    // recursion helper function
    function Tuple2#(Integer, List#(Char)) hexStringToIntegerHelper(Integer i, List#(Char) in);
        if (in == tagged Nil) begin
            return tuple2(i, in);
        end else begin
            return hexStringToIntegerHelper(16*i + hexDigitToInteger(head(in)), tail(in));
        end
    endfunction
    
```

### doubleQuotedToString
```bluespec
function String doubleQuotedToString(String inStr);
    List#(Char) inCharList = stringToCharList(inStr);
    // sanity check 1
    if ((head(inCharList) != "\"") || (last(inCharList) != "\"")) begin
        let x = error("doubleQuotedToString used on non-double-quoted string: " + inStr);
    end
    return charListToString(init(tail(inCharList)));
endfunction


```

