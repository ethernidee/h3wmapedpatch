unit RSListView;

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

 LVM_SETCOLUMNWIDTH works properly when Style is vsList

{ *********************************************************************** }
{$I RSPak.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ComCtrls, CommCtrl, RSCommon,
  RSQ, Types;

{ TODO :
Fix cdPostPaint
AutoSizeColumns for OwnerData ?
}

{$I RSWinControlImport.inc}

type
  TRSListView = class(TListView)
  private
    FOnCreateParams: TRSCreateParamsEvent;
    FProps: TRSWinControlProps;
    FImproveRight: boolean;
    FTotalCmdNovigation: boolean;
    FBorderSelect: boolean;
    function GetSelectedItem: TListItem;
    procedure SetBorderSelect(const Value: boolean);
  protected
    {$IFDEF D2006}
     // Delphi 2006 bug: ListView doesn't save state in case DestroyHandle is called
    procedure DestroyWnd; override;
    {$ENDIF}

    procedure CreateParams(var Params: TCreateParams); override;
    procedure TranslateWndProc(var Msg: TMessage);
    procedure WndProc(var Msg: TMessage); override;
    procedure CNNotify(var Msg: TWMNotify); message CN_NOTIFY;
    procedure WMKeyDown(var Msg: TWMKeyDown); message WM_KeyDown;
    procedure LVMSetExtendedListViewStyle(var Msg: TMessage); message LVM_SETEXTENDEDLISTVIEWSTYLE;
    procedure LVMSetColumnWidth(var Msg: TMessage); message LVM_SETCOLUMNWIDTH;
  public
    constructor Create(AOwner:TComponent); override;
    function GetExactItemAt(X, Y: integer): TListItem;
    function GetSelectedIndex(var index: integer): boolean;
     // Used to enumerate items
    function NextSelected(index:int = -1):int;
     // Correct in MultiSelect case
    property SelectedItem: TListItem read GetSelectedItem;
  published
     // Improves Right and Page Down buttons behavior when ViewStyle = vsList
    property ImproveRightBehavior: boolean read FImproveRight write FImproveRight default true;
    property TotalCmdNovigation: boolean read FTotalCmdNovigation write FTotalCmdNovigation default false;
    property BorderSelect: boolean read FBorderSelect write SetBorderSelect default false;
    property OnCanResize;
    property OnCreateItemClass;
    {$I RSWinControlProps.inc}
  end;

const
  LVS_EX_BORDERSELECT = $00008000;

procedure register;

implementation

procedure register;
begin
  RegisterComponents('RSPak', [TRSListView]);
end;

{
********************************* TRSListView **********************************
}
constructor TRSListView.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  WindowProc:=TranslateWndProc;
  FImproveRight:=true;
end;

procedure TRSListView.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if Assigned(FOnCreateParams) then FOnCreateParams(Params);
end;

{$IFDEF D2006}
procedure TRSListView.DestroyWnd;
var state: TControlState;
begin
  state:= ControlState;
  ControlState:= state + [csRecreating];
  inherited;
  ControlState:= state;
end;
{$ENDIF}

procedure TRSListView.TranslateWndProc(var Msg: TMessage);
var b:boolean;
begin
  if assigned(FProps.OnWndProc) then
  begin
    b:=false;
    FProps.OnWndProc(Self, Msg, b, WndProc);
    if b then exit;
  end;
  WndProc(Msg);
end;

procedure TRSListView.WndProc(var Msg: TMessage);
begin
  RSProcessProps(self, Msg, FProps);
  inherited;
end;

procedure TRSListView.CNNotify(var Msg: TWMNotify);
begin
  inherited;
  with Msg.NMHdr^, PNMListView(Msg.NMHdr)^ do
    if (code = LVN_ITEMCHANGED) and Assigned(OnSelectItem) and
      (uOldState xor uNewState = LVNI_FOCUSED) and (uChanged = LVIF_STATE) then
{
       (uOldState and (LVNI_FOCUSED + LVNI_SELECTED) = 0) and
       (uNewState and (LVNI_FOCUSED + LVNI_SELECTED) = LVNI_FOCUSED) then
}
    begin
      OnSelectItem(self, Items[iItem], uNewState and LVNI_FOCUSED <> 0);
    end;
end;

function TRSListView.GetExactItemAt(X, Y: integer): TListItem;
var
  Info: TLVHitTestInfo;
  index: integer;
begin
  result := nil;
  if HandleAllocated then
  begin
    Info.pt := Point(X, Y);
    index := ListView_HitTest(Handle, Info);
    if (Info.flags and LVHT_ONITEM <> 0) and (index <> -1) then
      result := Items[index];
  end;
end;

function TRSListView.GetSelectedIndex(var index: integer): boolean;
var i:int;
begin
  i:= ListView_GetNextItem(Handle, -1, LVIS_SELECTED or LVIS_FOCUSED);
  result:= i>=0;
  if result then
    index:= i;
end;

procedure TRSListView.WMKeyDown(var Msg: TWMKeyDown);

  procedure DoIt;
  var i,j,k:int; p, p1:TPoint;
  begin
    i:= ListView_GetNextItem(Handle, -1, LVIS_FOCUSED);
    k:= Msg.CharCode;
    inherited;
    if i = -1 then  exit;
    j:= ListView_GetNextItem(Handle, -1, LVIS_FOCUSED);
    if (Msg.CharCode = k) and (i = j) and
       ( FTotalCmdNovigation or (Msg.CharCode = VK_PGDN) or
          ListView_GetItemPosition(Handle, Items.Count-1, p) and
          ListView_GetItemPosition(Handle, i, p1) and (p1.X < p.X) ) then
    begin
      if k in [VK_LEFT, VK_PGUP] then
        Msg.CharCode:= VK_HOME
      else
        Msg.CharCode:= VK_END;
      DefaultHandler(Msg);
    end;
  end;

begin
  if ( FTotalCmdNovigation and
       (Msg.CharCode in [VK_LEFT, VK_RIGHT, VK_PGUP, VK_PGDN]) or
       FImproveRight and (Msg.CharCode in [VK_RIGHT, VK_PGDN]) ) and
     (ViewStyle = vsList) then
    DoIt 
  else
    inherited;
end;

procedure TRSListView.LVMSetExtendedListViewStyle(var Msg: TMessage);
begin
  if FBorderSelect then
    Msg.LParam:= Msg.LParam or LVS_EX_BORDERSELECT;
  inherited;
end;

 // A workaround for ListView bug
procedure TRSListView.LVMSetColumnWidth(var Msg: TMessage);
var i,j:int; r:TRect; Partial:boolean;
begin
  with Msg do
    if (WParam = 0) and (ViewStyle = vsList) and (Items.Count<>0) then
    begin
      j:= ListView_GetTopIndex(Handle);

      if j>0 then
      begin
        if not GetSelectedIndex(i) or
           not ListView_GetItemRect(Handle, i, r, LVIR_SELECTBOUNDS) or
           (r.Left < 0) or (r.Left >= ClientWidth) then
        begin
          i:= j + Perform(LVM_GETCOUNTPERPAGE, 0, 0) div 2;
          Partial:=false;
        end else
          Partial:= (r.Right > ClientWidth) and (r.Left <> 0);

        Perform(WM_HSCROLL, SB_TOP, 0);
        inherited;
        ListView_EnsureVisible(Handle, i, Partial);
      end else
        inherited;
    end else
      inherited;
end;

function TRSListView.GetSelectedItem: TListItem;
begin
  result:= GetNextItem(nil, sdAll, [isSelected, isFocused]);
end;

function TRSListView.NextSelected(index:int = -1): int;
begin
  if HandleAllocated then
    result:= ListView_GetNextItem(Handle, index, LVIS_SELECTED)
  else
    result:= 0;
end;

procedure TRSListView.SetBorderSelect(const Value: boolean);
begin
  if FBorderSelect = Value then  exit;
  FBorderSelect:= Value;
  Perform(LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_BORDERSELECT, 0);
   // LVMSetExtendedListViewStyle handler will set it if FBorderSelect = true
end;

end.

