(*
  PressObjects, Dialog Classes
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

unit PressDialogs;

interface

{$I Press.inc}

uses
  PressClasses;

type
  TPressDialogsClass = class of TPressDialogs;

  TPressDialogs = class(TPressSingleton)
  protected
    function ConfirmationDlg(const AMsg: string): Boolean; virtual;
    function InternalCancelChanges: Boolean; virtual;
    function InternalConfirmRemove(ACount: Integer): Boolean; virtual;
    function InternalSaveChanges: Boolean; virtual;
  public
    function CancelChanges: Boolean;
    function ConfirmRemove(ACount: Integer): Boolean;
    function SaveChanges: Boolean;
  end;

procedure AssignPressDialogClass(ADialogClass: TPressDialogsClass);
function PressDialog: TPressDialogs;

implementation

uses
  SysUtils,
  Controls,
  Dialogs,
  PressConsts;

var
  _PressDialogsClass: TPressDialogsClass;

procedure AssignPressDialogClass(ADialogClass: TPressDialogsClass);
begin
  if Assigned(_PressDialogsClass) then
    raise EPressError.Create(SDialogClassIsAssigned);
  _PressDialogsClass := ADialogClass;
end;

function PressDialog: TPressDialogs;
begin
  if not Assigned(_PressDialogsClass) then
    _PressDialogsClass := TPressDialogs;
  Result := _PressDialogsClass.Instance;
end;

{ TPressDialogs }

function TPressDialogs.CancelChanges: Boolean;
begin
  Result := InternalCancelChanges;
end;

function TPressDialogs.ConfirmationDlg(const AMsg: string): Boolean;
begin
  Result := MessageDlg(AMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

function TPressDialogs.ConfirmRemove(ACount: Integer): Boolean;
begin
  Result := InternalConfirmRemove(ACount);
end;

function TPressDialogs.InternalCancelChanges: Boolean;
begin
  Result := ConfirmationDlg(SPressCancelChangesDialog);
end;

function TPressDialogs.InternalConfirmRemove(ACount: Integer): Boolean;
begin
  if ACount = 1 then
    Result := ConfirmationDlg(SPressConfirmRemoveOneItemDialog)
  else
    Result := ConfirmationDlg(Format(
     SPressConfirmRemoveItemsDialog, [ACount]));
end;

function TPressDialogs.InternalSaveChanges: Boolean;
begin
  Result := ConfirmationDlg(SPressSaveChangesDialog);
end;

function TPressDialogs.SaveChanges: Boolean;
begin
  Result := InternalSaveChanges;
end;

end.