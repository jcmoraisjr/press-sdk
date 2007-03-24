unit MainCommand;

{$I PhoneBook.inc}

interface

uses
  Classes, PressSubject, PressMVP, PressMVPCommand;

type
  TMainAddPersonCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalObjectClass: TPressObjectClass; override;
  end;

  TMainAddCompanyCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalObjectClass: TPressObjectClass; override;
  end;

  TMainConnectorCommand = class(TPressMVPCommand)
  protected
    procedure InternalExecute; override;
  end;

implementation

uses
  {$IFDEF FPC}LCLType{$ELSE}Windows{$ENDIF}, Menus, ObjectModel;

{ TMainAddPersonCommand }

function TMainAddPersonCommand.GetCaption: string;
begin
  Result := 'Add Person';
end;

function TMainAddPersonCommand.GetShortCut: TShortCut;
begin
  Result := VK_F2;
end;

function TMainAddPersonCommand.InternalObjectClass: TPressObjectClass;
begin
  Result := TPerson;
end;

{ TMainAddCompanyCommand }

function TMainAddCompanyCommand.GetCaption: string;
begin
  Result := 'Add Company';
end;

function TMainAddCompanyCommand.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(VK_F2, [ssCtrl]);
end;

function TMainAddCompanyCommand.InternalObjectClass: TPressObjectClass;
begin
  Result := TCompany;
end;

{ TMainConnectorCommand }

procedure TMainConnectorCommand.InternalExecute;
begin
  PressDefaultDAO.ShowConnectionManager;
end;

end.
