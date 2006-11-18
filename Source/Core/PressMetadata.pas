(*
  PressObjects, Metadata Parser
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

unit PressMetadata;

{$I Press.inc}

interface

uses
  Classes,
  PressParser,
  PressSubject,
  PressQuery;

type
  TPressMetaParserReader = class(TPressParserReader)
  end;

  TPressMetaParserObject = class;
  TPressMetaParserAttributes = class;

  TPressMetaParser = class(TPressParserObject)
  private
    FObject: TPressMetaParserObject;
    FAttributes: TPressMetaParserAttributes;
    function GetMetadata: TPressObjectMetadata;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Metadata: TPressObjectMetadata read GetMetadata;
    class function ParseMetadata(const AMetadataStr: string): TPressObjectMetadata;
  end;

  TPressMetaParserObject = class(TPressParserObject)
  private
    FMetadata: TPressObjectMetadata;
  protected
    function CreateObjectMetadata(Reader: TPressParserReader): TPressObjectMetadata;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
    procedure InternalReadParams(Reader: TPressParserReader); virtual;
  public
    property Metadata: TPressObjectMetadata read FMetadata;
  end;

  TPressMetaParserQuery = class(TPressMetaParserObject)
  private
    function GetMetadata: TPressQueryMetadata;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalReadParams(Reader: TPressParserReader); override;
  public
    property Metadata: TPressQueryMetadata read GetMetadata;
  end;

  TPressMetaParserAttributeType = class;
  TPressMetaParserCalculated = class;

  TPressMetaParserAttributes = class(TPressParserObject)
  private
    FAttributeType: TPressMetaParserAttributeType;
    FCalcMetadata: TPressMetaParserCalculated;
    FNextAttribute: TPressMetaParserAttributes;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property AttributeType: TPressMetaParserAttributeType read FAttributeType;
  end;

  TPressMetaParserCalculated = class(TPressParserObject)
  private
    FCalcMetadata: TPressCalcMetadata;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;  

  TPressMetaParserAttributeType = class(TPressParserObject)
  private
    FMetadata: TPressAttributeMetadata;
  protected
    class function AttributeInheritsFrom(const AAttributeName: string; AAttributeClassList: array of TPressAttributeClass): Boolean;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Metadata: TPressAttributeMetadata read FMetadata;
  end;

  TPressMetaParserSizeable = class(TPressMetaParserAttributeType)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressMetaParserEnum = class(TPressMetaParserAttributeType)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressMetaParserStructure = class(TPressMetaParserAttributeType)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressMetaParserProperties = class(TPressParserObject)
  private
    FTarget: TPersistent;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property Target: TPersistent read FTarget write FTarget;
  end;

implementation

uses
  SysUtils,
  TypInfo,
  PressConsts,
  PressClasses;

const
  CClassName = 'class name';
  CAttributeName = 'attribute name';
  CPropertyName = 'property name';
  CCalcString = 'Calc';

{ TPressMetaParser }

function TPressMetaParser.GetMetadata: TPressObjectMetadata;
begin
  if Assigned(FObject) then
    Result := FObject.Metadata
  else
    Result := nil;
end;

procedure TPressMetaParser.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FObject := Parse(Reader, [
   TPressMetaParserQuery, TPressMetaParserObject]) as TPressMetaParserObject;
  if not Assigned(FObject) then
    Reader.ErrorExpected(CClassName, Reader.ReadToken);
  if Reader.ReadToken = '(' then
  begin
    FAttributes := Parse(Reader, [
     TPressMetaParserAttributes]) as TPressMetaParserAttributes;
    Reader.ReadMatch(')');
  end else
    Reader.UnreadToken;
  if not Reader.Eof then
    Reader.ReadMatch(';');
  Reader.ReadMatchEof;
end;

class function TPressMetaParser.ParseMetadata(
  const AMetadataStr: string): TPressObjectMetadata;
var
  VParser: TPressMetaParser;
  VReader: TPressMetaParserReader;
begin
  VReader := TPressMetaParserReader.Create(AMetadataStr);
  VParser := TPressMetaParser.Create(nil);
  Result := nil;
  try
    try
      VParser.Read(VReader);
      Result := VParser.Metadata;
    except
      on E: EPressParseError do
        raise EPressError.CreateFmt(SMetadataParseError,
         [E.Line, E.Column, E.Message, AMetadataStr]);
      else
        raise;
    end;
  finally
    VParser.Free;
    VReader.Free;
  end;
end;

{ TPressMetaParserObject }

function TPressMetaParserObject.CreateObjectMetadata(
  Reader: TPressParserReader): TPressObjectMetadata;
var
  Token: string;
  VObjClass: TPressObjectClass;
begin
  Token := Reader.ReadIdentifier;
  VObjClass := PressFindObjectClass(Token);
  if not Assigned(VObjClass) then
    Reader.ErrorExpected(CClassName, Token);
  Result := VObjClass.ObjectMetadataClass.Create(VObjClass);
end;

class function TPressMetaParserObject.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Assigned(PressFindObjectClass(Reader.ReadToken));
end;

procedure TPressMetaParserObject.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FMetadata := CreateObjectMetadata(Reader);
  InternalReadParams(Reader);
  if TPressMetaParserProperties.Apply(Reader) then
    with TPressMetaParserProperties.Create(Self) do
    try
      Target := FMetadata;
      Read(Reader);
    finally
      Free;
    end;
end;

procedure TPressMetaParserObject.InternalReadParams(
  Reader: TPressParserReader);
begin
end;

{ TPressMetaParserQuery }

function TPressMetaParserQuery.GetMetadata: TPressQueryMetadata;
begin
  Result := inherited Metadata as TPressQueryMetadata;
end;

class function TPressMetaParserQuery.InternalApply(
  Reader: TPressParserReader): Boolean;
var
  VObjectClass: TPressObjectClass;
begin
  VObjectClass := PressFindObjectClass(Reader.ReadToken);
  Result := Assigned(VObjectClass) and VObjectClass.InheritsFrom(TPressQuery);
end;

procedure TPressMetaParserQuery.InternalReadParams(
  Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Token := Reader.ReadToken;
  if Token = '(' then
  begin
    Token := Reader.ReadIdentifier;
    Reader.ReadMatch(')');
    Metadata.ItemObjectClassName := Token;
  end else
    Reader.UnreadToken;
end;

{ TPressMetaParserAttributes }

class function TPressMetaParserAttributes.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadToken);
end;

procedure TPressMetaParserAttributes.InternalRead(
  Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Token := Reader.ReadIdentifier;
  Reader.ReadMatch(':');
  FAttributeType := Parse(Reader, [TPressMetaParserSizeable,
   TPressMetaParserEnum, TPressMetaParserStructure,
   TPressMetaParserAttributeType]) as TPressMetaParserAttributeType;
  if not Assigned(FAttributeType) then
    Reader.ErrorExpected(CAttributeName, Reader.ReadToken);
  FAttributeType.Metadata.Name := Token;
  FCalcMetadata := Parse(Reader, [
   TPressMetaParserCalculated]) as TPressMetaParserCalculated;
  if TPressMetaParserProperties.Apply(Reader) then
    with TPressMetaParserProperties.Create(Self) do
    try
      Target := FAttributeType.Metadata;
      Read(Reader);
    finally
      Free;
    end;
  if Reader.ReadToken = ';' then
    FNextAttribute := Parse(Reader, [TPressMetaParserAttributes],
     Owner) as TPressMetaParserAttributes
  else
    Reader.UnreadToken;
end;

{ TPressMetaParserCalculated }

class function TPressMetaParserCalculated.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := SameText(Reader.ReadToken, CCalcString);
end;

procedure TPressMetaParserCalculated.InternalRead(Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Reader.ReadMatchText(CCalcString);
  FCalcMetadata := TPressCalcMetadata.Create;
  try
    if Reader.ReadToken = '(' then
    begin
      Token := Reader.ReadPath;
      while Token <> ')' do
      begin
        FCalcMetadata.AddListenedAttribute(Token);
        Token := Reader.ReadToken;
        if Token = ',' then
          Token := Reader.ReadPath
        else if Token <> ')' then
          Reader.ErrorExpected(')', Token);
      end;
    end else
      Reader.UnreadToken;
    (Owner as TPressMetaParserAttributes).
     AttributeType.Metadata.CalcMetadata := FCalcMetadata;
  except
    FCalcMetadata.Free;
    raise;
  end;
end;

{ TPressMetaParserAttributeType }

class function TPressMetaParserAttributeType.AttributeInheritsFrom(
  const AAttributeName: string;
  AAttributeClassList: array of TPressAttributeClass): Boolean;
var
  I: Integer;
  VAttributeClassItem: TPressAttributeClass;
begin
  Result := True;
  VAttributeClassItem := PressFindAttributeClass(AAttributeName);
  if Assigned(VAttributeClassItem) then
    for I := Low(AAttributeClassList) to High(AAttributeClassList) do
      if VAttributeClassItem.InheritsFrom(AAttributeClassList[I]) then
        Exit;
  Result := False;
end;

class function TPressMetaParserAttributeType.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Assigned(PressFindAttributeClass(Reader.ReadToken));
end;

procedure TPressMetaParserAttributeType.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  FMetadata :=
   (Owner.Owner as TPressMetaParser).Metadata.CreateAttributeMetadata;
  FMetadata.AttributeName := Reader.ReadIdentifier;
end;

{ TPressMetaParserSizeable }

class function TPressMetaParserSizeable.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := AttributeInheritsFrom(Reader.ReadToken, [TPressString]);
end;

procedure TPressMetaParserSizeable.InternalRead(
  Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Token := Reader.ReadToken;
  if Token = '(' then
  begin
    Metadata.Size := Reader.ReadInteger;
    Reader.ReadMatch(')');
  end else
    Reader.UnreadToken;
end;

{ TPressMetaParserEnum }

class function TPressMetaParserEnum.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := AttributeInheritsFrom(Reader.ReadToken, [TPressEnum]);
end;

procedure TPressMetaParserEnum.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('(');
  Metadata.EnumMetadata := PressEnumMetadataByName(Reader.ReadIdentifier);
  Reader.ReadMatch(')');
end;

{ TPressMetaParserStructure }

class function TPressMetaParserStructure.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := AttributeInheritsFrom(Reader.ReadToken,
   [TPressPart, TPressReference, TPressParts, TPressReferences]);
end;

procedure TPressMetaParserStructure.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('(');
  Metadata.ObjectClassName := Reader.ReadToken;
  Reader.ReadMatch(')');
end;

{ TPressMetaParserProperties }

class function TPressMetaParserProperties.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadToken);
end;

procedure TPressMetaParserProperties.InternalRead(
  Reader: TPressParserReader);
var
  Token: string;
  VPropertyName: string;
  VValue: string;
begin
  inherited;
  Token := Reader.ReadToken;
  while IsValidIdent(Token) do
  begin
    VPropertyName := Token;
    Token := Reader.ReadToken;
    if Token = '=' then
    begin
      VValue := Reader.ReadToken;
      Token := Reader.ReadToken;
    end else
      VValue := SPressTrueString;
    if not Assigned(GetPropInfo(FTarget, VPropertyName)) then
      Reader.ErrorExpected(CPropertyName, VPropertyName);
    SetPropValue(FTarget, VPropertyName, VValue);
  end;
  Reader.UnreadToken;
end;

end.
