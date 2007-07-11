(*
  PressObjects, Compatibility and Utilities unit
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressCompatibility;
{ TODO : Rename to PressUtils }

{$I Press.inc}

interface

uses
  Classes,
  {$IFDEF D6+}Variants,{$ENDIF}
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
function SetPropertyValue(AObject: TObject; const APathName, AValue: string): Boolean;
procedure OutputDebugString(const AStr: string);
procedure ThreadSafeIncrement(var AValue: Integer);
procedure ThreadSafeDecrement(var AValue: Integer);

implementation

uses
  TypInfo,
  PressConsts,
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

function SetPropertyValue(AObject: TObject;
  const APathName, AValue: string): Boolean;
var
  VPropInfo: PPropInfo;
  VPropName, VPathName: string;
  VField: Pointer;
  VPos: Integer;
{$IFDEF FPC}
  VPropValue: Variant;
{$ENDIF}
begin
  Result := False;
  if Assigned(AObject) then
  begin
    VPos := Pos(SPressAttributeSeparator, APathName);
    if VPos > 0 then
    begin
      VPropName := Copy(APathName, 1, VPos - 1);
      VPathName := Copy(APathName, VPos + 1, Length(APathName) - VPos);
      VPropInfo := GetPropInfo(AObject, VPropName);
      if Assigned(VPropInfo) and (VPropInfo^.PropType^.Kind = tkClass) then
      begin
        Result := SetPropertyValue(
         GetObjectProp(AObject, VPropInfo), VPathName, AValue);
      end else
      begin
        VField := AObject.FieldAddress(VPropName);
        { TODO : VField might point to an interface }
        if Assigned(VField) and Assigned(TObject(VField^)) then
          Result := SetPropertyValue(TObject(VField^), VPathName, AValue);
      end;
    end else
    begin
      {$IFDEF FPC}
      VPropInfo := GetPropInfo(AObject, APathName);
      Result := Assigned(VPropInfo);
      if Result then
      begin
        case VPropInfo^.PropType^.Kind of
          tkEnumeration:
            VPropValue := GetEnumValue(VPropInfo^.PropType, AValue);
          tkBool:
            VPropValue := not SameText(AValue, SPressFalseString);
          else
            VPropValue := AValue;
        end;
        SetPropValue(AObject, APathName, VPropValue);
      end;
      {$ELSE}
      Result := Assigned(GetPropInfo(AObject, APathName));
      if Result then
        SetPropValue(AObject, APathName, AValue);
      {$ENDIF}
    end;
  end;
end;

procedure OutputDebugString(const AStr: string);
begin
  {$IFDEF FPC}
  {$ELSE}
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
