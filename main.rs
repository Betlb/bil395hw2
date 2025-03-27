use std::collections::HashMap;
use std::io::{self, Write};

#[derive(Debug, Clone)]
enum Token {
    Number(f64),
    Operator(char),
    Variable(String),
    LParen,
    RParen,
}

fn main() {
    let mut variables = HashMap::new();

    loop {
        print!("> ");
        io::stdout().flush().unwrap();

        let mut input = String::new();
        if io::stdin().read_line(&mut input).is_err() {
            println!("Girdi okunamadı.");
            continue;
        }

        let input = input.trim();
        if input == "exit" {
            break;
        }

        if input.contains('=') {
            let parts: Vec<&str> = input.splitn(2, '=').map(|s| s.trim()).collect();
            if parts.len() == 2 {
                let var_name = parts[0];
                match eval_expression(parts[1], &variables) {
                    Ok(result) => {
                        variables.insert(var_name.to_string(), result);
                        println!("{} = {}", var_name, result);
                    }
                    Err(e) => println!("Hata: {}", e),
                }
            } else {
                println!("Hata: Geçersiz atama.");
            }
        } else {
            match eval_expression(input, &variables) {
                Ok(result) => println!("{}", result),
                Err(e) => println!("Hata: {}", e),
            }
        }
    }
}

fn eval_expression(expr: &str, vars: &HashMap<String, f64>) -> Result<f64, String> {
    let tokens = tokenize(expr)?;
    let rpn = shunting_yard(&tokens)?;
    eval_rpn(&rpn, vars)
}

fn tokenize(expr: &str) -> Result<Vec<Token>, String> {
    let mut tokens = Vec::new();
    let mut chars = expr.chars().peekable();

    while let Some(&ch) = chars.peek() {
        match ch {
            ' ' => {
                chars.next();
            }
            '0'..='9' | '.' => {
                let mut num = String::new();
                while let Some(&c) = chars.peek() {
                    if c.is_numeric() || c == '.' {
                        num.push(c);
                        chars.next();
                    } else {
                        break;
                    }
                }
                let n = num.parse::<f64>().map_err(|_| "Geçersiz sayı")?;
                tokens.push(Token::Number(n));
            }
            '+' | '-' | '*' | '/' | '^' => {
                tokens.push(Token::Operator(ch));
                chars.next();
            }
            '(' => {
                tokens.push(Token::LParen);
                chars.next();
            }
            ')' => {
                tokens.push(Token::RParen);
                chars.next();
            }
            c if c.is_alphabetic() => {
                let mut var = String::new();
                while let Some(&c2) = chars.peek() {
                    if c2.is_alphanumeric() {
                        var.push(c2);
                        chars.next();
                    } else {
                        break;
                    }
                }
                tokens.push(Token::Variable(var));
            }
            _ => return Err(format!("Geçersiz karakter: {}", ch)),
        }
    }

    Ok(tokens)
}

fn shunting_yard(tokens: &[Token]) -> Result<Vec<Token>, String> {
    let mut output = Vec::new();
    let mut ops = Vec::new();

    let precedence = |op: &char| match op {
        '+' | '-' => 1,
        '*' | '/' => 2,
        '^' => 3,
        _ => 0,
    };

    let right_associative = |op: &char| *op == '^';

    for token in tokens {
        match token {
            Token::Number(_) | Token::Variable(_) => output.push(token.clone()),
            Token::Operator(op1) => {
                while let Some(Token::Operator(op2)) = ops.last() {
                    if (precedence(op1) < precedence(op2))
                        || (!right_associative(op1) && precedence(op1) == precedence(op2))
                    {
                        output.push(ops.pop().unwrap());
                    } else {
                        break;
                    }
                }
                ops.push(token.clone());
            }
            Token::LParen => ops.push(token.clone()),
            Token::RParen => {
                while let Some(top) = ops.pop() {
                    if matches!(top, Token::LParen) {
                        break;
                    } else {
                        output.push(top);
                    }
                }
            }
        }
    }

    while let Some(op) = ops.pop() {
        if matches!(op, Token::LParen | Token::RParen) {
            return Err("Parantez hatası".to_string());
        }
        output.push(op);
    }

    Ok(output)
}

fn eval_rpn(tokens: &[Token], vars: &HashMap<String, f64>) -> Result<f64, String> {
    let mut stack = Vec::new();

    for token in tokens {
        match token {
            Token::Number(n) => stack.push(*n),
            Token::Variable(name) => {
                if let Some(val) = vars.get(name) {
                    stack.push(*val);
                } else {
                    return Err(format!("Tanımsız değişken: {}", name));
                }
            }
            Token::Operator(op) => {
                if stack.len() < 2 {
                    return Err("Yetersiz operand".to_string());
                }
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                let result = match op {
                    '+' => a + b,
                    '-' => a - b,
                    '*' => a * b,
                    '/' => {
                        if b == 0.0 {
                            return Err("Sifira bolme hatasi".to_string());
                        }
                        a / b
                    }
                    '^' => a.powf(b),
                    _ => return Err("Bilinmeyen operator".to_string()),
                };
                stack.push(result);
            }
            _ => return Err("Gecersiz token RPN aşamasinda".to_string()),
        }
    }

    if stack.len() == 1 {
        Ok(stack.pop().unwrap())
    } else {
        Err("İfade cozulemedi".to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn vars_with(x: f64, y: f64) -> HashMap<String, f64> {
        let mut vars = HashMap::new();
        vars.insert("x".to_string(), x);
        vars.insert("y".to_string(), y);
        vars
    }

    #[test]
    fn test_simple_addition() {
        let vars = HashMap::new();
        let result = eval_expression("2 + 3", &vars);
        assert_eq!(result.unwrap(), 5.0);
    }

    #[test]
    fn test_operator_precedence() {
        let vars = HashMap::new();
        let result = eval_expression("2 + 3 * 4", &vars);
        assert_eq!(result.unwrap(), 14.0);
    }

    #[test]
    fn test_parentheses() {
        let vars = HashMap::new();
        let result = eval_expression("(2 + 3) * 4", &vars);
        assert_eq!(result.unwrap(), 20.0);
    }

    #[test]
    fn test_power_operator() {
        let vars = HashMap::new();
        let result = eval_expression("2 ^ 3", &vars);
        assert_eq!(result.unwrap(), 8.0);
    }

    #[test]
    fn test_variables() {
        let vars = vars_with(2.0, 3.0);
        let result = eval_expression("x + y", &vars);
        assert_eq!(result.unwrap(), 5.0);
    }

    #[test]
    fn test_variable_expression() {
        let vars = vars_with(5.0, 2.0);
        let result = eval_expression("x + y * 3", &vars);
        assert_eq!(result.unwrap(), 11.0);
    }

    #[test]
    fn test_divide_by_zero() {
        let vars = HashMap::new();
        let result = eval_expression("5 / 0", &vars);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Sifira bolme hatasi");
    }

    #[test]
    fn test_undefined_variable() {
        let vars = HashMap::new();
        let result = eval_expression("z + 1", &vars);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("Tanımsız değişken"));
    }

    #[test]
    fn test_unmatched_parentheses() {
        let vars = HashMap::new();
        let result = eval_expression("(2 + 3", &vars);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Parantez hatası");
    }
}



