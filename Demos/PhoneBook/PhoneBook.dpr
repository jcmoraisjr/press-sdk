program PhoneBook;

uses
  Forms,
  Brokers in 'Brokers.pas',
  IOModel in 'IOModel.pas',
  ObjectModel in 'ObjectModel.pas',
  Main in 'Main.pas' {MainForm},
  MainPresenter in 'MainPresenter.pas',
  MainModel in 'MainModel.pas',
  MainCommand in 'MainCommand.pas',
  Populate in 'Populate.pas',
  CustomEdit in 'CustomEdit.pas' {CustomEditForm},
  CustomEditPresenter in 'CustomEditPresenter.pas',
  CustomEditModel in 'CustomEditModel.pas',
  ReportGroupEdit in 'ReportGroupEdit.pas' {ReportGroupEditForm},
  ReportGroupEditPresenter in 'ReportGroupEditPresenter.pas',
  ReportItemEdit in 'ReportItemEdit.pas' {ReportItemEditForm},
  ReportItemEditPresenter in 'ReportItemEditPresenter.pas',
  ReportItemEditModel in 'ReportItemEditModel.pas',
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

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  TMainPresenter.Run;
end.
