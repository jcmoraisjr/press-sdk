program PhoneBook;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Brokers,
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
  ReportItemEditFrm,
  PressLazReportRT;

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  TMainPresenter.Run;
end.
