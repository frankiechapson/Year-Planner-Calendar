# Year-Planner-Calendar

This is an Oracle APEX Region Plug-in

# About
This region plug-in displays a full year view calendar.
For example like this:

![yearplanner](https://user-images.githubusercontent.com/39552762/40416939-e27b959a-5e7e-11e8-9eb8-be632fe64925.png "Sample" )

## There are two ways to define day types: ##

# Leave as it is -> Default pattern #
In this case Saturday and Sunday will be "E" type which means "Weekend" and other days will be "W" type what means "Workday"

# Optionally define day types and write over, change the default pattern. #
To do this, you have to create some tables and views. The script of them is in "CA_Install Simple.sql" file. The "simple" means here, that is a Gregorian, and single user calendar.
After the Database objects have created, you can define different types of days in **CA_DAY_TYPES** table.
You can specify the default types for days of a week in **CA_WEEK_DAYS** table.
And you can overwrite the default pattern of day types in the **CA_CALENDAR_DAY_CHANGES** table. That is all!

## How to use plug-in? ##

# Attribute #
This is a region plug-in.
The plug-in has only one additional attribute: Year
This is a text field and you can specify constant, or any SQL expression. The YEAR attribute string will evaluate in a "select YEAR from dual" where YEAR is the attribute.
If you refer a page item, you have to submit first (with a "null;" pl/sql block for example)
Since this is pl/sql based region plug-in, you can refresh it only with page submit.

# Format #
The plug-in uses the following CSS classes:
The base is CSS of IRR.

* **table**: a-IRR-table YPC-Table YPC-Year-yyyy   *(where yyyy it the Year attr.)*
* first header column (Year) **th**: a-IRR-header YPC-Header-Year
* additional header columns (Day Names) **th**: a-IRR-header YPC-Header-Day-dd YPC-Header-Column-cc *(where dd is the day name eg: Mo, Su ... cc is the column number 01-37)*
* month rows: **tr**: YPC-Month-mm *(where mm is the month number)*
* 1st col of month rows:  **td**: YPC-Month-mm YPC-Column-00 *(where mm is the month number)*
* additional cols of month rows if the cell is empty: **td**: YPC-Empty YPC-Month-mm YPC-Column-cc *(where mm is the month number and cc is the column number 01-37)*
* additional cols of month rows if the cell is a day: **td**: YPC-Month-mm YPC-Column-cc YPC-Orig-Day-Code-ddd YPC-Orig-Day-Type-x YPC-New-Day-Code-ddd YPC-New-Day-Type-x *(where mm is the month number, ddd is the day CODE from CA_WEEK_DAYS, x is the week day type CODE from CA_DAY_TYPES and cc is the column number 01-37)*
* Today additional class is: YPC-Today

So, you can define formats in the inline CSS part of the page. For example:

    .YPC-New-Day-Type-W {
     background-color: #F0FFFF !important;
    } 
    
    .YPC-New-Day-Type-E {
     background-color: #C9C9C9 !important;
    } 
    
    .YPC-Empty {
     background-color: #F9F9F9 !important;
    } 
    
    td.YPC-Column-00 {
     font-weight:bold !important;
    } 
    
    td.YPC-Today {
     background-color: #2578CF !important;
     color: #FFFFFF !important;
     font-weight:bold !important;
    } 



