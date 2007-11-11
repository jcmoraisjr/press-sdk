program PhoneBook;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Brokers,
  Populate,
  MainMVP,
  MainFrm,
  CustomMVP,
  CustomEditFrm,
  ContactBO,
  ContactMVP,
  ContactEditFrm,
  PersonEditFrm,
  CompanyEditFrm,
  CityEditFrm,
  PhoneEditFrm,
  ReportMVP,
  ReportGroupEditFrm,
  ReportItemEditFrm;

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  TMainPresenter.Run;
end.
