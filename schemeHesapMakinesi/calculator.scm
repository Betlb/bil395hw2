;; Scheme Hesap Makinesi
;; Aritmetik işlemler, değişken tanımlama ve hata yönetimi destekli

;; Gerekli modülleri içe aktar
(use-modules (ice-9 rdelim))  ;; read-line için

;; Değişkenleri saklamak için ortam (environment) tanımlama
(define environment (make-hash-table))

;; Hata mesajları görüntüleme
(define (display-error message)
  (display "Hata: ")
  (display message)
  (newline)
  #f)

;; İşlemleri değerlendirme
(define (evaluate expr)
  (cond
    ;; Sayı ise direkt döndür
    ((number? expr) expr)
    
    ;; Sembol (değişken) ise değerini bul
    ((symbol? expr)
     (let ((value (hash-ref environment expr (lambda () #f))))
       (if value
           value
           (display-error "Tanımsız değişken"))))
    
    ;; Liste (işlem) ise işlemi değerlendir
    ((pair? expr)
     (let ((operator (car expr))
           (operands (cdr expr)))
       (cond
         ;; Değişken tanımlama
         ((eq? operator 'set!)
          (if (= (length operands) 2)
              (let ((var (car operands))
                    (val (evaluate (cadr operands))))
                (if val ; Eğer değerlendirme başarılı ise
                    (begin
                      (hash-set! environment var val)
                      (display var)
                      (display " = ")
                      (display val)
                      (newline)
                      val)
                    #f)) ; Değerlendirme başarısız ise
              (display-error "set! için iki argüman gerekli: (set! var değer)")))
         
         ;; Aritmetik işlemler
         (else
          (let ((proc (case operator
                        ((+) +)
                        ((-) -)
                        ((*) *)
                        ((/) /)
                        ((^) expt)
                        (else (display-error "Geçersiz işlem")))))
            (if proc
                (let ((args (map evaluate operands)))
                  (if (member #f args)
                      #f ; Bir argüman değerlendirmesi başarısız olursa
                      (if (and (eq? operator '/) (= (cadr args) 0))
                          (display-error "Sıfıra bölme")
                          (apply proc args))))
                #f))))))
    
    ;; Diğer durumlar
    (else (display-error "Geçersiz ifade"))))

;; Kullanıcı girdisini işleme
(define (process-input input)
  (if (string=? input "exit")
      'exit
      (let ((expr (false-if-exception (read (open-input-string input)))))
        (if expr
            (evaluate expr)
            (display-error "Geçersiz ifade formatı")))))

;; Ana döngü
(define (calculator-loop)
  (display "Scheme Hesap Makinesi (Çıkış için 'exit' yazın)")
  (newline)
  (display "Örnekler:")
  (newline)
  (display "  Toplama: (+ 2 3)")
  (newline)
  (display "  Çıkarma: (- 5 2)")
  (newline)
  (display "  Çarpma: (* 4 3)")
  (newline)
  (display "  Bölme: (/ 10 2)")
  (newline)
  (display "  Üs alma: (^ 2 3)")
  (newline)
  (display "  Değişken tanımlama: (set! x 5)")
  (newline)
  (display "  Değişken kullanma: (+ x 3)")
  (newline)
  (display "  Parantezli işlemler: (* (+ 2 3) 4)")
  (newline)
  (let loop ()
    (display "> ")
    (force-output)
    (let ((input (false-if-exception (read-delimited "\n"))))
      (if (or (eof-object? input) (string=? input "exit"))
          (display "Hesap makinesi kapatılıyor...\n")
          (begin
            (let ((result (process-input input)))
              (when (and result (not (eq? result 'exit)))
                (display result)
                (newline)))
            (loop))))))

;; Hesap makinesini başlat
(calculator-loop) 