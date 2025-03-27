with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Calculator is
   function Is_Operator (Ch : Character) return Boolean is
   begin
      return Ch in '+' | '-' | '*' | '/' | '^';
   end Is_Operator;
   
   function Get_Variable_Value 
     (Name : String; 
      Variables : in out String_Vectors.Vector) return Float is
      I : Natural := 0;
   begin
      while I < Natural(Variables.Length) - 1 loop
         if To_String(Variables.Element(I)) = Name then
            return Float'Value(To_String(Variables.Element(I+1)));
         end if;
         I := I + 2;
      end loop;
      raise Undefined_Variable;
   end Get_Variable_Value;

   procedure Set_Variable 
     (Name : String; 
      Value : String;
      Variables : in out String_Vectors.Vector) is
      I : Natural := 0;
      Found : Boolean := False;
   begin
      while I < Natural(Variables.Length) - 1 loop
         if To_String(Variables.Element(I)) = Name then
            Variables.Replace_Element(I+1, To_Unbounded_String(Value));
            Found := True;
            exit;
         end if;
         I := I + 2;
      end loop;

      if not Found then
         Variables.Append(To_Unbounded_String(Name));
         Variables.Append(To_Unbounded_String(Value));
      end if;
   end Set_Variable;
   
   function Calculate (Left, Right : Float; Op : Character) return Float is
   begin
      case Op is
         when '+' => return Left + Right;
         when '-' => return Left - Right;
         when '*' => return Left * Right;
         when '/' => return Left / Right;  -- Ada'nın yerleşik kontrolü kullanılacak
         when '^' => return Float'(Left ** Natural(Right));
         when others => raise Constraint_Error;
      end case;
   end Calculate;

   function Evaluate_Expression 
     (Expr : String; 
      Variables : in out String_Vectors.Vector) return Float is
      Tokens : String_Vectors.Vector;
   begin
      -- Clear previous tokens
      Tokens.Clear;

      -- Tokenization
      declare
         I : Positive := Expr'First;
      begin
         while I <= Expr'Last loop
            -- Skip whitespace
            if Expr(I) = ' ' then
               I := I + 1;
               goto Continue;
            end if;
            
            -- Handle operators
            if Is_Operator(Expr(I)) then
               Tokens.Append(To_Unbounded_String(Expr(I..I)));
               
            -- Handle numbers (including negative numbers)
            elsif Expr(I) in '0'..'9' or Expr(I) = '.' or 
                  (Expr(I) = '-' and (I = Expr'First or Is_Operator(Expr(I-1)) or Expr(I-1) = '(')) then
               -- Number token
               declare
                  Start : constant Positive := I;
                  Finish : Positive := I;
                  Is_Negative : constant Boolean := Expr(I) = '-';
               begin
                  -- Move past negative sign if present
                  if Is_Negative then
                     I := I + 1;
                     Finish := I;
                  end if;
                  
                  -- Find end of number
                  while Finish < Expr'Last and then 
                        (Expr(Finish+1) in '0'..'9' or Expr(Finish+1) = '.') loop
                     Finish := Finish + 1;
                  end loop;
                  
                  Tokens.Append(To_Unbounded_String(Expr(Start..Finish)));
                  I := Finish;
               end;
               
            -- Handle parentheses
            elsif Expr(I) in '(' | ')' then
               Tokens.Append(To_Unbounded_String(Expr(I..I)));
               
            -- Handle variables
            elsif Expr(I) in 'a'..'z' or Expr(I) in 'A'..'Z' then
               -- Variable token
               declare
                  Start : constant Positive := I;
                  Finish : Positive := I;
               begin
                  while Finish < Expr'Last and then 
                        (Expr(Finish+1) in 'a'..'z' or Expr(Finish+1) in 'A'..'Z') loop
                     Finish := Finish + 1;
                  end loop;
                  
                  -- Get variable value
                  declare
                     Var_Name : constant String := Expr(Start..Finish);
                     Var_Value : constant Float := Get_Variable_Value(Var_Name, Variables);
                  begin
                     Tokens.Append(To_Unbounded_String(Float'Image(Var_Value)));
                  end;
                  
                  I := Finish;
               end;
            end if;
            
            I := I + 1;
            <<Continue>>
         end loop;
      end;
      
      -- Calculation
      declare
         Result : Float := 0.0;
         Last_Operator : Character := '+';  -- Default to addition
         Token_Count : constant Natural := Natural(Tokens.Length);
      begin
         -- Ensure there are tokens to process
         if Token_Count = 0 then
            return 0.0;
         end if;

         -- Iterate through tokens with explicit index calculation
         for I in 1 .. Token_Count loop
            -- Adjust index to 0-based for vector access
            declare
               Token_Str : constant String := To_String(Tokens.Element(I-1));
            begin
               -- Check if token is an operator
               if Is_Operator(Token_Str(1)) and Token_Str'Length = 1 then
                  Last_Operator := Token_Str(1);
               
               -- Check if token is a number
               elsif Token_Str(1) in '0'..'9' or Token_Str(1) = '.' or 
                     (Token_Str(1) = '-' and Token_Str'Length > 1) then
                  declare
                     Val : constant Float := Float'Value(Token_Str);
                  begin
                     -- Perform calculation based on last operator
                     case Last_Operator is
                        when '+' => Result := Result + Val;
                        when '-' => Result := Result - Val;
                        when '*' => Result := Result * Val;
                        when '/' => Result := Result / Val;  -- Ada'nın yerleşik kontrolü kullanılacak
                        when '^' => Result := Result ** Natural(Val);
                        when others => Result := Val;  -- First number or unexpected case
                     end case;
                  end;
               end if;
            end;
         end loop;
         
         return Result;
      end;
   end Evaluate_Expression;

   procedure Run is
   begin
      Put_Line("Hesap Makinesi");
      Put_Line("Çıkış için 'q' yazın");
      
      declare
         Input : String(1..100);
         Last : Natural;
         Variables : String_Vectors.Vector;
      begin
         loop
            Put("> ");
            Get_Line(Input, Last);
            
            exit when Last > 0 and then Input(1) = 'q';
            
            begin
               declare
                  Result : constant Float := Evaluate_Expression(Input(1..Last), Variables);
               begin
                  Put("Sonuç: ");
                  Ada.Float_Text_IO.Put(Result, Fore => 1, Aft => 2, Exp => 0);
                  New_Line;
               end;
            exception
               when Constraint_Error =>
                  Put_Line("Hata: Sıfıra bölme");
               when Undefined_Variable =>
                  Put_Line("Hata: Tanımsız değişken");
               when others =>
                  Put_Line("Hata: Geçersiz ifade");
            end;
         end loop;
      end;
   end Run;
end Calculator;