

  unit Deltics.IO.SearchPath;


interface

  uses
    Classes,
    Deltics.IO.SearchPath.Interfaces;


  type
    ISearchPath = Deltics.IO.SearchPath.Interfaces.SearchPath;


    SearchPath = class
    public
      class function New: ISearchPath; overload;
      class function New(const aSearchPath: String): ISearchPath; overload;
    end;




implementation

  uses
    SysUtils,
    Deltics.InterfacedObjects,
    Deltics.IO.Path,
    Deltics.Strings;





  type
    TSearchPath = class(TComInterfacedObject, ISearchPath)
    private
      fHomeDir: String;
      fPath: TStringList;
      function get_Count: Integer;
      function get_HomeDir: String;
      function get_Item(const aIndex: Integer): String;
      function get_AsString: String;
      procedure set_AsString(const aValue: String);
      procedure set_HomeDir(const aValue: String);
      function FindFile(const aDir: String; const aFilename: String; var aFilePath: String): Boolean; overload;
    public
      constructor Create;
      destructor Destroy; override;
      function FindFile(const aFilename: String): Boolean; overload;
      function FindFile(const aFilename: String; var aFilePath: String): Boolean; overload;
      procedure Add(const aDir: String);
      procedure Delete(const aIndex: Integer);
      procedure Remove(const aDir: String);
      property Count: Integer read get_Count;
      property HomeDir: String read get_HomeDir write set_HomeDir;
      property Items[const aIndex: Integer]: String read get_Item; default;
      property Value: String read get_AsString write set_AsString;
    end;



  constructor TSearchPath.Create;
  begin
    inherited Create;

    fPath := TStringList.Create;
  end;


  destructor TSearchPath.Destroy;
  begin
    fPath.Free;

    inherited;
  end;


  function TSearchPath.get_AsString: String;
  var
    i: Integer;
  begin
    result := '';
    if fPath.Count = 0 then
      EXIT;

    for i := 0 to Pred(fPath.Count) do
      result := result + fPath[i] + ';';

    SetLength(result, Length(result) - 1);
  end;


  function TSearchPath.get_Count: Integer;
  begin
    result := fPath.Count;
  end;


  function TSearchPath.get_HomeDir: String;
  begin
    result := fHomeDir;
    if result = '' then
      result := GetCurrentDir;
  end;


  function TSearchPath.get_Item(const aIndex: Integer): String;
  begin
    result := fPath[aIndex];
  end;


  procedure TSearchPath.set_AsString(const aValue: String);
  var
    s: String;
    p: String;
  begin
    fPath.Clear;

    s := Trim(aValue);
    if s = '' then
      EXIT;

    while Pos(';', s) <> 0 do
    begin
      p := Copy(s, 1, Pos(';', s) - 1);
      Add(Trim(p));

      System.Delete(s, 1, Length(p) + 1);
    end;

    Add(Trim(s));
  end;


  procedure TSearchPath.set_HomeDir(const aValue: String);
  begin
    fHomeDir := aValue;
  end;


  procedure TSearchPath.Add(const aDir: String);
  begin
    if Trim(aDir) = '' then
      EXIT;

    if (fPath.IndexOf(aDir) = -1) then
      fPath.Add(aDir);
  end;


  procedure TSearchPath.Delete(const aIndex: Integer);
  begin
    fPath.Delete(aIndex);
  end;


  function TSearchPath.FindFile(const aDir: String;
                                const aFilename: String;
                                var   aFilePath: String): Boolean;
  var
    recursive: Boolean;
    subfolders: Boolean;
    dir: String;
    filename: String;
    rec: TSearchRec;
  begin
    dir       := aDir;
    filename  := aFilename;

    recursive   := Copy(dir, Length(dir) - 3, 3) = '\**';
    subfolders  := Copy(dir, Length(dir) - 2, 2) = '\*';

    if recursive then
    begin
      SetLength(dir, Length(dir) - 3);
      subfolders := TRUE;
    end
    else if subfolders then
      SetLength(dir, Length(dir) - 2);

    filename  := Path.Append(dir, aFilename);
    result    := FileExists(filename);

    if result then
    begin
      aFilePath := filename;
      EXIT;
    end;

    if NOT subfolders then
      EXIT;

    if FindFirst(dir + '\*.*', faDirectory, rec) = 0 then
    try
      repeat
        if (rec.Name = '.') or (rec.Name = '..') or ((rec.Attr and faDirectory) = 0) then
          CONTINUE;

        filename  := Path.MakePath([dir, rec.Name, aFilename]);
        result    := FileExists(filename);
        if result then
        begin
          aFilePath := filename;
          EXIT;
        end;

        if recursive then
        begin
          dir     := Path.MakePath([dir, rec.Name, '**']);
          result  := FindFile(dir, aFilename, aFilePath);
          if result then
            EXIT;
        end;
      until FindNext(rec) <> 0;

    finally
      FindClose(rec);
    end;
  end;


  function TSearchPath.FindFile(const aFilename: String): Boolean;
  var
    notUsed: String;
  begin
    result := FindFile(aFilename, notUsed);
  end;


  function TSearchPath.FindFile(const aFilename: String;
                                var   aFilePath: String): Boolean;
  var
    i: Integer;
  begin
    result := FALSE;

    if aFilename = '' then
      EXIT;

    try
      // If filename is absolute, just check for existence

      if Path.IsAbsolute(aFilename) then
      begin
        result := FileExists(aFilename);
        EXIT;
      end;

      // OTHERWISE
      //
      // If filename contains path elements then check existence
      //  relative to HomeDir

      if Pos('\', aFilename) > 0 then
      begin
        aFilePath := Path.RelativeToAbsolute(aFilename, HomeDir);
        result    := FileExists(aFilePath);
        EXIT;
      end;

      // OTHERWISE
      //
      // Check existence in HomeDir

      aFilePath := Path.Append(HomeDir, aFilename);
      result    := FileExists(aFilePath);
      if result then
        EXIT;

      // If not found, now check each path in the search path

      for i := 0 to Pred(fPath.Count) do
      begin
        result := FindFile(Path.Absolute(fPath[i], HomeDir), aFilename, aFilePath);
        if result then
          EXIT;
      end;

    finally
      if NOT result then
        aFilePath := '';
    end;
  end;


  procedure TSearchPath.Remove(const aDir: String);
  var
    idx: Integer;
  begin
    idx := fPath.IndexOf(aDir);
    if idx <> -1 then
      fPath.Delete(idx);
  end;




{ SearchPath }

  class function SearchPath.New: ISearchPath;
  begin
    result := TSearchPath.Create;
  end;


  class function SearchPath.New(const aSearchPath: String): ISearchPath;
  begin
    result := TSearchPath.Create;
    result.AsString := aSearchPath;
  end;





end.
