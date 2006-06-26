(*
  PressObjects, MVP-Command Classes
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

unit PressMVPCommand;

interface

{$I Press.inc}

uses
  Classes,
  Controls,
  Menus,
  PressNotifier,
  PressSubject,
  PressMVP,
  PressMVPModel;

type
  { TPressMVPCommandMenuItem }

  TPressMVPCommandMenuItem = class(TMenuItem)
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
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPStructureCommand = class(TPressMVPCommand)
  private
    function GetModel: TPressMVPStructureModel;
  public
    constructor Create(AModel: TPressMVPModel); override;
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
    property Model: TPressMVPItemsModel read GetModel;
  end;

  TPressMVPAddItemCommand = class(TPressMVPItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
  end;

  TPressMVPRemoveItemCommand = class(TPressMVPItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPObjectCommand = class(TPressMVPCommand)
  private
    function GetModel: TPressMVPObjectModel;
  public
    property Model: TPressMVPObjectModel read GetModel;
  end;

  TPressMVPSaveObjectCommand = class(TPressMVPObjectCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPCancelObjectCommand = class(TPressMVPObjectCommand)
  protected
    function GetCaption: string; override;
    procedure InternalExecute; override;
    function InternalIsEnabled: Boolean; override;
  end;

  TPressMVPQueryCommand = class(TPressMVPCommand)
  private
    function GetModel: TPressMVPQueryModel;
  public
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
  Windows, { TODO : Move to Compatibility }
  SysUtils,
  Forms,
  ExtDlgs,
  PressConsts,
  PressDialogs,
  PressPersistence,
  PressMVPPresenter;

type
  TPressMVPPopupCommandControlFriend = class(TControl);

{ TPressMVPCommandMenuItem }

constructor TPressMVPCommandMenuItem.Create(AOwner: TComponent; ACommand: TPressMVPCommand);
begin
  inherited Create(AOwner);
  if Assigned(ACommand) then
  begin
    FNotifier := TPressNotifier.Create(Notify);
    FCommand := ACommand;
    Caption := FCommand.Caption;
    Enabled := FCommand.Enabled;
    ShortCut := FCommand.ShortCut;
    FNotifier.AddNotificationItem(FCommand, [TPressMVPCommandChangedEvent]);
  end else
    Caption := '-';
end;

procedure TPressMVPCommandMenuItem.Click;
begin
  inherited;
  if Assigned(FCommand) then
    FCommand.Execute;
end;

destructor TPressMVPCommandMenuItem.Destroy;
begin
  FNotifier.Free;
  inherited;
end;

procedure TPressMVPCommandMenuItem.Notify(AEvent: TPressEvent);
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
  Menu.Items.Add(TPressMVPCommandMenuItem.Create(Menu, ACommand));
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
  Result := VK_INSERT;
end;

procedure TPressMVPLoadPictureCommand.InternalExecute;
begin
  with TOpenPictureDialog.Create(nil) do
  try
    if Execute then
      Subject.AssignPictureFromFile(FileName);
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
  Result := VK_DELETE;
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

constructor TPressMVPStructureCommand.Create(AModel: TPressMVPModel);
begin
  inherited Create(AModel);
  Notifier.AddNotificationItem(Model.Selection, [TPressMVPSelectionChangedEvent]);
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
  TPressMVPModelCreateFormEvent.Create(Model).Notify;
end;

function TPressMVPEditItemCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.Selection.Count = 1;
end;

{ TPressMVPReferenceCommand }

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
  VObject := Model.Subject.ObjectClass.Create;
  Model.Subject.Value := VObject;
  VObject.Release;
  TPressMVPModelCreateFormEvent.Create(Model, True).Notify;
end;

{ TPressMVPItemsCommand }

function TPressMVPItemsCommand.GetModel: TPressMVPItemsModel;
begin
  Result := inherited Model as TPressMVPItemsModel;
end;

{ TPressMVPAddItemCommand }

function TPressMVPAddItemCommand.GetCaption: string;
begin
  Result := SPressAddItemCommand;
end;

function TPressMVPAddItemCommand.GetShortCut: TShortCut;
begin
  Result := VK_F2;
end;

procedure TPressMVPAddItemCommand.InternalExecute;
var
  VObject: TPressObject;
begin
  VObject := Model.Subject.ObjectClass.Create;
  Model.Subject.Add(VObject, False);
  Model.Selection.SelectObject(VObject);
  TPressMVPModelCreateFormEvent.Create(Model, True).Notify;
end;

{ TPressMVPRemoveItemCommand }

function TPressMVPRemoveItemCommand.GetCaption: string;
begin
  Result := SPressRemoveItemCommand;
end;

function TPressMVPRemoveItemCommand.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(VK_F8, [ssCtrl]);
end;

procedure TPressMVPRemoveItemCommand.InternalExecute;
begin
  if (Model.Selection.Count > 0) and
   PressDialog.ConfirmRemove(Model.Selection.Count) then
    with Model.Selection.CreateIterator do
    try
      BeforeFirstItem;
      while NextItem do
        Model.Subject.UnassignObject(CurrentItem);
    finally
      Free;
    end;
end;

function TPressMVPRemoveItemCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.Selection.Count > 0;
end;

{ TPressMVPObjectCommand }

function TPressMVPObjectCommand.GetModel: TPressMVPObjectModel;
begin
  Result := inherited Model as TPressMVPObjectModel;
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

procedure TPressMVPSaveObjectCommand.InternalExecute;
begin
  Model.UpdateData;
  if not Model.Subject.IsUpdated then
  begin
    if not PressDialog.SaveChanges then
      Exit;
    PressPersistenceBroker.Store(Model.Subject);
  end;
  TPressMVPModelCloseFormEvent.Create(Model).Notify;
end;

function TPressMVPSaveObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.HasSubject and Model.Subject.IsValid;
end;

{ TPressMVPCancelObjectCommand }

function TPressMVPCancelObjectCommand.GetCaption: string;
begin
  Result := SPressCancelFormCommand;
end;

procedure TPressMVPCancelObjectCommand.InternalExecute;
begin
  Model.UpdateData;
  if Model.IsChanged then
  begin
    if not PressDialog.CancelChanges then
      Exit;
    Model.RevertChanges;
  end;
  TPressMVPModelCloseFormEvent.Create(Model).Notify;
  if Model.IsIncluding and Assigned(Model.HookedSubject) then
    Model.HookedSubject.UnassignObject(Model.Subject);
end;

function TPressMVPCancelObjectCommand.InternalIsEnabled: Boolean;
begin
  Result := Model.HasSubject;
end;

{ TPressMVPQueryCommand }

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
  Application.Terminate;
end;

end.
