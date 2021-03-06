unit DBClassu;  //Borrowed code

interface
uses ADODB;
type
  TRecordStrArray = Array of String; //Dynamic - No predefined indexes eg. [1..n]
  TStrArray = Array of TRecordStrArray;
  TNumArray = Array of Word;
  TDBClass = Class
  private
    DBError : Boolean;
    ADOQ : TADOQuery;
    StrDataArray : TStrArray;
    function GetStrDataArrayFieldValues(RN:Cardinal):TRecordStrArray;
    function GetAllDataInStrArray:TStrArray;
    function GetMaxFieldSizes : TNumArray;
    function StrDataArrayToString : String;
    procedure DoSQL(S:String);
  public     //Only 3 public methods
   constructor Create(CS:String);    //To create an instance of a class. Receives a parameter CS indicating the name of the database
   function ProcessQuery(SS:String) : String; //To obtain a string-based version of a SELECT query
   procedure ProcessUpdate(SS:String);  //To perform an update on the database (INSERT, UPDATE, DELETE)
 end;

function ChkApos(S:String):String;

Var SQLADO : TDBClass;

implementation
uses Forms, SysUtils, Dialogs;

function ChkApos(S:String):String;
Var Posi : Word;
begin
  Result := S;
  Posi := Pos('''',Result);
  While Posi > 0 do
    begin
      Delete(Result,Posi,1);
      Insert(#232,Result,Posi);
      Posi := Pos('''',Result);
    end;
  Posi := Pos(#232,Result);
  While Posi > 0 do
    begin
      Delete(Result,Posi,1);
      Insert('''''',Result,Posi);
      Posi := Pos(#232,Result);
    end;
end;

constructor TDBClass.Create(CS: String);
//Because of different Access versions, extension must be included in CS
Var Ext : String;
begin
  ADOQ := TADOQuery.Create(Application);
  Ext := Copy(CS,Pos('.',CS),Length(CS));
  If Ext = '.mdb' then
    ADOQ.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + CS + ';Persist Security Info=False'
  else
    ADOQ.ConnectionString := 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=' + CS + ';Persist Security Info=False';
end;

procedure TDBClass.DoSQL(S: String);
begin
  DBError := False;
  try
    ADOQ.Close;
    ADOQ.SQL.Text := S;
    ADOQ.ExecSQL;
  except
    DBError := True;
    ShowMessage('Database Error: Cannot complete action.');
  end;
end;

function TDBClass.GetStrDataArrayFieldValues(RN:Cardinal) : TRecordStrArray;
Var I : Word;
begin
  SetLength(Result,0);
  For I := 0 to ADOQ.FieldCount-1 do
    begin
      SetLength(Result,Length(Result)+1);
      If RN = 0 then
        Result[High(Result)] := ADOQ.Fields[I].FieldName
      else
        begin
          ADOQ.RecNo := RN;
          Result[High(Result)] := ADOQ.Fields[I].AsString;
        end;
    end;
end;

function TDBClass.GetAllDataInStrArray:TStrArray;
Var I : Cardinal;
begin
  SetLength(Result,ADOQ.RecordCount+1);
  For I := 0 to High(Result) do
    Result[I] := GetStrDataArrayFieldValues(I);
end;

function TDBClass.GetMaxFieldSizes : TNumArray;
Var I:Cardinal;
    J:Word;
begin
  SetLength(Result,ADOQ.FieldCount);
  For J := 0 to ADOQ.FieldCount - 1 do
    Result[J] := Length(StrDataArray[0][J]);
  If ADOQ.RecordCount > 0 then
    For I := 1 to High(StrDataArray) do
      For J := 0 to High(StrDataArray[I]) do
        If Length(StrDataArray[I][J]) > Result[J] then
          Result[J] := Length(StrDataArray[I][J]);
end;

function TDBClass.StrDataArrayToString : String;
Var I : Cardinal;
    J : Word;
    LenArr : TNumArray;
begin
  Result := '';
  LenArr := GetMaxFieldSizes;
  For I := 1 to High(StrDataArray) do
    begin
      For J := 0 to High(StrDataArray[I]) do
        begin
          Result := Result + StrDataArray[I][J];
          Result := Result + StringOfChar(' ',LenArr[J] - Length(StrDataArray[I][J])+1);
          Result := Result + '#';
        end;
      Result := Trim(Result) ;
    end;
  Result := Trim(Result);
end;

function TDBClass.ProcessQuery(SS:String): String;
begin
  DoSQL(SS);
  If not(DBError) then
    begin
      ADOQ.Open;
      StrDataArray := GetAllDataInStrArray;
      Result := StrDataArrayToString;
    end;
end;

procedure TDBClass.ProcessUpdate(SS: String);
begin
  DoSQL(SS);
  If not(DBError) then
    begin
      ADOQ.Close;
      //ShowMessage('Your details have been successfully updated!');
    end;
end;

end.
