(*
  PressObjects, Compatibility unit
  Copyright (C) 2006 Laserpress Ltda.

  http://www.pressobjects.org

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

unit PressCompatibility;

{$I Press.inc}

interface

uses
  {$IFDEF FPC}Calendar, Grids{$ELSE}ComCtrls{$ENDIF}
  {$IFDEF DELPHI}, Windows{$ENDIF};

type
  {$IFDEF D5}
  IInterface = IUnknown;
  {$ENDIF}

  {$IFDEF DELPHI}
  TRect = Windows.TRect;
  {$ENDIF}

  {$IFDEF FPC}
  TDrawCellEvent = TOnDrawCell;
  {$ENDIF}

  TCustomCalendar =
   {$IFDEF FPC}Calendar.TCustomCalendar{$ELSE}ComCtrls.TCommonCalendar{$ENDIF};

function FormatMaskText(const EditMask: string; const Value: string): string;
procedure OutputDebugString(const AStr: string);
procedure ThreadSafeIncrement(var AValue: Integer);
procedure ThreadSafeDecrement(var AValue: Integer);

implementation

uses
  {$IFDEF FPC}MaskEdit{$ELSE}{$IFDEF D6+}MaskUtils{$ELSE}Mask{$ENDIF}{$ENDIF};

function FormatMaskText(const EditMask: string; const Value: string): string;
begin
  Result :=
   {$IFDEF FPC}MaskEdit{$ELSE}{$IFDEF D6+}MaskUtils{$ELSE}Mask{$ENDIF}{$ENDIF}.
   FormatMaskText(EditMask, Value);
end;

procedure OutputDebugString(const AStr: string);
begin
  Windows.OutputDebugString(PChar(AStr));
end;

procedure ThreadSafeIncrement(var AValue: Integer);
begin
  InterlockedIncrement(AValue);
end;

procedure ThreadSafeDecrement(var AValue: Integer);
begin
  InterlockedDecrement(AValue);
end;

end.
