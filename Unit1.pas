unit Unit1;
 {**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-}
(* Данная программа разработана, как выполнение задания
   по дисциплине: Технологии программирования, УГТУ-УПИ, студентом 3 курса,
   специальность: Информационные системы и технологии,
   группа: ИТ-36012да.
   Разработчик: Севастьянов Семен Владимирович
   дата последней коррекции: 05. 12. 2008
   версия: 1.0.2
 {**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-}(**)
{--- Данная версия от предыдущей отличается: ---}
(*
 1. Стало возможным производить рокировку короля (пока только для белых)
 2. Теперь можно изменять вид фигур, соотв. дополнил файл ресурсов
 3. Пронумерована доска по вертикале и по горизонтале проставлены буквенные обозначения 
(**)
{--- некоторые термины английского языка ---}
(* checkmate         - шах и мат
   a chess game      - партия в шахматы
   Check to the king - шах королю
   chess-board       - шахматная доска
   possible          - вероятный, возможный
   castle            - рокировка 
   Pawn              - пешка
   Rook              - ладья
   KNIGHT            - конь
   BISHOP            - слон
(**)
{-------------------------------------------}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
{}
  TSymbolicPos = (A, B, C, D, E, F, G, H);
  TPosition = record
   Chess_Y : Byte;
   Chess_X : TSymbolicPos;
   ABS_X   : Integer;
   ABS_Y   : Integer;
  end;
{}
  TStep = record
   Chess_Y : Byte;
   Chess_X : TSymbolicPos;
  end;
{}
  TFigure                 = class; // Описание класса будет привидено ниже !!!
  TOnBeforeMoveFigure     = procedure (NewPOS : TPosition; Var FigureMove : Boolean) of object;
  TOnBeforeDoubleClick    = procedure (POS : TPosition; Var DoubleClick : Boolean) of object;
  TOnCheck_figure_in_cell = function (White_figure : Boolean; POS : TPosition; Var FigureID : Byte; Var Check_to_the_king : Boolean) : Boolean of object;
  TOnIsCheck_to_the_king  = function (White_figure : Boolean) : Boolean of object;
  TOnGetFirstFigureByFID  = function (FID : Byte; White_figure : Boolean; Var POS : TPosition) : TFigure of object;
{}
  TChessBoard = class(TPaintBox) {-- Шахматная доска, также играет роль интерфейса --}
   private
   {}
    CellWidth     : Integer;
    CellHeight    : Integer;
   {}
    Flft_shift    : Integer;
    Frgt_shift    : Integer;
   {}
    FBeforeDoubleClick  : TOnBeforeDoubleClick; // событие
    FOnBeforeMoveFigure : TOnBeforeMoveFigure;  // событие
   {}
    LCELL_MD_POS  : TPosition; // позиция в которой в прошлый раз была выбрана ячейка
    CELL_MD_POS   : TPosition; // позиция в которой сейчас выбрана ячейка
   {}
    CELL_Gamer_WhiteF : TPosition; // Позиция в которую переместил фигуру игрок 1 в прошлый ход
    CELL_Gamer_BlackF : TPosition; // Позиция в которую переместил фигуру игрок 2 в прошлый ход
   {}
    double_click  : Boolean;
    Step_White    : Boolean; // Перем определяет чей сейчас ход
    Figure_sel    : Boolean; // Перем определяет выбрана или нет фигура
   {}
    FOnCheck_figure_in_cell : TOnCheck_figure_in_cell; // событие
    FOnIsCheck_to_the_king  : TOnIsCheck_to_the_king;  // событие
   {}
    FOnGetFirstFigureByFID  : TOnGetFirstFigureByFID;  // событие
   {}
   protected
   {-- Прорисовка шахматной доски ---}
    procedure Paint; override;
   {-- Прорисовка выбранной ячейки --}
    Procedure Paint_Cell(CELL   : TPosition; double_click : Boolean);
   {}
   public
   {}
   {--- Функция дает абсолютные коорд по относительным ---}
    Function GetXYtoPos (Pos : TPosition) : TPosition;
   {--- Функция дает относительные коорд по абсолютным ---}
    Function GetPostoXY (Pos : TPosition; var res : Boolean) : TPosition;
   {}
    Function IndexToSymbolicPos(I : Integer) : TSymbolicPos;
    Function SymbolicPosToIndex(SymP : TSymbolicPos) : Integer;
   {}
    Constructor Create(Left : Integer; Top : Integer; Width : Integer; Height : Integer; Aowner : TComponent); reintroduce;
   {}
    Function Black_Cell(POS : TStep) : Boolean; // Определяет какого цвета клетка, в опр позиции
   {-- Обработка событий от мыши --}
    procedure MouseDown_(Sender: TObject; Button: TMouseButton;
     Shift: TShiftState; X, Y: Integer);
    procedure MouseUp_(Sender: TObject; Button: TMouseButton;
     Shift: TShiftState; X, Y: Integer);
   {}
    property OnBeforeDoubleClick : TOnBeforeDoubleClick read FBeforeDoubleClick write FBeforeDoubleClick;
    property OnBeforeMoveFigure  : TOnBeforeMoveFigure  read FOnBeforeMoveFigure write FOnBeforeMoveFigure;
   {}
    property OnCheck_figure_in_cell : TOnCheck_figure_in_cell read FOnCheck_figure_in_cell write FOnCheck_figure_in_cell;
    property OnIsCheck_to_the_king  : TOnIsCheck_to_the_king  read FOnIsCheck_to_the_king write FOnIsCheck_to_the_king;
   {}
    property OnGetFirstFigureByFID  : TOnGetFirstFigureByFID read FOnGetFirstFigureByFID write FOnGetFirstFigureByFID;
   {}
   end;
{}
  TFigure = Class
  private
  {--- перем. хранит цвет фона изображения для имитации прозрачности ---}
   BackColor    : TColor;    {-- цвет фона изображения --}
  {}
   Shift_y,
   Shift_x      : Integer;   {-- Сдвиг изображения относительно клетки шахм. доски --}
  {}
   FPosition    : TPosition; {--- позиция фигуры ---}
   FColor_White : Boolean;   {--- цвет фигуры ---}
  {}
   FPaintBox    : TPaintBox; {-- поверхность --}
   FBmp         : TBitmap;   {-- битмап для хранения изображения --}
  {}
   Bcheck_to_the_king : Boolean; // фигура сделала шах королю (лог признак)
  {}
   FID                : Byte;    // Идентификатор фигуры
  {--- Check_to_the_king --- проверка сделала ли фигура шах королю ---}
   function Check_to_the_king (Position : TPosition) : Boolean; virtual; abstract;
  {--- function Check_Step --- функция, задача: только определяет можно или нет переместить фигуру и все ---}
   function Check_Step(Position : TPosition) : Boolean; virtual; abstract;
   {--- procedure MoveFigure --- безусловно двигает фигуру ---}
   procedure MoveFigure(Position : TPosition); virtual;
  {}

  Protected
  {--- Прорисовка фигуры, обр события OnPaint поверхности фигуры ---}
   procedure Paint_figure(Sender: TObject);
  {}
   {-- Обработка событий от мыши --}
   procedure MouseDown_(Sender: TObject; Button: TMouseButton;
     Shift: TShiftState; X, Y: Integer); virtual;
   procedure MouseUp_(Sender: TObject; Button: TMouseButton;
     Shift: TShiftState; X, Y: Integer); virtual;
  {}
  public
  {-- позиция на доске в которой сейчас находится фигура --}
   property Position : TPosition read FPosition;
  {-- цвет фигуры (белый или черный) --}
   Property    Color_White : Boolean read FColor_White;
  {-- конструктор объекта --}
   Constructor Create(Position : TPosition; Color_White : Boolean); virtual;
  {-- деструктор объекта --}
   Destructor  Destroy; override;
  {-- Процедура Шаг --}
   Function Step(Step : TStep) : Boolean; virtual;
   {--- Процедура Шаг: определяет можно или нет переместить фигуру и
        если можно то перемешает ---}
  {}
  end;

{-- пешка --}
  TPawn = Class (TFigure)
   private
   {-- Первый раз пешка может ходить на две клетки вперед --}
    First_Step : Boolean;
   {-- проверка сделала ли пешка шах королю --}
    function Check_to_the_king (Position : TPosition) : Boolean; override;
   {-- проверка возможен ли ход в опр позицию --}
    function Check_Step(Position : TPosition) : Boolean; override;
   {}
   protected
   {}
   public
    {-- конструктор объекта --}
    Constructor Create(Position : TPosition; Color_White : Boolean); override;
    {}
   end;
{-- слон --}
  TBISHOP = Class (TFigure)
   {--- На основе фигуры слон будут реализованы следующие фигуры:
         1) ладья (rook)
         2) ферзь (queen)
         3) король (king) ---}
   private
   {--- Следующая функция проверяет можно ли двигать фигуру, без учета положений других фигур ---}
    function Can_cell_cxy(cell_cx, cell_cy : Integer) : Boolean; virtual;
   {--- Следующая функция проверяет делает данная фигура шах королю или нет ---}
    function Check_to_the_king (Position : TPosition) : Boolean; override;
   {--- Проверка хода для данной фигуры ---}
    function Check_Step(Position : TPosition) : Boolean; override;
   {--- Проверяет есть ли на линии по которой идет фигура другие фигуры неважно какого цвета ---}
    function Check_to_Line(Position : TPosition) : Boolean;
   {}
   protected
   public
   end;

{-- ладья --}
  TRook = Class (TBISHOP)
   private
   protected
   public
   end;
{-- ферзь --}
  TQueen = Class (TBISHOP)
   private
   protected
   public
   end;
{-- король --}
  TKing = Class (TBISHOP)
   private
   {--- Перем. можно нет делать рокировку ---}
    IsPossibleCastle : Boolean;
   {--- Перем. Сделана уже рокировка или нет ---} 
    castle_bool      : Boolean;
   {-- Проверка хода --} 
    function Check_Step(Position : TPosition) : Boolean; override;
   {}
   protected
   public
   {-- конструктор объекта --}
    Constructor Create(Position : TPosition; Color_White : Boolean); override;
   {}
   end;

{-- конь --}
  TKNIGHT = Class (TFigure)
   private
   {--- Следующая функция проверяет делает данная фигура шах королю или нет ---}
    function Check_to_the_king (Position : TPosition) : Boolean; override;
   {--- Проверка хода для данной фигуры ---} 
    function Check_Step(Position : TPosition) : Boolean; override;
   {}
   protected
   public
   end;
{}
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
   function Check_destroyFigure(Step_White : Boolean; Step : TStep) : Boolean;
   function GetFirstFigureByFID(FID : Byte; White_figure : Boolean; Var POS : TPosition) : TFigure;
   function GetSelIndexFigureInPOS(White_figure : Boolean; POS : TPosition) : Integer;
   procedure ChessBox_BeforeDoubleClick(POS : TPosition; Var DoubleClick : Boolean);
   procedure ChessBox_BeforeMoveFigure(NewPOS : TPosition; Var MoveFigure : Boolean);
   function  Check_figure_in_cell(White_figure : Boolean; POS : TPosition; Var FigureID : Byte; Var Check_to_the_king : Boolean) : Boolean;
   function  IsCheck_to_the_king(White_figure : Boolean) : Boolean;
  public
    { Public declarations }
   Select_    : Integer; // Индекс в массиве выбранной в данный момент фигуры
  end;

var
  Form1: TForm1;

implementation

uses Math;
{$R *.dfm}

 const
  CreateWhiteFigure = true;
  CreateBlackFigure = false;
  fid_pawn          = $01;
  fid_rook          = $02;
  fid_Knight        = $03;
  fid_Queen         = $04;
  fid_BISHOP        = $05;
  fid_king          = $FF;
  WhiteCellColor    = clCream;
  BlackCellColor    = clSkyBlue;
  figskin1          = $01;
  figskin2          = $02;
  figskin3          = $03;
  figskin4          = $04;
  figskin5          = $05;
 Var
  ChessBoard   : TChessBoard;
  Arr_figure   : Array of TFigure;
  Count_f      : Integer;
  skin         : Byte = figskin5;
{--- class TFigure ---}

Constructor TFigure.Create(Position : TPosition; Color_White : Boolean);
 Var
  FigureName : String;
begin
{--- записываем цвет для созданной фигуры ---}
 FColor_White := Color_White;
{}
 Bcheck_to_the_king := false;
{}
// FSelected := false;
 FPosition := Position;
{-- получаем имя фигуры --}
 FigureName := UpperCase(Copy(ClassName, 2, Length(ClassName)-1));
{--- создаем Bitmap и загружаем туда картинку ---}
 FBmp             := TBitmap.Create;
 FBmp.Transparent := true;
{}
 if skin = figskin5 then
  FBmp.LoadFromResourceName(HInstance, FigureName + '_5') else
 if skin = figskin4 then
  FBmp.LoadFromResourceName(HInstance, FigureName + '_4') else
 if skin = figskin3 then
  FBmp.LoadFromResourceName(HInstance, FigureName + '_3') else
 if skin = figskin2 then
  FBmp.LoadFromResourceName(HInstance, FigureName + '_2') else
  FBmp.LoadFromResourceName(HInstance, FigureName );
 BackColor        := FBMP.Canvas.Pixels[0,0];
 if not FColor_White then
  FBmp.Canvas.CopyRect(Rect(0, 0, FBmp.Width div 2, FBmp.Height), FBmp.Canvas, Rect(FBmp.Width div 2  + 1, 0, FBMP.Width, FBMP.Height)); {}
 FBmp.Width := FBmp.Width div 2;
{--- определяем знач. перем. для сдвига картинки в лево и вправо внутри клетки ---}
 Shift_x := (Round((ChessBoard.CellWidth / 2) - (FBmp.Width / 2)));
 Shift_y := (Round((ChessBoard.CellHeight / 2) - (FBmp.Height / 2)));
{--- создаем поверхность для вывода Bitmap ---}
 FPaintBox         := TPaintBox.Create(ChessBoard);
 FPaintBox.Parent  := ChessBoard.Parent;
 FPaintBox.OnPaint := Paint_figure;
 FPaintBox.Width   := FBMP.Width;
 FPaintBox.Height  := FBMP.Height;
 FPaintBox.Left    := ChessBoard.GetXYtoPos(Position).ABS_X + Shift_x;
 FPaintBox.Top     := ChessBoard.GetXYtoPos(Position).ABS_Y + Shift_y;
 FPaintBox.Visible := true;
 FPaintBox.OnMouseDown := MouseDown_;
 FPaintBox.OnMouseUp   := MouseUp_;
{}
 if FigureName = UpperCase('Pawn')   then FID := fid_pawn;
 if FigureName = UpperCase('Rook')   then FID := fid_rook;
 if FigureName = UpperCase('Knight') then FID := fid_Knight;
 if FigureName = UpperCase('Queen')  then FID := fid_Queen;
 if FigureName = UpperCase('BISHOP') then FID := fid_BISHOP;
 if FigureName = UpperCase('King')   then FID := fid_king;
{}
end;

Destructor  TFigure.Destroy;
begin
{}
 FBmp.Free;
 FPaintBox.Free;
{}
 inherited;
{}
end;

procedure TFigure.Paint_figure(Sender: TObject);
 Var
  POS : TStep;
begin
{--- Прорисовка фигуры данные для вывода картинки хранятся в Bitmap ---}
 POS.Chess_Y := FPosition.Chess_Y;
 POS.Chess_X := FPosition.Chess_X;
{}
 if not ChessBoard.Black_Cell(POS) then
  begin
  {}
   FBMP.Canvas.Brush.Color := WhiteCellColor; // WhiteCellColor - Цвет, которым мы заменим в изображении цвет фона
   FBMP.Canvas.FloodFill(0,0, BackColor, fsSurface);
   //BackColor := WhiteCellColor;               // теперь у фигуры изменили цвет фона это важно учесть !!!
  {}
  // FBMP.Canvas.Brush.Color := BackColor; // WhiteCellColor - Цвет, которым мы заменим в изображении цвет фона
   FBMP.Canvas.FloodFill(FBMP.Width - 1,0, BackColor, fsSurface);
   BackColor := WhiteCellColor;               // теперь у фигуры изменили цвет фона это важно учесть !!!
  {}
  end else {}
  begin
  {}
   FBMP.Canvas.Brush.Color := BlackCellColor; // BlackCellColor - Цвет, которым мы заменим в изображении цвет фона
   FBMP.Canvas.FloodFill(0,0, BackColor, fsSurface);
   //BackColor := BlackCellColor; // теперь у фигуры изменили цвет фона это важно учесть !!!
  {}
  // FBMP.Canvas.Brush.Color := BackColor; // BlackCellColor - Цвет, которым мы заменим в изображении цвет фона
   FBMP.Canvas.FloodFill(FBMP.Width - 1, 0, BackColor, fsSurface);
   BackColor := BlackCellColor; // теперь у фигуры изменили цвет фона это важно учесть !!!
  {}
  end;
{}
 with FPaintBox do
  begin
   Windows.BitBlt(Canvas.Handle, 0, 0,
        FBMP.Width, FBMP.Height, FBmp.Canvas.Handle,
        0, 0, cmSrcCopy{});
  end;
{}
end;

procedure TFigure.MouseDown_;
begin
{}
 x := ChessBoard.GetXYtoPos(FPosition).ABS_X;
 y := ChessBoard.GetXYtoPos(FPosition).ABS_Y;
 ChessBoard.MouseDown_(sender, button, shift, x, y);
{}
end;

procedure TFigure.MouseUp_;
begin
{}
 x := ChessBoard.GetXYtoPos(FPosition).ABS_X;
 y := ChessBoard.GetXYtoPos(FPosition).ABS_Y;
 ChessBoard.MouseUp_(sender, button, shift, x, y);
{}
end;

procedure TFigure.MoveFigure(Position : TPosition);
begin
{}
 FPaintBox.Left    := ChessBoard.GetXYtoPos(Position).ABS_X + Shift_x;
 FPaintBox.Top     := ChessBoard.GetXYtoPos(Position).ABS_Y + Shift_y;
 FPosition         := Position;
 Paint_figure(self); // перерисовываем фигуру в новой позиции
{} 
end;

Function  TFigure.Step (Step : TStep) : Boolean;
 Var
  NewPOS : TPosition;
begin
{}
 result := false;
 NewPOS.Chess_Y := Step.Chess_Y;
 NewPOS.Chess_X := Step.Chess_X;
 If Check_Step(NewPOS) then
  begin
  {}
   MoveFigure(NewPos);
   result := true;
  {}
  end;
{}
end;

{--- class TChessBoard ---}
Constructor TChessBoard.Create(Left : Integer; Top : Integer; Width : Integer; Height : Integer; Aowner : TComponent);
 Var
  W, H : Integer;
begin
{}
 inherited Create(Aowner);
{--- переменные сдвигают игровое поле по X, Y внутри PaintBox ---}
 Flft_shift := 52;
 Frgt_shift := 52;
{}
 self.left   := Left;
 self.top    := Top;
 self.Width  := width - Flft_shift*2;
 self.Height := height - Flft_shift*2;
{}
 Visible := true;
 OnMouseDown := MouseDown_;
 OnMouseUp   := MouseUp_;
 LCELL_MD_POS.Chess_Y := 0;
{}
 Step_White  := true; // Сначале ходят белые и смелые :))))
{}
 CELL_Gamer_BlackF.Chess_Y := 2;
 CELL_Gamer_BlackF.Chess_X := D; // Начальная позиция курсора для игрока "черных"
{}
 CELL_Gamer_WhiteF.Chess_Y := 7;
 CELL_Gamer_WhiteF.Chess_X := D; // Начальная позиция курсора для игрока "белых"
{}
 w := width;
 h := Height;
{}
 w := w - Flft_shift*2;
 h := h - Frgt_shift*2;
{}
 CellWidth  := (w div 8);
 CellHeight := (h div 8);
{}
end;

Procedure TChessBoard.MouseDown_;
 Var
  POS, NewPOS : TPosition;
  res         : Boolean;
begin
{}
 POS.ABS_X := X;
 POS.ABS_Y := Y;
 NewPOS := GetPostoXY(POS, res);
{}
 CELL_MD_POS.Chess_Y := 0;
 CELL_MD_POS.ABS_X   := 0;
 CELL_MD_POS.ABS_Y   := 0;
{}
 if res then
  CELL_MD_POS := NewPOS;
{}
end;

procedure TChessBoard.MouseUp_;
 Var
  POS, NewPOS  : TPosition;
  res, res1    : Boolean;
  double_click : boolean;
  FigureMove   : Boolean;
begin
{}
 POS.ABS_X := X;
 POS.ABS_Y := Y;
 NewPOS := GetPostoXY(POS, res);
 GetPostoXY(CELL_MD_POS, res1);
{}
 if (newPOS.Chess_X = CELL_MD_POS.Chess_X) and
    (newPOS.Chess_Y = CELL_MD_POS.Chess_Y) and
    res1 and res then
  begin
  {}
  if (Button = mbRight) and Figure_sel then
   begin
    double_click := false;
    Figure_sel   := false;
   end else
   if (Button = mbLeft) and (not Figure_sel) then
    double_click := true else
    begin
     if (Figure_sel) then
      double_click := false;
    end; {}
  {}
   if not Figure_sel then
   if double_click and Assigned(OnBeforeDoubleClick) then
    OnBeforeDoubleClick(CELL_MD_POS, double_click);
  {}
   FigureMove := false;
   if (not double_click) and Assigned(OnBeforeMoveFigure) and
       Figure_sel then
    OnBeforeMoveFigure(CELL_MD_POS, FigureMove);
  {}
   if FigureMove then {--- Если фигура была перемещена ---}
    begin
    {}
     Paint_Cell(CELL_MD_POS, double_click);
     LCELL_MD_POS := CELL_MD_POS;
    {}
     if Step_White then
      begin
       CELL_MD_POS       := CELL_Gamer_BlackF;
       CELL_Gamer_WhiteF := LCELL_MD_POS;
      end else
      begin
       CELL_MD_POS       := CELL_Gamer_WhiteF;
       CELL_Gamer_BlackF := LCELL_MD_POS;
      end;
    {}
     Step_White   := not Step_White; // ход передается другому игроку
     Figure_sel   := false;
     double_click := false;
     Paint_Cell(CELL_MD_POS, double_click);
     LCELL_MD_POS := CELL_MD_POS;
     exit;
    {}
    end;

  {}
   if Figure_sel then
    Figure_sel := (CELL_MD_POS.Chess_X = LCELL_MD_POS.Chess_X) and
                  (CELL_MD_POS.Chess_Y = LCELL_MD_POS.Chess_Y);
  {}                
   if (Button = mbLeft) and (Figure_sel) and (not double_click) then
    Paint_Cell(CELL_MD_POS, true) else
    Paint_Cell(CELL_MD_POS, double_click);
  {}
   if not Figure_sel then
    Figure_sel := double_click;
   LCELL_MD_POS := CELL_MD_POS;
  {}
  end;
{}
end;

Function TChessBoard.IndexToSymbolicPos(I : Integer) : TSymbolicPos;
begin
{}
 result := A;
   case I of
    1 : result := A;
    2 : result := B;
    3 : result := C;
    4 : result := D;
    5 : result := E;
    6 : result := F;
    7 : result := G;
    8 : result := H;
   end;
{}
end;

Function TChessBoard.SymbolicPosToIndex(SymP : TSymbolicPos) : Integer;
begin
 result := 1;
   case SymP of
    A : result := 1;
    B : result := 2;
    C : result := 3;
    D : result := 4;
    E : result := 5;
    F : result := 6;
    G : result := 7;
    H : result := 8;
   end;
{}
end;

Function TChessBoard.GetPostoXY (Pos : TPosition; Var res : Boolean) : TPosition;
 Var
  X, Y   : Integer;
  X1, Y1 : Integer;
  I, J   : Integer;
  w, h   : Integer;
{}
  check_x : Boolean;
  check_y : Boolean;
{}
  save_I  : Integer;
  save_J  : Integer;
{}
begin
{}
 X := POS.ABS_X;
 Y := Pos.ABS_Y;

{}
 w := width;
 h := Height;
{}
 w := w - Flft_shift*2;
 h := h - Frgt_shift*2;
{}
  For J := 1 to 8 do
  begin
  {}
   For I := 1 to 8 do
    begin
    {}
     X1 := Flft_shift + ((w div 8)*(I+0)) - (w div 8);
     Y1 := Frgt_shift + ((h div 8)*(J+0)) - (h div 8);
    {}
     if I = 8 then
      check_x := (X >= X1) else
      check_x := (X >= X1) and (x <= x1 + (w div 8));
    {}
     if J = 8 then
      check_y := (Y >= Y1) else
      check_y := (Y >= Y1) and (y <= y1 + (h div 8));
    {}
     save_I := I;
     save_J := J;
    {}
     if check_x and check_y then break;
    {}
    end;
  {}
   if check_x and check_y then break;
  {}
  end;
{}
 res            := (check_x and check_y);
 result         := POS;
 result.Chess_Y := save_J;
 result.Chess_X := IndexToSymbolicPos(save_I);
{}
end;

Function TChessBoard.GetXYtoPos (Pos : TPosition) : TPosition;
 Var
  X, Y : Integer;
  W, H1 : Integer;
begin
{}
 w  := width;
 h1 := Height;
 w  := w - Flft_shift*2;
 h1 := h1 - Frgt_shift*2;
{}
 X  := 1;
 Case POS.Chess_X of
  A: X := 1;
  B: X := 2;
  C: X := 3;
  D: X := 4;
  E: X := 5;
  F: X := 6;
  G: X := 7;
  H: X := 8;
 end;
 Y := POS.Chess_Y;
 X := left + Flft_shift + ((w div 8)*(X + 0)) - (w div 8);
 Y := top  + Frgt_shift + ((h1 div 8)*(Y + 0)) - (h1 div 8);
 POS.ABS_X := X;
 POS.ABS_Y := Y;
 result := Pos;
{}
end;

Function TChessBoard.Black_Cell(POS : TStep) : Boolean; // Определяет какого цвета клетка, в опр позиции
 Var
  I, J : Integer;
begin
 J := POS.Chess_Y;
 I := SymbolicPosToIndex(POS.Chess_X);
 result := ((i + j) mod 2 = 1);
end;

Procedure TChessBoard.Paint_Cell(CELL   : TPosition; double_click : Boolean);
 Var
  x1, y1, x, y, w, h : Integer;
  POS        : TStep;
begin
{}
 self.double_click := double_click;
{}
 w := width;
 h := Height;
{}
 POS.Chess_Y := CELL.Chess_Y;
 POS.Chess_X := CELL.Chess_X;
{}
 w := w - Flft_shift*2;
 h := h - Frgt_shift*2;
{}
 if (CELL_MD_POS.Chess_Y = CELL.Chess_Y) and
    (CELL_MD_POS.Chess_X = CELL.Chess_X) then
     begin
     {}
      x1 := SymbolicPosToIndex(Cell.Chess_X);
      y1 := Cell.Chess_Y;
      X := Flft_shift + ((w div 8)*(x1+0)) - (w div 8);
      Y := Frgt_shift + ((h div 8)*(y1+0)) - (h div 8);
     {}
      Canvas.Brush.Color := clred;
      if self.double_click then Canvas.Brush.Color := clgreen;
     {}
      Canvas.FrameRect(Rect(x + 2 , y + 2, x + (w div 8) - 2, y + (h div 8) - 2));
     {}
      if (LCELL_MD_POS.Chess_Y <> 0)
         and
         ((LCELL_MD_POS.Chess_X <> CELL.Chess_X) or
          (LCELL_MD_POS.Chess_Y <> CELL.Chess_Y)) then
       begin
       {}
        x1 := SymbolicPosToIndex(LCELL_MD_POS.Chess_X);
        y1 := LCELL_MD_POS.Chess_Y;
        X  := Flft_shift + ((w div 8)*(x1+0)) - (w div 8);
        Y  := Frgt_shift + ((h div 8)*(y1+0)) - (h div 8);
       {}
        POS.Chess_Y := LCELL_MD_POS.Chess_Y;
        POS.Chess_X := LCELL_MD_POS.Chess_X;
       {}
        if Black_Cell(POS) then
         Canvas.Brush.Color := BlackCellColor else
         Canvas.Brush.Color := WhiteCellColor;
       {}
        Canvas.FrameRect(Rect(x + 2 , y + 2, x + (w div 8) - 2, y + (h div 8) - 2));
       {} 
       end;
     {}
     end;
{}
end;

procedure TChessBoard.Paint;
 Var
  w, h : Integer;
  I, j : Integer;
  x, y : Integer;
begin
{}
 w := width;
 h := Height;
{} 
 Canvas.Pen.Color   := clBlack;
 Canvas.Brush.Color := clwhite;
 Canvas.Rectangle(Rect(0,0, w,h));
{}
 w := w - Flft_shift*2;
 h := h - Frgt_shift*2;
{}
 CellWidth  := (w div 8);
 CellHeight := (h div 8);
{}
 For J := 1 to 8 do
  For I := 1 to 8 do
   begin
   {}
    X := Flft_shift + ((w div 8)*(I+0)) - (w div 8);
    Y := Frgt_shift + ((h div 8)*(J+0)) - (h div 8);
   {}
    if ((i + j) mod 2 = 1) then
     Canvas.Brush.Color := BlackCellColor else
     Canvas.Brush.Color := WhiteCellColor;
   {}
    Canvas.Pen.Color := clBlack;
    Canvas.Rectangle(Rect(x , y, x + (w div 8), y + (h div 8)));
   {--- Выводим обозначение клеток по X (A,B,C,...,H) ---}
    Canvas.Brush.Color := clWhite;
    if (J = 8) then
     Canvas.TextOut(X + ((w div 8) div 2) - 8, Y + (h div 8) + 8, Chr(ORD('A') + I-1));
   {--- Выводим обозначение клеток по Y ---}
   if  (I = 1) then
     Canvas.TextOut(X - 16, Y + (h div 8) div 2 -  8, IntToStr(9 - J));
   {}
   end;
{}
 if CELL_MD_POS.Chess_Y <> 0 then
  Paint_Cell(CELL_MD_POS, double_click);
 inherited;
{} 
end;

{-- TPawn -- Объект "Пешка" --}
Constructor TPawn.Create(Position : TPosition; Color_White : Boolean);
begin
{}
 inherited Create(Position, Color_White);
{}
 First_Step := true;
{}
end;

function TPawn.Check_to_the_king (Position : TPosition) : Boolean;
 Var
  L_Cell_AtP : TPosition;
  R_Cell_AtP : TPosition;
  X, X1      : Integer;
  FigureID   : Byte;
  Checktotheking : Boolean;
begin
{}
 result := false;
{-- Чтобы проверить делает ли данная фигура шах королю нам нужно проверить те клетки,
    которые может атаковать данная фигура --}
 L_Cell_AtP         := Position;
{}
 if Color_White then
  L_Cell_AtP.Chess_Y := L_Cell_AtP.Chess_Y - 1 else
  L_Cell_AtP.Chess_Y := L_Cell_AtP.Chess_Y + 1;
{}
 X                  := ChessBoard.SymbolicPosToIndex(L_Cell_AtP.Chess_X) - 1;
 L_Cell_AtP.Chess_X := ChessBoard.IndexToSymbolicPos(X);
{}
 R_Cell_AtP         := Position;
{}
 if Color_White then
  R_Cell_AtP.Chess_Y := R_Cell_AtP.Chess_Y - 1 else
  R_Cell_AtP.Chess_Y := R_Cell_AtP.Chess_Y + 1;
{}
 X1                 := ChessBoard.SymbolicPosToIndex(R_Cell_AtP.Chess_X) + 1;
 R_Cell_AtP.Chess_X := ChessBoard.IndexToSymbolicPos(X1);
{}
 if (X > 0) and (L_Cell_AtP.Chess_Y > 0) and (L_Cell_AtP.Chess_Y <= 8) then
  begin
  {}
   ChessBoard.OnCheck_figure_in_cell(not Color_White, L_Cell_AtP, FigureID, Checktotheking);
   if FigureID = fid_king then
    result := true;
  {}
  end;
{}
 if (X1 < 9) and (R_Cell_AtP.Chess_Y > 0) and (R_Cell_AtP.Chess_Y <= 8) then
  begin
  {}
   ChessBoard.OnCheck_figure_in_cell(not Color_White, R_Cell_AtP, FigureID, Checktotheking);
   if FigureID = fid_king then
    result := true;
  {}
  end;
{}
end;

Function TPawn.Check_Step(Position : TPosition) : Boolean;
 Var
  X, X1  : Integer;
  Y, Y1  : Integer;
  Step_F : Boolean;
  limv   : Integer;
  cell_c : Integer;
  FigureID : Byte;          //
  Checktotheking : Boolean; //
  help_king      : Boolean; // переменная уст. в истину только тогда, когда королю шах и данная фигура спасет его от шаха срубив вражескую
{}
  SaveFPosition  : TPosition;
{}
begin
 help_king := false;
{-- Преобразуем позицию по X --}
 X      := ChessBoard.SymbolicPosToIndex(Position.Chess_X);
 X1     := ChessBoard.SymbolicPosToIndex(FPosition.Chess_X);
{-- Преобразуем позицию по Y --}
 Y      := Position.Chess_Y;
 Y1     := FPosition.Chess_Y;
{-- Пешка назад не ходит и не рубит и это нужно проверить и не допустить такой казус --}
 if First_Step then limv := 2 else limv := 1;
 cell_c := Y - Y1;
 if FColor_White then cell_c := cell_c*-1;
 Step_F := (cell_c <= limv) and (cell_c > 0); // Если (cell_c <= 0), то пешка или меняет позицию по X но не меняет по Y или идет назад, что недопустимо!
{-- далее проверям невозможный ход, когда пешка ходит на две клетки вперед и одновременно меняет позицию по X
    или меняет позицию по X на две или более клетки, такие ходы запрещены вне зависимости от того есть там чужая фигура или нет --}
 if Step_F and
    (((X <> X1) and (cell_c = 2)) or (abs(X-X1) >= 2)) then Step_F := false;
{-- теперь важно проверить: ситуацию 1, когда пешка хочет срубить другую ("чужую") фигуру (это можно)
    и проверить ситуацию 2, чтобы пешка не перепрыгнула через свою же фигуру (этого
    пешки делать нельзя) --}
 if Assigned(ChessBoard.OnCheck_figure_in_cell) and (X <> X1) and step_f then // ситуация 1
  begin
   step_f    := ChessBoard.OnCheck_figure_in_cell(not FColor_White, Position, FigureID, Checktotheking) and step_f;
   help_king := Checktotheking;
  end;
{-- пешка не может рубить вперед, проверяем и это --}
 if (X = X1) and step_f then
  step_f := (not ChessBoard.OnCheck_figure_in_cell(not FColor_White, Position, FigureID, Checktotheking)) and step_f;
{-- пешка не может встать в позицию в которой есть "своя" пешка }
  step_f := (not ChessBoard.OnCheck_figure_in_cell(FColor_White, Position, FigureID, Checktotheking)) and step_f;
{-- пешка не может прыгать через фигуры, причем не важно свои или чужие! (ситуация 2) --}
 if FColor_White then
  Position.Chess_Y := FPosition.Chess_Y - 1 else
  Position.Chess_Y := FPosition.Chess_Y + 1;
 if (cell_c > 1) and step_f then
  step_f := (not ChessBoard.OnCheck_figure_in_cell(FColor_White, Position, FigureID, Checktotheking)) and
            (not ChessBoard.OnCheck_figure_in_cell(not FColor_White, Position, FigureID, Checktotheking));
 if FColor_White then
  Position.Chess_Y := FPosition.Chess_Y + 1 else
  Position.Chess_Y := FPosition.Chess_Y - 1;
{-- теперь когда теор пешка может совершить ход нам нужно проверить следующее:
    1) Есть ли такая вражеская фигура, которая сделала шах нашему королю?[да, нет]
       а) [нет]: Если нету проверяем делает ли наша пешка шах королю
       б) [да]:  Если есть то проверяем: ход нашей пешкой спасет от угрозы нашего короля?, если спасет то ей можно ходить иначе нельзя --}
 if step_f then
  begin
  {}
   if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
    begin
     {-- Есть шах нашему королю --}
      if help_king then
       result := help_king else
       begin
       {--- Здесь нужно вставить проверку: перекрывает ли линию атаки данная фигура,
            таким образом спасает ли она короля от угрозы ---}
       {}
        {-1-}
        Position.Chess_Y   := Y;
        SaveFPosition      := FPosition;
        FPosition          := Position; // Выполняем пункт 1 меняем временно текущую позицию фигуры
        {-2-}
        if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
         begin
          FPosition          := SaveFPosition;
          result := false;
          exit;
         end;
        {-3-}
        FPosition := SaveFPosition; // на отображении это не отражается !!!
        result    := Step_F;
       {}
       end;
       {}
       exit;
       {}
    end else
    begin
     {-- Нет шаха нашему королю --}
      Position.Chess_Y   := Y;
     {-- Но теперь надо проверить главное: не подставляем ли мы короля под удар своим ходом?
          А для этого нам нужно сделать следующее:
          1) поменять временно текущую позицию фигуры на позицию в которую ее хотят поставить
          2) после чего для каждой вражеской фигуры на доске вызвать функцию: Check_to_the_king
             и если она хотя бы раз возвратит истину то
             значит мы подставляем короля а этого не в коем случае нельзя делать!
          3) Возвращаем все как было, то есть текущую позицию фигуры, делаем такой какой она была до проверки !    --}
      {-1-}    
       SaveFPosition      := FPosition;
       FPosition          := Position; // Выполняем пункт 1 меняем временно текущую позицию фигуры
                                       // на отображении это не отражается !!!
      {-2-}
        if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
         begin
          FPosition          := SaveFPosition;
          result := false;
          exit;
         end;
      {-3-}
       FPosition          := SaveFPosition;
      {-------------------------------------------------------------------------------}
      
      {-- Если данная фигура делает шах враж. королю нам нужно запомнить этот факт! --}
      Bcheck_to_the_king := Check_to_the_king(Position);
    end;
  {}
  end; 
{}  
 result     := Step_F;
 if result then
  First_Step := false;
{}
end;

{-- TKNIGHT -- конь}
Function TKNIGHT.Check_to_the_king(Position : TPosition) : Boolean;
 Var
  L_Cell_AtP : TPosition;
  R_Cell_AtP : TPosition;
  X, X1      : Integer;
  FigureID   : Byte;
  Checktotheking : Boolean;
  I              : Integer;
  jump_Y         : Integer;
begin
{}
 result := false;
{-- Чтобы проверить делает ли данная фигура шах королю нам нужно проверить те клетки,
    которые может атаковать данная фигура --}
{}
 jump_Y := 2;
 For I := 1 to 4 do
 begin
 {}
   Case I of
    1: jump_Y := 2;
    2: jump_Y := -2;
    3: jump_Y := 1;
    4: jump_Y := -1;
   end;
 {}
  L_Cell_AtP         := Position;
 {}
  L_Cell_AtP.Chess_Y := L_Cell_AtP.Chess_Y + jump_Y;
 {}
  X                  := ChessBoard.SymbolicPosToIndex(L_Cell_AtP.Chess_X) - 1;
  if abs(jump_Y) <> 2 then X := X - 1;
  L_Cell_AtP.Chess_X := ChessBoard.IndexToSymbolicPos(X);
 {}
  R_Cell_AtP         := Position;
 {}
  R_Cell_AtP.Chess_Y := R_Cell_AtP.Chess_Y + jump_Y;
 {}
  X1                 := ChessBoard.SymbolicPosToIndex(R_Cell_AtP.Chess_X) + 1;
  if abs(jump_Y) <> 2 then X1 := X1 + 1;
  R_Cell_AtP.Chess_X := ChessBoard.IndexToSymbolicPos(X1);
 {}
  if (X > 0) and (L_Cell_AtP.Chess_Y > 0) and (L_Cell_AtP.Chess_Y <= 8) then
   begin
   {}
    ChessBoard.OnCheck_figure_in_cell(not Color_White, L_Cell_AtP, FigureID, Checktotheking);
    if FigureID = fid_king then
     result := true;
   {}
   end;
 {}
  if (X1 < 9) and (R_Cell_AtP.Chess_Y > 0) and (R_Cell_AtP.Chess_Y <= 8) then
   begin
   {}
    ChessBoard.OnCheck_figure_in_cell(not Color_White, R_Cell_AtP, FigureID, Checktotheking);
    if FigureID = fid_king then
     result := true;
   {}
   end;
 {}
 end;
{} 
end;

Function TKNIGHT.Check_Step(Position : TPosition) : Boolean;
 Var
  X, X1     : Integer;
  Y, Y1     : Integer;
  FigureID  : Byte;
  cell_cy   : Integer; // перемещение по "Y" в кол-ве ячеек
  cell_cx   : Integer; // перемещение по "X" в кол-ве ячеек
  Step_F    : Boolean; // можно или нет совершить ход
  help_king : Boolean; // переменная уст. в истину только тогда, когда королю шах и данная фигура спасет его от шаха срубив вражескую
  Checktotheking : Boolean; //
  SaveFPosition  : TPosition;
begin
{-- Преобразуем позицию по X --}
 X      := ChessBoard.SymbolicPosToIndex(Position.Chess_X);
 X1     := ChessBoard.SymbolicPosToIndex(FPosition.Chess_X);
{-- Преобразуем позицию по Y --}
 Y      := Position.Chess_Y;
 Y1     := FPosition.Chess_Y;
{-- Что может конь? --
     - конь может перепрыгивать через свои и вражеские фигуры
     - конь может двигаться назад, вперед и вправо, влево,
        при этом он ходит буквой "Г" --}
{}
 help_king := false;
{}
 cell_cy := abs(Y - Y1);
 cell_cx := abs(X - X1);
{}
 Step_F := ((cell_cy = 2) and (cell_cx = 1)) or ((cell_cx = 2) and (cell_cy = 1));
{-- далее мы проверяем рубит ли кого-то конь? --}
 if Assigned(ChessBoard.OnCheck_figure_in_cell) and step_f then // ситуация 1
  begin
   step_f    := ChessBoard.OnCheck_figure_in_cell(not FColor_White, Position, FigureID, Checktotheking) and step_f;
   {-- Если рубит то запоминаем что у этой фигуры было в переменной BCheck_to_the_king --}
   if step_f then help_king := Checktotheking else
    step_f := true;
   {}
  end;
{-- конь не может встать в позицию в которой есть "своя" фигура --}
  step_f := (not ChessBoard.OnCheck_figure_in_cell(FColor_White, Position, FigureID, Checktotheking)) and step_f;
{-- теперь когда теор фигура может совершить ход нам нужно проверить следующее:
    1) Есть ли такая вражеская фигура, которая сделала шах нашему королю?[да, нет]
       а) [нет]: Если нету проверяем делает ли наша ф. шах враж. королю и
                  одновременно проверяем не подставляем ли мы нашего короля под шах !
       б) [да]:  Если есть то проверяем: ход нашей ф. спасет от угрозы нашего короля?, если спасет то ей можно ходить иначе нельзя --}
 if step_f then
  begin
  {}
   if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
    begin
     {-- Есть шах нашему королю --}
      if help_king then
       result := help_king else
       begin
       {--- Здесь нужно вставить проверку: перекрывает ли линию атаки данная фигура,
            таким образом спасает ли она короля от угрозы ---}
       {}
        {-1-}
        Position.Chess_Y   := Y;
        SaveFPosition      := FPosition;
        FPosition          := Position; // Выполняем пункт 1 меняем временно текущую позицию фигуры
        {-2-}
        if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
         begin
          FPosition          := SaveFPosition;
          result := false;
          exit;
         end;
        {-3-}
        FPosition := SaveFPosition; // на отображении это не отражается !!!
        result    := Step_F;
       {}
       end;
       {}
       exit;
       {}
    end else
    begin
     {-- Нет шаха нашему королю --}
      {-- Но теперь надо проверить главное: не подставляем ли мы короля под удар своим ходом?
          А для этого нам нужно сделать следующее:
          1) поменять временно текущую позицию фигуры на позицию в которую ее хотят поставить
          2) после чего для каждой вражеской фигуры на доске вызвать функцию: Check_to_the_king
             и если она хотя бы раз возвратит истину то
             значит мы подставляем короля а этого не в коем случае нельзя делать!
          3) Возвращаем все как было, то есть текущую позицию фигуры, делаем такой какой она была до проверки !    --}
      {-1-}
       Position.Chess_Y   := Y;
       SaveFPosition      := FPosition;
       FPosition          := Position; // Выполняем пункт 1 меняем временно текущую позицию фигуры
                                       // на отображении это не отражается !!!
      {-2-}
        if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
         begin
          FPosition          := SaveFPosition;
          result := false;
          exit;
         end;
      {-3-}
       FPosition          := SaveFPosition;
      {-------------------------------------------------------------------------------}
      {-- Если данная фигура делает шах враж. королю нам нужно запомнить этот факт! --}
      Bcheck_to_the_king := Check_to_the_king(Position);
    end;
  {}
  end;
{}  
 result := Step_F;
{}
end;

{-- TBISHOP -- слон}
Function TBISHOP.Check_to_the_king(Position : TPosition) : Boolean;
 var
  BISHOP_CellColorW : Boolean;
  KING_CellColorW   : Boolean;
  Step              : TStep;
  Step_K            : TStep;
  King              : TFigure;
  POS_              : TPosition;
{}
  X, X1     : Integer;
  Y, Y1     : Integer;
{}
  cell_cy   : Integer; // перемещение по "Y" в кол-ве ячеек
  cell_cx   : Integer; // перемещение по "X" в кол-ве ячеек
{}
  fid_        : Byte;
  checkthking : Boolean;
{}
begin
{--- Как проверить делает ли этот слон(ферзь или ладья) шах королю? ---
      Если проверка для слона, то может для начала проверить
      а) клетка на которой стоит слон
      имеет такой же цвет как и клетка на которой стоит король?
       [да]: Тогда этот слон может поставить шах или мат (теор)
       [нет]: У этого слана нет возможности поставить шах или мат --}
 Step.Chess_Y      := Position.Chess_Y;
 Step.Chess_X      := Position.Chess_X;
{}
 King              := ChessBoard.OnGetFirstFigureByFID(fid_king, not FColor_White, POS_);
 Step_K.Chess_Y    := King.FPosition.Chess_Y;
 Step_K.Chess_X    := King.FPosition.Chess_X;
 KING_CellColorW   := not ChessBoard.Black_Cell(Step_K);
{}
 if FID = fid_BISHOP then
  begin
  {}
   BISHOP_CellColorW := not ChessBoard.Black_Cell(Step);
   if BISHOP_CellColorW then
    result := (BISHOP_CellColorW and KING_CellColorW) else
    result := (not BISHOP_CellColorW and not KING_CellColorW);
  {}
   if not result then exit;
  {} 
  end;
{-- теперь когда данная фигура теор. может угрожать королю проверяем есть ли король на линии атаки --}
{-- Преобразуем позицию по X --}
 X      := ChessBoard.SymbolicPosToIndex(Step_K.Chess_X);
 X1     := ChessBoard.SymbolicPosToIndex(Step.Chess_X);
{-- Преобразуем позицию по Y --}
 Y      := Step_K.Chess_Y;
 Y1     := Step.Chess_Y;
{}
 cell_cy := abs(Y - Y1);
 cell_cx := abs(X - X1);
{}
  {}
   result := Can_cell_cxy(cell_cx, cell_cy);
   if not result then exit;
  {}
{-- Проверяем ситуацию, когда фигуру хотят срубить и для нее вся эта проверка вообще не актуальна ---}
 if ChessBoard.OnCheck_figure_in_cell(not Color_White, Position, fid_, checkthking) then
  begin
  {}
   result := false;
   exit;
  {}
  end;
{-- По прежнему данная фигура только теор. может угрожать королю,
    так как мы не проверили есть ли на линии атаки такие фигуры которые защищают короля !!!--}
 Position.Chess_Y := Step_K.Chess_Y;
 Position.Chess_X := Step_K.Chess_X;
 result := Check_to_Line(Position);
{}
end;

function TBISHOP.Can_cell_cxy(cell_cx, cell_cy : Integer) : Boolean;
begin
{}
 If (FID = fid_BISHOP) then  // Если слон
  result := (cell_cy = cell_cx) else
 If (FID = fid_Queen)  then // Если ферзь
  result := (cell_cy = cell_cx) or
            ((cell_cy = 0) and (cell_cx <> 0)) or
            ((cell_cx = 0) and (cell_cy <> 0)) else
 If (FID = fid_rook)  then  // Если ладья
  result := ((cell_cy = 0) and (cell_cx <> 0)) or
            ((cell_cx = 0) and (cell_cy <> 0)) else
 If (FID = fid_king)  then  // Если король
  result := ((cell_cy = cell_cx) and (cell_cy = 1)) or
            ((cell_cy = 0) and (cell_cx <> 0) and (cell_cx < 2)) or
            ((cell_cx = 0) and (cell_cy <> 0) and (cell_cy < 2))
{}            
             else result := (cell_cy = cell_cx);
{}
end;

Function TBISHOP.Check_Step(Position : TPosition) : Boolean;
 Var
  X, X1          : Integer;
  Y, Y1          : Integer;
  FigureID       : Byte;
  cell_cy        : Integer; // перемещение по "Y" в кол-ве ячеек
  cell_cx        : Integer; // перемещение по "X" в кол-ве ячеек
  Step_F         : Boolean; // можно или нет совершить ход
  help_king      : Boolean; // переменная уст. в истину только тогда, когда королю шах и данная фигура спасет его от шаха срубив вражескую
  Checktotheking : Boolean; //
  SaveFPosition  : TPosition;
{}
begin
 result := false;
{-- Преобразуем позицию по X --}
 X      := ChessBoard.SymbolicPosToIndex(Position.Chess_X);
 X1     := ChessBoard.SymbolicPosToIndex(FPosition.Chess_X);
{-- Преобразуем позицию по Y --}
 Y      := Position.Chess_Y;
 Y1     := FPosition.Chess_Y;
{-- Что может слон? --
     - слон может двигаться:
        назад и вправо,
        назад и влево,
        вперед и вправо,
        вперед и влево,
        при этом кол-во клеток перемещения по "X" должно быть равно
        кол-ву клеток перемещения по "Y" (при этом "X" и "Y" по модулю конечно же).
     - слон не может перепрыгивать через свои и вражеские фигуры   
        --}
{}
 help_king := false;
{}
 cell_cy := abs(Y - Y1);
 cell_cx := abs(X - X1);
{}
 Step_F  := Can_cell_cxy(cell_cx, cell_cy);
{}
 if Step_F then
  begin
  {-- здесь проверяем чтобы слон не дай бог не прыгнул через чужую или свою фигуру ---}
  {-- и одновременно проверяем чтобы слон не вставал в позицию где есть своя фигура --}
   Step_F := Check_to_Line(Position);
   if not Step_F then exit;
  end else exit;
{-- далее мы проверяем рубит ли кого-то слон? --}
 if Assigned(ChessBoard.OnCheck_figure_in_cell) and step_f then // ситуация 1
  begin
   step_f    := ChessBoard.OnCheck_figure_in_cell(not FColor_White, Position, FigureID, Checktotheking) and step_f;
   {-- Если рубит то запоминаем что у этой фигуры было в переменной BCheck_to_the_king --}
   if step_f then help_king := Checktotheking else
    step_f := true;
   {}
  end;
{-- теперь когда теор фигура может совершить ход нам нужно проверить следующее:
    1) Есть ли такая вражеская фигура, которая сделала шах нашему королю?[да, нет]
       а) [нет]: Если нету проверяем делает ли наша ф. шах враж. королю и
                  одновременно проверяем не подставляем ли мы нашего короля под шах !
       б) [да]:  Если есть то проверяем: ход нашей ф. спасет от угрозы нашего короля?, если спасет то ей можно ходить иначе нельзя --}
 if step_f then
  begin
  {}
   if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
    begin
     {-- Есть шах нашему королю --}
      if help_king and (FID <> fid_king) then
       begin
        result := help_king;
       end else
       begin
       {--- Здесь нужно вставить проверку: перекрывает ли линию атаки данная фигура,
            таким образом спасает ли она короля от угрозы ---}
       {}
        {-1-}
        Position.Chess_Y   := Y;
        SaveFPosition      := FPosition;
        FPosition          := Position; // Выполняем пункт 1 меняем временно текущую позицию фигуры
        {-2-}
        if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
         begin
          FPosition          := SaveFPosition;
          result := false;
          exit;
         end;
        {-3-}
        FPosition := SaveFPosition; // на отображении это не отражается !!!
        result    := Step_F;
       {}
       end;
       {}
       exit;
       {}
    end else
    begin
     {-- Нет шаха нашему королю --}
      Position.Chess_Y   := Y;
      {-- Но теперь надо проверить главное: не подставляем ли мы короля под удар своим ходом?
          А для этого нам нужно сделать следующее:
          1) поменять временно текущую позицию фигуры на позицию в которую ее хотят поставить
          2) после чего для каждой вражеской фигуры на доске вызвать функцию: Check_to_the_king
             и если она хотя бы раз возвратит истину то
             значит мы подставляем короля а этого не в коем случае нельзя делать!
          3) Возвращаем все как было, то есть текущую позицию фигуры, делаем такой какой она была до проверки !    --}
      {-1-}    
       SaveFPosition      := FPosition;
       FPosition          := Position; // Выполняем пункт 1 меняем временно текущую позицию фигуры
                                       // на отображении это не отражается !!!
      {-2-}
        if ChessBoard.OnIsCheck_to_the_king(not FColor_White) then
         begin
          FPosition          := SaveFPosition;
          result := false;
          exit;
         end;
      {-3-}
       FPosition          := SaveFPosition;
      {-------------------------------------------------------------------------------}
      {-- Если данная фигура делает шах враж. королю нам нужно запомнить этот факт! --}
      Bcheck_to_the_king := Check_to_the_king(Position);
    end;
  {}
  end;
{}  
 result := Step_F;
{}
end;

function TBISHOP.Check_to_Line(Position : TPosition) : Boolean;
 Var
  X, X1          : Integer;
  Y, Y1          : Integer;
  cell_cy        : Integer; // перемещение по "Y" в кол-ве ячеек
  cell_cx        : Integer; // перемещение по "X" в кол-ве ячеек
  LeftCheckB     : Boolean;
  POS_           : TPosition;
  j              : Integer;
  fid_           : Byte;
  checkthking    : Boolean;
{}
  cicl_count     : Integer;
{}
begin
{}
 result := false;
{-- Преобразуем позицию по X --}
 X      := ChessBoard.SymbolicPosToIndex(Position.Chess_X);
 X1     := ChessBoard.SymbolicPosToIndex(FPosition.Chess_X);
{-- Преобразуем позицию по Y --}
 Y      := Position.Chess_Y;
 Y1     := FPosition.Chess_Y;
{}
 cell_cy := abs(Y - Y1);
 cell_cx := abs(X - X1);
 if cell_cx <> 0 then ;
{}
 LeftCheckB := (X < X1);
 POS_       := FPosition;
{}
 if (Y1 <> Y) then
  cicl_count := cell_cy else
  cicl_count := cell_cx;
{}
// if (FID = fid_king) and (cicl_count > 1) then exit;
{}
 For J := 1 to cicl_count do
  begin
  {}
   if (Y1 < Y) then
    POS_.Chess_Y := POS_.Chess_Y + 1 else
   if (Y1 <> Y) then
    POS_.Chess_Y := POS_.Chess_Y - 1;
  {}
    if (Y1 = Y) then
     begin
     {}
      if LeftCheckB then
       POS_.Chess_X := ChessBoard.IndexToSymbolicPos( ChessBoard.SymbolicPosToIndex(POS_.Chess_X) - 1 ) else
       POS_.Chess_X := ChessBoard.IndexToSymbolicPos( ChessBoard.SymbolicPosToIndex(POS_.Chess_X) + 1 );
     {}
     end else
     begin
     {}
      if (X <> X1) then
       if LeftCheckB then
        POS_.Chess_X := ChessBoard.IndexToSymbolicPos( ChessBoard.SymbolicPosToIndex(POS_.Chess_X) - 1 )
         else
        POS_.Chess_X := ChessBoard.IndexToSymbolicPos( ChessBoard.SymbolicPosToIndex(POS_.Chess_X) + 1 );
     {}
     end;
  {}
   if ((POS_.Chess_Y = Position.Chess_Y) and (POS_.Chess_X = Position.Chess_X)) then
    begin
    {}
     if (ChessBoard.OnCheck_figure_in_cell(not FColor_White, POS_, fid_, checkthking)) then
      begin
      {}
       result := true; // Здесь мы рубим чужую фигуру, а до нее на линии ничего небыло (разрешено!)
       break;
      {}
      end else
     if (ChessBoard.OnCheck_figure_in_cell(FColor_White, POS_, fid_, checkthking)) then
      begin
      {}
       result := false; // Здесь мы встаем в позицию где есть наша фигура (запрещено!)
       break;
      {}
      end else
      begin
      {}
       result := true;
      {}
      end;
    {}
    end else
   if ((ChessBoard.OnCheck_figure_in_cell(true, POS_, fid_, checkthking)) or
      (ChessBoard.OnCheck_figure_in_cell(false, POS_, fid_, checkthking))) then
    begin
    {}
     result := false; // На линии перемещения оказалась фигура (запрещено!)
     break;
    {}
    end else
    begin
    {}
     result := true;
    {}
    end;
  {}
  end;
{}
end;

{-- TKing -- король}
Constructor TKing.Create(Position : TPosition; Color_White : Boolean);
begin
{}
 inherited Create(Position, Color_White);
 IsPossibleCastle := true;  // Рокировка возможна если истина !
 castle_bool      := false; // Логич. признак того что король уже совершил рокировку
{}
end;

function TKing.Check_Step;
{}
 Var
  cf_0           : Boolean;
  cf_1           : Boolean;
  cf_2           : Boolean;
  FigureID       : Byte;
  Checktotheking : Boolean;
{}
begin
 result := inherited Check_Step(Position);
 if (result or castle_bool) then IsPossibleCastle := false else
 if (not result) and (IsPossibleCastle) then
  begin
  {--- Проверяем а что если здесь имеет место попытка рокировки --}
    if Color_White and // Проверка для белого короля
       (Position.Chess_Y = 8) and
       (Position.Chess_X = G) then
     begin
     {}
      Position.Chess_X := F;
      cf_0  := ChessBoard.OnCheck_figure_in_cell(FColor_White, Position, FigureID, Checktotheking);
      Position.Chess_X := G;
      cf_1 := ChessBoard.OnCheck_figure_in_cell(FColor_White, Position, FigureID, Checktotheking);
      Position.Chess_X := H;
      cf_2 := ChessBoard.OnCheck_figure_in_cell(FColor_White, Position, FigureID, Checktotheking);
      if (FigureID = fid_rook) and
         (not (cf_0 or cf_1) and cf_2)then
       begin
       {}
        castle_bool := true; // Сообщ. о рокировке
        result      := true;
       {} 
       end;
     {} 
     end;
  {}
  end;
end;
{------------------}


Procedure TForm1.ChessBox_BeforeDoubleClick(POS : TPosition; Var DoubleClick : Boolean);
 Var
  Find_In : Boolean;
  I       : Integer;
begin
{}
 Find_In := false; Select_ := 0;
 For I := 0 to Count_f - 1 do
  begin
  {}
   if not Assigned(Arr_figure[I]) then continue;
  {}
   if (POS.Chess_Y = Arr_figure[I].Position.Chess_Y) and
      (POS.Chess_X = Arr_figure[I].Position.Chess_X) then
    begin
    {}
     Select_  := I;
     Find_In  := true;
     break;
    {}
    end;
  {}
  end;
{}
 if ChessBoard.Step_White and Find_In then
  begin
  {}
   if not Arr_figure[Select_].FColor_White then
    DoubleClick := false;
  {}
  end;
{}  
 if not ChessBoard.Step_White and Find_In then
  begin
  {}
   if Arr_figure[Select_].FColor_White then
    DoubleClick := false;
  {}
  end;
{}
 if not Find_In then DoubleClick := false;
{}
end;

function TForm1.GetFirstFigureByFID(FID : Byte; White_figure : Boolean; Var POS : TPosition) : TFigure;
 Var
  I       : Integer;
  Find_In : Boolean;
  Select_ : Integer;
begin
{}
{}  Find_In := false; Select_  := -1; result := nil;
 For I := 0 to Count_f - 1 do
  begin
  {}
   if not Assigned(Arr_figure[I]) then continue;
  {}
   if (Arr_figure[I].Color_White = White_figure) and
      (Arr_figure[I].FID         = FID) {} then
    begin
    {}
     POS.Chess_Y := Arr_figure[I].Position.Chess_Y;
     POS.Chess_X := Arr_figure[I].Position.Chess_X;
    {}
     Select_  := I;
     Find_In  := true;
     break;
    {}
    end;
  {}
  end;
{}
 if Find_In then
  result := Arr_figure[Select_];
{}
end;

function TForm1.GetSelIndexFigureInPOS(White_figure : Boolean; POS : TPosition) : Integer;
 Var
  POS_     : TStep;
  I       : Integer;
  Find_In : Boolean;
  Select_ : Integer;
begin
{}
 POS_.Chess_Y := POS.Chess_Y;
 POS_.Chess_X := POS.Chess_X;
{}  Find_In := false; Select_  := -1; result := Select_;
 For I := 0 to Count_f - 1 do
  begin
  {}
   if not Assigned(Arr_figure[I]) then continue;
  {}
   if (POS_.Chess_Y = Arr_figure[I].Position.Chess_Y) and
      (POS_.Chess_X = Arr_figure[I].Position.Chess_X) and
      (Arr_figure[I].Color_White = White_figure) {} then
    begin
    {}
     Select_  := I;
     Find_In  := true;
     break;
    {}
    end;
  {}
  end;
{}
 if Find_In then
  result := Select_;
{}
end;

function TForm1.Check_destroyFigure(Step_White : Boolean; Step : TStep) : Boolean;
 Var
  POS     : TPosition;
  Find_In : Boolean;
  Select_ : Integer;
begin
{}
 POS.Chess_Y := Step.Chess_Y;
 POS.Chess_X := Step.Chess_X;
 Select_     := GetSelIndexFigureInPOS(not Step_White, POS);
 Find_In     := (Select_ <> -1);
{}
 if Find_In then
  begin
  {-- Если срубили фигуру то освобождаем память --}
   Arr_figure[Select_].Free;
   Arr_figure[Select_] := nil;
  {}
  end;
 result := Find_In; 
{}
end;

procedure TForm1.ChessBox_BeforeMoveFigure(NewPOS : TPosition; Var MoveFigure : Boolean);
{}
 Var
  Step     : TStep;
  POS      : TPosition;
  SelRookI : Integer;
{}
begin
{}
 MoveFigure := false;
 if Select_ = -1 then exit;
{}
 Step.Chess_Y := NewPOS.Chess_Y;
 Step.Chess_X := NewPOS.Chess_X;
 MoveFigure   := Arr_figure[Select_].Step(Step);
 if MoveFigure{-- Если фигура перемещена --} then
  begin
  {-- определяем срубили мы фигуру или нет --}
   Check_destroyFigure(ChessBoard.Step_White, Step);
  {-- Проверка на рокировку короля --}
   if (Arr_figure[Select_].FID = fid_king) then
    begin
    {}
     if (Arr_figure[Select_] as TKing).castle_bool and
        (Arr_figure[Select_] as TKing).IsPossibleCastle then
      begin
      {}
       POS         := Arr_figure[Select_].Position;
       POS.Chess_X := H;
       SelRookI    := GetSelIndexFigureInPOS(Arr_figure[Select_].FColor_White, POS);
       Arr_figure[SelRookI].FPosition.Chess_X := F;
       Arr_figure[SelRookI].MoveFigure(Arr_figure[SelRookI].FPosition);
      {}
      end;
    {}
    end;
  {--- Проверка на повышение пешки в звании! ---}
   if (Arr_figure[Select_].FID = fid_pawn) then
    begin
    {}
     if Arr_figure[Select_].Color_White and
        (Arr_figure[Select_].FPosition.Chess_Y = 1) then
       begin
       {-- ситуация когда пешка повышается в звании!!! --}
        Arr_figure[Select_].Free;
        Arr_figure[Select_] := TQueen.Create(NewPOS, CreateWhiteFigure);
       end else
     if not Arr_figure[Select_].Color_White and
        (Arr_figure[Select_].FPosition.Chess_Y = 8) then
       begin
       {-- ситуация когда пешка повышается в звании!!! --}
        Arr_figure[Select_].Free;
        Arr_figure[Select_] := TQueen.Create(NewPOS, CreateBlackFigure);
       end; 
    {}
    end;
  {-- проверка на мат --}
  
  {}
  end;
{}
end;

function  TForm1.IsCheck_to_the_king(White_figure : Boolean) : Boolean;
 Var
  I       : Integer;
begin
{}
 result := false;
 For I := 0 to Count_f - 1 do
  begin
  {}
   if not Assigned(Arr_figure[i]) then continue;
  {}
   if (Arr_figure[i].Color_White = White_figure) then
   if Arr_figure[i].Bcheck_to_the_king then
    begin
    {}
     result := Arr_figure[i].Check_to_the_king(Arr_figure[i].FPosition);
     if result then break;
    {} 
    end else
    begin
    {}
     result := Arr_figure[i].Check_to_the_king(Arr_figure[i].FPosition);
     if result then break;
    {}
    end;
  {}
  end;
{} 
end;

function TForm1.Check_figure_in_cell(White_figure : Boolean; POS : TPosition;
           Var FigureID : Byte;
           Var Check_to_the_king : Boolean) : Boolean;
 Var
  Select_ : Integer;
begin
{}
 result := false; FigureID := 0;
 Select_ := GetSelIndexFigureInPOS(White_figure, POS);
 if Select_ <> -1 then
  begin
   result := true;
   if Assigned(Arr_figure[Select_]) then
    FigureID := Arr_figure[Select_].FID;
    Check_to_the_king := Arr_figure[Select_].Bcheck_to_the_king;
  end;
{}
end;

procedure TForm1.FormCreate(Sender: TObject);
 Var
  Position : TPosition;
  I        : Integer;
begin
{}
 ChessBoard                        := TChessBoard.Create(20,20, width, height, self);
 ChessBoard.Parent                 := self;
{--- подкл обработчиков событий ---}
 ChessBoard.OnBeforeDoubleClick    := ChessBox_BeforeDoubleClick;
 ChessBoard.OnBeforeMoveFigure     := ChessBox_BeforeMoveFigure;
 ChessBoard.OnCheck_figure_in_cell := Check_figure_in_cell;
 ChessBoard.OnIsCheck_to_the_king  := IsCheck_to_the_king;
 ChessBoard.OnGetFirstFigureByFID  := GetFirstFigureByFID;
{}
 Select_                      := -1;
{--- Создание массива фигур ---}
 Count_f          := 32;
 SetLength(Arr_figure, Count_f);
{--- Создание "белых" фигур ---}
 For I := 1 to 8 do
  begin
  {--- создание пешек --}
   Position.Chess_Y := 7;
   Position.Chess_X := ChessBoard.IndexToSymbolicPos(I);
   Arr_figure[I-1]  := TPawn.Create(Position, CreateWhiteFigure);
  {}
  end;
{}
 For I := 1 to 8 do
  begin
  {--- создание остальных фигур --}
   Position.Chess_Y    := 8;
   Position.Chess_X    := ChessBoard.IndexToSymbolicPos(I);
   Case I of
    1: Arr_figure[(I+8)-1] := TRook.Create(Position, CreateWhiteFigure);   {-- ладья --}
    2: Arr_figure[(I+8)-1] := TKNIGHT.Create(Position, CreateWhiteFigure); {-- конь --}
    3: Arr_figure[(I+8)-1] := TBISHOP.Create(Position, CreateWhiteFigure); {-- слон --}
    4: Arr_figure[(I+8)-1] := TQueen.Create(Position, CreateWhiteFigure);  {-- ферзь --}
    5: Arr_figure[(I+8)-1] := TKing.Create(Position, CreateWhiteFigure);   {-- король --}
    6: Arr_figure[(I+8)-1] := TBISHOP.Create(Position, CreateWhiteFigure); {-- слон --}
    7: Arr_figure[(I+8)-1] := TKNIGHT.Create(Position, CreateWhiteFigure); {-- конь --}
    8: Arr_figure[(I+8)-1] := TRook.Create(Position, CreateWhiteFigure);   {-- ладья --}
   end; 
  {}
  end;
{}

{--- Создание "черных" фигур  ---}
 For I := 1 to 8 do
  begin
  {--- создание пешек --}
   Position.Chess_Y     := 2;
   Position.Chess_X     := ChessBoard.IndexToSymbolicPos(I);
   Arr_figure[(I+16)-1] := TPawn.Create(Position, CreateBlackFigure);
  {}
  end;  (**)
{} 
 For I := 1 to 8 do
  begin
  {--- создание остальных фигур --}
   Position.Chess_Y     := 1;
   Position.Chess_X     := ChessBoard.IndexToSymbolicPos(I);
   Case I of
    1: Arr_figure[(I+24)-1] := TRook.Create(Position, CreateBlackFigure);   {-- ладья --}
    2: Arr_figure[(I+24)-1] := TKNIGHT.Create(Position, CreateBlackFigure); {-- конь --}
    3: Arr_figure[(I+24)-1] := TBISHOP.Create(Position, CreateBlackFigure); {-- слон --}
    4: Arr_figure[(I+24)-1] := TQueen.Create(Position, CreateBlackFigure);  {-- ферзь --}
    5: Arr_figure[(I+24)-1] := TKing.Create(Position, CreateBlackFigure);   {-- король --}
    6: Arr_figure[(I+24)-1] := TBISHOP.Create(Position, CreateBlackFigure); {-- слон --}
    7: Arr_figure[(I+24)-1] := TKNIGHT.Create(Position, CreateBlackFigure); {-- конь --}
    8: Arr_figure[(I+24)-1] := TRook.Create(Position, CreateBlackFigure);   {-- ладья --}
   end;
  {}
  end;
{} (**)
end;

end.
 