with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Hashed_Maps;
with Ada.Strings.Hash;
with Ada.Exceptions; use Ada.Exceptions;

procedure Calculator is

   package String_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => Unbounded_String,
      Element_Type    => Float,
      Hash            => Ada.Strings.Hash,
      Equivalent_Keys => "=");

   use String_Maps;
   Vars : Map;

   function Get_Token(Expr : String; Pos : in out Natural) return String;
   function Parse_Expr(Expr : String; Pos : in out Natural) return Float;
   function Parse_Term(Expr : String; Pos : in out Natural) return Float;
   function Parse_Factor(Expr : String; Pos : in out Natural) return Float;
   function Evaluate(Expression : String) return Float;

   function Get_Token(Expr : String; Pos : in out Natural) return String is
      Token : String (1 .. 100);
      TLen  : Natural := 0;
   begin
      while Pos <= Expr'Length and then Expr(Pos) = ' ' loop
         Pos := Pos + 1;
      end loop;

      while Pos <= Expr'Length and then
         (Expr(Pos) in '0' .. '9' or Expr(Pos) = '.' or
          Expr(Pos) in 'a' .. 'z' | 'A' .. 'Z')
      loop
         TLen := TLen + 1;
         Token(TLen) := Expr(Pos);
         Pos := Pos + 1;
      end loop;

      return Token(1 .. TLen);
   end Get_Token;

   function Parse_Expr(Expr : String; Pos : in out Natural) return Float is
      Result : Float := Parse_Term(Expr, Pos);
   begin
      while Pos <= Expr'Length loop
         if Expr(Pos) = '+' then
            Pos := Pos + 1;
            Result := Result + Parse_Term(Expr, Pos);
         elsif Expr(Pos) = '-' then
            Pos := Pos + 1;
            Result := Result - Parse_Term(Expr, Pos);
         else
            exit;
         end if;
      end loop;
      return Result;
   end Parse_Expr;

   function Parse_Term(Expr : String; Pos : in out Natural) return Float is
      Result : Float := Parse_Factor(Expr, Pos);
   begin
      while Pos <= Expr'Length loop
         if Expr(Pos) = '*' then
            Pos := Pos + 1;
            Result := Result * Parse_Factor(Expr, Pos);
         elsif Expr(Pos) = '/' then
            Pos := Pos + 1;
            declare
               Denom : Float := Parse_Factor(Expr, Pos);
            begin
               if Denom = 0.0 then
                  raise Constraint_Error with "Sıfıra bölme hatası";
               end if;
               Result := Result / Denom;
            end;
         else
            exit;
         end if;
      end loop;
      return Result;
   end Parse_Term;

   function Parse_Factor(Expr : String; Pos : in out Natural) return Float is
      Result : Float;
   begin
      while Pos <= Expr'Length and then Expr(Pos) = ' ' loop
         Pos := Pos + 1;
      end loop;

      if Expr(Pos) = '(' then
         Pos := Pos + 1;
         Result := Parse_Expr(Expr, Pos);
         if Expr(Pos) = ')' then
            Pos := Pos + 1;
         else
            raise Constraint_Error with "Parantez hatası";
         end if;

      elsif Expr(Pos) in '0' .. '9' then
         declare
            Num_Str : String := Get_Token(Expr, Pos);
         begin
            Result := Float'Value(Num_Str);
         end;

      elsif Expr(Pos) in 'a' .. 'z' | 'A' .. 'Z' then
         declare
            Name_Str : String := Get_Token(Expr, Pos);
            Name     : Unbounded_String := To_Unbounded_String(Name_Str);
         begin
            if Vars.Contains(Name) then
               Result := Vars.Element(Name);
            else
               raise Constraint_Error with "Tanımsız değişken: " & Name_Str;
            end if;
         end;

      else
         raise Constraint_Error with "Geçersiz ifade";
      end if;

      while Pos <= Expr'Length and then Expr(Pos) = '^' loop
         Pos := Pos + 1;
         declare
            Exp : Float := Parse_Factor(Expr, Pos);
         begin
            Result := Result ** Exp;
         end;
      end loop;

      return Result;
   end Parse_Factor;

   function Evaluate(Expression : String) return Float is
      Pos : Natural := Expression'First;
   begin
      return Parse_Expr(Expression, Pos);
   end Evaluate;

   Input : String (1 .. 200);
   Last  : Natural;

begin
   Put_Line("Ada Hesap Makinesi. Çıkmak için 'exit' yazın.");
   loop
      Put("> ");
      Get_Line(Input, Last);
      declare
         Line : constant String := Input(1 .. Last);
      begin
         exit when Line = "exit";

         if Line'Length > 0 and then '=' in Line then
            declare
               Eq_Pos : Natural := Index(Line, "=");
               Name   : Unbounded_String := To_Unbounded_String(Line(1 .. Eq_Pos - 1));
               Expr   : String := Line(Eq_Pos + 1 .. Line'Last);
               Val    : Float;
            begin
               Val := Evaluate(Expr);
               Vars.Include(Name, Val);
               Put_Line(To_String(Name) & " = " & Float'Image(Val));
            exception
               when E : others => Put_Line("Hata: " & Exception_Message(E));
            end;

         else
            declare
               Val : Float := Evaluate(Line);
            begin
               Put_Line("= " & Float'Image(Val));
            exception
               when E : others => Put_Line("Hata: " & Exception_Message(E));
            end;
         end if;
      end;
   end loop;
end Calculator;
