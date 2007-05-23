unit MainPresenter;

{$I PhoneBook.inc}

interface

uses
  PressSubject, PressMVPPresenter;

type
  TMainPresenter = class(TPressMVPMainFormPresenter)
  private
    FInternalCache: TPressObjectList;
  protected
    procedure InitPresenter; override;
    procedure Running; override;
  public
    destructor Destroy; override;
  end;

implementation

uses
  PressUser, PressMVPCommand, MainCommand, ObjectModel,
  Main, MainModel, Populate;

{ TMainPresenter }

destructor TMainPresenter.Destroy;
begin
  FInternalCache.Free;
  inherited;
end;

procedure TMainPresenter.InitPresenter;
begin
  inherited;
  CreateQueryItemsPresenter(
   'ItemsStringGrid', 'Name(240);Address.City.Name(160)', TMainModel);
  BindCommand(TPressMVPExecuteQueryCommand, 'QuerySpeedButton');
  BindCommand(TMainConnectorCommand, 'ConnectorMenuItem');
  BindCommand(TPressMVPCloseApplicationCommand, 'CloseMenuItem');
  CreateSubPresenter('Name', 'NameQueryEdit');
end;

procedure TMainPresenter.Running;
begin
  inherited;
  PressUserData.Logon;
  {$IFDEF DontUsePersistence}
  FInternalCache := TPressObjectList.Create(True);
  PopulatePhoneBook(FInternalCache);
  {$ENDIF}
end;

initialization
  TMainPresenter.RegisterFormPresenter(TMainQuery, TMainForm);

end.
