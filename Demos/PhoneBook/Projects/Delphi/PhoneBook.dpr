program PhoneBook;

uses
  Forms,
  Brokers in '..\..\Units\Brokers.pas',
  MainMVP in '..\..\Units\MainMVP.pas',
  MainFrm in '..\..\Units\vcl\MainFrm.pas' {MainForm},
  CustomMVP in '..\..\Units\CustomMVP.pas',
  CustomEditFrm in '..\..\Units\vcl\CustomEditFrm.pas' {CustomEditForm},
  ReportMVP in '..\..\Units\ReportMVP.pas',
  ReportGroupEditFrm in '..\..\Units\vcl\ReportGroupEditFrm.pas' {ReportGroupEditForm},
  ReportItemEditFrm in '..\..\Units\vcl\ReportItemEditFrm.pas' {ReportItemEditForm},
  ContactBO in '..\..\Units\ContactBO.pas',
  ContactMVP in '..\..\Units\ContactMVP.pas',
  ContactEditFrm in '..\..\Units\vcl\ContactEditFrm.pas' {ContactEditForm},
  CompanyEditFrm in '..\..\Units\vcl\CompanyEditFrm.pas' {CompanyEditForm},
  PersonEditFrm in '..\..\Units\vcl\PersonEditFrm.pas' {PersonEditForm},
  PhoneEditFrm in '..\..\Units\vcl\PhoneEditFrm.pas' {PhoneEditForm},
  CityEditFrm in '..\..\Units\vcl\CityEditFrm.pas' {CityEditForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  TMainPresenter.Run;
end.
