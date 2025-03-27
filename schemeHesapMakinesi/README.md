# Scheme Hesap Makinesi

Bu hesap makinesi, temel aritmetik işlemleri ve değişken tanımlamayı destekleyen bir Scheme programıdır.

## Özellikler

✅ Float ve int değerleri için hesaplama desteği
✅ Aritmetik işlemler: `+`, `-`, `*`, `/`, `^`  
✅ Parantez desteği: `(* (+ 2 3) 4)`  
✅ Değişken tanımlama: `(set! x 5)`, `(set! y 2)`  
✅ Tanımsız değişken ve sıfıra bölme hatası yönetimi  
✅ Basit hata mesajları

## Kullanım

Programı çalıştırmak için bir Scheme yorumlayıcısı gereklidir (örneğin Guile, Racket, Chicken Scheme vb.)

```bash
guile calculator.scm
```

veya 

```bash
racket calculator.scm
```

### Örnek Kullanımlar

1. Basit hesaplamalar:
```scheme
> (+ 2 3)
5
> (* 4 5)
20
```

2. Parantezli işlemler:
```scheme
> (* (+ 2 3) 4)
20
```

3. Değişken tanımlama ve kullanma:
```scheme
> (set! x 5)
x = 5
> (set! y 2)
y = 2
> (+ x y)
7
```

4. Üs alma:
```scheme
> (^ 2 3)
8
```

5. Hata durumları:
```scheme
> (/ 5 0)
Hata: Sıfıra bölme
> (+ x z)
Hata: Tanımsız değişken
```

## Çıkış

Programdan çıkmak için `exit` yazın. 