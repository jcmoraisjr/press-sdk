(*
  PressObjects, Code Updater
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressCodeUpdater;

{$I Press.inc}

interface

uses
  Classes,
  PressPascal;

type
  TPressClassType = (ctBusiness, ctMVP);

  TPressClassTypes = set of TPressClassType;

  TPressCodeUpdater = class(TObject)
  private
    FCodeMetadatas: TStrings;
  protected
    function ModuleImplements(AModule: IPressIDEModule; AClassTypes: TPressClassTypes): Boolean;
    property CodeMetadatas: TStrings read FCodeMetadatas;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(AModule: IPressIDEModule);
    procedure ParseBusinessClasses;
    procedure ParseMVPClasses;
    procedure ParseProject(AClassTypes: TPressClassTypes);
  end;

implementation

uses
  SysUtils,
  PressDesignConsts,
  PressIDEIntf;

{ TPressCodeUpdater }

constructor TPressCodeUpdater.Create;
begin
  inherited Create;
  FCodeMetadatas := TStringList.Create;
end;

destructor TPressCodeUpdater.Destroy;
begin
  FCodeMetadatas.Free;
  inherited;
end;

function TPressCodeUpdater.ModuleImplements(AModule: IPressIDEModule;
  AClassTypes: TPressClassTypes): Boolean;
begin
  { TODO : Implement }
  Result := True;
end;

procedure TPressCodeUpdater.Parse(AModule: IPressIDEModule);

   procedure ExtractMetadata(
     Reader: TPressPascalReader; ABlock: TPressPascalBlockStatement);
   var
     VLastStatement: TPressPascalStatement;
   begin
     VLastStatement := ABlock[Pred(ABlock.ItemCount)] as TPressPascalStatement;
     if VLastStatement is TPressPascalPlainStatement then
     begin
       Reader.Position := VLastStatement.StartPos;
       if SameText(Reader.ReadToken, SPressResultStr) and
        (Reader.ReadToken = ':=') then
         CodeMetadatas.Add(Reader.ReadConcatString);
     end;
   end;

   procedure ExtractMVP(
     Reader: TPressPascalReader; ABlock: TPressPascalBlockStatement);
   begin
     { TODO : Implement }
   end;

var
  VReader: TPressPascalReader;
  VUnit: TPressPascalUnit;
  VSection: TPressPascalImplementationSection;
  I: Integer;
begin
  { TODO : Detect if unit type matches with AClassTypes parameter }
  VReader := TPressPascalReader.Create(ASource);
  VUnit := TPressPascalUnit.Create(nil);
  try
    VUnit.Read(VReader);
    VSection := VUnit.ImplementationSection;
    for I := 0 to Pred(VSection.ItemCount) do
      if VSection[I] is TPressPascalProcDeclaration then
        with TPressPascalProcDeclaration(VSection[I]) do
          if Assigned(Header) and Assigned(Body) and Assigned(Body.Block) then
            if (ctBusiness in AClassTypes) and
             SameText(Header.ClassMethodName, SPressMetadataMethodName) then
              ExtractMetadata(VReader, Body.Block)
            else if (ctMVP in AClassTypes) and
            { TODO : Fix method name }
             SameText(Header.ClassMethodName, 'SomeMethodName') then
              ExtractMVP(VReader, Body.Block);
  finally
    VUnit.Free;
    VReader.Free;
  end;
end;

procedure TPressCodeUpdater.ParseBusinessClasses;
begin
  ParseProject([ctBusiness]);
end;

procedure TPressCodeUpdater.ParseMVPClasses;
begin
  ParseProject([ctMVP]);
end;

procedure TPressCodeUpdater.ParseProject(AClassTypes: TPressClassTypes);
var
  VModuleNames: TStrings;
  VModule: IPressIDEModule;
  I: Integer;
begin
  if Assigned(FCodeMetadatas) and (ctBusiness in AClassTypes) then
    FCodeMetadatas.Clear;
  VModuleNames := TStringList.Create;
  try
    PressIDEInterface.ProjectModuleNames(VModuleNames);
    for I := 0 to Pred(VModuleNames.Count) do
    begin
      VModule := PressIDEInterface.ProjectModuleByName(VModuleNames[I]);
      if ModuleImplements(VModule, AClassTypes) then
        Parse(VModule);
    end;
  finally
    VModuleNames.Free;
  end;
end;

end.
