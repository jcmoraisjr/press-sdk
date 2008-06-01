(*
  PressObjects, Design Data Access Class
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressDesignDAO;

{$I Press.inc}

interface

uses
  PressSubject,
  PressSession,
  PressCodeUpdater,
  PressProjectModel;

type
  TPressDesignDAO = class(TPressSession)
  private
    FCodeUpdater: TPressCodeUpdater;
    FProject: TPressProject;
    procedure AddProjectItems(AProxyList: TPressProxyList; AItems: TPressProjectItemReferences);
    function CreateAttributeTypeList: TPressProxyList;
    function CreateObjectMetadataList: TPressProxyList;
    function CreateProjectModuleList: TPressProxyList;
  protected
    procedure InternalCommit; override;
    function InternalRetrieveQuery(AQuery: TPressQuery): TPressProxyList; override;
    procedure InternalRollback; override;
    procedure InternalStartTransaction; override;
    procedure InternalStore(AObject: TPressObject); override;
    property CodeUpdater: TPressCodeUpdater read FCodeUpdater;
    property Project: TPressProject read FProject;
  public
    constructor Create(AProject: TPressProject; ACodeUpdater: TPressCodeUpdater); reintroduce;
  end;

implementation

uses
  SysUtils,
  PressDesignClasses,
  PressDesignConsts;

{ TPressDesignDAO }

procedure TPressDesignDAO.AddProjectItems(AProxyList: TPressProxyList;
  AItems: TPressProjectItemReferences);
var
  I: Integer;
begin
  for I := 0 to Pred(AItems.Count) do
  begin
    AProxyList.AddInstance(AItems[I]);
    AddProjectItems(AProxyList, AItems[I].ChildItems);
  end;
end;

constructor TPressDesignDAO.Create(
  AProject: TPressProject; ACodeUpdater: TPressCodeUpdater);
begin
  inherited Create;
  FProject := AProject;
  FCodeUpdater := ACodeUpdater;
end;

function TPressDesignDAO.CreateAttributeTypeList: TPressProxyList;
var
  I: Integer;
begin
  { TODO : Sort }
  Result := TPressProxyList.Create(True, ptShared);
  try
    AddProjectItems(Result, Project.PressAttributeRegistry);
    for I := 0 to Pred(Project.RootUserAttributes.ChildItems.Count) do
      AddProjectItems(
       Result, Project.RootUserAttributes.ChildItems[I].ChildItems);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TPressDesignDAO.CreateObjectMetadataList: TPressProxyList;
begin
  { TODO : Sort }
  Result := TPressProxyList.Create(True, ptShared);
  try
    AddProjectItems(Result, Project.RootBusinessClasses.ChildItems);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TPressDesignDAO.CreateProjectModuleList: TPressProxyList;
var
  I: Integer;
begin
  { TODO : Sort }
  Result := TPressProxyList.Create(True, ptShared);
  try
    for I := 0 to Pred(Project.Modules.Count) do
      Result.AddInstance(Project.Modules[I]);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TPressDesignDAO.InternalCommit;
begin
end;

function TPressDesignDAO.InternalRetrieveQuery(
  AQuery: TPressQuery): TPressProxyList;
var
  VTarget: TPressObjectClass;
begin
  VTarget := AQuery.Metadata.ItemObjectClass;
  if VTarget = TPressAttributeTypeRegistry then
    Result := CreateAttributeTypeList
  else if VTarget = TPressObjectMetadataRegistry then
    Result := CreateObjectMetadataList
  else if VTarget = TPressProjectModule then
    Result := CreateProjectModuleList
  else
    Result := nil;
end;

procedure TPressDesignDAO.InternalRollback;
begin
end;

procedure TPressDesignDAO.InternalStartTransaction;
begin
end;

procedure TPressDesignDAO.InternalStore(AObject: TPressObject);
begin
  if AObject is TPressProjectItem then
    CodeUpdater.StoreProjectItem(TPressProjectItem(AObject))
  else
    EPressDesignError.CreateFmt(SUnsupportedClass, [AObject.ClassName]);
end;

end.
