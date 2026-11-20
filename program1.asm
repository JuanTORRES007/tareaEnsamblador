.MODEL SMALL
.STACK 100h

.DATA
    msg1     DB 'Primer valor (00-FF): $'
    msg2     DB 13,10,'Segundo valor (00-FF): $'
    msg3     DB 13,10,'Operador (+ o -): $'
    msgRes   DB 13,10,'Resultado: $'
    msgAc    DB 13,10,'Acarreo/Prestamo (CF): $'
    msgErr   DB 13,10,'Entrada invalida.',13,10,'$'
    num1     DB ?
    num2     DB ?
    oper     DB ?
    resultado DB ?
    acarreo  DB 0

.CODE
inicio:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, msg1
    CALL imprimir
    CALL leerByteHex
    JC  errorEntrada
    MOV num1, AL

    LEA DX, msg2
    CALL imprimir
    CALL leerByteHex
    JC  errorEntrada
    MOV num2, AL

    LEA DX, msg3
    CALL imprimir
    MOV AH, 01h
    INT 21h
    MOV oper, AL

    MOV AL, num1
    MOV BL, num2
    CMP oper, '+'
    JE  suma
    CMP oper, '-'
    JE  resta
    JMP errorEntrada

suma:
    ADD AL, BL
    JMP guardar
resta:
    SUB AL, BL

guardar:
    MOV BH, 0
    JNC sinAcarreo
    MOV BH, 1
sinAcarreo:
    MOV resultado, AL
    MOV acarreo, BH

    LEA DX, msgRes
    CALL imprimir
    MOV AL, resultado
    CALL imprimirHexByte
    MOV DL, 'h'
    MOV AH, 02h
    INT 21h

    LEA DX, msgAc
    CALL imprimir
    MOV DL, acarreo
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    JMP fin

errorEntrada:
    LEA DX, msgErr
    CALL imprimir

fin:
    MOV AH, 4Ch
    INT 21h

; ---------- Procedimientos ----------

imprimir PROC
    MOV AH, 09h
    INT 21h
    RET
imprimir ENDP

; Lee dos caracteres hex y devuelve el byte en AL (CF=1 si hay error)
leerByteHex PROC
    PUSH BX
    PUSH CX
    MOV AH, 01h
    INT 21h
    CALL hexANibble
    JC  finLeer
    MOV BL, AL
    MOV CL, 4
    SHL BL, CL
    MOV AH, 01h
    INT 21h
    CALL hexANibble
    JC  finLeer
    OR  AL, BL
finLeer:
    POP CX
    POP BX
    RET
leerByteHex ENDP

; Convierte el caracter en AL a su valor 0-15 (CF=1 si no es hex)
hexANibble PROC
    CMP AL, '0'
    JB  noHex
    CMP AL, '9'
    JBE esDigito
    CMP AL, 'A'
    JB  noHex
    CMP AL, 'F'
    JBE esMayus
    CMP AL, 'a'
    JB  noHex
    CMP AL, 'f'
    JA  noHex
    SUB AL, 20h
esMayus:
    SUB AL, 37h
    CLC
    RET
esDigito:
    SUB AL, 30h
    CLC
    RET
noHex:
    STC
    RET
hexANibble ENDP

; Imprime el byte de AL como dos digitos hexadecimales
imprimirHexByte PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV DH, AL
    MOV DL, AL
    MOV CL, 4
    SHR DL, CL
    CALL imprimirNibble
    MOV DL, DH
    AND DL, 0Fh
    CALL imprimirNibble
    POP DX
    POP CX
    POP AX
    RET
imprimirHexByte ENDP

; Imprime el digito hexadecimal (0-15) que esta en DL
imprimirNibble PROC
    PUSH AX
    CMP DL, 9
    JBE nibDigito
    ADD DL, 37h
    JMP nibImp
nibDigito:
    ADD DL, 30h
nibImp:
    MOV AH, 02h
    INT 21h
    POP AX
    RET
imprimirNibble ENDP

END inicio