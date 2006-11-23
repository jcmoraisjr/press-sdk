(*
  PressObjects, Base Parser Classes
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

unit PressParser;

{$I Press.inc}

interface

uses
  PressClasses;

type
  TPressParserReader = class(TPressTextReader)
  end;

  TPressParserList = class;

  PPressParserObject = ^TPressParserObject;
  TPressParserClass = class of TPressParserObject;

  TPressParserObject = class(TObject)
  private
    FParserObjects: TPressParserList;
    FOwner: TPressParserObject;
    function GetParserObjects: TPressParserList;
  protected
    function FindRule(Reader: TPressParserReader; AClasses: array of TPressParserClass): TPressParserClass;
    class function InternalApply(Reader: TPressParserReader): Boolean; virtual;
    procedure InternalRead(Reader: TPressParserReader); virtual;
    function Parse(Reader: TPressParserReader; AParserClasses: array of TPressParserClass; AOwner: TPressParserObject = nil): TPressParserObject;
    property ParserObjects: TPressParserList read GetParserObjects;
  public
    constructor Create(AOwner: TPressParserObject);
    destructor Destroy; override;
    class function Apply(Reader: TPressParserReader): Boolean;
    procedure Read(Reader: TPressParserReader);
    property Owner: TPressParserObject read FOwner;
  end;

  TPressParserIterator = class;

  TPressParserList = class(TPressList)
  private
    function GetItems(AIndex: Integer): TPressParserObject;
    procedure SetItems(AIndex: Integer; Value: TPressParserObject);
  protected
    function InternalCreateIterator: TPressCustomIterator; override;
  public
    function Add(AObject: TPressParserObject): Integer;
    function CreateIterator: TPressParserIterator;
    function IndexOf(AObject: TPressParserObject): Integer;
    procedure Insert(Index: Integer; AObject: TPressParserObject);
    function Remove(AObject: TPressParserObject): Integer;
    property Items[AIndex: Integer]: TPressParserObject read GetItems write SetItems; default;
  end;

  TPressParserIterator = class(TPressIterator)
  private
    function GetCurrentItem: TPressParserObject;
  public
    property CurrentItem: TPressParserObject read GetCurrentItem;
  end;

implementation

{ TPressParserObject }

class function TPressParserObject.Apply(Reader: TPressParserReader): Boolean;
var
  VPosition: TPressTextPos;
begin
  VPosition := Reader.Position;
  try
    Result := InternalApply(Reader);
  finally
    Reader.Position := VPosition;
  end;
end;

constructor TPressParserObject.Create(AOwner: TPressParserObject);
begin
  inherited Create;
  FOwner := AOwner;
  if Assigned(FOwner) then
    FOwner.ParserObjects.Add(Self);
end;

destructor TPressParserObject.Destroy;
begin
  if Assigned(FOwner) then
    FOwner.ParserObjects.Extract(Self);
  FParserObjects.Free;
  inherited;
end;

function TPressParserObject.FindRule(Reader: TPressParserReader;
  AClasses: array of TPressParserClass): TPressParserClass;
var
  I: Integer;
begin
  for I := Low(AClasses) to High(AClasses) do
  begin
    Result := AClasses[I];
    if Assigned(Result) and Result.Apply(Reader) then
      Exit;
  end;
  Result := nil;
end;

function TPressParserObject.GetParserObjects: TPressParserList;
begin
  if not Assigned(FParserObjects) then
    FParserObjects := TPressParserList.Create(True);
  Result := FParserObjects;
end;

class function TPressParserObject.InternalApply(
  Reader: TPressParserReader): Boolean;
begin
  Result := False;
end;

procedure TPressParserObject.InternalRead(Reader: TPressParserReader);
begin
end;

function TPressParserObject.Parse(
  Reader: TPressParserReader;
  AParserClasses: array of TPressParserClass;
  AOwner: TPressParserObject): TPressParserObject;
var
  VRule: TPressParserClass;
begin
  VRule := FindRule(Reader, AParserClasses);
  if Assigned(VRule) then
  begin
    if not Assigned(AOwner) then
      AOwner := Self;
    Result := VRule.Create(AOwner);
    Result.Read(Reader);
  end else
    Result := nil;
end;

procedure TPressParserObject.Read(Reader: TPressParserReader);
begin
  InternalRead(Reader);
end;

{ TPressParserList }

function TPressParserList.Add(AObject: TPressParserObject): Integer;
begin
  Result := inherited Add(AObject);
end;

function TPressParserList.CreateIterator: TPressParserIterator;
begin
  Result := TPressParserIterator.Create(Self);
end;

function TPressParserList.GetItems(AIndex: Integer): TPressParserObject;
begin
  Result := inherited Items[AIndex] as TPressParserObject;
end;

function TPressParserList.IndexOf(AObject: TPressParserObject): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TPressParserList.Insert(
  Index: Integer; AObject: TPressParserObject);
begin
  inherited Insert(Index, AObject);
end;

function TPressParserList.InternalCreateIterator: TPressCustomIterator;
begin
  Result := CreateIterator;
end;

function TPressParserList.Remove(AObject: TPressParserObject): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TPressParserList.SetItems(
  AIndex: Integer; Value: TPressParserObject);
begin
  inherited Items[AIndex] := Value;
end;

{ TPressParserIterator }

function TPressParserIterator.GetCurrentItem: TPressParserObject;
begin
  Result := inherited CurrentItem as TPressParserObject;
end;

end.
