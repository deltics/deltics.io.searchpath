

  unit Deltics.IO.SearchPath.Interfaces;


interface


  type
    SearchPath = interface
    ['{978011C3-3818-4420-840E-4B3322A48642}']
      function get_AsString: String;
      function get_Count: Integer;
      function get_HomeDir: String;
      function get_Item(const aIndex: Integer): String;
      procedure set_AsString(const aValue: String);
      procedure set_HomeDir(const aValue: String);

      function FindFile(const aFilename: String): Boolean; overload;
      function FindFile(const aFilename: String; var aFilePath: String): Boolean; overload;
      procedure Add(const aDir: String);
      procedure Delete(const aIndex: Integer);
      procedure Remove(const aDir: String);

      property Count: Integer read get_Count;
      property HomeDir: String read get_HomeDir write set_HomeDir;
      property Items[const aIndex: Integer]: String read get_Item; default;
      property AsString: String read get_AsString write set_AsString;
    end;



implementation



end.
