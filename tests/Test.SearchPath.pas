
  unit Test.SearchPath;

interface

  uses
    Deltics.Smoketest;


  type
    SearchPathTests = class(TTest)
      procedure SetupMethod;
      procedure FindFileFindsFileInCurrentDirWithNoPathSet;
      procedure FindFileReturnsFalseWhenFileDoesNotExist;
      procedure GetAsString;
      procedure HomeDirIsCurrentDirWhenNotSet;
      procedure HomeDirOverridesCurrentDirWhenSet;
      procedure SetAsString;
    {$ifNdef _CICD}
      procedure FindTestDprByRelativePathInFilename;
      procedure FindTestDprByRelativeSearchPathReturnsFalseWhenNotFound;
      procedure FindTestDprByRelativeSearchPathReturnsTrueWhenFound;
      procedure FindTestDprByRelativeSearchPathReturnsTrueWhenFoundRecursively;
    {$endif}
    end;



implementation

  uses
    SysUtils,
    Deltics.IO.SearchPath;




{ SearchPathTest }

  var
    sut: ISearchPath;


  procedure SearchPathTests.SetupMethod;
  begin
    sut := SearchPath.New;
  end;






  procedure SearchPathTests.FindFileFindsFileInCurrentDirWithNoPathSet;
  begin
    Test('FindFile').Assert(sut.FindFile('test.exe')).IsTrue;
  end;


  procedure SearchPathTests.FindFileReturnsFalseWhenFileDoesNotExist;
  begin
    Test('FindFile').Assert(sut.FindFile('test.zoo')).IsFalse;
  end;


  procedure SearchPathTests.GetAsString;
  begin
    sut.Add('c:\foo');
    sut.Add('..\bar');
    sut.Add('\\host\share\chew');

    Test('(get).AsString').Assert(sut.AsString).Equals('c:\foo;..\bar;\\host\share\chew');
  end;


  procedure SearchPathTests.HomeDirIsCurrentDirWhenNotSet;
  begin
    Test('HomeDir (not set)').Assert(sut.HomeDir).Equals(GetCurrentDir);
  end;


  procedure SearchPathTests.HomeDirOverridesCurrentDirWhenSet;
  begin
    sut.HomeDir := 'c:\foo';

    Test('HomeDir (set)').Assert(sut.HomeDir).Equals('c:\foo');
  end;


  procedure SearchPathTests.SetAsString;
  begin
    sut := SearchPath.New('c:\foo;..\bar;\\host\share\chew');

    Test('Items[0]').Assert(sut[0]).Equals('c:\foo');
    Test('Items[1]').Assert(sut[1]).Equals('..\bar');
    Test('Items[2]').Assert(sut[2]).Equals('\\host\share\chew');
  end;


{$ifNdef _CICD}
  procedure SearchPathTests.FindTestDprByRelativePathInFilename;
  begin
    Test('FindFile(..\..\test.dpr').Assert(sut.FindFile('..\..\test.dpr')).IsTrue;
  end;


  procedure SearchPathTests.FindTestDprByRelativeSearchPathReturnsFalseWhenNotFound;
  begin
    sut.Add('..\..\..');
    Test('FindFile(test.dpr').Assert(sut.FindFile('test.dpr')).IsFalse;
  end;


  procedure SearchPathTests.FindTestDprByRelativeSearchPathReturnsTrueWhenFound;
  begin
    sut.Add('..\..');
    Test('FindFile(test.dpr').Assert(sut.FindFile('test.dpr')).IsTrue;
  end;


  procedure SearchPathTests.FindTestDprByRelativeSearchPathReturnsTrueWhenFoundRecursively;
  begin
    sut.Add('..\..\**');
    Test('FindFile(test.dpr').Assert(sut.FindFile('test.dpr')).IsTrue;
  end;
{$endif}




end.
