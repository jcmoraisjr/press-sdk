(*
  PressObjects, MVP-Widget Manager Interface
  Copyright (C) 2008 Laserpress Ltda.

  http://www.pressobjects.org

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit PressMVPWidget;

{$I Press.inc}

interface

uses
  Classes,
  PressClasses,
  PressDialogs,
  PressMVP,
  PressMVPView;

type
  IPressMVPWidgetManager = interface(IPressInterface)
  ['{0F98D9EF-C7EE-4710-8E74-5D940F300469}']
    function ControlName(AControl: TObject): string;
    function CreateCommandComponent(ACommand: TPressMVPCommand; AComponent: TObject): TPressMVPCommandComponent;
    function CreateCommandMenu: TPressMVPCommandMenu;
    function CreateForm(AFormClass: TClass): TObject;
    procedure Draw(ACanvasHandle: TObject; AShapeType: TPressShapeType; X1, Y1, X2, Y2: Integer; ASolid: Boolean);
    function MessageDlg(AMsgType: TPressMessageType; const AMsg: string): Integer;
    function OpenDlg(AOpenDlgType: TPressOpenDlgType; var AFileName: string): Boolean;
    function ShortCut(const AShortCutText: string): TShortCut;
    procedure ShowForm(AForm: TObject; AModal: Boolean);
    function TextHeight(ACanvasHandle: TObject; const AStr: string): Integer;
    procedure TextRect(ACanvasHandle: TObject; ARect: TPressRect; ALeft, ATop: Integer; const AStr: string);
    function TextWidth(ACanvasHandle: TObject; const AStr: string): Integer;
  end;

function PressWidget: IPressMVPWidgetManager;
procedure PressRegisterWidgetManager(const AWidgetManager: IPressMVPWidgetManager);

implementation

uses
  PressConsts;

var
  _WidgetManager: IPressMVPWidgetManager;

function PressWidget: IPressMVPWidgetManager;
begin
  if not Assigned(_WidgetManager) then
    raise EPressMVPError.Create(SUnassignedWidgetManager);
  Result := _WidgetManager;
end;

procedure PressRegisterWidgetManager(const AWidgetManager: IPressMVPWidgetManager);
begin
  if Assigned(_WidgetManager) then
    raise EPressMVPError.Create(SWidgetManagerAlreadyAssigned);
  _WidgetManager := AWidgetManager;
end;

end.
