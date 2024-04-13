/*Cleaning Data in SQL Queries*/

Select *
From PortfolioProj2..HousingData

------------------------------------------------------------
-- Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProj2..HousingData

Update HousingData
SET SaleDate = CONVERT(Date, SaleDate)

/*Other way*/
ALTER TABLE HousingData Add SaleDateConverted Date

Update HousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)
/*Check to see if changes are applied. Use SELECT + FROM statement*/


------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProj2.dbo.HousingData
--Where PropertyAddress is null
Order By ParcelID

/*Drag select for ease of copy pasting. Dragging also works for copy paste*/
/*After executing the update script below. This script no longer returns null values*/
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProj2.dbo.HousingData a
JOIN PortfolioProj2.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProj2.dbo.HousingData a
JOIN PortfolioProj2.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

/*
ISNULL([columnreplacee that is NULL], [columnreplacement])
or
ISNULL([columnreplacee that is NULL], [string])

*/

------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)
--Delimiter - is something (may it be a comma or etc.) that seperates two cells

Select PropertyAddress
From PortfolioProj2.dbo.HousingData

/*CHARACTER INDEX - searches for specific value
CHARINDEX([specific value], [the column you want to search it from])
SUBSTRING() accepts 3 arguments
*/
Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1) as Address--, CHARINDEX(',', PropertyAddress) 
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProj2.dbo.HousingData

ALTER Table HousingData
Add PropertySplitAddress nvarchar(255);

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE HousingData
Add PropertySplitCity nvarchar(255);

Update HousingData
SET PropertySplitCity =  SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProj2.dbo.HousingData



Select OwnerAddress
From PortfolioProj2.dbo.HousingData


/*
REPLACE([columnName], [replacee], [replacement])
PARSENAME([columnName], [index]). Note: PARSENAME works backwards
*/
Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProj2.dbo.HousingData

ALTER TABLE HousingData
Add OwnerSplitAddress nvarchar(255);

Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE HousingData
Add OwnerSplitCity nvarchar(255);

Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE HousingData
Add OwnerSplitState nvarchar(255);

Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProj2.dbo.HousingData

-----------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

ALTER Table HousingData /*Not in the video*/
Alter Column SoldAsVacant nvarchar(255) /*Not in the video*/

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProj2.dbo.HousingData
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE
	When SoldAsVacant = '1' THEN 'Yes'
	When SoldAsVacant = '0' THEN 'No'
	Else SoldAsVacant
END
From PortfolioProj2.dbo.HousingData

Update HousingData
SET SoldAsVacant = 
CASE
	When SoldAsVacant = '1' THEN 'Yes'
	When SoldAsVacant = '0' THEN 'No'
	Else SoldAsVacant
END

/*Check if updated*/


------------------------------------------------------------------
/*Remove Duplicates*/

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortfolioProj2.dbo.HousingData
--order by ParcelID
)
Select *--DELETE--Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress--order by PropertyAddress

/*if you want to have a do over with this project. I suggest to
re-import the table*/

--------------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProj2.dbo.HousingData

ALTER Table PortfolioProj2.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table PortfolioProj2.dbo.HousingData
DROP COLUMN SaleDate

