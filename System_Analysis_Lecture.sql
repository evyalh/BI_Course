--Create Dim Categories

CREATE TABLE public.Dim_Categories (
    ID SERIAL PRIMARY KEY, -- Auto-incrementing ID
    Category_ID INTEGER, -- Foreign key to another category table (optional)
    Category_Name VARCHAR(255), -- String type, length defined as 255
    Category_Description TEXT, -- String type for longer descriptions
    DWH_Created_Date TIMESTAMP, -- Timestamp for when the record is created
    DWH_Updated_Date TIMESTAMP -- Timestamp for when the record is last updated
);


-- Insert data from category into the Dim_Categories
INSERT INTO public.Dim_Categories (Category_ID, Category_Name, Category_Description, DWH_Created_Date, DWH_Updated_Date)
SELECT 
    c.categoryid,                                 -- Category_ID
    c.categoryname,                               -- Category_Name
    c.description,                                -- Category_Description
    NOW() AS DWH_Created_Date,                   -- Current timestamp
    NOW() AS DWH_Updated_Date                    -- Current timestamp
FROM 
    public.category c   
