(*
  PressObjects, Metadata Parser
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMetadata;

{$I Press.inc}

interface

uses
  PressClasses,
  PressParser,
  PressSubject;

type
  TPressMetaParserReader = class(TPressParserReader)
  private
    FModel: TPressModel;
  public
    property Model: TPressModel read FModel write FModel;
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
    class function ParseMetadata(const AMetadataStr: string; AModel: TPressModel = nil): TPressObjectMetadata;
  end;

  TPressMetaParserStreamable = class(TPressParserObject)
  protected
    procedure ParseProperties(Reader: TPressParserReader; ATarget: TPressStreamable);
  end;

  TPressMetaParserObject = class(TPressMetaParserStreamable)
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

  TPressMetaParserAttributes = class(TPressParserObject)
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressMetaParserAttributeType = class;
  TPressMetaParserCalculated = class;

  TPressMetaParserAttribute = class(TPressMetaParserStreamable)
  private
    FAttributeType: TPressMetaParserAttributeType;
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
  public
    property CalcMetadata: TPressCalcMetadata read FCalcMetadata;
  end;

  TPressMetaParserAttributeType = class(TPressParserObject)
  private
    FMetadata: TPressAttributeMetadata;
  protected
    class function AttributeInheritsFrom(Reader: TPressParserReader; const AAttributeName: string; AAttributeClassList: array of TPressAttributeClass): Boolean;
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
    FTarget: TPressStreamable;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressCompatibility,
  PressAttributes;

{ Local routines }

function ReadModel(Reader: TPressParserReader): TPressModel;
begin
  if (Reader is TPressMetaParserReader) and
   Assigned(TPressMetaParserReader(Reader).Model) then
    Result := TPressMetaParserReader(Reader).Model
  else
    Result := PressModel;
end;

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
  FObject := TPressMetaParserObject(Parse(Reader, [
   TPressMetaParserQuery, TPressMetaParserObject],
   Self, True, SPressClassNameMsg));
  FAttributes := TPressMetaParserAttributes(
   Parse(Reader, [TPressMetaParserAttributes]));
  if not Reader.Eof then
    Reader.ReadMatch(';');
  Reader.ReadMatchEof;
end;

class function TPressMetaParser.ParseMetadata(
  const AMetadataStr: string; AModel: TPressModel): TPressObjectMetadata;
var
  VParser: TPressMetaParser;
  VReader: TPressMetaParserReader;
begin
  VReader := TPressMetaParserReader.Create(AMetadataStr);
  VReader.Model := AModel;
  VParser := TPressMetaParser.Create(nil);
  Result := nil;
  try
    try
      if Assigned(AModel) then
        Result := AModel.FindMetadata(VReader.ReadNextToken);
      if not Assigned(Result) then
      begin
        VParser.Read(VReader);
        Result := VParser.Metadata;
      end;
    except
      on E: Exception do
        raise EPressError.CreateFmt(SMetadataParseError, [
         VReader.TokenPos.Line, VReader.TokenPos.Column,
         E.Message, AMetadataStr]);
    end;
  finally
    VParser.Free;
    VReader.Free;
  end;
end;

{ TPressMetaParserStreamable }

procedure TPressMetaParserStreamable.ParseProperties(
  Reader: TPressParserReader; ATarget: TPressStreamable);
var
  VParser: TPressMetaParserProperties;
begin
  if TPressMetaParserProperties.Apply(Reader) then
  begin
    VParser := TPressMetaParserProperties.Create(Self);
    VParser.FTarget := ATarget;  // friend class
    VParser.Read(Reader);
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
  VObjClass := ReadModel(Reader).FindClass(Token);
  if not Assigned(VObjClass) then
    Reader.ErrorExpected(SPressClassNameMsg, Token);
  Result := VObjClass.ObjectMetadataClass.Create(Token, ReadModel(Reader));
end;

class function TPressMetaParserObject.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Assigned(ReadModel(Reader).FindClass(Reader.ReadToken));
end;

procedure TPressMetaParserObject.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FMetadata := CreateObjectMetadata(Reader);
  InternalReadParams(Reader);
  ParseProperties(Reader, Metadata);
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
  VObjectClass := ReadModel(Reader).FindClass(Reader.ReadToken);
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
  Result := Reader.ReadToken = '(';
end;

procedure TPressMetaParserAttributes.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('(');
  repeat
    Parse(Reader, [TPressMetaParserAttribute]);
  until Reader.ReadToken <> ';';
  Reader.UnreadToken;
  Reader.ReadMatch(')');
end;

{ TPressMetaParserAttribute }

class function TPressMetaParserAttribute.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadToken);
end;

procedure TPressMetaParserAttribute.InternalRead(
  Reader: TPressParserReader);
var
  VCalcMetadata: TPressMetaParserCalculated;
  Token: string;
begin
  inherited;
  Token := Reader.ReadIdentifier;
  Reader.ReadMatch(':');
  FAttributeType := TPressMetaParserAttributeType(Parse(Reader, [
   TPressMetaParserSizeable, TPressMetaParserEnum, TPressMetaParserStructure,
   TPressMetaParserAttributeType], Self, True, SPressAttributeNameMsg));
  FAttributeType.Metadata.Name := Token;
  VCalcMetadata := TPressMetaParserCalculated(
   Parse(Reader, [TPressMetaParserCalculated]));
  if Assigned(VCalcMetadata) then
    AttributeType.Metadata.CalcMetadata := VCalcMetadata.CalcMetadata;
  ParseProperties(Reader, AttributeType.Metadata);
end;

{ TPressMetaParserCalculated }

class function TPressMetaParserCalculated.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := SameText(Reader.ReadToken, SPressCalcString);
end;

procedure TPressMetaParserCalculated.InternalRead(Reader: TPressParserReader);
var
  Token: string;
begin
  inherited;
  Reader.ReadMatchText(SPressCalcString);
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
  except
    FCalcMetadata.Free;
    raise;
  end;
end;

{ TPressMetaParserAttributeType }

class function TPressMetaParserAttributeType.AttributeInheritsFrom(
  Reader: TPressParserReader; const AAttributeName: string;
  AAttributeClassList: array of TPressAttributeClass): Boolean;
var
  I: Integer;
  VAttributeClassItem: TPressAttributeClass;
begin
  Result := True;
  VAttributeClassItem := ReadModel(Reader).FindAttribute(AAttributeName);
  if Assigned(VAttributeClassItem) then
    for I := Low(AAttributeClassList) to High(AAttributeClassList) do
      if VAttributeClassItem.InheritsFrom(AAttributeClassList[I]) then
        Exit;
  Result := False;
end;

class function TPressMetaParserAttributeType.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Assigned(ReadModel(Reader).FindAttribute(Reader.ReadToken));
end;

procedure TPressMetaParserAttributeType.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  FMetadata :=
   (Owner.Owner.Owner as TPressMetaParser).Metadata.CreateAttributeMetadata;
  FMetadata.AttributeName := Reader.ReadIdentifier;
end;

{ TPressMetaParserSizeable }

class function TPressMetaParserSizeable.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := AttributeInheritsFrom(Reader, Reader.ReadToken, [TPressString]);
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
  Result := AttributeInheritsFrom(Reader, Reader.ReadToken, [TPressEnum]);
end;

procedure TPressMetaParserEnum.InternalRead(
  Reader: TPressParserReader);
begin
  inherited;
  Reader.ReadMatch('(');
  Metadata.EnumMetadata :=
   ReadModel(Reader).EnumMetadataByName(Reader.ReadIdentifier);
  Reader.ReadMatch(')');
end;

{ TPressMetaParserStructure }

class function TPressMetaParserStructure.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := AttributeInheritsFrom(Reader, Reader.ReadToken,
   [TPressPart, TPressReference, TPressParts, TPressReferences]);
end;

procedure TPressMetaParserStructure.InternalRead(
  Reader: TPressParserReader);
var
  Token: string;
  VValidObjectClass: TPressObjectClass;
begin
  inherited;
  if not Metadata.AttributeClass.InheritsFrom(TPressStructure) then
    raise EPressError.CreateFmt(SInvalidClassInheritance,
     [Metadata.AttributeClass.ClassName, TPressStructure.ClassName]);
  VValidObjectClass :=
   TPressStructureClass(Metadata.AttributeClass).ValidObjectClass;
  if VValidObjectClass = TPressObject then
  begin
    Reader.ReadMatch('(');
    Metadata.ObjectClassName := Reader.ReadToken;
    Reader.ReadMatch(')');
  end else
  begin
    Token := Reader.ReadToken;
    if Token <> '(' then
    begin
      Reader.UnreadToken;
      Metadata.ObjectClass := VValidObjectClass;
    end else
    begin
      Metadata.ObjectClassName := Reader.ReadToken;
      Reader.ReadMatch(')');
    end;
  end;
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
  VPropertyName: string;
  VValue: string;
  Token: string;
begin
  inherited;
  Token := Reader.ReadToken;
  while IsValidIdent(Token) do
  begin
    VPropertyName := Token;
    Token := Reader.ReadToken;
    if Token = '=' then
    begin
      if IsValidIdent(Reader.NextChar) then
        VValue := Reader.ReadPath
      else
        VValue := Reader.ReadToken;
      Token := Reader.ReadToken;
    end else
      VValue := SPressTrueString;
    if not SetPropertyValue(FTarget, VPropertyName, VValue) then
      Reader.ErrorExpected(SPressPropertyNameMsg, VPropertyName);
  end;
  Reader.UnreadToken;
end;

end.
