#lang racket

(require rackunit)

;; String ifadeyi matematiksel ifadeye dönüştür
(define (parse-expression expr)
  (let* 
      ;; ^ operatörünü expt ile değiştir
      ([modified-expr (string-replace expr "^" "expt")]
       
       ;; Matematiksel ifadeyi Racket ifadesine çevir
       [sexpr 
        (with-handlers 
            ([exn:fail? 
              (lambda (exn)
                (error "Geçersiz ifade"))])
          (read (open-input-string 
                 (string-append "(" modified-expr ")"))))])
    sexpr))

;; Güvenli ifade değerlendirme fonksiyonu
(define (safe-evaluate expression)
  (with-handlers
    ([exn:fail? 
      (lambda (exn)
        (error (format "Hesaplama hatası: ~a" (exn-message exn))))])
    
    ;; İfadeyi değerlendir
    (let* 
        ([parsed-expr (parse-expression expression)]
         [result (eval parsed-expr)])
      
      (if (number? result)
          result
          (error "Geçerli bir sonuç oluşturulamadı.")))))

;; Test senaryoları
(define (run-tests)
  (test-suite 
   "Hesap Makinesi Testleri"
   
   ;; Temel aritmetik işlem testleri
   (check-equal? (safe-evaluate "2+2") 4 "Basit toplama işlemi")
   (check-equal? (safe-evaluate "10-5") 5 "Basit çıkarma işlemi")
   (check-equal? (safe-evaluate "3*4") 12 "Basit çarpmaişlemi")
   (check-equal? (safe-evaluate "20/4") 5 "Basit bölme işlemi")
   
   ;; Ondalık sayı testleri
   (check-equal? (safe-evaluate "3.5+2.5") 6.0 "Ondalık toplama")
   (check-equal? (safe-evaluate "10.5/2") 5.25 "Ondalık bölme")
   
   ;; Parantezli ifade testleri
   (check-equal? (safe-evaluate "(2+3)*4") 20 "Parantezli çarpma")
   (check-equal? (safe-evaluate "10/(2+3)") 2 "Parantezli bölme")
   
   ;; Karmaşık ifade testleri
   (check-equal? (safe-evaluate "2+3*4") 14 "Karmaşık aritmetik 1")
   (check-equal? (safe-evaluate "(2+3)*4-5") 15 "Karmaşık aritmetik 2")
   
   ;; Üs alma testleri
   (check-equal? (safe-evaluate "2^3") 8 "Üs alma")
   (check-equal? (safe-evaluate "3^2") 9 "Başka bir üs alma")
   
   ;; Negatif sayı testleri
   (check-equal? (safe-evaluate "-5+3") -2 "Negatif sayı toplama")
   (check-equal? (safe-evaluate "5*-2") -10 "Negatif sayı çarpma")
   
   ;; Sınır durumu testleri
   (check-equal? (safe-evaluate "0*100") 0 "Sıfırla çarpma")
   (check-equal? (safe-evaluate "1+0") 1 "Sıfır ekleme")
   
   ;; Karmaşık üs alma ve parantez testleri
   (check-equal? (safe-evaluate "2^(1+2)") 8 "Üs alma ve parantez karışımı")
   (check-equal? (safe-evaluate "(2+1)^2") 9 "Parantezli üs alma")
   
   ;; Hata durumu testleri
   (check-exn exn:fail? (lambda () (safe-evaluate "1/0")) "Sıfıra bölme hatası")
   (check-exn exn:fail? (lambda () (safe-evaluate "abc+2")) "Geçersiz ifade hatası")
   ))

;; Hesap makinesi fonksiyonu
(define (calculator)
  (display "Matematiksel İfade Hesap Makinesi\n")
  (display "Örnek kullanım: 1 + 4 * (2-3)\n")
  (display "Çıkış için 'q' yazın.\n\n")
  
  (let loop ()
    (display "İfade girin: ")
    (let ([input (read-line)])
      (cond 
        [(string=? input "q") 
         (display "Hesap makinesinden çıkılıyor...\n")]
        [(string=? input "")
         (loop)]
        [else 
         (with-handlers
           ([exn:fail? 
             (lambda (exn)
               (display (exn-message exn))
               (newline))])
           (let ([result (safe-evaluate input)])
             (printf "Sonuç: ~a\n\n" result)))
         (loop)]))))

;; Testleri çalıştır
(run-tests)

;; Kullanıcı etkileşimi için hesap makinesini çalıştır
(calculator)