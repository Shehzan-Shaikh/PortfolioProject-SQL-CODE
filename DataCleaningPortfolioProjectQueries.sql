/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject..NashvilledataCleaning

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilledataCleaning

UPDATE NashvilledataCleaning
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilledataCleaning
ADD SaleDateConverted Date

UPDATE NashvilledataCleaning
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT * 
FROM PortfolioProject..NashvilledataCleaning
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilledataCleaning

SELECT PropertyAddress
FROM PortfolioProject..NashvilledataCleaning
WHERE PropertyAddress is NULL

SELECT *
FROM PortfolioProject..NashvilledataCleaning
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

--ISNULL works like 'if a.property is null than put b.property'
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM PortfolioProject..NashvilledataCleaning a
JOIN PortfolioProject..NashvilledataCleaning b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--In update statement we have to use ALIAS not the table name if ALIAS is used

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress) 
FROM PortfolioProject..NashvilledataCleaning a
JOIN PortfolioProject..NashvilledataCleaning b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT PropertyAddress
FROM PortfolioProject..NashvilledataCleaning
WHERE PropertyAddress is NULL
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM PortfolioProject..NashvilledataCleaning

SELECT PropertyAddress 
FROM PortfolioProject..NashvilledataCleaning

--CHARINDEX AND SUBSTRING (my way)
SELECT PropertyAddress,LEFT(PropertyAddress, CHARINDEX(',',PropertyAddress)-1)
--,RIGHT(PropertyAddress,LEN(PropertyAddress) - CHARINDEX(',',PropertyAddress))
FROM PortfolioProject..NashvilledataCleaning


--CHARINDEX AND SUBSTRING (Alex's Way)
SELECT 
SubString(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1) AS PropertySplitAddress
,SubString(PropertyAddress ,  CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS PropertySplitCity
FROM PortfolioProject..NashvilledataCleaning

--Updated New Address In table
ALTER TABLE NashvilledataCleaning
ADD PropertySplitAddress NVARCHAR(255)
UPDATE NashvilledataCleaning
SET PropertySplitAddress = SubString(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress)-1)

--Updated New City in table
ALTER TABLE NashvilledataCleaning
ADD PropertySplitCity NVARCHAR(255)
UPDATE NashvilledataCleaning
SET PropertySplitCity = SubString(PropertyAddress ,  CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitCity,PropertySplitAddress 
FROM PortfolioProject..NashvilledataCleaning

SELECT *
FROM PortfolioProject..NashvilledataCleaning

--PARSENAME does the same work of CharIndex and Substring 
--But there should be dot('.') instead of comma(',')
Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
From PortfolioProject..NashvilledataCleaning

ALTER TABLE NashvilledataCleaning
ADD OwnerSplitAddress NVARCHAR(255)
UPDATE NashvilledataCleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilledataCleaning
ADD OwnerSplitCity NVARCHAR(255)
UPDATE NashvilledataCleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilledataCleaning
ADD OwnerSplitState NVARCHAR(255)
UPDATE NashvilledataCleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT * --OwnerSplitCity,OwnerSplitAddress,OwnerSplitState
FROM PortfolioProject..NashvilledataCleaning

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT * 
FROM PortfolioProject..NashvilledataCleaning

--Find out total number of yes,no,y,n
Select DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM PortfolioProject..NashvilledataCleaning
GROUP BY (SoldAsVacant)
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
      ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilledataCleaning

UPDATE NashvilledataCleaning
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                        WHEN SoldAsVacant = 'N' THEN 'NO'
                        ELSE SoldAsVacant
                   END


SELECT SoldAsVacant
FROm PortfolioProject..NashvilledataCleaning

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *
FROm PortfolioProject..NashvilledataCleaning


SELECT *,
         ROW_NUMBER()OVER(
         PARTITION BY ParcelID,
		              PropertyAddress,
					  SaleDate,
					  SalePrice,
					  LegalReference
					  ORDER BY UniqueID)row_num
FROM PortfolioProject..NashvilledataCleaning
Order BY ParcelID


--We can use condiotional statement directly thats y we are going to use CTE
WITH RowNumCTE AS (
SELECT *,
         ROW_NUMBER()OVER(
         PARTITION BY ParcelID,
		              PropertyAddress,
					  SaleDate,
					  SalePrice,
					  LegalReference
					  ORDER BY UniqueID)row_num
FROM PortfolioProject..NashvilledataCleaning
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--FROM THE ABOVE CODE WE CAN SAY THAT THOSE 104 ARE THE DUPLICATE ROWS

--NOW Deleting THOSE 104 ROWS
WITH RowNumCTE AS (
SELECT *,
         ROW_NUMBER()OVER(
         PARTITION BY ParcelID,
		              PropertyAddress,
					  SaleDate,
					  SalePrice,
					  LegalReference
					  ORDER BY UniqueID)row_num
FROM PortfolioProject..NashvilledataCleaning
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROm PortfolioProject..NashvilledataCleaning

ALTER TABLE NashvilledataCleaning
DROP COLUMN IF EXISTS OwnerAddress,PropertyAddress,TaxDistrict

ALTER TABLE NashvilledataCleaning
DROP COLUMN SaleDate












-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















