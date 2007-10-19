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
    procedure AddReportGroup; virtual;
    procedure AddReportItem(AItem: TPressObject; APosition: Integer); virtual;
    function GetReportGroup: TPressCustomReportGroup; virtual;
  public
    constructor Create(AModel: TPressMVPObjectModel);
    destructor Destroy; override;
    property ReportGroup: TPressCustomReportGroup read GetReportGroup;
    property Model: TPressMVPObjectModel read FModel;
  end;

implementation

uses
  Windows,
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

procedure TPressReportManager.AddReportGroup;
var
  VGroupCommand: TPressManageReportsCommand;
begin
  VGroupCommand := TPressManageReportsCommand.Create(
   Model, SPressManageReportCommand, Menus.ShortCut(VK_F9, [ssAlt]));
  VGroupCommand.ReportGroup := ReportGroup;
  Model.AddCommandInstance(VGroupCommand);
end;

procedure TPressReportManager.AddReportItem(
  AItem: TPressObject; APosition: Integer);
var
  VItem: TPressCustomReportItem;
  VReportCommand: TPressExecuteReportCommand;
  VShortCut: TShortCut;
begin
  VItem := AItem as TPressCustomReportItem;
  if VItem.ReportVisible then
  begin
    if APosition = 0 then
      VShortCut := Menus.ShortCut(VK_F9, [ssCtrl])
    else
      VShortCut := 0;
    VReportCommand := TPressExecuteReportCommand.Create(
     Model, VItem.ReportCaption, VShortCut);
    try
      VReportCommand.ReportItem := VItem;
      Model.AddCommandInstance(VReportCommand);
    except
      VReportCommand.Free;
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
        AddReportItem(CurrentItem, CurrentPosition);
    finally
      Free;
    end;
    Model.AddCommand(nil);
    AddReportGroup;
  end;
end;

destructor TPressReportManager.Destroy;
begin
  FReportGroup.Free;
  inherited;
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
     (PressApp.DefaultService(CPressReportDataService) as TPressCustomReportData).
      FindReportGroup(VObject.DataAccess, VObject.ClassName);
    FReportGroup.BusinessObj := VObject;
  end;
  Result := FReportGroup;
end;

end.
