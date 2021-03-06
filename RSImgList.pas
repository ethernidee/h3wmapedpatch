unit RSImgList;

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

uses Windows, Classes, SysUtils, Graphics, Math, RSQ, ImgList, CommCtrl;

function RSImgListToBmp(il:TCustomImageList; index:int; Bmp:TBitmap=nil):TBitmap;

implementation

function GetRGBColor(Value: TColor): DWORD;
begin
  result := ColorToRGB(Value);
  case result of
    clNone: result := CLR_NONE;
    clDefault: result := CLR_DEFAULT;
  end;
end;

function RSImgListToBmp(il:TCustomImageList; index:int;  Bmp:TBitmap=nil):TBitmap;
var
  b: TBitmap;
begin
  if Bmp<>nil then
    Bmp.Height:= 0
  else
    Bmp:=TBitmap.Create;

  with Bmp do
  begin
    Width:=il.Width;
    Height:=il.Height;

    il.Draw(Canvas, 0, 0, index);
    Transparent:= true;
    b:= TBitmap.Create;
    try
      b.HandleType:= bmDIB;
      b.Handle:= MaskHandle;
      b.Canvas.Brush.Color:= clWhite;
      b.Canvas.FillRect(Rect(0, 0, Width, Height));
      ImageList_Draw(il.Handle, index, b.Canvas.Handle, 0, 0, ILD_MASK);
      MaskHandle:= b.ReleaseHandle;
    finally
      b.Free;
    end;
  end;
  result:=Bmp;
end;

end.
