# Prolog Hesap Makinesi

Bu hesap makinesi, temel aritmetik işlemleri ve değişken tanımlamayı destekleyen bir Prolog programıdır.

## Özellikler

✅ Float ve int değerleri için hesaplama desteği
✅ Aritmetik işlemler: `+`, `-`, `*`, `/`, `^`  
✅ Liste tabanlı ifade desteği: `[*, [+, 2, 3], 4]`  
✅ Değişken tanımlama: `set_variable(x, 5)`, `set_variable(y, 2)`  
✅ Tanımsız değişken ve sıfıra bölme hatası yönetimi  
✅ Basit hata mesajları

## Kullanım

Programı çalıştırmak için bir Prolog yorumlayıcısı gereklidir (örneğin SWI-Prolog).

```bash
swipl calculator.pl
```

### Örnek Kullanımlar

1. Basit hesaplamalar:
```prolog
?- [+, 2, 3].
5
?- [*, 4, 5].
20
```

2. İç içe işlemler:
```prolog
?- [*, [+, 2, 3], 4].
20
```

3. Değişken tanımlama ve kullanma:
```prolog
?- set_variable(x, 5).
x = 5
?- set_variable(y, 2).
y = 2
?- [+, x, y].
7
```

4. Üs alma:
```prolog
?- [^, 2, 3].
8
```

5. Hata durumları:
```prolog
?- [/, 5, 0].
Error: Division by zero
?- [+, x, z].
Error: Undefined variable
```

## Çıkış

Programdan çıkmak için `exit.` yazın. 