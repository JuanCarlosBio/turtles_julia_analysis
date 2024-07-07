#!/usr/bin/env julia

using 
  CSV, 
  DataFrames, 
  DataFramesMeta, 
  StringEncodings, 
  Dates

## Transform the original CSV from ISO-8859-1, to UTF-8 
function transform_encoding_csv(input_file::String, output_file::String, original_encoding::String, transformed_encoding::String)
run(
    `
    iconv -f $original_encoding -t $transformed_encoding \
        $input_file -o $output_file
   ` 
)
end

## Creating the weather stations variables:
function map_to_season(month::String)
  if month in ["December", "January", "February"]
      return "Winter"
  elseif month in ["March", "April", "May"]
      return "Spring"
  elseif month in ["June", "July", "August"]
      return "Summer"
  elseif month in ["September", "October", "November"]
      return "Fall"
  end
end

function main()

  ##=================##
  ## Pre-processing  ##
  ##=================##

  ## Params to transform ISO-8859-1 to UTF-8 
  input_file::String           = "data/raw/stranding_turtles.csv"
  out_dir::String = "data/processed/"
  output_file::String          = "data/processed/stranding_turtles_processed.csv" 
  original_encoding::String    = "ISO-8859-1"
  transformed_encoding::String = "UTF-8"

  if !isdir(out_dir) mkdir(out_dir) end

  transform_encoding_csv(input_file, output_file, original_encoding, transformed_encoding)

  ## Reading the turtle data
  df_turtles = CSV.read(output_file, DataFrame, delim = ";")

  ##=================##
  ## Processing      ##
  ##=================##

  ## Removing emty rows
  df_turtles_remove_emtyrows = df_turtles[.!ismissing.(df_turtles.Date), :]
  ## Transfor the dates from String to Date format
  df_turtles_remove_emtyrows[!, :Date] = Date.(df_turtles_remove_emtyrows.Date, "dd/mm/yyyy")
  ## Creating new columns of DAY, MONTH and YEAR 
  df_turtles_remove_emtyrows[!, :day] = day.(df_turtles_remove_emtyrows[!, :Date])
  df_turtles_remove_emtyrows[!, :month] = monthname.(df_turtles_remove_emtyrows.Date)
  df_turtles_remove_emtyrows[!, :year] = year.(df_turtles_remove_emtyrows[!, :Date])
  ## Creating the variable for the seasons
  transform!(df_turtles_remove_emtyrows, :month => ByRow(map_to_season) => :season)
  ## Filtering from the year 2000 above
  df_turtles_date_filter = filter(row -> row.Date >= Date("01/01/2000", "dd/mm/yyyy"), df_turtles_remove_emtyrows)
  
  CSV.write(output_file, df_turtles_date_filter)
end

main()
