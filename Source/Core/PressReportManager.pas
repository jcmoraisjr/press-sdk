(*
  PressObjects, Report Manager Classes
  Copyright (C) 2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressReportManager;

{$I Press.inc}

interface

uses
  Classes,
  PressSubject,
  PressReport,
  PressMVPModel,
  PressMVPCommand;

type
  TPressExecuteReportCommandClass = class of TPressExecuteReportCommand;

  TPressExecuteReportCommand = class(TPressMVPObjectCommand)
  private
    FReportItem: TPressCustomReportItem;
    procedure SetReportItem(Value: TPressCustomReportItem);
  protected
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  public
    destructor Destroy; override;
    property ReportItem: TPressCustomReportItem read FReportItem write SetReportItem;
  end;

  TPressManageReportsCommandClass = class of TPressManageReportsCommand;

  TPressManageReportsCommand = class(TPressMVPObjectCommand)
  private
    FReportGroup: TPressCustomReportGroup;
    procedure SetReportGroup(Value: TPressCustomReportGroup);
  protected
    procedure InternalExecute; override;
  public
    destructor Destroy; override;
    property ReportGroup: TPressCustomReportGroup read FReportGroup write SetReportGroup;
  end;

  TPressReportManager = class(TObject)
  private
    FModel: TPressMVPObjectModel;
    FReportGroup: TPressCustomReportGroup;
  protected
    function AddReportGroup: TPressManageReportsCommand; virtual;
    function AddReportItem(AItem: TPressCustomReportItem; APosition: Integer): TPressExecuteReportCommand; virtual;
    function GetReportGroup: TPressCustomReportGroup; virtual;
    function InternalManageReportsCommandClass: TPressManageReportsCommandClass; virtual;
    function InternalExecuteReportCommandClass: TPressExecuteReportCommandClass; virtual;
  public
    constructor Create(AModel: TPressMVPObjectModel);
    property ReportGroup: TPressCustomReportGroup read GetReportGroup;
    property Model: TPressMVPObjectModel read FModel;
  end;

implementation

uses
{$IFDEF BORLAND_CG}
  Windows,
{$ELSE}
  LCLType,
{$ENDIF}
  SysUtils,
  Menus,
  PressApplication,
  PressConsts,
  PressMVPPresenter,
  PressMVPFactory;

{ TPressExecuteReportCommand }

destructor TPressExecuteReportCommand.Destroy;
begin
  FReportItem.Free;
  inherited;
end;

procedure TPressExecuteReportCommand.InternalExecute;
begin
  inherited;
  if Assigned(FReportItem) then
    FReportItem.Execute;
end;

function TPressExecuteReportCommand.InternalIsEnabled: Boolean;
var
  VSubject: TPressObject;
begin
  VSubject := Model.Subject;
  Result := not (VSubject is TPressQuery) or (TPressQuery(VSubject).Count > 0);
end;

procedure TPressExecuteReportCommand.SetReportItem(Value: TPressCustomReportItem);
begin
  FReportItem.Free;
  FReportItem := Value;
  if Assigned(FReportItem) then
    FReportItem.AddRef;
end;

{ TPressManageReportsCommand }

destructor TPressManageReportsCommand.Destroy;
begin
  FReportGroup.Free;
  inherited;
end;

procedure TPressManageReportsCommand.InternalExecute;
var
  VIndex: Integer;
begin
  inherited;
  if not Assigned(FReportGroup) then
    Exit;
  VIndex := PressDefaultMVPFactory.Forms.IndexOfObjectClass(
   TPressCustomReportGroup, fpExisting, True);
  if VIndex >= 0 then
    PressDefaultMVPFactory.Forms[VIndex].PresenterClass.Run(FReportGroup);
end;

procedure TPressManageReportsCommand.SetReportGroup(Value: TPressCustomReportGroup);
begin
  FReportGroup.Free;
  FReportGroup := Value;
  if Assigned(FReportGroup) then
    FReportGroup.AddRef;
end;

{ TPressReportManager }

function TPressReportManager.AddReportGroup: TPressManageReportsCommand;
begin
  Result := InternalManageReportsCommandClass.Create(
   Model, SPressManageReportCommand, Menus.ShortCut(VK_F9, [ssAlt]));
  try
    Result.ReportGroup := ReportGroup;
    Model.AddCommandInstance(Result);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TPressReportManager.AddReportItem(
  AItem: TPressCustomReportItem; APosition: Integer): TPressExecuteReportCommand;
var
  VShortCut: TShortCut;
begin
  if AItem.ReportVisible then
  begin
    if APosition = 0 then
      VShortCut := Menus.ShortCut(VK_F9, [ssCtrl])
    else
      VShortCut := 0;
    Result := InternalExecuteReportCommandClass.Create(
     Model, AItem.ReportCaption, VShortCut);
    try
      Result.ReportItem := AItem;
      Model.AddCommandInstance(Result);
    except
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

constructor TPressReportManager.Create(AModel: TPressMVPObjectModel);
begin
  inherited Create;
  if Assigned(AModel) and
   PressApp.Registry[CPressReportDataService].HasDefaultService then
  begin
    FModel := AModel;
    Model.AddCommand(nil);
    with ReportGroup.CreateReportItemIterator do
    try
      BeforeFirstItem;
      while NextItem do
        AddReportItem(CurrentItem as TPressCustomReportItem, CurrentPosition);
    finally
      Free;
    end;
    Model.AddCommand(nil);
    AddReportGroup;
  end;
end;

function TPressReportManager.GetReportGroup: TPressCustomReportGroup;
var
  VObject: TPressObject;
begin
  if not Assigned(FReportGroup) then
  begin
    { TODO : Cache report group objects; include refresh option }
    VObject := Model.Subject;
    FReportGroup :=
     PressDefaultReportDataService.ReportGroupByClassName(VObject.DataAccess, VObject.ClassName);
    FReportGroup.BusinessObj := VObject;
  end;
  Result := FReportGroup;
end;

function TPressReportManager.InternalExecuteReportCommandClass: TPressExecuteReportCommandClass;
begin
  Result := TPressExecuteReportCommand;
end;

function TPressReportManager.InternalManageReportsCommandClass: TPressManageReportsCommandClass;
begin
  Result := TPressManageReportsCommand
end;

end.
