unit MainCommand;

{$I PhoneBook.inc}

interface

uses
  Classes, PressSubject, PressMVPCommand;

type
  TMainAddPersonCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalCreateObject: TPressObject; override;
  end;

  TMainAddCompanyCommand = class(TPressMVPCustomAddItemsCommand)
  protected
    function GetCaption: string; override;
    function GetShortCut: TShortCut; override;
    function InternalCreateObject: TPressObject; override;
  end;

implementation

uses
  Windows, Menus, ObjectModel;

{ TMainAddPersonCommand }

function TMainAddPersonCommand.GetCaption: string;
begin
  Result := 'Add Person';
end;

function TMainAddPersonCommand.GetShortCut: TShortCut;
begin
  Result := VK_F2;
end;

function TMainAddPersonCommand.InternalCreateObject: TPressObject;
begin
  Result := TPerson.Create;
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

function TMainAddCompanyCommand.InternalCreateObject: TPressObject;
begin
  Result := TCompany.Create;
end;

end.
