(*
  PressObjects, Configuration File Parser
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressConfig;

{$I Press.inc}

interface

uses
  Classes,
  Contnrs,
  PressClasses,
  PressParser;

type
  TPressConfigReader = class(TPressParserReader)
  protected
    procedure InternalCheckComment(var AToken: string); override;
    function InternalCreateBigSymbolsArray: TPressStringArray; override;
  end;

  TPressConfigObject = class(TPressParserObject)
  end;

  TPressConfigSection = class;

  TPressConfigFile = class(TPressConfigObject)
  private
    FSections: TObjectList;
    function GetSections(AIndex: Integer): TPressConfigSection;
  protected
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    constructor Create(AOwner: TPressParserObject); override;
    destructor Destroy; override;
    function SectionCount: Integer;
    property Sections[AIndex: Integer]: TPressConfigSection read GetSections;
  end;

  TPressConfigAssignment = class;

  TPressConfigSection = class(TPressConfigObject)
  private
    FAssignments: TObjectList;
    FSectionName: string;
    FSubSectionName: string;
    function GetAssignments(AIndex: Integer): TPressConfigAssignment;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    constructor Create(AOwner: TPressParserObject); override;
    destructor Destroy; override;
    function AssignmentCount: Integer;
    procedure Execute(AObject: TPersistent);
    property Assignments[AIndex: Integer]: TPressConfigAssignment read GetAssignments;
    property SectionName: string read FSectionName;
    property SubSectionName: string read FSubSectionName;
  end;

  TPressConfigValue = class;

  TPressConfigAssignment = class(TPressConfigObject)
  private
    FPropertyName: string;
    FPropertyValue: TPressConfigValue;
    function GetPropertyValue: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property PropertyName: string read FPropertyName;
    property PropertyValue: string read GetPropertyValue;
  end;

  TPressConfigValue = class(TPressConfigObject)
  protected
    function GetValue: string; virtual; abstract;
  public
    property Value: string read GetValue;
  end;

  TPressConfigLiteralValue = class(TPressConfigValue)
  private
    FValue: string;
  protected
    function GetValue: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  end;

  TPressConfigFunction = class;

  TPressConfigFunctionValue = class(TPressConfigValue)
  private
    FFunction: TPressConfigFunction;
  protected
    function GetValue: string; override;
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    destructor Destroy; override;
  end;

  TPressConfigFunction = class(TObject)
  private
    FParams: TStrings;
    function GetParams: TStrings;
  protected
    function GetValue: string; virtual; abstract;
  public
    destructor Destroy; override;
    class procedure RegisterFunction(const AFunctionName: string);
    property Params: TStrings read GetParams;
    property Value: string read GetValue;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressCompatibility;

var
  _FunctionsList: IPressHolder;

function PressFunctionsList: TStrings;
begin
  if not Assigned(_FunctionsList) then
  begin
    _FunctionsList := TPressHolder.Create(TStringList.Create);
    with TStringList(_FunctionsList.Instance) do
    begin
      Sorted := True;
      Duplicates := dupError;
    end;
  end;
  Result := TStrings(_FunctionsList.Instance);
end;

{ TPressConfigReader }

procedure TPressConfigReader.InternalCheckComment(var AToken: string);
begin
  inherited;
  if (AToken = '//') or (AToken = '#') then
    while ReadChar <> #10 do
  else
    Exit;
  AToken := ReadToken;
end;

function TPressConfigReader.InternalCreateBigSymbolsArray: TPressStringArray;
begin
  SetLength(Result, 2);
  Result[0] := ':=';
  Result[1] := '//';
end;

{ TPressConfigFile }

constructor TPressConfigFile.Create(AOwner: TPressParserObject);
begin
  inherited Create(AOwner);
  FSections := TObjectList.Create(False);
end;

destructor TPressConfigFile.Destroy;
begin
  FSections.Free;
  inherited;
end;

function TPressConfigFile.GetSections(AIndex: Integer): TPressConfigSection;
begin
  Result := FSections[AIndex] as TPressConfigSection;
end;

procedure TPressConfigFile.InternalRead(Reader: TPressParserReader);
var
  VSection: TPressConfigSection;
begin
  inherited;
  repeat
    VSection := TPressConfigSection(
     Parse(Reader, [TPressConfigSection]));
    if Assigned(VSection) then
      FSections.Add(VSection);
  until not Assigned(VSection);
  Reader.ReadMatchEof;
end;

function TPressConfigFile.SectionCount: Integer;
begin
  Result := FSections.Count;
end;

{ TPressConfigSection }

function TPressConfigSection.AssignmentCount: Integer;
begin
  Result := FAssignments.Count;
end;

constructor TPressConfigSection.Create(AOwner: TPressParserObject);
begin
  inherited Create(AOwner);
  FAssignments := TObjectList.Create(False);
end;

destructor TPressConfigSection.Destroy;
begin
  FAssignments.Free;
  inherited;
end;

procedure TPressConfigSection.Execute(AObject: TPersistent);
var
  I: Integer;
begin
  for I := 0 to Pred(AssignmentCount) do
    with Assignments[I] do
      SetPropertyValue(AObject, PropertyName, PropertyValue, True);
end;

function TPressConfigSection.GetAssignments(
  AIndex: Integer): TPressConfigAssignment;
begin
  Result := FAssignments[AIndex] as TPressConfigAssignment;
end;

class function TPressConfigSection.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := Reader.ReadToken = '[';
end;

procedure TPressConfigSection.InternalRead(Reader: TPressParserReader);
var
  VAssignment: TPressConfigAssignment;
begin
  inherited;
  Reader.ReadMatch('[');
  FSectionName := Reader.ReadIdentifier;
  if Reader.ReadToken = '.' then
    FSubSectionName := Reader.ReadIdentifier
  else
    Reader.UnreadToken;
  Reader.ReadMatch(']');
  repeat
    VAssignment := TPressConfigAssignment(
     Parse(Reader, [TPressConfigAssignment]));
    if Assigned(VAssignment) then
      FAssignments.Add(VAssignment);
  until not Assigned(VAssignment);
end;

{ TPressConfigAssignment }

function TPressConfigAssignment.GetPropertyValue: string;
begin
  if Assigned(FPropertyValue) then
    Result := FPropertyValue.Value
  else
    Result := '';
end;

class function TPressConfigAssignment.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadToken);
end;

procedure TPressConfigAssignment.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FPropertyName := Reader.ReadIdentifier;
  while Reader.ReadToken = '.' do
    FPropertyName := FPropertyName + '.' + Reader.ReadIdentifier;
  Reader.UnreadToken;
  Reader.ReadMatch(':=');
  FPropertyValue := TPressConfigValue(Parse(Reader, [
   TPressConfigFunctionValue, TPressConfigLiteralValue],
   Self, True, SPressExpressionMsg));
  while Reader.ReadToken = ';' do
    ;
  Reader.UnreadToken;
end;

{ TPressConfigLiteralValue }

function TPressConfigLiteralValue.GetValue: string;
begin
  Result := FValue;
end;

class function TPressConfigLiteralValue.InternalApply(
  Reader: TPressParserReader): Boolean;
var
  Token: string;
begin
  Token := Reader.ReadToken;
  Result := (Length(Token) > 0) and (Token[1] in ['0'..'9', '''', '"']);
end;

procedure TPressConfigLiteralValue.InternalRead(Reader: TPressParserReader);
begin
  inherited;
  FValue := Reader.ReadToken;
end;

{ TPressConfigFunctionValue }

destructor TPressConfigFunctionValue.Destroy;
begin
  FFunction.Free;
  inherited;
end;

function TPressConfigFunctionValue.GetValue: string;
begin
  if Assigned(FFunction) then
    Result := FFunction.Value
  else
    Result := '';
end;

class function TPressConfigFunctionValue.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := IsValidIdent(Reader.ReadToken);
end;

procedure TPressConfigFunctionValue.InternalRead(Reader: TPressParserReader);
var
  VIndex: Integer;
  Token: string;
begin
  inherited;
  Token := Reader.ReadToken;
  VIndex := PressFunctionsList.IndexOf(Token);
  if VIndex = -1 then
    Reader.ErrorExpected(SPressFunctionMsg, Token);
  FFunction :=
   TClass(PressFunctionsList.Objects[VIndex]).Create as TPressConfigFunction;
  if Reader.ReadNextToken = '(' then
  begin
    Reader.ReadMatch('(');
    Token := Reader.ReadToken;
    while Token <> ')' do
    begin
      if (Token = '') or (not IsValidIdent(Token) and
       not (Token[1] in ['0'..'9', '''', '"'])) then
        Reader.ErrorExpected(SPressExpressionMsg, Token);
      FFunction.Params.Add(Token);
      Token := Reader.ReadToken;
      if Token = ',' then
        Token := Reader.ReadToken
      else if Token <> ')' then
        Reader.ErrorExpected(')', Token);
    end;
  end
end;

{ TPressConfigFunction }

destructor TPressConfigFunction.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TPressConfigFunction.GetParams: TStrings;
begin
  if not Assigned(FParams) then
    FParams := TStringList.Create;
  Result := FParams;
end;

class procedure TPressConfigFunction.RegisterFunction(
  const AFunctionName: string);
begin
  PressFunctionsList.AddObject(AFunctionName, TObject(Self));
end;

end.
