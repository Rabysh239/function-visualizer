uses GraphABC;


type
  Real = double;


const
  prs = '(+-*/^scla'; // символы операций 
  pri: array [1 .. 10] of byte = (0, 1, 1, 2, 2, 3, 4, 4, 4, 4); // приоритеты операций (соответственно строке символов)
  fn: array[1..4] of string = ('sin','cos','ln','abs'); // полное написание унарных операций


var
  s1, s2, stt: String; // вспомогательные переменные
  q: array [0 .. 500] of Real; // массив для организации стека чисел
  w: array [0 .. 500] of Char; // массив для огранизации стека операций
  n, len, len2: Cardinal; // вспомогательные переменные


procedure Push(x: Real); // добавление числа в стек
begin
  Inc(len);
  q[len] := x;
end;


function Pop: Real;// вывод числа из стека
begin
  Pop := q[len];
  q[len] := 0;
  Dec(len);
end;


procedure PushC(x: Char); // добавление опреации в стек
begin
  Inc(len2);
  w[len2] := x;
end;


function Popc: Char; // вывод операции из стека
begin
  Popc := w[len2];
  w[len2] := #0;
  Dec(len2);
end;


// обработка арифметических операций (на входе два числа и символ операции, на выходе результат операции. В унарном случае используется только второе число)
function Oper(s1, s2: Real; s3: Char): Real;
var
  x, y, z: Real;
begin
  x := s1;
  y := s2;
  case s3 of
    '+': z := x + y;
    '-': z := x - y;
    '*': z := x * y;
    '/': z := x / y;
    '^': z := power(x,y);
    's': z := sin(y);
    'c': z := cos(y);
    'l': z := ln(y);
    'a': z := abs(y);
  end;
  Oper := z;
end;


// добавление нуля для обработки унарного минуса
procedure PreChange(var s: String);
var
  i: integer;
begin
  if s[1] in ['-'] then s := '0' + s;
  
  i := 1;
  while i <= n do
    if (s[i] = '(') and (s[i+1] in ['-']) then insert('0', s, i + 1) else Inc(i);
end;


// перевод в обратную польскую запись (алгоритм сортировочной станции)
function Change(s: String): String;
var
  rezs: String;
  c: Boolean;
begin
  c := false;
  for var i := 1 to n do
    begin
      if not(s[i] in ['+', '-', '*', '/', '(', ')','^','s','c','l','a']) then
      begin
        if c then
          rezs := rezs + ' ';
        rezs := rezs + s[i];
        c := false;
      end
      else
      begin
        c := true;
        if s[i] = '(' then
          PushC(s[i])
        else
        if s[i] = ')' then
        begin
          while w[len2] <> '(' do
          begin
            rezs := rezs + ' ' + Popc;
          end;
          Popc;
        end
        else
        if s[i] in ['+', '-', '*', '/','^','s','c','l','a'] then
        begin
          while pri[Pos(w[len2], prs)] >= pri[Pos(s[i], prs)] do
        rezs := rezs + ' ' + Popc;
        PushC(s[i]);
        end;
      end;
    end;    
  if rezs[1] = ' ' then delete(rezs, 1, 1);
  rezs := rezs + ' ';
  Change := rezs;
end;


// вычисление выражения по обратной польской записи (алгоритм стековой машины)
function Count(s: String): Real;
var
  ss: String;
  p,x, s1, s2: Real;
  chh, s3: Char;
  i, j: Cardinal;
  tmp: Integer;
begin
  i := 0;
  repeat
    j := i + 1;
    repeat
      Inc(i)
    until s[i] = ' ';
    ss := copy(s, j, i - j);
    chh := ss[1];
    if not(chh in ['+', '-', '*', '/', '^', 's', 'c', 'l', 'a']) then
    begin
      Val(ss, p, tmp);
      Push(p);
    end
    else
    begin
      s2 := Pop;
      if chh in ['+', '-', '*', '/', '^'] then s1 := Pop else s1 := 0;
      s3 := chh;
      Push(Oper(s1, s2, s3));
    end;
  until i >= n;
  x := Pop;
  Count := x;
end;


// подготовка входного выражения x1 < 0 (все символы делаем маленькими, унарные операции заменяем на сокращеное обозначение)
function Format0(st:string):string;
var
ts: string;
begin  
  ts := st.ToLower();
  for var i:=1 to 4 do
    ts := ts.Replace(fn[i],fn[i][1]);
  ts := ts.Replace('x','(-x)');
  result :='('+ts+')';
end;


// подготовка входного выражения x1 >= 0(все символы делаем маленькими, унарные операции заменяем на сокращеное обозначение)
function Format(st:string):string;
var
ts: string;
begin 
  ts := st.ToLower();
  for var i:=1 to 4 do
    ts := ts.Replace(fn[i],fn[i][1]);
  ts := ts.Replace('x','(x)');
  result := '('+ts+')';
end;


// заменяем вхождение символа x на соответствующее числовое значение
function setX(tmp:string; x:Real):string;
begin
  result := tmp.Replace('x',floattostr(abs(x)));
end;


// переменные для построения графика функции и осей координат 
var
  x0, y0, x, y, xLeft, yLeft, xRight, yRight: integer;
  x1, y1, xp, mx, my, OX, OY, num: real; 
  c: boolean;
  
  s:string;
  ww:integer = 800;
  hh:integer = 800; // параметры графического окна


begin

  Writeln('Введите диапазон по OX от 0');
  readln(OX);
 
  Writeln('Введите диапазон по OY от 0');
  readln(OY);

  while true do
  begin
  
    Writeln('Введите выражение ');
    Readln(stt);
    window.clear();
    if(length(stt) = 0) then exit;
    
 
    SetWindowSize(ww, hh); // размеры графического окна
    // координаты левой верхней границы системы координат:
    xLeft := 50;
    yLeft := 50;
    // координаты правой нижней границы системы координат:
    xRight := wW - 50;
    yRight := hH - 50;
 
    mx := (xRight - xLeft) / (2 * OX); 
    my := (yRight - yLeft) / (2 * OY); 

    x0 := trunc(OX * mx) + xLeft;
    y0 := yRight - trunc(OY * my);
  
    // параметры отображения графика
    SetPenColor(clRed);
    line(x0, yLeft - 10, x0, yRight);
    line(xLeft, y0, xRight + 10, y0); 
    SetFontSize(15); 
    SetPenColor(clRed);
    SetFontColor(clRed);
    TextOut(xRight + 10, y0 - 13, 'x');
    TextOut(x0 - 4, yLeft - 30, 'y');
    SetFontSize(10); 
    SetFontColor(clBlack);
  
  
    // засечки по оси OX, OY
    for var i := -10 to 10 do
    begin
      num := i * OX / 10; // координата на оси ОХ
      x := x0 + round(num * mx); // координата num в окнe
      str(num:0:1, s);
      if abs(num) > 0 then // исключаем 0 на оси OX и линию сетки
      begin
        SetPenColor(clGray);
        Line(x, round(y0 - OY * my), x, round(y0 + OY * my)); // рисуем сетку на оси OX
        TextOut(x - TextWidth(s) div 2, y0 + 10, s)
      end;
      SetPenColor(clRed);
      Line(x, y0 - 5, x, y0 + 5); // рисуем засечки на оси OX
      num := i * OY / 10; // координата на оси ОY
      y := y0 - round(num * my);
      str(num:0:1, s);
      if abs(num) > 0 then // исключаем 0 на оси OY и линию сетки
      begin
        SetPenColor(clGray);
        Line(round(x0 - OX * mx), y, round(x0 + OX * mx), y); // рисуем сетку на оси OY
        TextOut(x0 + 10, y - TextHeight(s) div 2, s)
      end;
      SetPenColor(clRed);
      Line(x0 - 5, y, x0 + 5, y); // рисуем засечки на оси OY
    end;
    TextOut(x0 - 10, y0 + 10, '0'); // нулевая точка
    
    
    // надпись выражения функции
    SetFontColor(clBlue);
    SetFontSize(18); 
    TextOut(x0 + 50, 20, 'y=');
    TextOut(x0 + 75, 20, stt);
    SetFontColor(clBlack);
    SetFontSize(10);


    // построение графика функции
    while (Pos(' ', stt) <> 0) do // удаление пробелов
      Delete(stt, Pos(' ', stt), 1);
    xp := OX / (ww * 10);
    c := false;
    x1 := -OX;
    s1 := Format0(stt);
    n := Length(s1);
    PreChange(s1);     
    n := Length(s1);
    s2 := Change(s1);
    while x1 < 0 do
    begin
      try      
        n := Length(setX(s2, x1));
        y1 := Count(setX(s2, x1));         
        if (y1 >= - OY) and (y1 <= OY) then
        begin
          x := x0 + round(x1 * mx);
          y := y0 - round(y1 * my);
          if c then 
            LineTo(x, y, ClBlue)
          else
          begin
            MoveTo(x, y);
            c := true;
          end;
        end
        else
          c := false;
        x1 := x1 + xp; 
      except
      x1 := x1 + xp;
      c := false;
      end;
    end;
    x1 := 0;
    s1 := Format(stt);
    n := Length(s1);
    PreChange(s1);     
    n := Length(s1);
    s2 := Change(s1); 
    while x1 < OX do
    begin
      try      
        n := Length(setX(s2, x1));
        y1 := Count(setX(s2, x1));         
        if (y1 >= - OY) and (y1 <= OY) then
        begin
          x := x0 + round(x1 * mx);
          y := y0 - round(y1 * my);
          if c then 
            LineTo(x, y, ClBlue)
          else
          begin
            MoveTo(x, y);
            c := true;
          end;
        end
        else
          c := false;
        x1 := x1 + xp; 
      except
      x1 := x1 + xp;
      c := false;
      end;
    end;
  end;
end.