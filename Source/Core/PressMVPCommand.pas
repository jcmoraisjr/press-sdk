(*
  PressObjects, MVP-Command Classes
  Copyright (C) 2006-2007 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMVPCommand;

{$I Press.inc}

interface

uses
  Classes,
  PressNotifier,
  PressSubject,
  PressAttributes,
  PressPicture,
  PressMVP,
  PressMVPModel;

type
  { TPressMVPCommand }

  TPressMVPNullCommand = class(TPressMVPCommand)
  protected
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPDateCommand = class(TPressMVPCommand)
  private
    function GetSubject: TPressValue;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    property Subject: TPressValue read GetSubject;
  end;

  TPressMVPTodayCommand = class(TPressMVPDateCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPPictureCommand = class(TPressMVPCommand)
  private
    function GetSubject: TPressPicture;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    property Subject: TPressPicture read GetSubject;
  end;

  TPressMVPLoadPictureCommand = class(TPressMVPPictureCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPRemovePictureCommand = class(TPressMVPPictureCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InitNotifier; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPStructureCommand = class(TPressMVPCommand)
  private
    function GetModel: TPressMVPStructureModel;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    property Model: TPressMVPStructureModel read GetModel;
  end;

  TPressMVPEditItemCommand = class(TPressMVPStructureCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPReferenceCommand = class(TPressMVPStructureCommand)
  private
    function GetModel: TPressMVPReferenceModel;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    property Model: TPressMVPReferenceModel read GetModel;
  end;

  TPressMVPIncludeObjectCommand = class(TPressMVPReferenceCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPItemsCommand = class(TPressMVPStructureCommand)
  private
    function GetModel: TPressMVPItemsModel;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    property Model: TPressMVPItemsModel read GetModel;
  end;

  TPressMVPAssignSelectionCommand = class(TPressMVPItemsCommand)
  protected
    function GetCaption: string; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPCustomAddItemsCommand = class(TPressMVPItemsCommand)
  protected
    function InternalCreateObject: TPressObject; virtual;
    procedure InternalExecute; override;
    function InternalObjectClass: TPressObjectClass; virtual;
  end;

  TPressMVPAddItemsCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
  end;

  TPressMVPInsertItemsCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalCreateObject: TPressObject; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPAddReferencesCommand = class(TPressMVPItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPRemoveItemsCommand = class(TPressMVPItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPSelectionCommand = class(TPressMVPItemsCommand)
  protected
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPSelectAllCommand = class(TPressMVPSelectionCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPSelectNoneCommand = class(TPressMVPSelectionCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPSelectCurrentCommand = class(TPressMVPSelectionCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPSelectInvertCommand = class(TPressMVPSelectionCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPSortCommand = class(TPressMVPItemsCommand)
  private
    FColumnNumber: Integer;
  protected
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  public
    property ColumnNumber: Integer read FColumnNumber write FColumnNumber;
  end;

  TPressMVPObjectCommand = class(TPressMVPCommand)
  private
    function GetModel: TPressMVPObjectModel;
  protected
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    procedure BindObject(AObject: TPressObject); override;
    procedure ReleaseObject(AObject: TPressObject); override;
    property Model: TPressMVPObjectModel read GetModel;
  end;

  TPressMVPEmptySubjectCommand = class(TPressMVPObjectCommand)
  protected
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPRefreshObjectCommand = class(TPressMVPObjectCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPSaveObjectCommand = class(TPressMVPObjectCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalConfirm: Boolean; virtual;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
    procedure InternalStoreObject; virtual;
  end;

  TPressMVPSaveConfirmObjectCommand = class(TPressMVPSaveObjectCommand)
  protected
    function InternalConfirm: Boolean; override;
  end;

  TPressMVPFinishObjectCommand = class(TPressMVPObjectCommand)
  protected
    procedure CloseForm;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPCancelObjectCommand = class(TPressMVPFinishObjectCommand)
  protected
    function GetCaption: string; override;
    function InternalConfirm: Boolean; virtual;
    procedure InternalExecute; override;
  end;

  TPressMVPCancelConfirmObjectCommand = class(TPressMVPCancelObjectCommand)
  protected
    function InternalConfirm: Boolean; override;
  end;

  TPressMVPCloseObjectCommand = class(TPressMVPFinishObjectCommand)
  protected
    function GetCaption: string; override;
    procedure InternalExecute; override;
  end;

  TPressMVPQueryCommand = class(TPressMVPCommand)
  private
    function GetModel: TPressMVPQueryModel;
  protected
    procedure InternalExecute; override;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    property Model: TPressMVPQueryModel read GetModel;
  end;

  TPressMVPExecuteQueryCommand = class(TPressMVPQueryCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPCloseApplicationCommand = class(TPressMVPCommand)
  protected
    procedure InternalExecute; override;
  end;

implementation

uses
  SysUtils,
  PressConsts,
  PressApplication,
  PressDialogs,
  PressMVPPresenter,
  PressMVPWidget;

{ TPressMVPNullCommand }

function TPressMVPNullCommand.InternalIsEnabled: Boolean;
begin
  Result := False;
end;

{ TPressMVPDateCommand }

class function TPressMVPDateCommand.Apply(AModel: TPressMVPModel): Boolean;
begin
  Result := AModel is TPressMVPDateModel;
end;

function TPressMVPDateCommand.GetSubject: TPressValue;
begin
  Result := Model.Subject as TPressValue;
end;

{ TPressMVPTodayCommand }

function TPressMVPTodayCommand.GetCaption: string;
begin
  Result := SPressTodayCommand;
end;

function TPressMVPTodayCommand.GetShortCut: TShortCut;
begin
  Result := SPressTodayCommandShortCut;
end;

procedure TPressMVPTodayCommand.InternalExecute;
begin
  inherited;
  Subject.AsDateTime := Now;
end;

{ TPressMVPPictureCommand }

class function TPressMVPPictureCommand.Apply(
  AModel: TPressMVPModel): Boolean;
begin
  Result := AModel is TPressMVPPictureModel;
end;

function TPressMVPPictureCommand.GetSubject: TPressPicture;
begin
  Result := Model.Subject as TPressPicture;
end;

{ TPressMVPLoadPictureCommand }

function TPressMVPLoadPictureCommand.GetCaption: string;
begin
  Result := SPressLoadPictureCommand;
end;

function TPressMVPLoadPictureCommand.GetShortCut: TShortCut;
begin
  Result := SPressAddCommandShortCut;
end;

procedure TPressMVPLoadPictureCommand.InternalExecute;
var
  VFileName: string;
begin
  inherited;
  if PressDialog.OpenPicture(VFileName) then
    Subject.AssignFromFile(VFileName);
end;

{ TPressMVPRemovePictureCommand }

function TPressMVPRemovePictureCommand.GetCaption: string;
begin
  Result := SPressRemovePictureCommand;
end;

function TPressMVPRemovePictureCommand.GetShortCut: TShortCut;
begin
  Result := SPressRemoveCommandShortCut;
end;

procedure TPressMVPRemovePictureCommand.InitNotifier;
begin
  inherited;
  { TODO : Merge in the core implementation }
  Notifier.AddNotificationItem(Model.Subject, [TPressAttributeChangedEvent]);
end;

procedure TPressMVPRemovePictureCommand.InternalExecute;
begin
  inherited;
  Subject.ClearPicture;
end;

function TPressMVPRemovePictureCommand.InternalIsEnabled: Boolean;
begin
  Result := Subject.HasPicture;
end;

{ TPressMVPStructureCommand }

class function TPressMVPStructureCommand.Apply(
  AModel: TPressMVPModel): Boolean;
begin
  Result := AModel is TPressMVPStructureModel;
end;

function TPressMVPStructureCommand.GetModel: TPressMVPStructureModel;
begin
  Result := inherited Model as TPressMVPStructureModel;
end;

{ TPressMVPEditItemCommand }

function TPressMVPEditItemCommand.GetCaption: string;
begin
  Result := SPressEditItemCommand;
end;

function TPressMVPEditItemCommand.GetShortCut: TShortCut;
begin
  Result := SPressChangeCommandShortCut;
end;

procedure TPressMVPEditItemCommand.InternalExecute;
begin
  inherited;
  TPressMVPModelCreatePresentFormEvent.Create(Model).Notify;
end;

function TPressMVPEditItemCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.Selection.Count = 1;
end;

{ TPressMVPReferenceCommand }

class function TPressMVPReferenceCommand.Apply(
  AModel: TPressMVPModel): Boolean;
begin
  Result := AModel is TPressMVPReferenceModel;
end;

function TPressMVPReferenceCommand.GetModel: TPressMVPReferenceModel;
begin
  Result := inherited Model as TPressMVPReferenceModel;
end;

{ TPressMVPIncludeObjectCommand }

function TPressMVPIncludeObjectCommand.GetCaption: string;
begin
  Result := SPressIncludeObjectCommand;
end;

function TPressMVPIncludeObjectCommand.GetShortCut: TShortCut;
begin
  Result := SPressAddCommandShortCut;
end;

procedure TPressMVPIncludeObjectCommand.InternalExecute;
var
  VObject: TPressObject;
begin
  inherited;
  VObject := Model.ObjectClass.Create;
  TPressMVPModelCreateIncludeFormEvent.Create(Model, VObject).Notify;
  VObject.Free;
end;

{ TPressMVPItemsCommand }

class function TPressMVPItemsCommand.Apply(
  AModel: TPressMVPModel): Boolean;
begin
  Result := AModel is TPressMVPItemsModel;
end;

function TPressMVPItemsCommand.GetModel: TPressMVPItemsModel;
begin
  Result := inherited Model as TPressMVPItemsModel;
end;

{ TPressMVPAssignSelectionCommand }

function TPressMVPAssignSelectionCommand.GetCaption: string;
begin
  Result := SPressAssignSelectionQueryCommand;
end;

procedure TPressMVPAssignSelectionCommand.InternalExecute;
var
  VHookedSubject: TPressStructure;
begin
  inherited;
  if Model.HasParent and (Model.Parent is TPressMVPObjectModel) and
   (Model.Selection.Count > 0) then
  begin
    VHookedSubject := TPressMVPObjectModel(Model.Parent).HookedSubject;
    if VHookedSubject is TPressItem then
      VHookedSubject.AssignObject(Model.Selection[0])
    else if VHookedSubject is TPressItems then
      with Model.Selection.CreateIterator do
      try
        BeforeFirstItem;
        while NextItem do
          VHookedSubject.AssignObject(CurrentItem);
      finally
        Free;
      end;
    TPressMVPModelCloseFormEvent.Create(Model.Parent).Notify;
  end;
end;

function TPressMVPAssignSelectionCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.HasParent and (Model.Parent is TPressMVPObjectModel) and
   Assigned(TPressMVPObjectModel(Model.Parent).HookedSubject) and
   (Model.Selection.Count > 0);
end;

{ TPressMVPCustomAddItemsCommand }

function TPressMVPCustomAddItemsCommand.InternalCreateObject: TPressObject;
begin
  Result := Model.Subject.Add(InternalObjectClass);
end;

procedure TPressMVPCustomAddItemsCommand.InternalExecute;
var
  VModel: TPressMVPItemsModel;
begin
  inherited;
  VModel := Model;
  VModel.Selection.Select(InternalCreateObject);
  TPressMVPModelCreateIncludeFormEvent.Create(VModel).Notify;
end;

function TPressMVPCustomAddItemsCommand.InternalObjectClass: TPressObjectClass;
begin
  Result := Model.Subject.ObjectClass;
end;

{ TPressMVPAddItemsCommand }

function TPressMVPAddItemsCommand.GetCaption: string;
begin
  Result := SPressAddItemCommand;
end;

function TPressMVPAddItemsCommand.GetShortCut: TShortCut;
begin
  Result := SPressAddCommandShortCut;
end;

{ TPressMVPInsertItemsCommand }

function TPressMVPInsertItemsCommand.GetCaption: string;
begin
  Result := SPressInsertItemCommand;
end;

function TPressMVPInsertItemsCommand.GetShortCut: TShortCut;
begin
  Result := SPressInsertCommandShortCut;
end;

function TPressMVPInsertItemsCommand.InternalCreateObject: TPressObject;
begin
  Result := Model.Subject.Insert(
   Model.IndexOf(Model.Selection.Focus), InternalObjectClass);
end;

function TPressMVPInsertItemsCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.Count > 0;
end;

{ TPressMVPAddReferencesCommand }

function TPressMVPAddReferencesCommand.GetCaption: string;
begin
  Result := SPressSelectItemCommand;
end;

function TPressMVPAddReferencesCommand.GetShortCut: TShortCut;
begin
  Result := SPressAddCommandShortCut;
end;

procedure TPressMVPAddReferencesCommand.InternalExecute;
begin
  inherited;
  TPressMVPModelCreateSearchFormEvent.Create(Model).Notify;
end;

{ TPressMVPRemoveItemsCommand }

function TPressMVPRemoveItemsCommand.GetCaption: string;
begin
  Result := SPressRemoveItemCommand;
end;

function TPressMVPRemoveItemsCommand.GetShortCut: TShortCut;
begin
  Result := SPressRemoveCommandShortCut;
end;

procedure TPressMVPRemoveItemsCommand.InternalExecute;
var
  VSelection: TPressMVPObjectSelection;
  VModel: TPressMVPItemsModel;
  VObject: TPressObject;
  VRemoveInstance: Boolean;
  I: Integer;
begin
  inherited;
  VSelection := Model.Selection;
  if (VSelection.Count > 0) and
   PressDialog.ConfirmRemove(VSelection.Count) then
  begin
    VModel := Model;
    VRemoveInstance := VModel.PersistChange;
    for I := Pred(VSelection.Count) downto 0 do
    begin
      VObject := VSelection[I];
      if VRemoveInstance then
        VModel.Session.Dispose(VObject);
      VModel.Subject.UnassignObject(VObject);
    end;
  end;
end;

function TPressMVPRemoveItemsCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.Selection.Count > 0;
end;

{ TPressMVPSelectionCommand }

function TPressMVPSelectionCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.Count > 0;
end;

{ TPressMVPSelectAllCommand }

function TPressMVPSelectAllCommand.GetCaption: string;
begin
  Result := SPressSelectAllCommand;
end;

function TPressMVPSelectAllCommand.GetShortCut: TShortCut;
begin
  Result := SPressSelectAllCommandShortCut;
end;

procedure TPressMVPSelectAllCommand.InternalExecute;
var
  I: Integer;
begin
  inherited;
  with Model do
    for I := 0 to Pred(Count) do
      Selection.Add(Objects[I]);
end;

{ TPressMVPSelectNoneCommand }

function TPressMVPSelectNoneCommand.GetCaption: string;
begin
  Result := SPressSelectNoneCommand;
end;

function TPressMVPSelectNoneCommand.GetShortCut: TShortCut;
begin
  Result := SPressSelectNoneCommandShortCut;
end;

procedure TPressMVPSelectNoneCommand.InternalExecute;
var
  VObject: TPressObject;
begin
  inherited;
  VObject := Model.Selection.Focus;
  Model.Selection.Clear;
  Model.Selection.Focus := VObject;
end;

{ TPressMVPSelectCurrentCommand }

function TPressMVPSelectCurrentCommand.GetCaption: string;
begin
  Result := SPressSelectCurrentCommand;
end;

function TPressMVPSelectCurrentCommand.GetShortCut: TShortCut;
begin
  Result := SPressSelectCurrentCommandShortCut;
end;

procedure TPressMVPSelectCurrentCommand.InternalExecute;
begin
  inherited;
  with Model.Selection do
    StrongSelection := not StrongSelection;
end;

{ TPressMVPSelectInvertCommand }

function TPressMVPSelectInvertCommand.GetCaption: string;
begin
  Result := SPressSelectInvertCommand;
end;

function TPressMVPSelectInvertCommand.GetShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TPressMVPSelectInvertCommand.InternalExecute;
var
  I: Integer;
begin
  inherited;
  with Model do
    for I := 0 to Pred(Count) do
      if Selection.HasStrongSelection(Objects[I]) then
        Selection.Remove(Objects[I])
      else
        Selection.Add(Objects[I]);
end;

{ TPressMVPSortCommand }

procedure TPressMVPSortCommand.InternalExecute;
begin
  inherited;
  Model.Reindex(FColumnNumber);
end;

function TPressMVPSortCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.Count > 1;
end;

{ TPressMVPObjectCommand }

class function TPressMVPObjectCommand.Apply(
  AModel: TPressMVPModel): Boolean;
begin
  Result := AModel is TPressMVPObjectModel;
end;

procedure TPressMVPObjectCommand.BindObject(AObject: TPressObject);
begin
  inherited;
  Notifier.AddNotificationItem(AObject, [TPressControlEvent]);
end;

function TPressMVPObjectCommand.GetModel: TPressMVPObjectModel;
begin
  Result := inherited Model as TPressMVPObjectModel;
end;

procedure TPressMVPObjectCommand.InternalExecute;
begin
  inherited;
  Model.UpdateData;
end;

function TPressMVPObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.HasSubject and not Model.Subject.ControlsDisabled;
end;

procedure TPressMVPObjectCommand.ReleaseObject(AObject: TPressObject);
begin
  inherited;
  Notifier.RemoveNotificationItem(AObject);
end;

{ TPressMVPEmptySubjectCommand }

function TPressMVPEmptySubjectCommand.InternalIsEnabled: Boolean;
begin
  Result := not Model.HasSubject or not Model.Subject.ControlsDisabled;
end;

{ TPressMVPRefreshObjectCommand }

function TPressMVPRefreshObjectCommand.GetCaption: string;
begin
  Result := SPressRefreshCommand;
end;

function TPressMVPRefreshObjectCommand.GetShortCut: TShortCut;
begin
  Result := 0;
end;

procedure TPressMVPRefreshObjectCommand.InternalExecute;
begin
  inherited;
  Model.Refresh;
end;

{ TPressMVPSaveObjectCommand }

function TPressMVPSaveObjectCommand.GetCaption: string;
begin
  Result := SPressSaveFormCommand;
end;

function TPressMVPSaveObjectCommand.GetShortCut: TShortCut;
begin
  Result := SPressSaveCommandShortCut;
end;

function TPressMVPSaveObjectCommand.InternalConfirm: Boolean;
begin
  Result := True;
end;

procedure TPressMVPSaveObjectCommand.InternalExecute;
var
  VModel: TPressMVPObjectModel;
begin
  inherited;
  VModel := Model;
  if VModel.CanSaveObject then
  begin
    if not VModel.Subject.IsUpdated then
    begin
      if not InternalConfirm then
        Exit;
      InternalStoreObject;
    end;
    if VModel.IsIncluding and Assigned(VModel.Subject.OwnerAttribute) then
      VModel.CleanUp
    else
      VModel.Close;
  end;
end;

function TPressMVPSaveObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := inherited InternalIsEnabled and Model.Subject.IsValid;
end;

procedure TPressMVPSaveObjectCommand.InternalStoreObject;
begin
  if not Model.StoreObject then
    Exit;
  Model.Store;
end;

{ TPressMVPSaveConfirmObjectCommand }

function TPressMVPSaveConfirmObjectCommand.InternalConfirm: Boolean;
begin
  Result := PressDialog.SaveChanges;
end;

{ TPressMVPFinishObjectCommand }

procedure TPressMVPFinishObjectCommand.CloseForm;
begin
  Model.RevertChanges;
  TPressMVPModelCloseFormEvent.Create(Model).Notify;
end;

function TPressMVPFinishObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := not Model.HasSubject or inherited InternalIsEnabled;
end;

{ TPressMVPCancelObjectCommand }

function TPressMVPCancelObjectCommand.GetCaption: string;
begin
  Result := SPressCancelFormCommand;
end;

function TPressMVPCancelObjectCommand.InternalConfirm: Boolean;
begin
  Result := True;
end;

procedure TPressMVPCancelObjectCommand.InternalExecute;
begin
  inherited;
  if Model.HasSubject and Model.IsChanged and not InternalConfirm then
    Exit;
  CloseForm;
end;

{ TPressMVPCancelConfirmObjectCommand }

function TPressMVPCancelConfirmObjectCommand.InternalConfirm: Boolean;
begin
  Result := PressDialog.CancelChanges;
end;

{ TPressMVPCloseObjectCommand }

function TPressMVPCloseObjectCommand.GetCaption: string;
begin
  Result := SPressCloseFormCommand;
end;

procedure TPressMVPCloseObjectCommand.InternalExecute;
begin
  inherited;
  CloseForm;
end;

{ TPressMVPQueryCommand }

class function TPressMVPQueryCommand.Apply(
  AModel: TPressMVPModel): Boolean;
begin
  Result := AModel is TPressMVPQueryModel;
end;

function TPressMVPQueryCommand.GetModel: TPressMVPQueryModel;
begin
  Result := inherited Model as TPressMVPQueryModel;
end;

procedure TPressMVPQueryCommand.InternalExecute;
begin
  inherited;
  Model.UpdateData;
end;

{ TPressMVPExecuteQueryCommand }

function TPressMVPExecuteQueryCommand.GetCaption: string;
begin
  Result := SPressExecuteQueryCommand;
end;

function TPressMVPExecuteQueryCommand.GetShortCut: TShortCut;
begin
  Result := SPressExecuteCommandShortCut;
end;

procedure TPressMVPExecuteQueryCommand.InternalExecute;
begin
  inherited;
  Model.Execute;
end;

{ TPressMVPCloseApplicationCommand }

procedure TPressMVPCloseApplicationCommand.InternalExecute;
begin
  inherited;
  PressApp.Finalize;
end;

initialization
  TPressMVPObjectCommand.RegisterCommand.EnabledIfNoUser := True;
  TPressMVPCloseApplicationCommand.RegisterCommand.EnabledIfNoUser := True;

end.
