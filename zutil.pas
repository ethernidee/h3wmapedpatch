unit ZUtil;

{
  Copyright (C) 1998 by Jacques Nomssi Nzali
  For conditions of distribution and use, see copyright notice in readme.txt
}

interface

{$I zconf.inc}

{ Type declarations }

type
  {Byte   = usigned char;  8 bits}
  Bytef  = byte;
  charf  = byte;

{$IFDEF FPC}
  int    = longint;
{$ELSE}
  int    = integer;
{$ENDIF}

  intf   = int;
{$IFDEF MSDOS}
  uInt   = word;
{$ELSE}
  {$IFDEF FPC}
    uInt   = longint;     { 16 bits or more }
    {$INFO Cardinal}
  {$ELSE}
    uInt   = cardinal;     { 16 bits or more }
  {$ENDIF}
{$ENDIF}
  uIntf  = uInt;

  Long   = longint;
  uLong  = LongInt;      { 32 bits or more }
  uLongf = uLong;

  voidp  = pointer;
  voidpf = voidp;
  pBytef = ^Bytef;
  pIntf  = ^intf;
  puIntf = ^uIntf;
  puLong = ^uLongf;

  ptr2int = uInt;
{ a pointer to integer casting is used to do pointer arithmetic.
  ptr2int must be an integer type and sizeof(ptr2int) must be less
  than sizeof(pointer) - Nomssi }

type
  zByteArray = array[0..(MaxInt div sizeof(Bytef))-1] of Bytef;
  pzByteArray = ^zByteArray;
type
  zIntfArray = array[0..(MaxInt div sizeof(Intf))-1] of Intf;
  pzIntfArray = ^zIntfArray;
type
  zuIntArray = array[0..(MaxInt div sizeof(uInt))-1] of uInt;
  PuIntArray = ^zuIntArray;

{ Type declarations - only for deflate }

type
  uch  = byte;
  uchf = uch; { FAR }
  ush  = word;
  ushf = ush;
  ulg  = LongInt;

  unsigned = uInt;

  pcharf = ^charf;
  puchf = ^uchf;
  pushf = ^ushf;

type
  zuchfArray = zByteArray;
  puchfArray = ^zuchfArray;
type
  zushfArray = array[0..(MaxInt div sizeof(ushf))-1] of ushf;
  pushfArray = ^zushfArray;

procedure zmemcpy(destp : pBytef; sourcep : pBytef; len : uInt);
function zmemcmp(s1p, s2p : pBytef; len : uInt) : int;
procedure zmemzero(destp : pBytef; len : uInt);
procedure zcfree(opaque : voidpf; ptr : voidpf);
function zcalloc (opaque : voidpf; items : uInt; size : uInt) : voidpf;

implementation

{$ifdef ver80}
  {$define Delphi16}
{$endif}
{$ifdef ver70}
  {$define HugeMem}
{$endif}
{$ifdef ver60}
  {$define HugeMem}
{$endif}

{$IFDEF CALLDOS}
uses
  WinDos;
{$ENDIF}
{$IFDEF Delphi16}
uses
  WinTypes,
  WinProcs;
{$ENDIF}
{$IFNDEF FPC}
  {$IFDEF DPMI}
  uses
    WinAPI;
  {$ENDIF}
{$ENDIF}

{$IFDEF CALLDOS}
{ reduce your application memory footprint with $M before using this }
function dosAlloc (Size : Longint) : pointer;
var
  regs: TRegisters;
begin
  regs.bx := (Size + 15) div 16; { number of 16-bytes-paragraphs }
  regs.ah := $48;                { Allocate memory block }
  msdos(regs);
  if regs.Flags and FCarry <> 0 then
    DosAlloc := nil
  else
    DosAlloc := Ptr(regs.ax, 0);
end;


function dosFree(P : pointer) : boolean;
var
  regs: TRegisters;
begin
  dosFree := FALSE;
  regs.bx := Seg(P^);             { segment }
  if Ofs(P) <> 0 then
    exit;
  regs.ah := $49;                { Free memory block }
  msdos(regs);
  dosFree := (regs.Flags and FCarry = 0);
end;
{$ENDIF}

type
  LH = record
    L, H : word;
  end;

{$IFDEF HugeMem}
  {$define HEAP_LIST}
{$endif}

{$IFDEF HEAP_LIST} {--- to avoid Mark and Release --- }
const
  MaxAllocEntries = 50;
type
  TMemRec = record
    orgvalue,
    value : pointer;
    size: longint;
  end;
const
  allocatedCount : 0..MaxAllocEntries = 0;
var
  allocatedList : array[0..MaxAllocEntries-1] of TMemRec;

 function NewAllocation(ptr0, ptr : pointer; memsize : longint) : boolean;
 begin
   if (allocatedCount < MaxAllocEntries) and (ptr0 <> nil) then
   begin
     with allocatedList[allocatedCount] do
     begin
       orgvalue := ptr0;
       value := ptr;
       size := memsize;
     end;
     Inc(allocatedCount);  { we don't check for duplicate }
     NewAllocation := TRUE;
   end
   else
     NewAllocation := FALSE;
 end;
{$ENDIF}

{$IFDEF HugeMem}

{ The code below is extremely version specific to the TP 6/7 heap manager!!}
type
  PFreeRec = ^TFreeRec;
  TFreeRec = record
    next: PFreeRec;
    size: pointer;
  end;
type
  HugePtr = voidpf;


 procedure IncPtr(var p:pointer;count:word);
 { Increments pointer }
 begin
   Inc(LH(p).L,count);
   if LH(p).L < count then
     Inc(LH(p).H,SelectorInc);  { $1000 }
 end;

 procedure DecPtr(var p:pointer;count:word);
 { decrements pointer }
 begin
   if count > LH(p).L then
     Dec(LH(p).H,SelectorInc);
   Dec(LH(p).L,Count);
 end;

 procedure IncPtrLong(var p:pointer;count:longint);
 { Increments pointer; assumes count > 0 }
 begin
   Inc(LH(p).H,SelectorInc*LH(count).H);
   Inc(LH(p).L,LH(Count).L);
   if LH(p).L < LH(count).L then
     Inc(LH(p).H,SelectorInc);
 end;

 procedure DecPtrLong(var p:pointer;count:longint);
 { Decrements pointer; assumes count > 0 }
 begin
   if LH(count).L > LH(p).L then
     Dec(LH(p).H,SelectorInc);
   Dec(LH(p).L,LH(Count).L);
   Dec(LH(p).H,SelectorInc*LH(Count).H);
 end;
 { The next section is for real mode only }

function Normalized(p : pointer)  : pointer;
var
  count : word;
begin
  count := LH(p).L and $FFF0;
  Normalized := Ptr(LH(p).H + (count shr 4), LH(p).L and $F);
end;

procedure FreeHuge(var p:HugePtr; size : longint);
const
  blocksize = $FFF0;
var
  block : word;
begin
  while size > 0 do
  begin
    { block := minimum(size, blocksize); }
    if size > blocksize then
      block := blocksize
    else
      block := size;

    Dec(size,block);
    freemem(p,block);
    IncPtr(p,block);    { we may get ptr($xxxx, $fff8) and 31 bytes left }
    p := Normalized(p); { to free, so we must normalize }
  end;
end;

function FreeMemHuge(ptr : pointer) : boolean;
var
  i : integer; { -1..MaxAllocEntries }
begin
  FreeMemHuge := FALSE;
  i := allocatedCount - 1;
  while (i >= 0) do
  begin
    if (ptr = allocatedList[i].value) then
    begin
      with allocatedList[i] do
        FreeHuge(orgvalue, size);

      Move(allocatedList[i+1], allocatedList[i],
           sizeof(TMemRec)*(allocatedCount - 1 - i));
      Dec(allocatedCount);
      FreeMemHuge := TRUE;
      break;
    end;
    Dec(i);
  end;
end;

procedure GetMemHuge(var p:HugePtr;memsize:Longint);
const
  blocksize = $FFF0;
var
  size : longint;
  prev,free : PFreeRec;
  save,temp : pointer;
  block : word;
begin
  p := nil;
  { Handle the easy cases first }
  if memsize > maxavail then
    exit
  else
    if memsize <= blocksize then
    begin
      getmem(p, memsize);
      if not NewAllocation(p, p, memsize) then
      begin
        FreeMem(p, memsize);
        p := nil;
      end;
    end
    else
    begin
      size := memsize + 15;

      { Find the block that has enough space }
      prev := PFreeRec(@freeList);
      free := prev^.next;
      while (free <> heapptr) and (ptr2int(free^.size) < size) do
      begin
        prev := free;
        free := prev^.next;
      end;

      { Now free points to a region with enough space; make it the first one and
        multiple allocations will be contiguous. }

      save := freelist;
      freelist := free;
      { In TP 6, this works; check against other heap managers }
      while size > 0 do
      begin
        { block := minimum(size, blocksize); }
        if size > blocksize then
          block := blocksize
        else
          block := size;
        Dec(size,block);
        getmem(temp,block);
      end;

      { We've got what we want now; just sort things out and restore the
        free list to normal }

      p := free;
      if prev^.next <> freelist then
      begin
        prev^.next := freelist;
        freelist := save;
      end;

      if (p <> nil) then
      begin
        { return pointer with 0 offset }
        temp := p;
        if Ofs(p^)<>0 then
          p := Ptr(Seg(p^)+1,0);  { hack }
        if not NewAllocation(temp, p, memsize + 15) then
        begin
          FreeHuge(temp, size);
          p := nil;
        end;
      end;

    end;
end;

{$ENDIF}

procedure zmemcpy(destp : pBytef; sourcep : pBytef; len : uInt);
begin
  Move(sourcep^, destp^, len);
end;

function zmemcmp(s1p, s2p : pBytef; len : uInt) : int;
var
  j : uInt;
  source,
  dest : pBytef;
begin
  source := s1p;
  dest := s2p;
  for j := 0 to pred(len) do
  begin
    if (source^ <> dest^) then
    begin
      zmemcmp := 2*Ord(source^ > dest^)-1;
      exit;
    end;
    Inc(source);
    Inc(dest);
  end;
  zmemcmp := 0;
end;

procedure zmemzero(destp : pBytef; len : uInt);
begin
  FillChar(destp^, len, 0);
end;

procedure zcfree(opaque : voidpf; ptr : voidpf);
{$ifdef Delphi16}
var
  Handle : THandle;
{$endif}
{$IFDEF FPC}
var
  memsize : uint;
{$ENDIF}
begin
  {$IFDEF DPMI}
  {h :=} GlobalFreePtr(ptr);
  {$ELSE}
    {$IFDEF CALL_DOS}
    dosFree(ptr);
    {$ELSE}
      {$ifdef HugeMem}
      FreeMemHuge(ptr);
      {$else}
        {$ifdef Delphi16}
        Handle := GlobalHandle(LH(ptr).H); { HiWord(LongInt(ptr)) }
        GlobalUnLock(Handle);
        GlobalFree(Handle);
        {$else}
          {$IFDEF FPC}
           asm
            mov ptr,%edi
            subl $4,%edi
            mov (%edi),%eax
            mov %eax,memsize
            mov %edi,ptr
           end ['EAX','EDI'];
          FreeMem(ptr,memsize);  { Delphi 2,3,4 }
          {$ELSE}
          FreeMem(ptr);  { Delphi 2,3,4 }
          {$ENDIF}
        {$endif}
      {$endif}
    {$ENDIF}
  {$ENDIF}
end;

function zcalloc (opaque : voidpf; items : uInt; size : uInt) : voidpf;
var
  p : voidpf;
  memsize : LongInt;
{$ifdef Delphi16}
  handle : THandle;
{$endif}
begin
  memsize := items * size;
  {$IFDEF DPMI}
  p := GlobalAllocPtr(gmem_moveable, memsize);
  {$ELSE}
    {$IFDEF CALLDOS}
    p := dosAlloc(memsize);
    {$ELSE}
      {$ifdef HugeMem}
      GetMemHuge(p, memsize);
      {$else}
        {$ifdef Delphi16}
        Handle := GlobalAlloc(HeapAllocFlags, memsize);
        p := GlobalLock(Handle);
        {$else}
          {$IFDEF FPC}
           Inc(memsize,4);
           GetMem(p, memsize);  { Delphi: p := AllocMem(memsize); }
           asm
            mov memsize,%eax
            mov p,%edi
            stosl
            mov %edi,p
           end ['EAX','EDI'];
          {$ELSE}
          GetMem(p, memsize);  { Delphi: p := AllocMem(memsize); }
          {$ENDIF}
        {$endif}
      {$endif}
    {$ENDIF}
  {$ENDIF}
  zcalloc := p;
end;


end.

