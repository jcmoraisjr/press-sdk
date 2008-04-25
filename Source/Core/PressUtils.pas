(*
  PressObjects, Utilities unit
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressUtils;

{$DEFINE PressBaseUnit}
{$I Press.inc}

interface

uses
{$ifndef d5down}
  Variants,
{$endif}
  Classes;

function PressFormatMaskText(const EditMask: string; const Value: string): string;
function PressVarFormat(const AFormat: string; const AArgs: array of Variant): string;
procedure PressGenerateGUID(out AGUID: TGUID);
function PressSetPropertyValue(AObject: TPersistent; const APathName, AValue: string; AError: Boolean = False): Boolean;
procedure PressOutputDebugString(const AStr: string);
function PressUnquotedStr(const AStr: string): string;

implementation

uses
  SysUtils,
  TypInfo,
{$IFDEF BORLAND_CG}
  Windows,
  ActiveX,
  ComObj,
  {$IFDEF D6Up}
    MaskUtils,
  {$ELSE}
    Mask,
  {$ENDIF}
{$ENDIF}
  PressClasses,
  PressConsts;

function PressFormatMaskText(const EditMask: string; const Value: string): string;
begin
  { TODO : MaskEdit for plain/laz/mse FPC }
  Result :=
   {$IFDEF FPC}Value{$ELSE}{$IFDEF D6Up}MaskUtils{$ELSE}Mask{$ENDIF}
   .FormatMaskText(EditMask, Value){$ENDIF};
end;

function PressVarFormat(const AFormat: string; const AArgs: array of Variant): string;
var
  VConsts: array of TVarRec;
  VExtended: Extended;
{$ifdef fpc}
  VInt64: Int64;
{$endif}
  I: Integer;
begin
  SetLength(VConsts, Length(AArgs));
  for I := 0 to Pred(Length(AArgs)) do
    case TVarData(AArgs[I]).VType of
      varSmallint: begin
        VConsts[I].VType := vtInteger;
        VConsts[I].VInteger := TVarData(AArgs[I]).VSmallint;
      end;
      varInteger: begin
        VConsts[I].VType := vtInteger;
        VConsts[I].VInteger := TVarData(AArgs[I]).VInteger;
      end;
      varSingle: begin
        VExtended := TVarData(AArgs[I]).VSingle;
        VConsts[I].VType := vtExtended;
        VConsts[I].VExtended := @VExtended;
      end;
      varDouble: begin
        VExtended := TVarData(AArgs[I]).VDouble;
        VConsts[I].VType := vtExtended;
        VConsts[I].VExtended := @VExtended;
      end;
      varCurrency: begin
        VConsts[I].VType := vtCurrency;
        VConsts[I].VCurrency := @TVarData(AArgs[I]).VCurrency;
      end;
      varDate: begin
        VExtended := TVarData(AArgs[I]).VDate;
        VConsts[I].VType := vtExtended;
        VConsts[I].VExtended := @VExtended;
      end;
      varBoolean: begin
        VConsts[I].VType := vtBoolean;
        VConsts[I].VBoolean := TVarData(AArgs[I]).VBoolean;
      end;
      varByte: begin
        VConsts[I].VType := vtInteger;
        VConsts[I].VInteger := TVarData(AArgs[I]).VByte;
      end;
      varString: begin
        VConsts[I].VType := vtAnsiString;
        VConsts[I].VAnsiString := TVarData(AArgs[I]).VString;
      end;
{$ifndef d5down}
      varShortInt: begin
        VConsts[I].VType := vtInteger;
        VConsts[I].VInteger := TVarData(AArgs[I]).VShortInt;
      end;
      varWord: begin
        VConsts[I].VType := vtInteger;
        VConsts[I].VInteger := TVarData(AArgs[I]).VWord;
      end;
      varLongWord: begin
        VConsts[I].VType := vtInteger;
        VConsts[I].VInteger := TVarData(AArgs[I]).VLongWord;
      end;
      varInt64: begin
        VConsts[I].VType := vtInt64;
        VConsts[I].VInt64 := @TVarData(AArgs[I]).VInt64;
      end;
{$endif}
{$ifdef fpc}
      varQWord: begin
        VInt64 := TVarData(AArgs[I]).VQWord;
        VConsts[I].VType := vtInt64;
        VConsts[I].VInt64 := @VInt64;
      end;
{$endif}
      else raise EPressError.Create(SUnsupportedVariantType);
    end;
  Result := Format(AFormat, VConsts);
end;

{$IFDEF FPC}
procedure CreateGUIDResultCheck(AResult: Integer);
begin
  { TODO : Check error }
end;
{$ENDIF}

procedure PressGenerateGUID(out AGUID: TGUID);
begin
  {$IFDEF FPC}
  CreateGUIDResultCheck(CreateGUID(AGUID));
  {$ELSE}
  OleCheck(CoCreateGUID(AGUID));
  {$ENDIF}
end;

function PressSetPropertyValue(AObject: TPersistent;
  const APathName, AValue: string; AError: Boolean): Boolean;
var
  VPropInfo: PPropInfo;
  VPropName, VPathName: string;
  VField: Pointer;
  VPos: Integer;
  VPropValue: Variant;
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
        Result := PressSetPropertyValue(TPersistent(
         GetObjectProp(AObject, VPropInfo, TPersistent)), VPathName, AValue);
      end else
      begin
        VField := AObject.FieldAddress(VPropName);
        { TODO : VField might point to an interface }
        if Assigned(VField) and Assigned(TObject(VField^)) and
         (TObject(VField^) is TPersistent) then
          Result := PressSetPropertyValue(TPersistent(VField^), VPathName, AValue);
      end;
    end else
    begin
      VPropInfo := GetPropInfo(AObject, APathName);
      Result := Assigned(VPropInfo);
      if Result then
      begin
        if not Assigned(VPropInfo^.SetProc) then
          raise EPressError.CreateFmt(SPropertyIsReadOnly, [
           AObject.ClassName, APathName]);
        case VPropInfo^.PropType^.Kind of
        {$IFDEF FPC}
          tkSString, tkLString, tkWString, tkAString:
        {$ELSE}
          tkString, tkLString, tkWString:
        {$ENDIF}
            VPropValue := PressUnquotedStr(AValue);
          tkEnumeration:
            begin
              VPropValue := GetEnumValue(
               VPropInfo^.PropType{$IFDEF BORLAND_CG}^{$ENDIF}, AValue);
              if VPropValue < 0 then
                raise EPressError.CreateFmt(SEnumItemNotFound, [AValue]);
            end;
        {$IFDEF FPC}
          tkBool:
            VPropValue := not SameText(AValue, SPressFalseString);
        {$ENDIF}
          else
            VPropValue := AValue;
        end;
        SetPropValue(AObject, APathName, VPropValue);
      end;
    end;
    if AError and not Result then
      raise EPressError.CreateFmt(SPropertyNotFound, [
       AObject.ClassName, APathName]);
  end;
end;

procedure PressOutputDebugString(const AStr: string);
begin
  {$IFDEF FPC}
  {$ELSE}
  Windows.OutputDebugString(PChar(AStr));
  {$ENDIF}
end;

function PressUnquotedStr(const AStr: string): string;
var
  PStr: PChar;
begin
  if (AStr <> '') and (AStr[1] in ['''', '"']) and
   (AStr[1] = AStr[Length(AStr)]) then
  begin
    PStr := PChar(AStr);
    Result := AnsiExtractQuotedStr(PStr, AStr[1]);
  end else
    Result := AStr;
end;

end.
