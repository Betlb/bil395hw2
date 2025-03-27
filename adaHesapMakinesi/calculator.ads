with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

package Calculator is
   package Float_Vectors is new Ada.Containers.Vectors
     (Index_Type => Natural, Element_Type => Float);
   
   package String_Vectors is new Ada.Containers.Vectors
     (Index_Type => Natural, Element_Type => Unbounded_String);

   -- Hata yönetimi için özel istisna tanımlamaları
   Undefined_Variable : exception;
   
   function Evaluate_Expression 
     (Expr : String; 
      Variables : in out String_Vectors.Vector) return Float;
   procedure Set_Variable 
     (Name : String; 
      Value : String;
      Variables : in out String_Vectors.Vector);
   procedure Run;
private
   function Is_Operator (Ch : Character) return Boolean;
   function Get_Variable_Value 
     (Name : String; 
      Variables : in out String_Vectors.Vector) return Float;
   function Calculate (Left, Right : Float; Op : Character) return Float;
end Calculator;