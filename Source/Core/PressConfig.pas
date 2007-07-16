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

  TPressConfigAssignment = class(TPressConfigObject)
  private
    FPropertyValue: string;
    FPropertyName: string;
  protected
    class function InternalApply(Reader: TPressParserReader): Boolean; override;
    procedure InternalRead(Reader: TPressParserReader); override;
  public
    property PropertyName: string read FPropertyName;
    property PropertyValue: string read FPropertyValue;
  end;

implementation

uses
  SysUtils,
  PressCompatibility;

{ TPressConfigReader }

function TPressConfigReader.InternalCreateBigSymbolsArray: TPressStringArray;
begin
  SetLength(Result, 1);
  Result[0] := ':=';
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
  FPropertyValue := Reader.ReadToken;
  Reader.ReadMatch(';');
end;

end.
