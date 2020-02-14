unit RSSplitter;

{ *********************************************************************** }
{                                                                         }
{ RSPak                                    Copyright (c) Rozhenko Sergey  }
{ http://sites.google.com/site/sergroj/                                   }
{ sergroj@mail.ru                                                         }
{                                                                         }
{ This file is a subject to any one of these licenses at your choice:     }
{ BSD License, MIT License, Apache License, Mozilla Public License.       }
{                                                                         }
{ *********************************************************************** )

 Bug fixed: When the splitter is at the edge and you resize the form,
  TSplitter stopped working, because of broken alignment order.

{ *********************************************************************** }
{$I RSPak.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ExtCtrls, RSCommon, RSQ;

{ TODO :
OnPaint
Roll }

{$I RSControlImport.inc}

type
  TRSSplitter = class(TSplitter)
  private
    FProps: TRSControlProps;
  protected
    procedure TranslateWndProc(var Msg:TMessage);
    procedure WndProc(var Msg:TMessage); override;

    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
  public
    constructor Create(AOwner:TComponent); override;
  published
    property ResizeStyle default rsUpdate;
    property OnClick;
    property OnDblClick;
    property OnContextPopup;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    {$I RSControlProps.inc}
  end;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('RSPak', [TRSSplitter]);
end;

{
********************************** TRSSplitter ***********************************
}
constructor TRSSplitter.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  WindowProc:=TranslateWndProc;
  ResizeStyle:=rsUpdate;
end;

procedure TRSSplitter.TranslateWndProc(var Msg:TMessage);
var b:boolean;
begin
  if Assigned(FProps.OnWndProc) then
  begin
    b:=false;
    FProps.OnWndProc(Self, Msg, b, WndProc);
    if b then exit;
  end;
  WndProc(Msg);
end;

procedure TRSSplitter.WndProc(var Msg:TMessage);
begin
  RSProcessProps(self, Msg, FProps);
  inherited;
end;

procedure TRSSplitter.MouseMove(Shift: TShiftState; X, Y: integer);
begin
  case Align of
    alLeft:  Left:= MaxInt;
    alTop:  Top:= MaxInt;
    alRight:  Left:= Low(int);
    alBottom:  Top:= Low(int);
  end;
  inherited;
end;

end.
