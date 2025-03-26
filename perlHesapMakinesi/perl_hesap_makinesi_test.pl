#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use Scalar::Util qw(looks_like_number);

# Test edilecek fonksiyon
sub safe_evaluate {
    my ($expression) = @_;
    
    # Boşlukları temizle
    $expression =~ s/\s+//g;  
    
    # Geçersiz karakterleri kontrol et
    if ($expression =~ /[^0-9+\-*\/().\^]/) {
        die "Hata: Geçersiz karakterler içeren ifade!\n";
    }
    
    # ^ operatörünü ** ile değiştir (Perl'de üs alma için)
    $expression =~ s/\^/**/g;
    
    # Güvenli eval ile hesaplama
    my $result = eval($expression);
    
    # Hata kontrolü
    if ($@) {
        die "Hesaplama hatası: $@\n";
    }
    
    # Sayı kontrolü
    unless (looks_like_number($result)) {
        die "Geçerli bir sonuç oluşturulamadı.\n";
    }
    
    return $result;
}

# Test senaryoları
sub run_tests {
    # Temel aritmetik işlem testleri
    is(safe_evaluate('2+2'), 4, 'Basit toplama işlemi');
    is(safe_evaluate('10-5'), 5, 'Basit çıkarma işlemi');
    is(safe_evaluate('3*4'), 12, 'Basit çarpma işlemi');
    is(safe_evaluate('20/4'), 5, 'Basit bölme işlemi');
    
    # Ondalık sayı testleri
    is(safe_evaluate('3.5+2.5'), 6, 'Ondalık toplama');
    is(safe_evaluate('10.5/2'), 5.25, 'Ondalık bölme');
    
    # Parantezli ifade testleri
    is(safe_evaluate('(2+3)*4'), 20, 'Parantezli çarpma');
    is(safe_evaluate('10/(2+3)'), 2, 'Parantezli bölme');
    
    # Karmaşık ifade testleri
    is(safe_evaluate('2+3*4'), 14, 'Karmaşık aritmetik 1');
    is(safe_evaluate('(2+3)*4-5'), 15, 'Karmaşık aritmetik 2');
    
    # Üs alma testleri
    is(safe_evaluate('2^3'), 8, 'Üs alma');
    is(safe_evaluate('3^2'), 9, 'Başka bir üs alma');
    
    # Negatif sayı testleri
    is(safe_evaluate('-5+3'), -2, 'Negatif sayı toplama');
    is(safe_evaluate('5*-2'), -10, 'Negatif sayı çarpma');
    
    # Sınır durumu testleri
    is(safe_evaluate('0*100'), 0, 'Sıfırla çarpma');
    is(safe_evaluate('1+0'), 1, 'Sıfır ekleme');
    
    # Hata durumu testleri
    eval {
        safe_evaluate('1/0');
        fail('Sıfıra bölme hatası yakalanmalı');
    };
    
    eval {
        safe_evaluate('abc+2');
        fail('Geçersiz ifade hatası yakalanmalı');
    };
    
    # Karmaşık üs alma ve parantez testleri
    is(safe_evaluate('2^(1+2)'), 8, 'Üs alma ve parantez karışımı');
    is(safe_evaluate('(2+1)^2'), 9, 'Parantezli üs alma');
}

# Testleri çalıştır
run_tests();

# Test sonuçlarını raporla
done_testing();