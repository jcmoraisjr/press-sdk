(*
  PressObjects, Compatibility unit
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressCompatibility;

{$I Press.inc}

interface

uses
  {$IFDEF FPC}Calendar{$ELSE}ComCtrls{$ENDIF}, Grids
  {$IFDEF DELPHI}, Windows{$ENDIF};

type
  {$IFDEF D5}
  IInterface = IUnknown;
  {$ENDIF}

  {$IFDEF DELPHI}
  TRect = Windows.TRect;
  TCustomDrawGrid = TDrawGrid;
  {$ENDIF}

  {$IFDEF FPC}
  TDrawCellEvent = TOnDrawCell;
  TSelectCellEvent = TOnSelectCellEvent;
  {$ENDIF}

  TCustomCalendar =
   {$IFDEF FPC}Calendar.TCustomCalendar{$ELSE}ComCtrls.TCommonCalendar{$ENDIF};

function FormatMaskText(const EditMask: string; const Value: string): string;
procedure GenerateGUID(out AGUID: TGUID);
procedure OutputDebugString(const AStr: string);
procedure ThreadSafeIncrement(var AValue: Integer);
procedure ThreadSafeDecrement(var AValue: Integer);

implementation

uses
  {$IFDEF FPC}MaskEdit{$ELSE}{$IFDEF D6+}MaskUtils{$ELSE}Mask{$ENDIF}{$ENDIF},
  {$IFDEF FPC}SysUtils{$ELSE}ActiveX, ComObj{$ENDIF};

function FormatMaskText(const EditMask: string; const Value: string): string;
begin
  Result :=
   {$IFDEF FPC}Value{$ELSE}{$IFDEF D6+}MaskUtils{$ELSE}Mask{$ENDIF}
   .FormatMaskText(EditMask, Value){$ENDIF};
end;

{$IFDEF FPC}
procedure CreateGUIDResultCheck(AResult: Integer);
begin
  { TODO : Check error }
end;
{$ENDIF}

procedure GenerateGUID(out AGUID: TGUID);
begin
  {$IFDEF FPC}
  CreateGUIDResultCheck(CreateGUID(AGUID));
  {$ELSE}
  OleCheck(CoCreateGUID(AGUID));
  {$ENDIF}
end;

procedure OutputDebugString(const AStr: string);
begin
  {$IFNDEF FPC}
  Windows.OutputDebugString(PChar(AStr));
  {$ENDIF}
end;

procedure ThreadSafeIncrement(var AValue: Integer);
begin
  {$IFDEF FPC}
  Inc(AValue);  // IncLocked(AValue);
  {$ELSE}
  InterlockedIncrement(AValue);
  {$ENDIF}
end;

procedure ThreadSafeDecrement(var AValue: Integer);
begin
  {$IFDEF FPC}
  Dec(AValue);  // DecLocked(AValue);
  {$ELSE}
  InterlockedDecrement(AValue);
  {$ENDIF}
end;

end.
