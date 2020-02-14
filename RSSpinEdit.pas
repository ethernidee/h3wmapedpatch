unit RSSpinEdit;

{ *********************************************************************** }
{                                                                         }
{ RSPak                                    Copyright (c) Rozhenko Sergey  }
{ http://sites.google.com/site/sergroj/                                   }
{ sergroj@mail.ru                                                         }
{                                                                         }
{ This file is a subject to any one of these licenses at your choice:     }
{ BSD License, MIT License, Apache License, Mozilla Public License.       }
{                                                                         }
{ *********************************************************************** }
{$I RSPak.inc}

interface

uses Windows, Classes, StdCtrls, Controls, Messages, SysUtils,
  Graphics, Buttons, Themes, RSCommon, UxTheme, RSSpeedButton, RSGraphics,
  RSStrUtils, RSTimer, RSQ;

{$I RSWinControlImport.inc}

type
  TNumGlyphs = Buttons.TNumGlyphs;
  TRSSpinButton = class;
  TRSSpinEvent = procedure (Sender:TRSSpinButton; SpinnedBy:integer) of object;

{ TRSSpinButton }

  TRSSpinButton = class (TCustomControl)
  private
    FButton: TObject;
    FDownButton: TRSSpeedButton;
    FDownKey: boolean;
    FFirstPause: integer;
    FFocusControl: TWinControl;
    FFocusedButton: TRSSpeedButton;
    FOnCreateParams: TRSCreateParamsEvent;
    FOnDownClick: TRSSpinEvent;
    FOnUpClick: TRSSpinEvent;
    FPause: integer;
    FProps: TRSWinControlProps;
    FSpin: boolean;
    FSpinFactor: integer;
    FTimer: TRSTimer;
    FUpButton: TRSSpeedButton;
    FUpKey: boolean;
    function GetDownGlyph: TBitmap;
    function GetDownNumGlyphs: TNumGlyphs;
    function GetFlat: boolean;
    function GetFlatHighlighted: boolean;
    function GetStyled: boolean;
    function GetStyledOnXP: boolean;
    function GetUpGlyph: TBitmap;
    function GetUpNumGlyphs: TNumGlyphs;
    procedure SetDownButton(v: TRSSpeedButton);
    procedure SetDownGlyph(Value: TBitmap);
    procedure SetDownNumGlyphs(Value: TNumGlyphs);
    procedure SetFlat(Value: boolean);
    procedure SetFlatHighlighted(Value: boolean);
    procedure SetFocusBtn(Btn: TRSSpeedButton);
    procedure SetStyled(v: boolean);
    procedure SetStyledOnXP(v: boolean);
    procedure SetUpButton(v: TRSSpeedButton);
    procedure SetUpGlyph(Value: TBitmap);
    procedure SetUpNumGlyphs(Value: TNumGlyphs);
    procedure WMGetDlgCode(var message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSize(var message: TWMSize); message WM_SIZE;
  protected
    procedure BtnMouseDown(Sender: TObject; Button: TMouseButton; Shift:
            TShiftState; X, Y: integer);
    procedure BtnMouseUp(Sender: TObject; Button: TMouseButton; Shift:
            TShiftState; X, Y: integer);
    procedure ButtonPaint(Sender: TRSSpeedButton; DefaultPaint:TRSProcedure;
            var AState: TButtonState; var MouseInControl:boolean;
            MouseReallyInControl:boolean); dynamic;
    function CreateButton: TRSSpeedButton;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ForceButtons;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure KeyUp(var Key: word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
            override;
    procedure PressDownKey(v:boolean);
    procedure PressUpKey(v:boolean);
    procedure SetEnabled(v:boolean); override;

    procedure SizeChanged; virtual;
    procedure DoUpClick(SpinnedBy:int); virtual;
    procedure DoDownClick(SpinnedBy:int); virtual;

    procedure Timer(Sender: TObject);
    procedure TranslateWndProc(var Msg: TMessage);
    procedure WndProc(var Msg: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: integer); override;
    property Spinning: boolean read FSpin;
  published
    property DownButton: TRSSpeedButton read FDownButton write SetDownButton;
    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph stored false;
    property DownNumGlyphs: TNumGlyphs read GetDownNumGlyphs write SetDownNumGlyphs stored false;
    property Flat: boolean read GetFlat write SetFlat stored false;
    property FlatHighlighted: boolean read GetFlatHighlighted write SetFlatHighlighted stored false;
    property FocusControl: TWinControl read FFocusControl write FFocusControl;
    property InitRepeatPause: integer read FFirstPause write FFirstPause
            default 400;
    property RepeatPause: integer read FPause write FPause default 100;
    property SpinFactor: integer read FSpinFactor write FSpinFactor;
    property Styled: boolean read GetStyled write SetStyled stored false;
    property StyledOnXP: boolean read GetStyledOnXP write SetStyledOnXP stored false;
    property UpButton: TRSSpeedButton read FUpButton write SetUpButton;
    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph stored false;
    property UpNumGlyphs: TNumGlyphs read GetUpNumGlyphs write SetUpNumGlyphs stored false;
    property OnDownClick: TRSSpinEvent read FOnDownClick write FOnDownClick;
    property OnUpClick: TRSSpinEvent read FOnUpClick write FOnUpClick;

    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BevelWidth;
    property Canvas;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCanResize;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    {$I RSWinControlProps.inc}
  end;

{ TRSSpinEdit }

  TRSSpinEdit = class (TCustomEdit)
  private
    FBase: integer;
    FButton: TRSSpinButton;
    FEditorEnabled: boolean;
    FIncrement: LongInt;
    FLastValue: integer;
    FMaxValue: LongInt;
    FMinValue: LongInt;
    FOnChanged: TNotifyEvent;
    FOnCreateParams: TRSCreateParamsEvent;
    FOnDownClick: TNotifyEvent;
    FOnUpClick: TNotifyEvent;
    FProps: TRSWinControlProps;
    FSelAnchor: int;
    FThous: boolean;
    FThousSep: char;
    FValue: integer;
    FDigits: int;
    procedure CMEnter(var message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var message: TCMExit); message CM_EXIT;
    function GetCaret: int;
    function GetMinHeight: integer;
    function GetStyled: boolean;
    function GetStyledOnXP: boolean;
    function GetValue: LongInt;
    procedure SetBase(v: integer);
    procedure SetButton(v: TRSSpinButton);
    procedure SetCaret(v: int);
    procedure SetMaxValue(v: LongInt);
    procedure SetMinValue(v: LongInt);
    procedure SetStyled(v: boolean);
    procedure SetStyledOnXP(v: boolean);
    procedure SetThous(b: boolean);
    procedure SetThousSep(c: char);
    procedure SetValue(NewValue: LongInt);
    procedure WMCut(var message: TWMCut); message WM_CUT;
    procedure WMKillFocus(var message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMPaste(var message: TWMPaste); message WM_PASTE;
    procedure WMSize(var message: TWMSize); message WM_SIZE;
    procedure SetDigits(v:int);
  protected
    function CheckValue(NewValue: LongInt): LongInt;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DoChanged;
    procedure DoDown(SpinnedBy:integer; Clicked:boolean=false); virtual;
    procedure DoUp(SpinnedBy:integer; Clicked:boolean=false); virtual;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function IsValidChar(Key: char): boolean; virtual;
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    procedure KeyUp(var Key: word; Shift: TShiftState); override;
    procedure MakeVisibleH;
    procedure SetEditRect;
    procedure SetEnabled(v:boolean); override;
    procedure TranslateWndProc(var Msg: TMessage);
    procedure Validate;
    procedure WndProc(var Msg: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetSelection(var Start, Caret: integer);
    procedure PlaceButton;
    procedure SetSelection(Start, Caret:int);
    property Caret: int read GetCaret write SetCaret;
  published
    property Base: integer read FBase write SetBase default 0;
    property Button: TRSSpinButton read FButton write SetButton;
    property Digits: int read FDigits write SetDigits default 0;
    property EditorEnabled: boolean read FEditorEnabled write FEditorEnabled default True;
    property Increment: LongInt read FIncrement write FIncrement default 1;
    property MaxValue: LongInt read FMaxValue write SetMaxValue default High(int);
    property MinValue: LongInt read FMinValue write SetMinValue default Low(int);
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
    property Styled: boolean read GetStyled write SetStyled stored false;
    property StyledOnXP: boolean read GetStyledOnXP write SetStyledOnXP stored false;
    property Thousands: boolean read FThous write SetThous default false;
    property ThousandsSeparator: char read FThousSep write SetThousSep default #0;
    property Value: LongInt read GetValue write SetValue default 0;
    property Align;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property OnCanResize;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    
{$IFDEF D2005}
    property OnMouseActivate;
{$ENDIF}
    {$I RSWinControlProps.inc}
  end;


{$R RSSpinEdit.res}

implementation

{
******************************** TRSSpinButton *********************************
}

type
  TRSSpinSpeedButton = class (TRSSpeedButton)
  protected
    procedure DoPaint; override;
    procedure DoInheritedPaint;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
  public
    constructor Create(AOwner:TComponent); override;
  published
    property DrawFrame default true;
  end;

{ TRSSpinSpeedButton }

constructor TRSSpinSpeedButton.Create(AOwner: TComponent);
begin
  inherited;
  DrawFrame:=true;
end;

procedure TRSSpinSpeedButton.DoInheritedPaint;
begin
  Canvas.Brush:= FNoBrush;
  Canvas.Pen:= FNoPen;
  inherited DoPaint;
end;

procedure TRSSpinSpeedButton.DoPaint;
begin
  (Owner as TRSSpinButton).ButtonPaint(self, DoInheritedPaint, fState,
    Pboolean(@MouseInControl)^, MouseInside);
end;

procedure TRSSpinSpeedButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  inherited;
  (Owner as TRSSpinButton).BtnMouseDown(self, Button, Shift, X, Y);
end;

procedure TRSSpinSpeedButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  inherited;
  (Owner as TRSSpinButton).BtnMouseUp(self, Button, Shift, X, Y);
end;

{ TRSSpinButton }

constructor TRSSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque] -
    [csAcceptsControls, csSetCaption, csReplicatable];
  fTimer:=TRSTimer.Create(Self);
  fTimer.Interval:=0;
  fTimer.Enabled:=true;
  fTimer.OnTimer:=Timer;
  fFirstPause:= 400;
  fPause:= 100;
  FUpButton := CreateButton;
  FDownButton := CreateButton;
  UpGlyph := nil;
  DownGlyph := nil;
  FSpin:=false;
  fButton:=nil;
  Width := 20;
  Height := 25;
  FFocusedButton := FUpButton;
  fDownKey:= false;
  fUpKey:= false;
  fSpinFactor:= 15;
  //Framed:=true;
end;

procedure TRSSpinButton.BtnMouseDown(Sender: TObject; Button: TMouseButton; 
        Shift: TShiftState; X, Y: integer);
begin
  if Button = mbLeft then
  begin
    fButton:=Sender;
    SetFocusBtn (TRSSpeedButton (Sender));
    if (FFocusControl <> nil) and FFocusControl.TabStop and
        FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle)
    then
      FFocusControl.SetFocus
    else
      if TabStop and (GetFocus <> Handle) and CanFocus then
        SetFocus;
  
    FSpin:=true;
    fTimer.Tag:=0;
    fTimer.Interval:=fFirstPause;
  
    if Sender=FUpButton then
      DoUpClick(1)
    else
      DoDownClick(1);
  end;
end;

procedure TRSSpinButton.BtnMouseUp(Sender: TObject; Button: TMouseButton; 
        Shift: TShiftState; X, Y: integer);
var
  ButtonBefore: TControl;
begin
  if (Button <> mbLeft) or (fButton=nil) then exit;
  FSpin:=false;
  fTimer.Interval:=0;
  ButtonBefore:=(fButton as TControl);
  fButton:=nil;
  ButtonBefore.Invalidate;
end;

procedure TRSSpinButton.ButtonPaint(Sender: TRSSpeedButton; 
        DefaultPaint:TRSProcedure; var AState: TButtonState; var 
        MouseInControl:boolean; MouseReallyInControl:boolean);
var
  a: TThemedElementDetails;
  lastNG: integer;
begin
  with Sender do
  begin
    if Glyph.Empty then
    begin
      BlockRepaint;
      lastNG:=NumGlyphs;
      if Sender=fUpButton then
        Glyph.Handle := LoadBitmap(HInstance, 'RSUPGLYPH')
      else
        Glyph.Handle := LoadBitmap(HInstance, 'RSDOWNGLYPH');
      Glyph.Transparent:=true;
      Glyph.TransparentColor:=clWhite;
      NumGlyphs := 1;
    end else
      lastNG:=-1;
  
    if (fButton<>nil) and (GetKeyState(VK_LBUTTON)>=0) then
      BtnMouseUp(fButton,mbLeft,[],0,0);
    if (Sender=fButton) and (AState=bsUp) and (fSpinFactor>0) then
      AState:=bsDown;

    if IsStyled then
    begin
      Canvas.Brush.Color:=clBtnFace;
      Canvas.Fillrect(Bounds(0,0,Sender.Width,Sender.Height));
      {
      if AState=bsDisabled then
      begin
        DefaultPaint;
      end
        with Canvas do
        begin
          if AState<>bsDisabled then


          Pen.Color:=RSMixColorsNorm(clBtnShadow, GetColorTheme.Button, 180);
          if AState=bsDisabled then
            Brush.Color:=GetColorTheme.Button
          else
            Brush.Style:=bsClear;
          Rectangle(Rect(0, 0, Width, Height));
          Pixels[0, 0]:=GetColorTheme.Button;
          Pixels[Width-1, 0]:=GetColorTheme.Button;
          Pixels[0, Height-1]:=GetColorTheme.Button;
          Pixels[Width-1, Height-1]:=GetColorTheme.Button;
          if AState=bsDisabled then
            RSDrawDisabled(Canvas, Glyph, clBtnShadow,
              (Width-Glyph.Width) div 2,
              (Height-Glyph.Height) div 2);
        end
      else
      }
        DefaultPaint;
    end else
      if ThemeServices.ThemesEnabled then
      begin
        a.Element:=teSpin;
        if Sender=FUpButton then a.Part:=1
        else a.Part:=2;
        case AState of
          bsUp:
            if MouseReallyInControl then a.State:=UPS_HOT
            else a.State:=UPS_NORMAL;
          bsDisabled:
            a.State:=UPS_DISABLED;
          bsDown, bsExclusive:
            a.State:=UPS_PRESSED;
        end;
        ThemeServices.DrawElement(Sender.Canvas.Handle,a,
                                Bounds(0,0,Sender.Width,Sender.Height));
      end else
      begin
        Canvas.Brush.Color:=clBtnFace;
        Canvas.FillRect(Bounds(0,0,Sender.Width,Sender.Height));
        DefaultPaint;
      end;
  
    if lastNG<>-1 then
    begin
      Glyph:=nil;
      NumGlyphs := lastNG;
    end;
  end;
end;

function TRSSpinButton.CreateButton: TRSSpeedButton;
begin
  result:= TRSSpinSpeedButton.Create(Self);
  result.Parent:= self;
  result.SetSubComponent(true);
end;

procedure TRSSpinButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if Assigned(FOnCreateParams) then FOnCreateParams(Params);
end;

procedure TRSSpinButton.ForceButtons;
begin
  FUpButton.ForceDown:= fUpKey;
  FDownButton.ForceDown:= fDownKey;
end;

function TRSSpinButton.GetDownGlyph: TBitmap;
begin
  result := FDownButton.Glyph;
end;

function TRSSpinButton.GetDownNumGlyphs: TNumGlyphs;
begin
  result := FDownButton.NumGlyphs;
end;

function TRSSpinButton.GetFlat: boolean;
begin
  result:=FUpButton.Flat;
end;

function TRSSpinButton.GetFlatHighlighted: boolean;
begin
  result:=FUpButton.Highlighted and FDownButton.Highlighted;
end;

function TRSSpinButton.GetStyled: boolean;
begin
  result:=FUpButton.Styled;
end;

function TRSSpinButton.GetStyledOnXP: boolean;
begin
  result:=FUpButton.StyledOnXP;
end;

function TRSSpinButton.GetUpGlyph: TBitmap;
begin
  result := FUpButton.Glyph;
end;

function TRSSpinButton.GetUpNumGlyphs: TNumGlyphs;
begin
  result := FUpButton.NumGlyphs;
end;

procedure TRSSpinButton.KeyDown(var Key: word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
    begin
      SetFocusBtn(FUpButton);
      PressUpKey(true);
    end;
    VK_DOWN:
    begin
      SetFocusBtn(FDownButton);
      PressDownKey(true);
    end;
    VK_SPACE:
    begin
      if FFocusedButton=FUpButton then PressUpKey(true)
      else if FFocusedButton=FDownButton then PressDownKey(true);
    end;
  end;
end;

procedure TRSSpinButton.KeyUp(var Key: word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
    begin
      SetFocusBtn(FUpButton);
      PressUpKey(false);
    end;
    VK_DOWN:
    begin
      SetFocusBtn(FDownButton);
      PressDownKey(false);
    end;
    VK_SPACE:
    begin
      if FFocusedButton=FUpButton then PressUpKey(false)
      else if FFocusedButton=FDownButton then PressDownKey(false);
    end;
  end;
end;

procedure TRSSpinButton.Notification(AComponent: TComponent; Operation: 
        TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then
    FFocusControl := nil;
end;

procedure TRSSpinButton.PressDownKey(v:boolean);
begin
  if fDownKey=v then exit;
  fDownKey:=v;
  if v and fUpKey then fUpKey:=false;
  ForceButtons;
end;

procedure TRSSpinButton.PressUpKey(v:boolean);
begin
  if fUpKey=v then exit;
  fUpKey:=v;
  if v and fDownKey then fDownKey:=false;
  ForceButtons;
end;

procedure TRSSpinButton.SetBounds(ALeft, ATop, AWidth, AHeight: integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  SizeChanged;
end;

procedure TRSSpinButton.SetDownButton(v: TRSSpeedButton);
begin
  FDownButton.Assign(v);
end;

procedure TRSSpinButton.SetDownGlyph(Value: TBitmap);
begin
  FDownButton.Glyph := Value;
end;

procedure TRSSpinButton.SetDownNumGlyphs(Value: TNumGlyphs);
begin
  FDownButton.NumGlyphs := Value;
end;

procedure TRSSpinButton.SetEnabled(v:boolean);
begin
  FUpButton.Enabled:=v;
  FDownButton.Enabled:=v;
  inherited SetEnabled(v);
end;

procedure TRSSpinButton.SetFlat(Value: boolean);
begin
  fUpButton.Flat:=Value;
  fDownButton.Flat:=Value;
  SizeChanged;
end;

procedure TRSSpinButton.SetFlatHighlighted(Value: boolean);
begin
  fUpButton.Highlighted:=Value;
  fDownButton.Highlighted:=Value;
  SizeChanged;
end;

procedure TRSSpinButton.SetFocusBtn(Btn: TRSSpeedButton);
begin
  if TabStop and CanFocus and  (Btn <> FFocusedButton) then
  begin
    FFocusedButton := Btn;
    if (GetFocus = Handle) then
    begin
      Invalidate;
    end;
  end;
end;

procedure TRSSpinButton.SetStyled(v: boolean);
begin
  fUpButton.Styled:=v;
  fDownButton.Styled:=v;
end;

procedure TRSSpinButton.SetStyledOnXP(v: boolean);
begin
  fUpButton.StyledOnXP:=v;
  fDownButton.StyledOnXP:=v;
end;

procedure TRSSpinButton.SetUpButton(v: TRSSpeedButton);
begin
  FUpButton.Assign(v);
end;

procedure TRSSpinButton.SetUpGlyph(Value: TBitmap);
begin
  FUpButton.Glyph := Value;
end;

procedure TRSSpinButton.SetUpNumGlyphs(Value: TNumGlyphs);
begin
  FUpButton.NumGlyphs := Value;
end;

procedure TRSSpinButton.SizeChanged;
var
  W, H: integer;
begin
  if not HandleAllocated or (FUpButton = nil) or
     (csLoading in ComponentState) then exit;
  W:=ClientWidth;
  H:=ClientHeight;

  if FUpButton.IsStyled or Flat or ThemeServices.ThemesEnabled then
  begin
    FUpButton.SetBounds(0, 0, W, (H+1) div 2);
    FDownButton.SetBounds(0, FUpButton.Height, W, H - FUpButton.Height);
  end else
  begin
    FUpButton.SetBounds(0, 0, W, H div 2 + 1);
    FDownButton.SetBounds(0, FUpButton.Height -1, W, H - FUpButton.Height +1);
  end;
end;

procedure TRSSpinButton.DoUpClick(SpinnedBy: int);
begin
  if Assigned(FOnUpClick) then  FOnUpClick(Self, SpinnedBy);
end;

procedure TRSSpinButton.DoDownClick(SpinnedBy: int);
begin
  if Assigned(FOnDownClick) then  FOnDownClick(Self, SpinnedBy);
end;

procedure TRSSpinButton.Timer(Sender: TObject);
var
  i, j: integer;
  r: TRect;
begin
  if GetKeyState(VK_LBUTTON) and 128=0 then
  begin
    BtnMouseUp(fButton,mbLeft,[],0,0);
    exit;
  end;
  GetWindowRect(Handle,r);
  i:=mouse.CursorPos.Y-r.Top;
  if fButton = FUpButton then
  begin
    Dec(i,FUpButton.Top);
    if fSpinFactor<>0 then
    begin
      if i>=FUpButton.Height then
        i:=0
      else
        if i<0 then
          i:=2+ (-i) div fSpinFactor
        else
          i:=1;
          
      i:=sqr(i);
    end else
      if (i>=FUpButton.Height) or (i<0) or not FProps.MouseIn then
        i:=0
      else
        i:=1;
        
    if i<=0 then
      i:=1
    else
      DoUpClick(FTimer.Tag + 1);
  end else
  begin
    Dec(i,FDownButton.Top);
    if fSpinFactor<>0 then
    begin
      if i<0 then
        i:=0
      else
        if i>=FDownButton.Height then
          i:=2+ (i-FDownButton.Height) div fSpinFactor
        else
          i:=1;
          
      i:=sqr(i);
    end else
      if (i>=FDownButton.Height) or (i<0) or not FProps.MouseIn then
        i:=0
      else
        i:=1;
        
    if i<=0 then
      i:=1
    else
      DoDownClick(FTimer.Tag + 1);
  end;
  j:=fPause div i;
  if j<10 then
  begin
    fTimer.Interval:=15;
    fTimer.Tag:=(15*i+fPause div 2) div fPause;
  end else
  begin
    fTimer.Interval:=j;
    fTimer.Tag:=0;
  end;
end;

procedure TRSSpinButton.TranslateWndProc(var Msg: TMessage);
var
  b: boolean;
begin
  if assigned(FProps.OnWndProc) then
  begin
    b:=false;
    FProps.OnWndProc(Self, Msg, b, WndProc);
    if b then exit;
  end;
  WndProc(Msg);
end;

procedure TRSSpinButton.WMGetDlgCode(var message: TWMGetDlgCode);
begin
  message.result := DLGC_WANTARROWS;
end;

procedure TRSSpinButton.WMSize(var message: TWMSize);
begin
  inherited;
  SizeChanged;
  message.result := 0;
end;

procedure TRSSpinButton.WndProc(var Msg: TMessage);
begin
  RSProcessProps(self, Msg, FProps);
  inherited;
end;

(*
procedure TRSSpinButton.ButtonPaint(Sender: TRSSpeedButton;
        DefaultPaint:TRSProcedure; var State: TButtonState; var
        MouseInControl:boolean; MouseReallyInControl:boolean);
var
  a: TThemedElementDetails;
  lastNG: Integer;
  wasFlat: Boolean;
  wasTransp: Boolean;
begin
  if Sender.Glyph.Empty then
  begin
    lastNG:=Sender.NumGlyphs;
    if Sender=fUpButton then
      Sender.Glyph.Handle := LoadBitmap(HInstance, 'RSUPGLYPH')
    else
      Sender.Glyph.Handle := LoadBitmap(HInstance, 'RSDOWNGLYPH');
    if ((Sender.Style<>RSsbStandard) or Sender.Flat) and
       (Sender.Glyph.Height>2) then
      Sender.Glyph.Height:=Sender.Glyph.Height-2;
    Sender.Glyph.Transparent:=true;
    Sender.Glyph.TransparentColor:=clWhite;
    Sender.NumGlyphs := 1;
  end else lastNG:=-1;
  if (fButton<>nil) and (GetKeyState(VK_LBUTTON)>=0) then
    BtnMouseUp(fButton,mbLeft,[],0,0);
  if (Sender=fButton) and (State=bsUp) and (fSpinFactor>0) then
    State:=bsDown;

  if not ThemeServices.ThemesEnabled then
  begin
    if Sender.Style=RSsbBright then
    begin
      if MouseReallyInControl then MouseInControl:=true;
      wasFlat:=Sender.Flat;
      wasTransp:=Sender.Transparent;
      Sender.Flat:=true;
      Sender.Transparent:=true;

      if MouseInControl or (State in [bsDown, bsExclusive]) then
        Sender.Canvas.Brush.Color:=clBtnHighlight
      else Sender.Canvas.Brush.Color:=clBtnFace;
      Sender.Canvas.Fillrect(Bounds(0,0,Sender.Width,Sender.Height));

      DefaultPaint;

      if MouseInControl or (State in [bsDown, bsExclusive]) then
      begin
        Sender.Canvas.Pen.Color:=clBtnFace;
        Sender.Canvas.Brush.Style:=bsClear;
        Sender.Canvas.Rectangle(Bounds(0,0,Sender.Width,Sender.Height));
      end;

      Sender.Flat:=wasFlat;
      Sender.Transparent:=wasTransp;
    end else
    begin
      Sender.Canvas.Brush.Color:=clBtnFace;
      Sender.Canvas.Fillrect(Bounds(0,0,Sender.Width,Sender.Height));
      if (Style=RSsbOffice) and not MouseInControl and (State<>bsDown) then
        with Sender, Canvas do
        begin
          if State<>bsDisabled then
            DefaultPaint;

          Pen.Color:=GetColorTheme.Dark;
          if State=bsDisabled then
            Brush.Color:=GetColorTheme.Button
          else
            Brush.Style:=bsClear;
          Rectangle(Rect(0, 0, Width, Height));
          Pixels[0, 0]:=GetColorTheme.Button;
          Pixels[Width-1, 0]:=GetColorTheme.Button;
          Pixels[0, Height-1]:=GetColorTheme.Button;
          Pixels[Width-1, Height-1]:=GetColorTheme.Button;
          if State=bsDisabled then
            RSDrawDisabled(Canvas, Glyph, clBtnShadow,
              (Width-Glyph.Width) div 2,
              (Height-Glyph.Height) div 2);
        end
      else
        DefaultPaint;
    end;
  end else
  begin
    a.Element:=teSpin;
    if Sender=FUpButton then a.Part:=1
    else a.Part:=2;
    case State of
      bsUp:
        if MouseReallyInControl then a.State:=UPS_HOT
        else a.State:=UPS_NORMAL;
      bsDisabled:
        a.State:=UPS_DISABLED;
      bsDown, bsExclusive:
        a.State:=UPS_PRESSED;
    end;
    ThemeServices.DrawElement(Sender.Canvas.Handle,a,
                            Bounds(0,0,Sender.Width,Sender.Height));
  end;
  if lastNG<>-1 then
  begin
    Sender.Glyph:=nil;
    Sender.NumGlyphs := lastNG;
  end;
end;
*)

{
********************************* TRSSpinEdit **********************************
}

type
  TRSSpinEditButton = class (TRSSpinButton)
  protected
    FNoPlace: boolean;
    procedure SizeChanged; override;
    procedure DoUpClick(SpinnedBy:int); override;
    procedure DoDownClick(SpinnedBy:int); override;
  end;

{ TRSSpinEditButton }

procedure TRSSpinEditButton.SizeChanged;
begin
  inherited;
  if not fNoPlace and (Parent = Owner) then
    (Owner as TRSSpinEdit).PlaceButton;
end;

procedure TRSSpinEditButton.DoUpClick(SpinnedBy: int);
begin
  inherited;
  (Owner as TRSSpinEdit).DoUp(SpinnedBy, true);
end;

procedure TRSSpinEditButton.DoDownClick(SpinnedBy: int);
begin
  inherited;
  (Owner as TRSSpinEdit).DoDown(SpinnedBy, true);
end;

{ TRSSpinEdit }

constructor TRSSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := TRSSpinEditButton.Create(self);
  FButton.Width := 15;
  FButton.Parent := Self;
  FButton.FocusControl := Self;
  //  FButton.Framed:=false;
  FButton.SetSubComponent(true);

  FMaxValue:=MaxInt;
  FMinValue:=Low(int);
  Value:=0;
  FLastValue:=FValue;
  ControlStyle := ControlStyle - [csSetCaption];
  FIncrement := 1;
  FEditorEnabled := True;
  ParentBackground := false;
    //FFirstCreateWnd:=true;
  
end;

destructor TRSSpinEdit.Destroy;
begin
  inherited Destroy;
end;

function TRSSpinEdit.CheckValue(NewValue: LongInt): LongInt;
begin
  result := NewValue;
  if (FMaxValue >= FMinValue) then
  begin
    if NewValue < FMinValue then
      result := FMinValue
    else
      if NewValue > FMaxValue then
        result := FMaxValue;
  end;
end;

procedure TRSSpinEdit.CMEnter(var message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
  inherited;
end;

procedure TRSSpinEdit.CMExit(var message: TCMExit);
begin
  inherited;
  Validate;
end;

procedure TRSSpinEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  // Params.Style := Params.Style and not WS_BORDER;
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
  if Assigned(FOnCreateParams) then FOnCreateParams(Params);
end;

procedure TRSSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  MakeVisibleH;
  SetEditRect;
  //if FFirstCreateWnd then
  //begin
  //  FFirstCreateWnd:=false;
  //  AutoSize:=false;
  //end;
end;

procedure TRSSpinEdit.DoChanged;
begin
  if (fValue<>FLastValue) and (Assigned(fOnChanged)) then FOnChanged(self);
  FLastValue:=FValue;
end;

procedure TRSSpinEdit.DoDown(SpinnedBy:integer; Clicked:boolean=false);
var
  v: integer;
begin
  if ReadOnly then MessageBeep(0);
  v:=Value;
  if not ReadOnly then
  begin
    SpinnedBy:= SpinnedBy*FIncrement;
    if v > Low(int)+SpinnedBy then
      Value:= v - SpinnedBy
    else
      Value:=Low(int);
  end;
  if Clicked and Assigned(FOnDownClick) then
    FOnDownClick(self);
  
  if ReadOnly then exit;
  
  //SelectAll;
  DoChanged;
end;

procedure TRSSpinEdit.DoUp(SpinnedBy:integer; Clicked:boolean=false);
var
  v: integer;
begin
  if ReadOnly then MessageBeep(0);
  v:=Value;
  if not ReadOnly then
  begin
    SpinnedBy:= SpinnedBy*FIncrement;
    if v < MaxInt-SpinnedBy then
      Value:= v + SpinnedBy
    else
      Value:=MaxInt;
  end;
  if Clicked and Assigned(FOnUpClick) then
    FOnUpClick(self);

  if ReadOnly then exit;

  //SelectAll;
  DoChanged;
end;

function TRSSpinEdit.GetCaret: int;
begin
  result:=RSEditGetCaret(self, FSelAnchor);
end;

procedure TRSSpinEdit.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
  
end;

function TRSSpinEdit.GetMinHeight: integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: integer;
  SysMetrics, Metrics: TTextMetric;
begin
   // text edit bug: if size too less than minheight, then edit ctrl does
   // not display the text
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

procedure TRSSpinEdit.GetSelection(var Start, Caret: integer);
begin
  RSEditGetSelection(self, Start, Caret, FSelAnchor);
end;

function TRSSpinEdit.GetStyled: boolean;
begin
  result:=FButton.Styled;
end;

function TRSSpinEdit.GetStyledOnXP: boolean;
begin
  result:=FButton.StyledOnXP;
end;

function TRSSpinEdit.GetValue: LongInt;
var
  i: integer;
begin
  i:=FBase;
  if i<2 then i:=10;
  if FThous then
    if FThousSep=#0 then result := RSStrToIntEx(Text,i,i,ThousandSeparator)
    else result := RSStrToIntEx(Text,i,i,FThousSep)
  else result := RSStrToIntEx(Text,i,i);
  if i>=3 then
    result:=FValue
  else
    result:=CheckValue(result);
end;

function TRSSpinEdit.IsValidChar(Key: char): boolean;
var
  i: int;
begin
  i:=FBase;
  if i<2 then i:=16;
  result := (FThous and (((FThousSep=#0) and (key=ThousandSeparator))
            or (key=FThousSep))) or (Key='+') or (Key='-') or
            (RSCharToInt(Key,i)>=0) or
            ((Key < #32) and (Key <> Chr(VK_RETURN))) or
            ((Key='$') and (FBase<=1));
  if not FEditorEnabled and result and ((Key >= #32) or
      (Key = char(VK_BACK)) or (Key = char(VK_DELETE))) then
    result := False;
end;

procedure TRSSpinEdit.KeyDown(var Key: word; Shift: TShiftState);
begin
  if Key = VK_UP then
  begin
    if not ReadOnly then FButton.PressUpKey(true);
    DoUp(1);
  end else
  if Key = VK_DOWN then
  begin
    if not ReadOnly then FButton.PressDownKey(true);
    DoDown(1);
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TRSSpinEdit.KeyPress(var Key: char);
var c:char;
begin
  c:=Key;
  if Key = #13 then
  begin
    Validate;
    SelectAll;
    Key:=#0;
  end;

  if Key<>#0 then
    inherited KeyPress(Key)
  else
    inherited KeyPress(c);
    
  case Key of
    #1: // Ctrl+A
    begin
      SelectAll;
      Key:=#0;
    end;
    else
      if not IsValidChar(Key) then
      begin
        Key := #0;
        MessageBeep(0);
      end;
  end;
end;

procedure TRSSpinEdit.KeyUp(var Key: word; Shift: TShiftState);
begin
  if Key = VK_UP then FButton.PressUpKey(false)
  else if Key = VK_DOWN then FButton.PressDownKey(false);
  inherited KeyUp(Key, Shift);
end;

procedure TRSSpinEdit.MakeVisibleH;
var
  h: integer;
begin
  // text edit bug: if size too less than minheight, then edit ctrl does
  // not display the text
  h:=height;
  height:=GetMinHeight;
  height:=h;
end;

procedure TRSSpinEdit.PlaceButton;
begin
  if FButton <> nil then
  begin
    TRSSpinEditButton(fButton).fNoPlace:=true;
    FButton.SetBounds(ClientWidth-FButton.Width, 0, FButton.Width,
      ClientHeight);
    TRSSpinEditButton(fButton).fNoPlace:=false;
    if HandleAllocated then SetEditRect;
  end;
end;

procedure TRSSpinEdit.SetBase(v: integer);
var
  c: char;
begin
  if (v<0) or (v>36) then exit;
  FValue:=Value;
  FBase:=v;
  c:=fThousSep;
  FThousSep:=#0;
  SetThousSep(c);
  Value:=FValue;
end;

procedure TRSSpinEdit.SetButton(v: TRSSpinButton);
begin
  FButton.Assign(v);
end;

procedure TRSSpinEdit.SetCaret(v: int);
begin
  Perform(EM_SETSEL, v, v);
end;

procedure TRSSpinEdit.SetEditRect;
var
  Loc: TRect;
  w: integer;
begin
    //SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  if FButton.Visible then w:=FButton.Width else w:=0;
  Loc.Bottom := ClientHeight + 1;
       //+1 is workaround for windows paint bug
    //if NewStyleControls and Ctl3D then Loc.Right := ClientWidth - w +1
  Loc.Right := ClientWidth - w + 1;
  if NewStyleControls and Ctl3D then
  begin
    Loc.Top := 0;
    Loc.Left := 0;
  end else
  begin
    Loc.Top:=1;
    Loc.Left:=1;
  end;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  //  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  //debug
end;

procedure TRSSpinEdit.SetEnabled(v:boolean);
begin
  FButton.Enabled:=v;
  inherited SetEnabled(v);
end;

procedure TRSSpinEdit.SetMaxValue(v: LongInt);
begin
  FMaxValue:=v;
  Value:=Value;
end;

procedure TRSSpinEdit.SetMinValue(v: LongInt);
begin
  FMinValue:=v;
  Value:=Value;
end;

procedure TRSSpinEdit.SetSelection(Start, Caret:int);
begin
  RSEditSetSelection(self, Start, Caret);
end;

procedure TRSSpinEdit.SetStyled(v: boolean);
begin
  fButton.Styled:=v;
end;

procedure TRSSpinEdit.SetStyledOnXP(v: boolean);
begin
  fButton.StyledOnXP:=v;
end;

procedure TRSSpinEdit.SetThous(b: boolean);
begin
  if b=FThous then exit;
  FValue:=Value;
  fThous:=b;
  Value:=FValue;
end;

procedure TRSSpinEdit.SetThousSep(c: char);
var
  i: int;
begin
  i:=FBase;
  if i=0 then i:=16;
  if (c=FThousSep) or (c='-') or (RSCharToInt(c,i)>=0) then exit;
  FValue:=Value;
  fThousSep:=c;
  Value:=FValue;
end;

procedure TRSSpinEdit.SetValue(NewValue: LongInt);
var
  i:int; s:string; c:char;
begin
  FLastValue:=FValue;
  FValue:=CheckValue(NewValue);
  i:=FBase;
  case i of
    0: i:=10;
    1: i:=16;
  end;
  if FThous then
    if FThousSep=#0 then
      c:=ThousandSeparator
    else
      c:=FThousSep
  else
    c:=#0;

  s:= RSIntToStr(FValue, i, c, true, FDigits);
  if FBase=1 then
    if s[1]='-' then
    begin
      s:='-'+s;
      s[2]:='$';
    end else
      s:='$'+s;

  Text:=s;
end;

procedure TRSSpinEdit.TranslateWndProc(var Msg: TMessage);
var
  b: boolean;
begin
  if assigned(FProps.OnWndProc) then
  begin
    b:=false;
    FProps.OnWndProc(Self, Msg, b, WndProc);
    if b then exit;
  end;
  WndProc(Msg);
end;

procedure TRSSpinEdit.Validate;
var
  i: int;
begin
  i:=FValue;
  Value:=Value;
  if FValue<>i then
    DoChanged;
end;

procedure TRSSpinEdit.WMCut(var message: TWMCut);
begin
  if not FEditorEnabled or ReadOnly then Perform(WM_COPY,0,0);
  inherited;
end;

procedure TRSSpinEdit.WMKillFocus(var message: TWMKillFocus);
begin
  inherited;
  FButton.PressUpKey(false);
  FButton.PressDownKey(false);
end;

procedure TRSSpinEdit.WMPaste(var message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then exit;
  inherited;
end;

procedure TRSSpinEdit.WMSize(var message: TWMSize);
begin
  inherited;
  PlaceButton;
end;

procedure TRSSpinEdit.WndProc(var Msg: TMessage);
begin
  RSProcessProps(self, Msg, FProps);
  inherited;
  RSEditWndProcAfter(self, Msg, FSelAnchor);
end;

procedure TRSSpinEdit.SetDigits(v:int);
begin
  v:=IntoRange(v, 0, 41);
  if FDigits=v then  exit;
  FDigits:=v;
  Value:=Value;
end;

end.
