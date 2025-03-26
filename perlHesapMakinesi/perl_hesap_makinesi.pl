#!/usr/bin/perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

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

# Ana hesap makinesi fonksiyonu
sub calculator {
    print "Matematiksel İfade Hesap Makinesi\n";
    print "Örnek kullanım: 1 + 4 * (2-3)\n";
    print "Çıkış için 'q' yazın.\n\n";
    
    while (1) {
        print "İfade girin: ";
        my $input = <STDIN>;
        chomp $input;
        
        # Çıkış kontrolü
        last if $input eq 'q';
        
        # Boş girdi kontrolü
        next if $input =~ /^\s*$/;
        
        eval {
            my $result = safe_evaluate($input);
            printf "Sonuç: %.4f\n\n", $result;
        };
        
        # Hata yakalama
        if ($@) {
            print $@;
        }
    }
    
    print "Hesap makinesinden çıkılıyor...\n";
}

# Hesap makinesini çalıştır
calculator() unless caller;