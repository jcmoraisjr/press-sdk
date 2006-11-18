program PhoneBook;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  ObjectModel,
  Main,
  MainPresenter,
  MainModel,
  MainCommand,
  CustomEdit,
  CustomEditPresenter,
  ContactEdit,
  ContactEditPresenter,
  PersonEdit,
  PersonEditPresenter,
  CompanyEdit,
  CompanyEditPresenter,
  PhoneEdit,
  PhoneEditPresenter,
  CityEdit,
  CityEditPresenter;

begin
  Application.Title := 'PhoneBook';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  TMainPresenter.Run;
end.
