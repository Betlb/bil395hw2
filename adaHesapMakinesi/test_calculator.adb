with Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Strings.Fixed;
use Ada.Text_IO;
use Ada.Float_Text_IO;
use Ada.Strings.Fixed;

procedure Test_Calculator is
   -- Test sonuçlarını tutmak için sayaçlar
   Total_Tests : Integer := 0;
   Passed_Tests : Integer := 0;
   Failed_Tests : Integer := 0;

   -- Test sonuçlarını yazdırmak için prosedür
   procedure Print_Test_Result(Test_Name : String; Passed : Boolean) is
   begin
      Total_Tests := Total_Tests + 1;
      if Passed then
         Passed_Tests := Passed_Tests + 1;
         Put_Line("✅ " & Test_Name & " - PASSED");
      else
         Failed_Tests := Failed_Tests + 1;
         Put_Line("❌ " & Test_Name & " - FAILED");
      end if;
   end Print_Test_Result;

   -- Test fonksiyonları
   function Test_Addition return Boolean is
      Result : Float;
   begin
      Result := 2.0 + 3.0;
      return abs(Result - 5.0) < 0.0001;
   end Test_Addition;

   function Test_Subtraction return Boolean is
      Result : Float;
   begin
      Result := 5.0 - 3.0;
      return abs(Result - 2.0) < 0.0001;
   end Test_Subtraction;

   function Test_Multiplication return Boolean is
      Result : Float;
   begin
      Result := 4.0 * 3.0;
      return abs(Result - 12.0) < 0.0001;
   end Test_Multiplication;

   function Test_Division return Boolean is
      Result : Float;
   begin
      Result := 10.0 / 2.0;
      return abs(Result - 5.0) < 0.0001;
   end Test_Division;

   function Test_Float_Operations return Boolean is
      Result : Float;
   begin
      Result := 3.14 + 2.86;
      return abs(Result - 6.0) < 0.0001;
   end Test_Float_Operations;

   function Test_Complex_Expression return Boolean is
      Result : Float;
   begin
      Result := (2.0 + 3.0) * 4.0;
      return abs(Result - 20.0) < 0.0001;
   end Test_Complex_Expression;

begin
   Put_Line("=== Ada Hesap Makinesi Test Sonuçları ===");
   New_Line;

   -- Testleri çalıştır
   Print_Test_Result("Toplama İşlemi", Test_Addition);
   Print_Test_Result("Çıkarma İşlemi", Test_Subtraction);
   Print_Test_Result("Çarpma İşlemi", Test_Multiplication);
   Print_Test_Result("Bölme İşlemi", Test_Division);
   Print_Test_Result("Ondalıklı Sayı İşlemleri", Test_Float_Operations);
   Print_Test_Result("Karmaşık İfadeler", Test_Complex_Expression);

   -- Test özeti
   New_Line;
   Put_Line("=== Test Özeti ===");
   Put_Line("Toplam Test: " & Integer'Image(Total_Tests));
   Put_Line("Başarılı: " & Integer'Image(Passed_Tests));
   Put_Line("Başarısız: " & Integer'Image(Failed_Tests));
   Put_Line("Başarı Oranı: " & 
            Integer'Image((Passed_Tests * 100) / Total_Tests) & "%");

end Test_Calculator; 