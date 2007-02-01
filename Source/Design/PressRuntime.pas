(*
  PressObjects, Runtime classes implementation for design time packages
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressRuntime;

{$I Press.inc}

interface

uses
  PressSubject,
  PressCodeUpdater;

type
  TPressRuntimeBOModel = class(TPressModel)
  public
    procedure ClearMetadatas;
  end;

  TPressRuntimeMVPModel = class(TObject)
  { TODO : Implement core MVPModel and MVPMetadata }
  end;

  TPressRuntimeClasses = class(TObject)
  private
    FCodeUpdater: TPressCodeUpdater;
    FBOModel: TPressRuntimeBOModel;
    FMVPModel: TPressRuntimeMVPModel;
    function GetCodeUpdater: TPressCodeUpdater;
    function GetBOModel: TPressRuntimeBOModel;
    function GetMVPModel: TPressRuntimeMVPModel;
  protected
    property CodeUpdater: TPressCodeUpdater read GetCodeUpdater;
  public
    destructor Destroy; override;
    procedure ReadBusinessClasses;
    procedure ReadMVPClasses;
    procedure WriteBusinessClasses;
    procedure WriteMVPClasses;
    property BOModel: TPressRuntimeBOModel read GetBOModel;
    property MVPModel: TPressRuntimeMVPModel read GetMVPModel;
  end;

function PressRuntimeClasses: TPressRuntimeClasses;

implementation

uses
  Classes;

var
  _PressRuntimeClasses: TPressRuntimeClasses;

function PressRuntimeClasses: TPressRuntimeClasses;
begin
  Result := _PressRuntimeClasses;
end;

{ TPressRuntimeBOModel }

procedure TPressRuntimeBOModel.ClearMetadatas;
begin
  with Metadatas do
    while Count > 0 do
      Delete(Count - 1);
end;

{ TPressRuntimeClasses }

destructor TPressRuntimeClasses.Destroy;
begin
  FCodeUpdater.Free;
  FBOModel.Free;
  FMVPModel.Free;
  inherited;
end;

function TPressRuntimeClasses.GetCodeUpdater: TPressCodeUpdater;
begin
  if not Assigned(FCodeUpdater) then
    FCodeUpdater := TPressCodeUpdater.Create;
  Result := FCodeUpdater;
end;

function TPressRuntimeClasses.GetBOModel: TPressRuntimeBOModel;
begin
  if not Assigned(FBOModel) then
    FBOModel := TPressRuntimeBOModel.Create;
  Result := FBOModel;
end;

function TPressRuntimeClasses.GetMVPModel: TPressRuntimeMVPModel;
begin
  if not Assigned(FMVPModel) then
    FMVPModel := TPressRuntimeMVPModel.Create;
  Result := FMVPModel;
end;

procedure TPressRuntimeClasses.ReadBusinessClasses;
var
  VCodeMetadatas: TStrings;
  I: Integer;
begin
  CodeUpdater.ParseBusinessClasses;
  VCodeMetadatas := CodeUpdater.CodeMetadatas;
  BOModel.ClearMetadatas;
  for I := 0 to Pred(VCodeMetadatas.Count) do
    BOModel.RegisterMetadata(VCodeMetadatas[I]);
end;

procedure TPressRuntimeClasses.ReadMVPClasses;
begin
  { TODO : Implement }
end;

procedure TPressRuntimeClasses.WriteBusinessClasses;
begin
  { TODO : Implement }
end;

procedure TPressRuntimeClasses.WriteMVPClasses;
begin
  { TODO : Implement }
end;

initialization
  _PressRuntimeClasses := TPressRuntimeClasses.Create;

finalization
  _PressRuntimeClasses.Free;

end.
