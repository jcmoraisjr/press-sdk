program SimpleOPF;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  PressApplication,
  MainFrm, PersonBO;

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  PressApp.Run;
end.
