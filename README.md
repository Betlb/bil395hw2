# HesapMakineleri 🧮

Bu proje, 5 farklı programlama dili kullanılarak geliştirilmiş basit bir komut satırı hesap makinesidir. 

## Özellikler

✅ Float ve int değerleri için hesaplama desteği
✅ Aritmetik işlemler: `+`, `-`, `*`, `/`, `^`  
✅ Parantez desteği: `(2 + 3) * 4`  
✅ Değişken tanımlama: `x = 5`, `y = 2`  
✅ Tanımsız değişken ve sıfıra bölme hatası yönetimi  
✅ Basit hata mesajları


### ▶️ Çalıştırma

```bash
#### 1-Rust rustHesapMakinesi/src directorysinde
cargo run
### ✅ Test Çalıştırma
cargo test

#### 2-Perl perlHesapMakinesi directorysinde
perl perl_hesap_makinesi.pl
### ✅ Test Çalıştırma
perl perl_hesap_makinesi_test.pl

#### 3-Ada adaHesapMakinesi directorysinde
# Tüm dosyaları derle
gnatmake calculator.ads
gnatmake calculator.adb
gnatmake main.adb

# Hesap makinesini çalıştır
./main
#test dosyasını çalıştır
./test_calculator
#### 4-Scheme schemeHesapMakinesi directorysinde
# Hesap makinesini çalıştır
guile scheme_hesap_makinesi.scm

### ✅ Test Çalıştırma
guile scheme_hesap_makinesi_test.scm

#### 5-Prolog prologHesapMakinesi directorysinde
# Hesap makinesini çalıştır
swipl calculator.pl
