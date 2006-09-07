program PhoneBook;

uses
  FastMM4,
  Forms,
  PressMVPPresenter,
  PressInstantObjectsBroker,
  InstantUIB,
  IOModel in 'IOModel.pas',
  ObjectModel in 'ObjectModel.pas',
  Main in 'Main.pas' {MainForm},
  MainPresenter in 'MainPresenter.pas',
  MainModel in 'MainModel.pas',
  MainCommand in 'MainCommand.pas',
  CustomEdit in 'CustomEdit.pas' {CustomEditForm},
  CustomEditPresenter in 'CustomEditPresenter.pas',
  ContactEdit in 'ContactEdit.pas' {ContactEditForm},
  ContactEditPresenter in 'ContactEditPresenter.pas',
  PersonEdit in 'PersonEdit.pas' {PersonEditForm},
  PersonEditPresenter in 'PersonEditPresenter.pas',
  CompanyEdit in 'CompanyEdit.pas' {CompanyEditForm},
  CompanyEditPresenter in 'CompanyEditPresenter.pas',
  PhoneEdit in 'PhoneEdit.pas' {PhoneEditForm},
  PhoneEditPresenter in 'PhoneEditPresenter.pas',
  CityEdit in 'CityEdit.pas' {CityEditForm},
  CityEditPresenter in 'CityEditPresenter.pas';

{$R *.RES}
{$R *.mdr} {IOModel}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  PressInitMainPresenter;
  Application.Run;
end.

