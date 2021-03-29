
{$apptype CONSOLE}

  program test;

uses
  Deltics.Smoketest,
  Deltics.IO.SearchPath in '..\src\Deltics.IO.SearchPath.pas',
  Deltics.IO.SearchPath.Interfaces in '..\src\Deltics.IO.SearchPath.Interfaces.pas',
  Test.SearchPath in 'Test.SearchPath.pas';

begin
  TestRun.Test(SearchPathTests);
end.
