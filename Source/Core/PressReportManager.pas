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
    FReportItem: TPressReportItem;
    procedure SetReportItem(Value: TPressReportItem);
  protected
    function GetCaption: string; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  public
    destructor Destroy; override;
    property ReportItem: TPressReportItem read FReportItem write SetReportItem;
  end;

  TPressManageReportsCommand = class(TPressMVPObjectCommand)
  private
    FReportGroup: TPressReportGroup;
    procedure SetReportGroup(Value: TPressReportGroup);
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  public
    destructor Destroy; override;
    property ReportGroup: TPressReportGroup read FReportGroup write SetReportGroup;
  end;

  TPressReportManager = class(TObject)
  private
    FModel: TPressMVPObjectModel;
    FReportGroup: TPressReportGroup;
  protected
    procedure AddReportGroup; virtual;
    procedure AddReportItem(AItem: TPressObject); virtual;
    function GetReportGroup: TPressReportGroup; virtual;
  public
    constructor Create(AModel: TPressMVPObjectModel);
    destructor Destroy; override;
    property ReportGroup: TPressReportGroup read GetReportGroup;
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

function TPressExecuteReportCommand.GetCaption: string;
begin
  if Assigned(FReportItem) then
    Result := FReportItem.ReportCaption
  else
    Result := '';
end;

procedure TPressExecuteReportCommand.InternalExecute;
begin
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

procedure TPressExecuteReportCommand.SetReportItem(Value: TPressReportItem);
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

function TPressManageReportsCommand.GetCaption: string;
begin
  Result := SPressManageReportCommand;
end;

function TPressManageReportsCommand.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(VK_F9, [ssCtrl]);
end;

procedure TPressManageReportsCommand.InternalExecute;
var
  VIndex: Integer;
begin
  if not Assigned(FReportGroup) then
    Exit;
  VIndex := PressDefaultMVPFactory.Forms.IndexOfObjectClass(
   TPressReportGroup, fpExisting, True);
  if VIndex >= 0 then
    PressDefaultMVPFactory.Forms[VIndex].PresenterClass.Run(FReportGroup);
end;

procedure TPressManageReportsCommand.SetReportGroup(Value: TPressReportGroup);
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
  VGroupCommand := TPressManageReportsCommand.Create(Model);
  VGroupCommand.ReportGroup := ReportGroup;
  Model.AddCommandInstance(VGroupCommand);
end;

procedure TPressReportManager.AddReportItem(AItem: TPressObject);
var
  VItem: TPressReportItem;
  VReportCommand: TPressExecuteReportCommand;
begin
  VItem := AItem as TPressReportItem;
  if VItem.ReportVisible then
  begin
    VReportCommand := TPressExecuteReportCommand.Create(Model);
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
        AddReportItem(CurrentItem);
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

function TPressReportManager.GetReportGroup: TPressReportGroup;
begin
  if not Assigned(FReportGroup) then
  begin
    { TODO : Cache report group objects; include refresh option }
    FReportGroup :=
     (PressApp.DefaultService(CPressReportDataService) as TPressReportData).
      FindReportGroup(Model.Subject.DataAccess, Model.Subject.ClassName);
    FReportGroup.BusinessObj := Model.Subject;
  end;
  Result := FReportGroup;
end;

end.
