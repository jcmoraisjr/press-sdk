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

{$DEFINE PressBaseUnit}
{$I Press.inc}

interface

uses
  Classes;

{$IFDEF D5Down}
type
  IInterface = IUnknown;
{$ENDIF}

function FormatMaskText(const EditMask: string; const Value: string): string;
function VarFormat(const AFormat: string; const AArg: Variant): string;
procedure GenerateGUID(out AGUID: TGUID);
function SetPropertyValue(AObject: TPersistent; const APathName, AValue: string; AError: Boolean = False): Boolean;
procedure OutputDebugString(const AStr: string);
function UnquotedStr(const AStr: string): string;

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

function FormatMaskText(const EditMask: string; const Value: string): string;
begin
  { TODO : MaskEdit for plain/laz/mse FPC }
  Result :=
   {$IFDEF FPC}Value{$ELSE}{$IFDEF D6Up}MaskUtils{$ELSE}Mask{$ENDIF}
   .FormatMaskText(EditMask, Value){$ENDIF};
end;

function VarFormat(const AFormat: string; const AArg: Variant): string;
begin
  case TVarData(AArg).VType of
    varSmallint: Result := Format(AFormat, [TVarData(AArg).VSmallint]);
    varInteger:  Result := Format(AFormat, [TVarData(AArg).VInteger]);
    varSingle:   Result := Format(AFormat, [TVarData(AArg).VSingle]);
    varDouble:   Result := Format(AFormat, [TVarData(AArg).VDouble]);
    varCurrency: Result := Format(AFormat, [TVarData(AArg).VCurrency]);
    varDate:     Result := Format(AFormat, [TVarData(AArg).VDate]);
    varBoolean:  Result := Format(AFormat, [TVarData(AArg).VBoolean]);
    varByte:     Result := Format(AFormat, [TVarData(AArg).VByte]);
    varString:   Result := Format(AFormat, [string(TVarData(AArg).VString)]);
{$ifndef d5down}
    varShortInt: Result := Format(AFormat, [TVarData(AArg).VShortInt]);
    varWord:     Result := Format(AFormat, [TVarData(AArg).VWord]);
    varLongWord: Result := Format(AFormat, [TVarData(AArg).VLongWord]);
    varInt64:    Result := Format(AFormat, [TVarData(AArg).VInt64]);
{$endif}
    else raise EPressError.Create(SUnsupportedVariantType);
  end;
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

function SetPropertyValue(AObject: TPersistent;
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
        Result := SetPropertyValue(TPersistent(
         GetObjectProp(AObject, VPropInfo, TPersistent)), VPathName, AValue);
      end else
      begin
        VField := AObject.FieldAddress(VPropName);
        { TODO : VField might point to an interface }
        if Assigned(VField) and Assigned(TObject(VField^)) and
         (TObject(VField^) is TPersistent) then
          Result := SetPropertyValue(TPersistent(VField^), VPathName, AValue);
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
            VPropValue := UnquotedStr(AValue);
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

procedure OutputDebugString(const AStr: string);
begin
  {$IFDEF FPC}
  {$ELSE}
  Windows.OutputDebugString(PChar(AStr));
  {$ENDIF}
end;

function UnquotedStr(const AStr: string): string;
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
