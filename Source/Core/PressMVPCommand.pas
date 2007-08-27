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
  Controls,
  Menus,
  PressNotifier,
  PressSubject,
  PressAttributes,
  PressMVP,
  PressMVPModel;

type
  { TPressMVPMenuItem }

  TPressMVPMenuItem = class(TMenuItem)
  private
    FNotifier: TPressNotifier;
    FCommand: TPressMVPCommand;
    procedure Notify(AEvent: TPressEvent);
  public
    constructor Create(AOwner: TComponent; ACommand: TPressMVPCommand); reintroduce; virtual;
    destructor Destroy; override;
    procedure Click; override;
    property Command: TPressMVPCommand read FCommand write FCommand;
  end;

  { TPressMVPCommandMenu }

  TPressMVPPopupCommandMenu = class(TPressMVPCommandMenu)
  private
    FControl: TControl;
    FMenu: TPopupMenu;
    procedure BindMenu;
    function GetMenu: TPopupMenu;
    procedure ReleaseMenu;
  protected
    procedure InternalAddItem(ACommand: TPressMVPCommand); override;
    procedure InternalAssignMenu(AControl: TControl); override;
    procedure InternalClearMenuItems; override;
  public
    destructor Destroy; override;
    property Menu: TPopupMenu read GetMenu;
  end;

  { TPressMVPCommand }

  TPressMVPNullCommand = class(TPressMVPCommand)
  protected
    procedure InternalExecute; override;
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
    procedure InitNotifier; override;
    function InternalIsEnabled: Boolean; override;
  public
    class function Apply(AModel: TPressMVPModel): Boolean; override;
    property Model: TPressMVPObjectModel read GetModel;
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
  end;

  TPressMVPCancelObjectCommand = class(TPressMVPFinishObjectCommand)
  protected
    function GetCaption: string; override;
    function InternalConfirm: Boolean; virtual;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
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
  {$IFDEF FPC}
  LCLType,
  {$ELSE}
  Windows, { TODO : Move to Compatibility }
  {$ENDIF}
  SysUtils,
  Forms,
  ExtDlgs,
  PressConsts,
  PressApplication,
  PressDialogs,
  PressPersistence,
  PressMVPPresenter;

type
  TPressMVPPopupCommandControlFriend = class(TControl);

{ TPressMVPMenuItem }

constructor TPressMVPMenuItem.Create(AOwner: TComponent; ACommand: TPressMVPCommand);
begin
  inherited Create(AOwner);
  if Assigned(ACommand) then
  begin
    FNotifier := TPressNotifier.Create({$IFDEF FPC}@{$ENDIF}Notify);
    FCommand := ACommand;
    Caption := FCommand.Caption;
    Enabled := FCommand.Enabled;
    ShortCut := FCommand.ShortCut;
    FNotifier.AddNotificationItem(FCommand, [TPressMVPCommandChangedEvent]);
  end else
    Caption := '-';
end;

procedure TPressMVPMenuItem.Click;
begin
  inherited;
  if Assigned(FCommand) then
    FCommand.Execute;
end;

destructor TPressMVPMenuItem.Destroy;
begin
  FNotifier.Free;
  inherited;
end;

procedure TPressMVPMenuItem.Notify(AEvent: TPressEvent);
begin
  if Assigned(FCommand) then
    Enabled := FCommand.Enabled;
end;

{ TPressMVPPopupCommandMenu }

procedure TPressMVPPopupCommandMenu.BindMenu;
begin
  if Assigned(FControl) then
    TPressMVPPopupCommandControlFriend(FControl).PopupMenu := FMenu;
end;

destructor TPressMVPPopupCommandMenu.Destroy;
begin
  ReleaseMenu;
  FMenu.Free;
  inherited;
end;

function TPressMVPPopupCommandMenu.GetMenu: TPopupMenu;
begin
  if not Assigned(FMenu) then
  begin
    FMenu := TPopupMenu.Create(nil);
    BindMenu;
  end;
  Result := FMenu;
end;

procedure TPressMVPPopupCommandMenu.InternalAddItem(ACommand: TPressMVPCommand);
begin
  Menu.Items.Add(TPressMVPMenuItem.Create(Menu, ACommand));
end;

procedure TPressMVPPopupCommandMenu.InternalAssignMenu(AControl: TControl);
begin
  if FControl <> AControl then
  begin
    ReleaseMenu;
    FControl := AControl;
    BindMenu;
  end;
end;

procedure TPressMVPPopupCommandMenu.InternalClearMenuItems;
begin
  if Assigned(FMenu) then
    FMenu.Items.Clear;
end;

procedure TPressMVPPopupCommandMenu.ReleaseMenu;
begin
  if Assigned(FControl) then
    TPressMVPPopupCommandControlFriend(FControl).PopupMenu := nil;
end;

{ TPressMVPNullCommand }

procedure TPressMVPNullCommand.InternalExecute;
begin
end;

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
  Result := Menus.ShortCut(Ord('D'), [ssCtrl]);
end;

procedure TPressMVPTodayCommand.InternalExecute;
begin
  Subject.AsDate := Date;
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
  Result := VK_F2;
end;

procedure TPressMVPLoadPictureCommand.InternalExecute;
begin
  with TOpenPictureDialog.Create(nil) do
  try
    if Execute then
      Subject.AssignFromFile(FileName);
  finally
    Free;
  end;
end;

{ TPressMVPRemovePictureCommand }

function TPressMVPRemovePictureCommand.GetCaption: string;
begin
  Result := SPressRemovePictureCommand;
end;

function TPressMVPRemovePictureCommand.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(VK_F8, [ssCtrl]);
end;

procedure TPressMVPRemovePictureCommand.InitNotifier;
begin
  inherited;
  { TODO : Merge in the core implementation }
  Notifier.AddNotificationItem(Model.Subject, [TPressAttributeChangedEvent]);
end;

procedure TPressMVPRemovePictureCommand.InternalExecute;
begin
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
  Result := VK_F3;
end;

procedure TPressMVPEditItemCommand.InternalExecute;
begin
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
  Result := VK_F2;
end;

procedure TPressMVPIncludeObjectCommand.InternalExecute;
var
  VObject: TPressObject;
begin
  VObject := Model.ObjectClass.Create;
  Model.Subject.Value := VObject;
  VObject.Release;
  TPressMVPModelCreateIncludeFormEvent.Create(Model).Notify;
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
  Result := VK_F2;
end;

{ TPressMVPAddReferencesCommand }

function TPressMVPAddReferencesCommand.GetCaption: string;
begin
  Result := SPressSelectItemCommand;
end;

function TPressMVPAddReferencesCommand.GetShortCut: TShortCut;
begin
  Result := VK_F2;
end;

procedure TPressMVPAddReferencesCommand.InternalExecute;
begin
  TPressMVPModelCreateSearchFormEvent.Create(Model).Notify;
end;

{ TPressMVPRemoveItemsCommand }

function TPressMVPRemoveItemsCommand.GetCaption: string;
begin
  Result := SPressRemoveItemCommand;
end;

function TPressMVPRemoveItemsCommand.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(VK_F8, [ssCtrl]);
end;

procedure TPressMVPRemoveItemsCommand.InternalExecute;
var
  VSelection: TPressMVPObjectSelection;
  I: Integer;
begin
  VSelection := Model.Selection;
  if (VSelection.Count > 0) and
   PressDialog.ConfirmRemove(VSelection.Count) then
    for I := Pred(VSelection.Count) downto 0 do
      Model.Subject.UnassignObject(VSelection[I]);
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
  Result := Menus.ShortCut(Ord('A'), [ssCtrl]);
end;

procedure TPressMVPSelectAllCommand.InternalExecute;
var
  I: Integer;
begin
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
  Result := Menus.ShortCut(Ord('W'), [ssCtrl]);
end;

procedure TPressMVPSelectNoneCommand.InternalExecute;
var
  VObject: TPressObject;
begin
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
  Result := 32;
end;

procedure TPressMVPSelectCurrentCommand.InternalExecute;
begin
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

function TPressMVPObjectCommand.GetModel: TPressMVPObjectModel;
begin
  Result := inherited Model as TPressMVPObjectModel;
end;

procedure TPressMVPObjectCommand.InitNotifier;
begin
  inherited;
  if Model.HasSubject then
    Notifier.AddNotificationItem(Model.Subject, [TPressLockingEvent]);
end;

function TPressMVPObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := not Model.HasSubject or not Model.Subject.IsLocked;
end;

{ TPressMVPSaveObjectCommand }

function TPressMVPSaveObjectCommand.GetCaption: string;
begin
  Result := SPressSaveFormCommand;
end;

function TPressMVPSaveObjectCommand.GetShortCut: TShortCut;
begin
  Result := VK_F12;
end;

function TPressMVPSaveObjectCommand.InternalConfirm: Boolean;
begin
  Result := True;
end;

procedure TPressMVPSaveObjectCommand.InternalExecute;
begin
  Model.UpdateData;
  if Model.CanSaveObject then
  begin
    if not Model.Subject.IsUpdated then
    begin
      if not InternalConfirm then
        Exit;
      InternalStoreObject;
    end;
    TPressMVPModelCloseFormEvent.Create(Model).Notify;
  end;
end;

function TPressMVPSaveObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := inherited InternalIsEnabled and
   Model.HasSubject and Model.Subject.IsValid;
end;

procedure TPressMVPSaveObjectCommand.InternalStoreObject;
begin
  if not Model.Store then
    Exit;
  Model.Subject.Store;
end;

{ TPressMVPSaveConfirmObjectCommand }

function TPressMVPSaveConfirmObjectCommand.InternalConfirm: Boolean;
begin
  Result := PressDialog.SaveChanges;
end;

{ TPressMVPFinishObjectCommand }

procedure TPressMVPFinishObjectCommand.CloseForm;
begin
  TPressMVPModelCloseFormEvent.Create(Model).Notify;
  if Model.IsIncluding and Assigned(Model.HookedSubject) then
    Model.HookedSubject.UnassignObject(Model.Subject);
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
  Model.UpdateData;
  if Model.IsChanged then
  begin
    if not InternalConfirm then
      Exit;
    Model.RevertChanges;
  end;
  CloseForm;
end;

function TPressMVPCancelObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := inherited InternalIsEnabled and Model.HasSubject;
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

{ TPressMVPExecuteQueryCommand }

function TPressMVPExecuteQueryCommand.GetCaption: string;
begin
  Result := SPressExecuteQueryCommand;
end;

function TPressMVPExecuteQueryCommand.GetShortCut: TShortCut;
begin
  Result := VK_F11;
end;

procedure TPressMVPExecuteQueryCommand.InternalExecute;
begin
  Model.UpdateData;
  Model.Execute;
end;

{ TPressMVPCloseApplicationCommand }

procedure TPressMVPCloseApplicationCommand.InternalExecute;
begin
  PressApp.Finalize;
end;

initialization
  TPressMVPObjectCommand.RegisterCommand.EnabledIfNoUser := True;
  TPressMVPCloseApplicationCommand.RegisterCommand.EnabledIfNoUser := True;

end.
