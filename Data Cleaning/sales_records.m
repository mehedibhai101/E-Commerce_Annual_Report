let
    // 1. Access the source folder and target the e-commerce CSV file
    Source_Folder = Folder.Files("your_folder_path"),
    File_Content = Source_Folder{[Name="dataa.csv"]}[Content],

    // 2. Import the CSV and promote the first row to headers
    Imported_CSV = Csv.Document(File_Content,[Delimiter=",", Columns=16, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    Promote_Headers = Table.PromoteHeaders(Imported_CSV, [PromoteAllScalars=true]),

    // 3. Remove unnecessary columns
    // 'index' is redundant and 'currency' is removed as it only contains "BDT"
    Remove_Unnecessary = Table.RemoveColumns(Promote_Headers,{"index", "currency"}),

    // 4. Assign initial data types
    // 'Date' is Int64 because it is currently in Excel Serial format (e.g., 45264)
    Set_Initial_Types = Table.TransformColumnTypes(Remove_Unnecessary,{
        {"Order ID", type text}, {"Cust ID", type text}, {"Gender", type text}, 
        {"Age", Int64.Type}, {"Age Group", type text}, {"Date", Int64.Type}, 
        {"Month", type text}, {"Status", type text}, {"Channel ", type text}, 
        {"Category", type text}, {"Qty", Int64.Type}, {"Amount", Int64.Type}, 
        {"District", type text}, {"Division", type text}
    }),

    // 5. Convert Excel Serial Date to proper Date type
    Convert_Date = Table.TransformColumns(Set_Initial_Types, {
        {"Date", each Date.From(Number.From(_)), type date}
    }),

    // 6. Clean text fields (Trimming trailing spaces from 'Channel' and others)
    Trim_Text = Table.TransformColumns(Convert_Date, {
        {"Channel ", Text.Trim, type text}, {"Status", Text.Trim, type text}, 
        {"Category", Text.Trim, type text}, {"Division", Text.Trim, type text}
    }),

    // 7. Professionalize headers for reporting
    Renamed_Columns = Table.RenameColumns(Trim_Text,{
        {"Cust ID", "Customer ID"}, 
        {"Channel ", "Sales Channel"}, 
        {"Amount", "Total Amount"},
        {"Status", "Order Status"}
    }),

    // 8. Reorder columns for logical flow: Identity -> Demographic -> Timing -> Logistics -> Financials
    Reordered_Columns = Table.ReorderColumns(Renamed_Columns, {
        "Order ID", "Customer ID", "Gender", "Age", "Age Group", "Date", "Month", 
        "Sales Channel", "Category", "Qty", "Total Amount", "Order Status", 
        "District", "Division"
    })
in
    Reordered_Columns
